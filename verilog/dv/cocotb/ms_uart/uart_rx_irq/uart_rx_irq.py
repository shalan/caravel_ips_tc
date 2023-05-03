from cocotb_includes import *
from cocotb.triggers import ClockCycles
from ms_uart.ms_uart import MsUart

@cocotb.test()
@repot_test
async def uart_rx_irq(dut):
    caravelEnv = await test_configure(dut, timeout_cycles=179222)
    ms_uart = MsUart(caravelEnv=caravelEnv, prescaler=0)
    await caravelEnv.wait_mgmt_gpio(1)  # wait for gpio configuration to happened
    for i in range(18): # fill the rx fifo with A's 
        await ms_uart.uart_send_char("A")
    await caravelEnv.wait_mgmt_gpio(0)  # wait for gpio configuration to happened
    cocotb.log.info(f"[TEST] fifo RX interrupt has seen by firmware")