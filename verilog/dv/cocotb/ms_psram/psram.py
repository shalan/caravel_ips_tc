import cocotb 
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, Edge, First, NextTimeStep


class Psram(object):

    def __init__(self, miso, mosi, sck, cs, drive_miso, release_miso, caravelEnv):
        """
            a vip of the ram with it's quad spi slave interface
        """
        self.miso = miso
        self.mosi = mosi
        self.sck = sck
        self.cs = cs
        self.memory = {}
        self.caravelEnv = caravelEnv
        self.drive_miso = drive_miso
        self.release_miso = release_miso
        self.memory_length = 0x7FFFF

    async def wait_assert_csb(self):
        await FallingEdge(self.cs)
        cocotb.log.info("[PSRAM] CS asserted")

    async def wait_deassert_csb(self):
        await RisingEdge(self.cs)
        cocotb.log.info("[PSRAM] CS deasserted")

    async def send(self, data):
        cocotb.log.info(f"[PSRAM] start sending {hex(data)} over miso")
        data_width = 8
        bits = []
        for i in range(data_width):
            bit = data & 0xf
            data >>= 4
            bits.append(bit)
        for bit in reversed(bits):
            await FallingEdge(self.sck)
            for i in range(4):
                pin =  (bit & (0x1 << i)) >> i
                self.miso[i].value = pin 
                cocotb.log.info(f"[PSRAM] write pin {i} drive miso with value {pin}")
            cocotb.log.info(f"[PSRAM] write bit drive miso with value {bit}")

    async def recv(self, command=False, addr = False, data=False):
        if command or data:
            data_width = 8
        elif addr:  # address or data
            data_width = 6
        else:
            cocotb.log.error("[PSRAM] unknown phase ")
        data = []
        self.release_miso(self.caravelEnv)
        Risingedge = RisingEdge(self.sck)
        cs = RisingEdge(self.cs)
        for _ in range(data_width):
            await First(Risingedge, cs)
            if self.cs.value.integer == 1:
                break
            if command:
                val = self.mosi[0].value
                cocotb.log.info(f"[PSRAM] read bit {_} = {val}")
            else:
                val = ""
                for mosi in self.mosi:
                    val = mosi.value.binstr+val
                cocotb.log.info(f"[PSRAM] read bit {_} = {hex(int(val, 2))}")
            data.append(val)
        received = int("".join(str(bit) for bit in data), 2)
        cocotb.log.info(f"[PSRAM] received {hex(received)} over mosi")
        return received

    def read(self, address):
        if address >= self.memory_length:
            raise ValueError("Address out of range")
        cocotb.log.info(f"[PSRAM] read {hex(self.memory[address])} from address {hex(address)}")
        if address in self.memory:
            return self.memory[address]
        else:
            return 0

    def write(self, address, data):
        if address >= self.memory_length:
            raise ValueError("Address out of range")
        cocotb.log.info(f"[PSRAM] write {hex(data)} to address {hex(address)}")
        self.memory[address] = data

    async def start(self):
        cocotb.log.info("[PSRAM] Starting")   
        while True:
            await self.wait_assert_csb()
            # need to kill the operation waiting if csb deasserted
            op_fork = await cocotb.start(self.op_run())
            # Wait for csb_deasserted to finish.
            await self.wait_deassert_csb()
            await NextTimeStep()
            # kill op
            op_fork.cancel()

    async def op_run(self):
        cocotb.log.info("[PSRAM] Start runnning operation")
        command = await self.recv(command=True)

        if command == 0xeb:  # Read command
            address = await self.recv(addr=True)
            data = self.read(address)
            self.drive_miso(self.caravelEnv)
            await ClockCycles(self.sck, 8)  # wait for 8 cycles before sending data 
            await self.send(data)

        elif command == 0x38:  # Write command
            address = await self.recv(addr=True)
            data = await self.recv(data=True)
            self.write(address, data)

        else:
            raise ValueError(f"Unknown command {hex(command)}")
