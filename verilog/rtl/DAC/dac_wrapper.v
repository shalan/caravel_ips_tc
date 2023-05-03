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
`timescale        1ns/1ps
`ifdef SYN
`define REAL real
`else
`define REAL
`endif

module dac_wrapper #(parameter FUNCTIONAL = 1) ( 
`ifdef USE_POWER_PINS
    input             VDD,
    input             VSS,
    input             DVDD,
    input             DVSS,
`endif
    input             ena,
   `ifndef COCOTB_SIM
    `ifndef PnR
    input `REAL        VH,
    input `REAL        VL,
    `endif // ! PnR
   `else 
    input real         VH,
    input real         VL,
   `endif // ! COCOTB_SIM
    input [7:0]      data,
   `ifndef COCOTB_SIM
    `ifndef PnR
      output `REAL dac_out
    `endif // ! PnR
   `else 
      output real dac_out
   `endif // ! COCOTB_SIM
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
        .out(dac_out),
      `endif
        .b0(data[0]),
        .b1(data[1]),
        .b2(data[2]),
        .b3(data[3]),
        .b4(data[4]),
        .b5(data[5]),
        .b6(data[6]),
        .b7(data[7]),
        .ena(ena)
      );


endmodule