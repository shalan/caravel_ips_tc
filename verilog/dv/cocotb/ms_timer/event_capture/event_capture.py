from cocotb_includes import test_configure
from cocotb_includes import report_test
from cocotb_includes import cocotb
from cocotb_includes import UART
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random

@cocotb.test()
@report_test
async def event_capture(dut):
    caravelEnv = await test_configure(dut, timeout_cycles=1194108)
    uart = UART(caravelEnv=caravelEnv)
    caravelEnv.drive_gpio_in(33, 0)
    await caravelEnv.wait_mgmt_gpio(1)
    cocotb.log.info("[TEST] Finish configure")
    await ClockCycles(caravelEnv.clk, 10)
    cycles_to_cp = generate_even_number()
    cocotb.log.info(f"[TEST] send 2 rising edges between {cycles_to_cp} cycles")
    await send_edge(caravelEnv=caravelEnv, rising=True, clock_cycles=cycles_to_cp/2)
    await send_edge(caravelEnv=caravelEnv, rising=False, clock_cycles=cycles_to_cp/2)
    await send_edge(caravelEnv=caravelEnv, rising=True, clock_cycles=1)
    rec_cycles = await uart.get_int()
    if rec_cycles != cycles_to_cp:
        cocotb.log.error(f"[TEST] recieved cycles is {rec_cycles} expected {cycles_to_cp}between rising")
    else:
        cocotb.log.info(f"[TEST] return expected value {rec_cycles}")
    
    await caravelEnv.wait_mgmt_gpio(0)
    cycles_to_cp = generate_even_number()
    cocotb.log.info(f"[TEST] send 2 falling edges between {cycles_to_cp} cycles")
    await send_edge(caravelEnv=caravelEnv, rising=False, clock_cycles=cycles_to_cp/2)
    await send_edge(caravelEnv=caravelEnv, rising=True, clock_cycles=cycles_to_cp/2)
    await send_edge(caravelEnv=caravelEnv, rising=False, clock_cycles=1)
    rec_cycles = await uart.get_int()
    if rec_cycles != cycles_to_cp:
        cocotb.log.error(f"[TEST] recieved cycles is {rec_cycles} expected {cycles_to_cp}between falling")
    else:
        cocotb.log.info(f"[TEST] return expected value {rec_cycles}")

    await caravelEnv.wait_mgmt_gpio(1)
    cycles_to_cp = generate_even_number()
    cocotb.log.info(f"[TEST] send 2 edges between {cycles_to_cp} cycles")
    await send_edge(caravelEnv=caravelEnv, rising=True, clock_cycles=cycles_to_cp)
    await send_edge(caravelEnv=caravelEnv, rising=False, clock_cycles=1)
    rec_cycles = await uart.get_int()
    if rec_cycles != cycles_to_cp:
        cocotb.log.error(f"[TEST] recieved cycles is {rec_cycles} expected {cycles_to_cp}between edges")
    else:
        cocotb.log.info(f"[TEST] return expected value {rec_cycles}")


async def send_edge(caravelEnv, rising, clock_cycles):
    clock_cycles = int(clock_cycles)
    if rising:
        caravelEnv.drive_gpio_in(33, 1)
        await ClockCycles(caravelEnv.clk, clock_cycles)
    else:
        caravelEnv.drive_gpio_in(33, 0)
        await ClockCycles(caravelEnv.clk, clock_cycles)
    

def generate_even_number():
    number = random.randint(1, 100)
    while number % 2 != 0:
        number = random.randint(1, 100)
    return number