from cocotb_includes import *
from cocotb.triggers import ClockCycles
from ms_uart.ms_uart import MsUart

@cocotb.test()
@report_test
async def uart_tx(dut):
    caravelEnv = await test_configure(dut, timeout_cycles=159457)
    ms_uart = MsUart(caravelEnv=caravelEnv, prescaler=50)
    await caravelEnv.wait_mgmt_gpio(1)  # wait for gpio configuration to happened
    line = await ms_uart.get_line()
    if line != "Hello World!":
        cocotb.log.error(f"[TEST] line received on uart tx is {line} expected Hello World!")
    else:
        cocotb.log.info(f"[TEST] line received on uart tx is {line}")
