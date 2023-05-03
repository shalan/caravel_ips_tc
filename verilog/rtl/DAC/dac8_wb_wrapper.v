`default_nettype none
`ifdef SYN
`define REAL real
`else
`define REAL
`endif
module dac8_wb_wrapper #(parameter FUNCTIONAL = 1)(
`ifdef USE_POWER_PINS
    input wire      vdd,	
    input wire      vss,	
    input wire      dvdd,
    input wire      dvss,
`endif
   
    `ifndef COCOTB_SIM
     output `REAL     out,
     input `REAL        VRp,
     input `REAL        VRm,
    `else 
     output real     out,
     input real         VRp,
     input real         VRm,
    `endif // COCOTB_SIM

	input [13:0]    bus_adr,
	input [31:0]    bus_dat_w,
	output [31:0]   bus_dat_r,
	input [3:0]     bus_sel,
	input           bus_cyc,
	input           bus_stb,
	output          bus_ack,
	input           bus_we,
	input           sys_clk,
	input           sys_rst
);

    reg [7:0]   data_reg;
    reg         ena_reg;

    wire        valid       = bus_cyc & bus_stb;
    wire        we          = bus_we && valid;
    wire        re          = ~bus_we && valid;
    wire [3:0]  byte_wr_en  = bus_sel & {4{we}} ;

    wire        we_data_reg = we & (bus_adr[7:0] == 8'h00);
    wire        we_ena_reg  = we & (bus_adr[7:0] == 8'h04);
    wire        re_data_reg = re & (bus_adr[7:0] == 8'h00);
    wire        re_ena_reg  = re & (bus_adr[7:0] == 8'h04);
    
    
    //assign bus_ack      =   bus_stb;
    
    reg bus_ack;
    always @(posedge sys_clk or posedge sys_rst)
    if(sys_rst)
        bus_ack <= 1'b0;
    else
        if(bus_cyc & bus_stb & !bus_ack)
            bus_ack <= 1'b1;
        else
            bus_ack <= 1'b0;
    
    assign bus_dat_r    =   re_data_reg ?   data_reg    :
                            re_ena_reg  ?   ena_reg     :
                            32'hDEADBEEF;

    always @(posedge sys_clk)
        if(we_data_reg) data_reg <= bus_dat_w;

    always @(posedge sys_clk or posedge sys_rst)
        if(sys_rst)
            ena_reg <= 1'b0;
        else if(we_ena_reg) 
            ena_reg <= bus_dat_w;


    (* keep *) dac_wrapper #(.FUNCTIONAL(FUNCTIONAL)) DAC (
      `ifdef USE_POWER_PINS
        .VDD(vdd),
        .VSS(vss),
        .DVDD(dvdd),
        .DVSS(dvss),
      `endif
    `ifndef PnR
        .VH(VRp),
        .VL(VRm),
        .dac_out(out),
    `endif
        .data(data_reg),
        .ena(ena_reg)
    );

endmodule