from cocotb_includes import test_configure
from cocotb_includes import report_test
from cocotb_includes import cocotb
from cocotb.triggers import ClockCycles

@cocotb.test()
@report_test
async def counter(dut):
    caravelEnv = await test_configure(dut, timeout_cycles=479640)
    await caravelEnv.release_csb()
    await caravelEnv.wait_mgmt_gpio(1)  # wait for gpio configuration to happened
    match_val = caravelEnv.monitor_gpio(31, 0).integer
    cocotb.log.info(f"[TEST] match_val is {match_val}")
    for i in range(match_val+1):
        cocotb.log.info(f"[TEST] sending pulse {i}")
        await send_pulse(caravelEnv)
        if i == match_val:  # last pulse 
            # wait for 100 to check if interrupt is seen
            mgmt_gpio_val = caravelEnv.monitor_mgmt_gpio()
            if mgmt_gpio_val == "0":
                cocotb.log.error("[TEST] match flag has been set too fast")
            await ClockCycles(caravelEnv.clk, 30000)
            mgmt_gpio_val = caravelEnv.monitor_mgmt_gpio()
            if mgmt_gpio_val == "0":
                cocotb.log.info("[TEST] match flag succefully set")
            else:
                cocotb.log.error("[TEST] match flag not set")
        elif i == match_val - 1:  # second last pulse
            # wait for 100 to check if interrupt is seen
            await ClockCycles(caravelEnv.clk, 30000)
            mgmt_gpio_val = caravelEnv.monitor_mgmt_gpio()
            if mgmt_gpio_val == "0":
                cocotb.log.error("[TEST] match flag set before sending all required pulses")
            

async def send_pulse(caravelEnv, width=10):
    caravelEnv.drive_gpio_in(33, 1)
    await ClockCycles(caravelEnv.clk, width)
    caravelEnv.drive_gpio_in(33, 0)
    await ClockCycles(caravelEnv.clk, width)
