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
/*
  A simple n-bit SAR controller 
*/

`timescale 1ns/1ns

`default_nettype  none
`timescale        1ns/1ps

module sar #(parameter SIZE = 8) ( 
`ifdef USE_POWER_PINS
    input       dvdd,
    input       dvss,
`endif
    input   wire                clk,        // The clock
    input   wire                rst_n,      // Active high reset
    input   wire                soc,        // Start of Conversion
    input   wire                cmp,        // Analog comparator output
    output  wire                hold,       // Hold
    output  wire [SIZE-1:0]     data,       // The output sample
    output  wire                eoc         // End of Conversion
);
	
    // rst synchronizer
    reg [1:0]   rstn_sync;
    wire        rstn = rstn_sync[1];
    
    always @(posedge clk)
        rstn_sync[1:0] <= {rstn_sync[0], rstn};


	reg [SIZE-1:0] result;
	reg [SIZE-1:0] shift;
	
    // FSM to handle the SAR operation
    reg [1:0]   state, nstate;
	localparam  IDLE  = 0, 
	            SAMPLE= 1, 
	            CONV  = 2, 
	            DONE  = 3;

	always @*
        case (state)
            IDLE    :   if(soc) nstate = SAMPLE;
                        else nstate = IDLE;
            SAMPLE  :   nstate = CONV;
            CONV    :   if(shift == 1'b1) nstate = DONE;
                        else nstate = CONV;
            DONE    :   nstate = IDLE;
            default:    nstate = IDLE;
        endcase
	  
	always @(posedge clk or negedge rstn)
        if(!rstn)
            state <= IDLE;
        else
            state <= nstate;

    // Shift Register
    always @(posedge clk)
        if(state == IDLE) 
            shift <= 1'b1 << (SIZE-1);
        else if(state == CONV)
            shift<= shift >> 1; 

    // The SAR
    wire [SIZE-1:0] current = (cmp == 1'b0) ? ~shift : {SIZE{1'b1}} ;
    wire [SIZE-1:0] next = shift >> 1;
    always @(posedge clk)
        if(state == IDLE) 
            result <= 1'b1 << (SIZE-1);
        else if(state == CONV)
            result <= (result | next) & current; 
	   
	assign data = result;
    
    assign eoc = (state==DONE);

    assign hold = (state == CONV);
	
endmodule
