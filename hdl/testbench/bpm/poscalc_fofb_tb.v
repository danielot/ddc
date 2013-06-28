`timescale 1ns / 1ps

module poscalc_fofb_tb;

  parameter CLK_PERIOD       = 100;

  parameter ADC_WIDTH        = 16;
  parameter POS_WIDTH        = 25;
  parameter NCO_WIDTH        = 25;
  parameter NCO_PHASE_WIDTH  = 12;
  parameter NCO_PHASE_INC    = 240;
  parameter NCO_COS_LUT_FILE = "coslut.mem";
  parameter NCO_SIN_LUT_FILE = "sinlut.mem";
  parameter NCO_EOTABLE      = 17*NCO_PHASE_INC;
  parameter CIC_M            = 2;
  parameter CIC_N            = 2;
  parameter CIC_MAXRATE      = 50;
  parameter RECT2POL_NSTAGES = 20;

  // testbench signals
  integer datain_file;
  integer dataout_file;

  integer dump;
  integer cnt = 0;
  integer x_int, y_int, sum_int;
  
  // UUT inputs
  reg clk_i;
  reg rst_i;
  reg en_i;
  reg act_i;
  reg act_out_i;
	reg [ADC_WIDTH-1:0] data_a_i;
	reg [ADC_WIDTH-1:0] data_b_i;
	reg [ADC_WIDTH-1:0] data_c_i;
	reg [ADC_WIDTH-1:0] data_d_i;
//	reg [NCO_WIDTH-1:0] phase_offset_a_i;
//	reg [NCO_WIDTH-1:0] phase_offset_b_i;
//	reg [NCO_WIDTH-1:0] phase_offset_c_i;
//	reg [NCO_WIDTH-1:0] phase_offset_d_i;

  // UUT outputs
  wire [POS_WIDTH-1:0] data_x_o;
  wire [POS_WIDTH-1:0] data_y_o;
  wire [POS_WIDTH-1:0] data_sum_o;
  wire val_o;

  // unit under test (UUT)
  poscalc_fofb
  #(
    .DATAIN_WIDTH(ADC_WIDTH),
    .DATAOUT_WIDTH(POS_WIDTH),
    .NCO_PHASE_WIDTH(NCO_PHASE_WIDTH),
    .NCO_WIDTH(NCO_WIDTH),
    .NCO_PHASE_INC(NCO_PHASE_INC),
    .NCO_COS_LUT_FILE(NCO_COS_LUT_FILE),
    .NCO_SIN_LUT_FILE(NCO_SIN_LUT_FILE),
    .NCO_EOTABLE(NCO_EOTABLE),
    .CIC_M(CIC_M),
    .CIC_N(CIC_N),
    .CIC_MAXRATE(CIC_MAXRATE),
    .RECT2POL_NSTAGES(RECT2POL_NSTAGES)
  )
  uut
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_i),
    .data_a_i(data_a_i),
    .data_b_i(data_b_i),
    .data_c_i(data_c_i),
    .data_d_i(data_d_i),
    .data_x_o(data_x_o),
    .data_y_o(data_y_o),
    .data_sum_o(data_sum_o),
//    .phase_offset_a_i(phase_offset_a_i),
//    .phase_offset_b_i(phase_offset_b_i),
//    .phase_offset_c_i(phase_offset_c_i),
//    .phase_offset_d_i(phase_offset_d_i),
    .act_i(act_i),
    .act_out_i(act_out_i),
    .val_o(val_o)
);

  // clock
  always #(CLK_PERIOD/2) clk_i = !clk_i;

  // decimation activate signal
  always @(posedge clk_i) begin
    if (act_i)
      if (cnt < CIC_MAXRATE-1) begin
        act_out_i <= 1'b0;
        cnt <= cnt + 1;
      end
      else begin
        act_out_i <= 1'b1;
        cnt <= 0;
      end
    else
      act_out_i <= 1'b0;
  end

  initial begin
    // initialize inputs
    clk_i     = 1'b0;
    en_i      = 1'b1;
    act_i     = 1'd0;
    act_out_i = 1'd0;

	  data_a_i = {ADC_WIDTH{1'd0}};
    data_b_i = {ADC_WIDTH{1'd0}};
    data_c_i = {ADC_WIDTH{1'd0}};
    data_d_i = {ADC_WIDTH{1'd0}};
	  //phase_offset_a_i = {NCO_PHASE_WIDTH{1'd0}};
    //phase_offset_b_i = {NCO_PHASE_WIDTH{1'd0}};
    //phase_offset_c_i = {NCO_PHASE_WIDTH{1'd0}};
    //phase_offset_d_i = {NCO_PHASE_WIDTH{1'd0}};

    // reset
    rst_i = 1'b1;
    #(100*CLK_PERIOD);
    rst_i = 1'b0;

    // verification
    @(posedge clk_i);
    // load data files
    datain_file = $fopen("datain.txt", "r");
    if (!datain_file) begin
      $display("Could not open \"datain.txt\"");
      $finish;
    end

    dataout_file = $fopen("dataout.txt", "w");
    if (!dataout_file) begin
      $display("Could not open \"dataout.txt\"");
      $finish;
    end

    while (!$feof(datain_file)) begin
      dump = $fscanf(datain_file, "%d %d %d %d\n", data_a_i, data_b_i, data_c_i, data_d_i);
      
      x_int = {{(32-POS_WIDTH){data_x_o[POS_WIDTH-1]}}, data_x_o};
      y_int = {{(32-POS_WIDTH){data_y_o[POS_WIDTH-1]}}, data_y_o};
      sum_int = {{(32-POS_WIDTH){data_sum_o[POS_WIDTH-1]}}, data_sum_o};
      $fdisplay(dataout_file, "%d %d %d", x_int, y_int, sum_int);
      
      act_i = #(CLK_PERIOD/100) 1'b1;
      @(posedge clk_i);
      act_i = #(CLK_PERIOD/100) 1'b0;;
      @(posedge clk_i);
    end
    
    $fclose(datain_file);
    $fclose(dataout_file);
    
    #(10*CLK_PERIOD);
    
    $finish;
  end

endmodule
