from cocotb_includes import test_configure
from cocotb_includes import report_test
from cocotb_includes import cocotb
from cocotb_includes import UART
from ms_psram.psram import Psram


@cocotb.test()
@report_test
async def wr_rd_psram(dut):
    caravelEnv = await test_configure(dut, timeout_cycles=11232966)
    uart = UART(caravelEnv=caravelEnv)
    # connect and start the psram 
    await caravelEnv.wait_mgmt_gpio(1)
    await cocotb.start(connect_psram(caravelEnv).start())
    status = await uart.get_line()
    if status != "P1":
        read_data = await uart.get_int()
        expected_data = await uart.get_int()
        cocotb.log.error(f"[TEST] phase 1 failed read {hex(read_data)} expected {hex(expected_data)}")
    else: 
        read_data = await uart.get_int()
        cocotb.log.info(f"[TEST] pass phase 1 read date {hex(read_data)}")
    return

    status = await uart.get_line()
    if status != "P2":
        read_data = await uart.get_int()
        expected_data = await uart.get_int()
        cocotb.log.error(f"[TEST] phase 2 failed read {hex(read_data)} expected {hex(expected_data)}")
    else: 
        read_data = await uart.get_int()
        cocotb.log.info(f"[TEST] pass phase 2 read date {hex(read_data)}")


    status = await uart.get_line()
    if status != "P3":
        read_data = await uart.get_int()
        expected_data = await uart.get_int()
        cocotb.log.error(f"[TEST] phase 3 failed read {hex(read_data)} expected {hex(expected_data)}")
    else: 
        read_data = await uart.get_int()
        cocotb.log.info(f"[TEST] pass phase 3 read date {hex(read_data)}")


def connect_psram(caravelEnv):
    mosi = [caravelEnv.dut.gpio36_monitor, caravelEnv.dut.gpio37_monitor, caravelEnv.dut.gpio28_monitor, caravelEnv.dut.gpio29_monitor]
    miso = [caravelEnv.dut.gpio36, caravelEnv.dut.gpio37, caravelEnv.dut.gpio28, caravelEnv.dut.gpio29]
    sck = caravelEnv.dut.gpio30_monitor
    cs = caravelEnv.dut.gpio31_monitor
    psram = Psram(miso, mosi, sck, cs, drive_miso, release_miso, caravelEnv)
    # drive miso with 1
    caravelEnv.drive_gpio_in((37, 36), 0)
    caravelEnv.drive_gpio_in((29, 28), 0)
    return psram


def drive_miso(caravelEnv):
    caravelEnv.drive_gpio_in((37, 36), 0)
    caravelEnv.drive_gpio_in((29, 28), 0)


def release_miso(caravelEnv):
    caravelEnv.release_gpio((37, 36))
    caravelEnv.release_gpio((29, 28))