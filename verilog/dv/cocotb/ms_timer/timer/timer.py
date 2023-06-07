from cocotb_includes import test_configure
from cocotb_includes import report_test
from cocotb_includes import cocotb
from cocotb.triggers import ClockCycles
import random
import queue

@cocotb.test()
@report_test
async def timer(dut):
    caravelEnv = await test_configure(dut, timeout_cycles=1498357)
    await caravelEnv.release_csb()
    caravelEnv.drive_gpio_in(16, 0)
    await caravelEnv.wait_mgmt_gpio(1)  # wait for gpio configuration to happened
    cocotb.log.info("[TEST] timer test configured")
    timer_max_val = 0x7FF
    old_timer_val = caravelEnv.monitor_gpio(14, 0).integer
    cocotb.log.info("[TEST] Start monitoring timer oneshot count down up")
    while True:
        timer_val = caravelEnv.monitor_gpio(14, 0).integer
        if timer_val != old_timer_val:
            if timer_val < old_timer_val and timer_val != 0:
                cocotb.log.error(f"[TEST] timer went from {old_timer_val} to {timer_val} in oneshot count up mode")
            else:
                cocotb.log.info(f"[TEST] timer went from {old_timer_val} to {timer_val} in oneshot count up mode")
            if timer_val == 0x0:
                cocotb.log.info(f"[TEST] timer reaches 0 at oneshot count up config")
                break
            old_timer_val = timer_val
        await ClockCycles(caravelEnv.clk, 100)
    # wait for random number of clock cycles and check if timer still max value
    await ClockCycles(caravelEnv.clk, random.randint(10000, 40000))
    timer_val = caravelEnv.monitor_gpio(14, 0).integer
    if timer_val != 0x0:
        cocotb.log.error(f"[TEST] timer doesn't stay at 0 at oneshot count up config {timer_val}")
    else: 
        cocotb.log.info("[TEST] timer stays at 0 at oneshot count up config")

    cocotb.log.info("[TEST] Start monitoring timer oneshot count down mode")
    caravelEnv.drive_gpio_in(16, 1)  # start oneshot count down mode
    # wait until timer enabled 
    while True:
        old_timer_val = caravelEnv.monitor_gpio(14, 0).integer
        if old_timer_val != 0:
            break
        await ClockCycles(caravelEnv.clk, 1)
    while True:
        timer_val = caravelEnv.monitor_gpio(14, 0).integer
        if timer_val != old_timer_val:
            if timer_val > old_timer_val and timer_val != timer_max_val:
                cocotb.log.error(f"[TEST] timer went from {old_timer_val} to {timer_val} in oneshot count down mode")
            else:
                cocotb.log.info(f"[TEST] timer went from {old_timer_val} to {timer_val} in oneshot count down mode")
            if timer_val == timer_max_val:
                cocotb.log.info(f"[TEST] timer reaches max value {timer_max_val} at oneshot count down config")
                break
            old_timer_val = timer_val
        await ClockCycles(caravelEnv.clk, 100)
    # wait for random number of clock cycles and check if timer still max value
    await ClockCycles(caravelEnv.clk, random.randint(10000, 40000))
    timer_val = caravelEnv.monitor_gpio(14, 0).integer
    if timer_val != timer_max_val:
        cocotb.log.error(f"[TEST] timer doesn't stays at max value {timer_max_val} at oneshot count down config {timer_val}")

    caravelEnv.drive_gpio_in(16, 0)  # start oneshot count down mode

    cocotb.log.info("[TEST] Start monitoring timer periodic count up")
    last_3_Seq = queue.Queue() # 1 means count up and 0 means count down
    for i in range(3):
        last_3_Seq.put(1)
    old_timer_val = caravelEnv.monitor_gpio(14, 0).integer
    rollover_count = 0
    while True:
        timer_val = caravelEnv.monitor_gpio(14, 0).integer
        if timer_val != old_timer_val:
            if timer_val > old_timer_val:
                last_3_Seq.get()
                last_3_Seq.put(1)
            else: 
                last_3_Seq.get()
                last_3_Seq.put(0)
            seq_list = list(last_3_Seq.queue)
            if (seq_list == [1, 0, 1]):
                cocotb.log.info("[TEST] timer rollover at periodic count up config")
                rollover_count += 1
                if rollover_count == 3:
                    break
            old_timer_val = timer_val
            # check if illegal sequence happened 
            for i in range(len(seq_list) - 1):
                if seq_list[i] == 0 and seq_list[i + 1] == 0:
                    cocotb.log.error("[TEST] value increase 2 times at periodic count up config")
        await ClockCycles(caravelEnv.clk, 100)
    
    caravelEnv.drive_gpio_in(16, 1)  # start oneshot count down mode
    cocotb.log.info("[TEST] Start monitoring timer periodic count down")
    last_3_Seq = queue.Queue() # 1 means count up and 0 means count down
    for i in range(3):
        last_3_Seq.put(0)
    old_timer_val = caravelEnv.monitor_gpio(14, 0).integer
    rollover_count = 0
    while True:
        timer_val = caravelEnv.monitor_gpio(14, 0).integer
        if timer_val != old_timer_val:
            if timer_val < old_timer_val:
                last_3_Seq.get()
                last_3_Seq.put(0)
            else: 
                last_3_Seq.get()
                last_3_Seq.put(1)
            seq_list = list(last_3_Seq.queue)
            if (seq_list == [0, 1, 0]):
                cocotb.log.info("[TEST] timer rollover at periodic count down config")
                rollover_count += 1
                if rollover_count == 3:
                    break
            old_timer_val = timer_val
            # check if illegal sequence happened 
            for i in range(len(seq_list) - 1):
                if seq_list[i] == 1 and seq_list[i + 1] == 1:
                    cocotb.log.error("[TEST] value increase 2 times at periodic count down config")
        await ClockCycles(caravelEnv.clk, 100)


@cocotb.test()
@report_test
async def timer_irq(dut):
    caravelEnv = await test_configure(dut, timeout_cycles=1498357)
    await caravelEnv.release_csb()
    await caravelEnv.wait_mgmt_gpio(1)
    cocotb.log.info("[TEST] one shot mode interrupt detected") 
    await caravelEnv.wait_mgmt_gpio(0)
    cocotb.log.info("[TEST] periodic mode interrupt detected")