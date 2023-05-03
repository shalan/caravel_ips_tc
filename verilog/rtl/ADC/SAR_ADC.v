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


`timescale 1ns/1ns

`default_nettype  none

module SAR_ADC #(parameter FUNCTIONAL = 1) ( 
`ifdef USE_POWER_PINS
    input             VDD,
    input             VSS,
    input             DVDD,
    input             DVSS,
`endif
`ifndef PnR
    `ifndef COCOTB_SIM
    input         A, //real
    input         VH, //real
    input         VL, //real
    `else
    input   real   A, //real
    input   real   VH, //real
    input   real   VL, //real
    `endif  //! COCOTB_SIM
`endif
    input wire        clk,
    input wire        rst_n,
    input wire        soc,
    input wire        ena,
    output wire       eoc,
    output wire [7:0] data
);

    `ifndef COCOTB_SIM
    wire  dac_out; //real
    wire  A_hold; //real
    `else
    real  dac_out; //real
    real  A_hold; //real
    `endif  //! COCOTB_SIM
    wire      cmp;
    wire      hold;

    sar SAR ( 
      `ifdef USE_POWER_PINS
        .dvdd(DVDD),
        .dvss(DVSS),
      `endif
        .clk(clk),
        .rst_n(rst_n),
        .soc(soc),
        .eoc(eoc),
        .hold(hold),
        .data(data),
        .cmp(cmp)
      );
    
    dac_3v_8bit #(.FUNCTIONAL(FUNCTIONAL)) DAC (
    `ifdef USE_POWER_PINS
        .vdd(VDD),
        .vss(VSS),
        .dvdd(DVDD),
        .dvss(DVSS),
    `endif
    `ifndef PnR
        .Vlow(VL),
        .Vhigh(VH),
    `endif
        .out(dac_out),
        .b0(data[0]),
        .b1(data[1]),
        .b2(data[2]),
        .b3(data[3]),
        .b4(data[4]),
        .b5(data[5]),
        .b6(data[6]),
        .b7(data[7]),
        .ena(ena),
        .out(dac_out)
      );

      comparator_top #(.FUNCTIONAL(FUNCTIONAL)) CMP (
    `ifdef USE_POWER_PINS
        .VDD(VDD),
        .VSS(VSS),
        .DVDD(DVDD),
        .DVSS(DVSS),
    `endif
        .VINM(dac_out),
        .VINP(A_hold),
        .VOUT(cmp)
      );

    sample_and_hold #(.FUNCTIONAL(FUNCTIONAL)) SnH (
    `ifdef USE_POWER_PINS
        .vdd(VDD),
        .vss(VSS),
        .dvdd(DVDD),
        .dvss(DVSS),
    `endif
    `ifndef PnR
        .in(A),
    `endif
        .ena(ena),
        .hold(hold),
        .out(A_hold)
    );


endmodule