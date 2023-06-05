from cocotb_includes import *
from cocotb.triggers import ClockCycles
from ms_uart.ms_uart import MsUart

@cocotb.test()
@report_test
async def uart_rx(dut):
    caravelEnv = await test_configure(dut, timeout_cycles=79222)
    ms_uart = MsUart(caravelEnv=caravelEnv, prescaler=0)
    await caravelEnv.wait_mgmt_gpio(1)  # wait for gpio configuration to happened
    await ms_uart.uart_send_char("A")
    await ms_uart.uart_send_char("X")
    await caravelEnv.wait_mgmt_gpio(0)  # wait for gpio configuration to happened
    first_char = await ms_uart.get_char()
    if first_char != "A":
        cocotb.log.error(f"[TEST] first char received on uart rx is {first_char} expected A")
    second_char = await ms_uart.get_char()
    if second_char != "X":
        cocotb.log.error(f"[TEST] second char received on uart rx is {second_char} expected X")
    cocotb.log.info(f"[TEST] first char received on uart rx is {first_char} and second char received on uart rx is {second_char}")
