import cocotb
from cocotb.triggers import Timer


class MsUart:

    def __init__(self, caravelEnv, prescaler=0) -> None:
        self.caravelEnv = caravelEnv
        clock = caravelEnv.get_clock_obj()
        self.period = clock.period / 1000
        self.bit_time_ns = MsUart.calculate_bit_time(self.period, prescaler)
        cocotb.log.info(f"[UART] configure uart bit_time_ns = {self.bit_time_ns}ns")

    
    @staticmethod
    def calculate_bit_time(clk_period, prescaler):
        """
        Calculates the bit time for a given clock period and prescaler value.
        Args:
            clk_period (float): the clock period in any units.
            prescaler (int): the prescaler value.

        Returns:
            float: the calculated bit time in the same unit as clk_period.
        """
        return clk_period * (prescaler + 1) * 16
    
    async def get_line(self):
        """Read line sent through UART (msg is sent by the software)

        - Line is a bunch of ASCII sybmols ended by linefeed '\\\\n'"""
        line = ""
        while True:
            new_char = await self.get_char()
            cocotb.log.info(f"[UART] new char = {new_char}")
            if new_char == "\n":
                break
            line += new_char
            cocotb.log.debug(f"[UART] part of the line recieved = {line}")
        cocotb.log.info(f"[UART] line recieved = {line}")
        return line

    async def get_char(self):
        """Read character sent through UART (character is sent by the software)

        - Character is a 8 bit ASCII symbol"""
        await self.start_of_tx()
        char = ""
        for i in range(8):
            char = self.caravelEnv.monitor_gpio((34, 34)).binstr + char
            await Timer(self.bit_time_ns, units="ns")
        return chr(int(char, 2))

    async def start_of_tx(self):
        while True:  # wait for the start of the transimission it 1 then 0
            if self.caravelEnv.monitor_gpio((34, 34)).integer == 0:
                break
            await Timer(round(self.bit_time_ns / 100), units="ns")
        await Timer(self.bit_time_ns, units="ns")
    

    async def uart_send_char(self, char):
        """Send character to UART (character is sent to the software)

        - Character is a 8 bit ASCII symbol"""
        char_bits = [int(x) for x in "{:08b}".format(ord(char))]
        cocotb.log.info(f"[TEST] start sending on uart {char}")
        # send start bit
        self.caravelEnv.drive_gpio_in(35, 0)
        extra_time = 0
        if "CPU_TYPE_ARM" in self.caravelEnv.design_macros._asdict():
            extra_time = (
                -479 * self.period
            )  # there is state 1 which takes 11975 ns and this time isn't in ARM only
        cocotb.log.info(f"[TEST] extra_time = {extra_time}ns")

        await Timer(self.bit_time_ns + extra_time, units="ns")
        # send bits
        for i in reversed(range(8)):
            self.caravelEnv.drive_gpio_in(35, char_bits[i])
            await Timer(self.bit_time_ns, units="ns")

        # stop of frame
        self.caravelEnv.drive_gpio_in(35, 1)
        await Timer(self.bit_time_ns, units="ns")
        await Timer(self.bit_time_ns, units="ns")
        # insert 4 bit delay just for debugging
        await Timer(self.bit_time_ns, units="ns")
        await Timer(self.bit_time_ns, units="ns")
        await Timer(self.bit_time_ns, units="ns")
        await Timer(self.bit_time_ns, units="ns")

    async def uart_send_line(self, line):
        """Send line to UART (msg is sent to the software)

        - Line is a bunch of ASCII sybmols ended by linefeed '\\\\n'
        """
        for char in line:
            await self.uart_send_char(char)

        # end of line \n
        await self.uart_send_char("\n")