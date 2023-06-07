// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * caravel_ips
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

 
 module caravel_ips #(
     parameter   BITS = 32,
                 FUNCTIONAL = 1
 )( 
`ifdef USE_POWER_PINS
    inout VPWR,	// User area 1 3.3V supply
    inout VGND,	// User area 2 3.3V supply
`endif

    // Wishbone Slave ports (WB MI A)
    input           wb_clk_i,
    input           wb_rst_i,
    input           wbs_stb_i,
    input           wbs_cyc_i,
    input           wbs_we_i,
    input [3:0]     wbs_sel_i,
    input [31:0]    wbs_dat_i,
    input [31:0]    wbs_adr_i,
    output          wbs_ack_o,
    output [31:0]   wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0]  la_data_in,
    output [127:0]  la_data_out,
    input  [127:0]  la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   clock2,

    // User maskable interrupt signals
    output [2:0] irq
);
    wire [31:0] wbs_dat_tmr_o, 
                wbs_dat_uart_o, 
                wbs_dat_psram_o;

    wire        wbs_stb_tmr_i, 
                wbs_stb_uart_i, 
                wbs_stb_psram_i;
    
    wire        wbs_ack_tmr_o, 
                wbs_ack_uart_o, 
                wbs_ack_psram_o;

    wire        psram_sck;
    wire        psram_ce_n;
    wire [3:0]  psram_din;
    wire [3:0]  psram_dout;
    wire [3:0]  psram_douten;  
    wire        ctr_in;    
    wire        pwm_out;
    wire        uart_tx;
    wire        uart_rx;

    assign      wbs_stb_tmr_i   =   wbs_stb_i & (wbs_adr_i[19:16] == 4'b0000); // 0x30000000
    assign      wbs_stb_uart_i  =   wbs_stb_i & (wbs_adr_i[19:16] == 4'b0010); // 0x30020000
    assign      wbs_stb_psram_i =   wbs_stb_i & (wbs_adr_i[19:16] == 4'b0100); // 0x30040000
    
    assign      wbs_ack_o       =   wbs_stb_tmr_i   ? wbs_ack_tmr_o     :
                                    wbs_stb_uart_i  ? wbs_ack_uart_o    :
                                    wbs_stb_psram_i ? wbs_ack_psram_o   :
                                    1'b1;
    
    assign      wbs_dat_o       =   wbs_stb_tmr_i   ?   wbs_dat_tmr_o   :
                                    wbs_stb_uart_i  ?   wbs_dat_uart_o  :
                                    wbs_stb_psram_i ?   wbs_dat_psram_o :
                                    32'hDEADBEEF;

    ms_psram_ctrl_wb psram (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(wbs_dat_psram_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i),
        .stb_i(wbs_stb_psram_i),
        .ack_o(wbs_ack_psram_o),
        .we_i(wbs_we_i),

        .sck(psram_sck),
        .ce_n(psram_ce_n),
        .din(psram_din),
        .dout(psram_dout),
        .douten(psram_douten)     
    );

    ms_tmr32_wb timer (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(wbs_dat_tmr_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i),
        .stb_i(wbs_stb_tmr_i),
        .ack_o(wbs_ack_tmr_o),
        .we_i(wbs_we_i),

        .ctr_in(ctr_in),
        .pwm_out(pwm_out),
        
        .irq(irq[0])
    );

    ms_uart_wb uart (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(wbs_dat_uart_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i),
        .stb_i(wbs_stb_uart_i),
        .ack_o(wbs_ack_uart_o),
        .we_i(wbs_we_i),

        .RX(uart_rx),
        .TX(uart_tx),

        .irq(irq[1])
    );

    // UART
    assign uart_rx          = io_in[35];            // I/O 35
    assign io_oeb[35]       = 1'b1;                 // Input
    assign io_out[34]       = uart_tx;              // I/O 34
    assign io_oeb[34]       = 1'b0;                 // Output

    // Timer
    assign ctr_in           = io_in[33];            // I/O 33
    assign io_oeb[33]       = 1'b1;                 // Input
    assign io_out[32]       = pwm_out;              // I/O 32
    assign io_oeb[32]       = 1'b0;                 // Output

    // PSRAM CTRL
    // PSRAM 
    assign io_out[31]       = psram_ce_n;           // I/O 31
    assign io_oeb[31]       = 1'b0;                 // Output
    assign io_out[30]       = psram_sck;            // I/O 31
    assign io_oeb[30]       = 1'b0;                 // Output
    assign io_out[26]       = psram_dout[0];        // I/Os 26-29 - Bidirectional
    assign io_oeb[26]       = ~psram_douten[0];
    assign psram_din[0]     = io_in[26];
    assign io_out[27]       = psram_dout[1];
    assign io_oeb[27]       = ~psram_douten[1];
    assign psram_din[1]     = io_in[27];
    assign io_out[28]       = psram_dout[2];
    assign io_oeb[28]       = ~psram_douten[2];
    assign psram_din[2]     = io_in[28];
    assign io_out[29]       = psram_dout[3];
    assign io_oeb[29]       = ~psram_douten[3];
    assign psram_din[3]     = io_in[29];

endmodule	// caravel_ips

`default_nettype wire