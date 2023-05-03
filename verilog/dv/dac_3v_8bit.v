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

/*--------------------------------------------------------------
 Verilog behavioral model of 8-bit digtal-to-analog converter 
                                                              
                                                              
 The analog signals are on a 3.3V domain (vdd, vss).          
 The data bits "b0" to "b7" are on a 1.8V domain (dvdd, dvss)
 The digital "ena" (enable) signal is on the 1.8V domain.	
                                                              
 "ena" is active high (1 = enabled)                           
--------------------------------------------------------------*/

`default_nettype none
`timescale 1 ns / 1 ps
`ifdef SYN
`define REAL real
`else
`define REAL 
`endif

module dac_3v_8bit #(parameter FUNCTIONAL = 1)(
`ifdef USE_POWER_PINS
   input       vdd,
   input       vss,
   input       dvdd,
   input       dvss,
`endif
   `ifndef COCOTB_SIM
    input `REAL Vlow,
    input `REAL Vhigh,
   `else 
    input real  Vlow,
    input real  Vhigh,
   `endif // COCOTB_SIM
   input       ena,

   input       b0,
   input       b1,
   input       b2,
   input       b3,
   input       b4,
   input       b5,
   input       b6,
   input       b7,

   `ifndef COCOTB_SIM
      output `REAL out
   `else 
      output real out
   `endif 
);


// generate
   `ifdef FUNCTIONAL
      `ifndef COCOTB_SIM
         reg `REAL     dacvalue;
      `else 
         real     dacvalue;
      `endif 
      assign out = dacvalue;

      initial begin
         dacvalue <= 0;
      end

      always @* begin
         if (ena == 1'b1) begin
            dacvalue = Vlow + {b7, b6, b5, b4, b3, b2, b1, b0} * (Vhigh - Vlow) / 255.0;
         end else begin
            dacvalue = 0.0;
         end
      end
   `endif
// endgenerate

endmodule
`default_nettype wire

