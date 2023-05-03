`default_nettype none

/*
    Wishbone wrapper for an 8-bit SAR ADC
    I/O Registers
    CTRL        RW  2-bit   {ena, soc}  0x00
    CLK_DIV     RW  8-bit               0x04
    DATA        RO  8-bit               0x08
    EOC         RO  1-bit               0x0C

    The ADC clock frequency = sys_clk freq / 2*(CLK_DIV + 1)
    AT reset the ADC frequency = sys_clk / 2
*/
`ifdef SYN
`define REAL real
`else
`define REAL
`endif
module adc8_wb_wrapper #(parameter FUNCTIONAL = 1)(
`ifdef USE_POWER_PINS
    input               vdd,
    input               vss,
    input               dvdd,
    input               dvss,
`endif


   `ifndef COCOTB_SIM
    input `REAL          A,
    input `REAL          VRp,
    input `REAL          VRm,
   `else 
    input real          A,
    input real          VRp,
    input real          VRm,
   `endif // COCOTB_SIM
    input [13:0]        bus_adr,
	input [31:0]        bus_dat_w,
	output [31:0]       bus_dat_r,
	input [3:0]         bus_sel,
	input               bus_cyc,
	input               bus_stb,
	output              bus_ack,
	input               bus_we,
	input               sys_clk,
	input               sys_rst  
);

    wire                sys_rst_n = ~ sys_rst;

    wire                eoc;
    reg                 eoc_reg;
    wire [7:0]          data;
    reg [7:0]           data_reg;

    // Control Register @ 0
    reg [1:0]           adc_ctrl_reg;
    //wire                soc = adc_ctrl_reg[0];
    reg                 soc;
    wire                ena = adc_ctrl_reg[1];

    // ADC clock divider @ 4
    reg [7:0]           adc_clk_div;
    reg [7:0]           adc_clk_cntr;
    reg                 adc_clk;

    wire                valid           = bus_cyc & bus_stb;
    wire                we              = bus_we && valid;
    wire                re              = ~bus_we && valid;
    wire [3:0]          byte_wr_en      = bus_sel & {4{we}} ; 
    wire                we_ctrl_reg     = we & (bus_adr[7:0] == 8'h00);
    wire                we_clk_div_reg  = we & (bus_adr[7:0] == 8'h04);
    wire                re_ctrl_reg     = re & (bus_adr[7:0] == 8'h00);
    wire                re_clk_div_reg  = re & (bus_adr[7:0] == 8'h04);
    wire                re_data_reg     = re & (bus_adr[7:0] == 8'h08);
    wire                re_eoc_reg      = re & (bus_adr[7:0] == 8'h0C);
    
    
    //assign              bus_ack     = bus_stb;

    reg bus_ack;
    always @(posedge sys_clk or posedge sys_rst)
    if(sys_rst)
        bus_ack <= 1'b0;
    else
        if(bus_cyc & bus_stb & !bus_ack)
            bus_ack <= 1'b1;
        else
            bus_ack <= 1'b0;

    wire    eq = (adc_clk_cntr == adc_clk_div);
    always @(posedge sys_clk or negedge sys_rst_n)
        if(!sys_rst_n)
            adc_clk_cntr <= 8'b0;  
        else if(eq)
            adc_clk_cntr <= 8'b0;    
        else
            adc_clk_cntr <= adc_clk_cntr + 1'b1; 

    always @(posedge sys_clk or negedge sys_rst_n)
        if(!sys_rst_n)
            adc_clk <= 1'b0;
        else if(eq)
            adc_clk <= !adc_clk;

    always @(posedge sys_clk or negedge sys_rst_n)
        if(!sys_rst_n)  
            adc_clk_div <= 8'b0;
        else if(we_clk_div_reg)
            adc_clk_div <= bus_dat_w;
    
    always @(posedge sys_clk or negedge sys_rst_n)
        if(!sys_rst_n)
            adc_ctrl_reg <= 2'b00;
        else if(we_ctrl_reg) 
                adc_ctrl_reg <= bus_dat_w;
        else if(soc)
                adc_ctrl_reg[0] <= 1'b0;

    always @(posedge adc_clk or negedge sys_rst_n)
        if(!sys_rst_n)
            soc <= 1'b0;
        else if(adc_ctrl_reg[0])
            soc <= 1'b1;
        else 
            soc <= 1'b0;

    always @(posedge sys_clk)
        if(eoc & adc_clk)
            data_reg <= data;

    always @(posedge sys_clk or negedge sys_rst_n)
        if(!sys_rst_n)
            eoc_reg <= 1'b0;
        else if(eoc & adc_clk)
            eoc_reg <= eoc;
        else if(soc)
            eoc_reg <=  1'b0;
        
    assign      bus_dat_r   =   (re_data_reg)       ? {24'd0, data_reg}         :
                                (re_eoc_reg)        ? {31'd0, eoc_reg}      :
                                (re_clk_div_reg)    ? {24'd0, adc_clk_div}  :
                                (re_ctrl_reg)       ? {30'd0, adc_ctrl_reg} :
                                32'hDEADBEEF;


    (* keep *) SAR_ADC #(.FUNCTIONAL(FUNCTIONAL)) SAR ( 
`ifdef USE_POWER_PINS
        .VDD(vdd),
        .VSS(vss),
        .DVDD(dvdd),
        .DVSS(dvss),
`endif
`ifndef PnR
    .A(A),
    .VH(VRp),
    .VL(VRm),
`endif
        .clk(adc_clk),
        .rst_n(sys_rst_n),
        .soc(soc),
        .ena(ena),
        .eoc(eoc),
        .data(data)
    );

endmodule