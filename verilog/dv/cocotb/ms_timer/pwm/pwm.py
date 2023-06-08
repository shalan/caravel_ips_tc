from cocotb_includes import test_configure
from cocotb_includes import report_test
from cocotb_includes import cocotb
from cocotb_includes import UART
from cocotb.triggers import RisingEdge, FallingEdge
import random

@cocotb.test()
@report_test
async def pwm(dut):
    caravelEnv = await test_configure(dut, timeout_cycles=94108)
    uart = UART(caravelEnv=caravelEnv)
    caravelEnv.drive_gpio_in((0, 0), 0)
    caravelEnv.drive_gpio_in((5, 5), 1)
    await caravelEnv.wait_mgmt_gpio(1)
    cocotb.log.info("[TEST] Finish configure")
    # send needed pulse width through uart
    # send even number because odd nubmer would give the same values 
    cycles_num = generate_even_number()
    cocotb.log.info(f"[TEST] send {cycles_num} cycles through uart")
    clock_period = caravelEnv.get_clock_period()
    expected_pulse_width = cycles_num * clock_period
    await uart.uart_send_char(chr(cycles_num))
    # check the pulses generated
    await caravelEnv.wait_mgmt_gpio(0)
    cocotb.log.info("[TEST] finish sending through uart")
    pwm_out = caravelEnv.dut.gpio32_monitor
    await FallingEdge(pwm_out)
    await RisingEdge(pwm_out)
    pulse_start = cocotb.utils.get_sim_time()
    await FallingEdge(pwm_out)
    pulse_end = cocotb.utils.get_sim_time()
    pulse_width = (pulse_end - pulse_start) / 1000
    if pulse_width != expected_pulse_width:
        cocotb.log.error(f"[TEST] pulse width is {pulse_width}ns expected {expected_pulse_width}ns")
    else:
        cocotb.log.info(f"[TEST] pulse width is {pulse_width}ns")

def generate_even_number():
    number = random.randint(1, 100)
    while number % 2 != 0:
        number = random.randint(1, 100)
    return number