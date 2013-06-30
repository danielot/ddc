`timescale 1ns / 1ps

module ddc_tb;

  parameter CLK_PERIOD       = 10;

  parameter ADC_WIDTH        = 16;
  parameter DATAMIXED_WIDTH  = 32;
  parameter DDCOUT_WIDTH     = 25;
  parameter NCO_WIDTH        = 24;      // could not read 25-bit hex values, then used 24 bits
  parameter NCO_PHASE_WIDTH  = 12;
  parameter NCO_PHASE_INC    = 240;
  parameter NCO_COS_LUT_FILE = "coslut.mem";
  parameter NCO_SIN_LUT_FILE = "sinlut.mem";
  parameter NCO_EOTABLE      = (17-1)*NCO_PHASE_INC;
  parameter CIC_M            = 2;
  parameter CIC_N            = 5;
  parameter CIC_MAXRATE      = 50;
  parameter RECT2POL_NSTAGES = 20;
  
  // testbench signals
  integer datain_file;
  integer dataout_file;

  integer dump;
  integer act_out_cnt = 0;
  integer amplitude_int, phase_int, i_int, q_int, i_undecim_int, q_undecim_int;
  
  // UUT inputs
  reg clk_i;
  reg rst_i;
  reg en_i;
  reg act_i;
  reg act_out_i;
	reg [ADC_WIDTH-1:0] data_i;
//	reg [NCO_WIDTH-1:0] phase_offset_i;

  // UUT outputs
  wire [DDCOUT_WIDTH-1:0]    data_amplitude_o;
  wire [DDCOUT_WIDTH-1:0]    data_phase_o;
  wire [DDCOUT_WIDTH-1:0]    idata_o;
  wire [DDCOUT_WIDTH-1:0]    qdata_o;
  wire [DATAMIXED_WIDTH-1:0] idata_undecim_o;
  wire [DATAMIXED_WIDTH-1:0] qdata_undecim_o;
  wire val_o;

  // unit under test (UUT)
  ddc
  #(
    .DATAIN_WIDTH(ADC_WIDTH),
    .DATAOUT_WIDTH(DDCOUT_WIDTH),
    .DATAMIXED_WIDTH(DATAMIXED_WIDTH),
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
    .data_i(data_i),
    .data_amplitude_o(data_amplitude_o),
    .data_phase_o(data_phase_o),
    .idata_o(idata_o),
    .qdata_o(qdata_o),
    .idata_undecim_o(idata_undecim_o),
    .qdata_undecim_o(qdata_undecim_o),
//    .phase_offset_i(phase_offset_i),
    .act_i(act_i),
    .act_out_i(act_out_i),
    .val_o(val_o)
);

  // clock
  always #(CLK_PERIOD/2) clk_i = !clk_i;

  // decimation activate signal
  always @(posedge clk_i) begin
    if (act_i)
      if (act_out_cnt < CIC_MAXRATE-1) begin
        act_out_i <= 1'b0;
        act_out_cnt <= act_out_cnt + 1;
      end
      else begin
        act_out_i <= 1'b1;
        act_out_cnt <= 0;
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

	  data_i = {ADC_WIDTH{1'd0}};
	  //phase_offset_i = {NCO_PHASE_WIDTH{1'd0}};

    // reset
    rst_i = 1'b1;
    #(100*CLK_PERIOD);
    rst_i = 1'b0;

    @(posedge clk_i);
    act_i = 1'b1;;

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
      @(posedge clk_i);
      dump = $fscanf(datain_file, "%d\n", data_i);
      
//      amplitude_int = {{(32-DDCOUT_WIDTH){data_amplitude_o[DDCOUT_WIDTH-1]}}, data_amplitude_o};
//      phase_int     = {{(32-DDCOUT_WIDTH){data_phase_o[DDCOUT_WIDTH-1]}}, data_phase_o};
      amplitude_int = data_amplitude_o;
      phase_int     = data_phase_o;
      i_int         = {{(32-DDCOUT_WIDTH){idata_o[DDCOUT_WIDTH-1]}}, idata_o};
      q_int         = {{(32-DDCOUT_WIDTH){qdata_o[DDCOUT_WIDTH-1]}}, qdata_o};
      i_undecim_int = {{(32-DDCOUT_WIDTH){idata_undecim_o[DATAMIXED_WIDTH-1]}}, idata_undecim_o};
      q_undecim_int = {{(32-DDCOUT_WIDTH){qdata_undecim_o[DATAMIXED_WIDTH-1]}}, qdata_undecim_o};
      $fdisplay(dataout_file, "%d %d %d %d %d %d", amplitude_int, phase_int, i_int, q_int, i_undecim_int, q_undecim_int);
    end
    
    $fclose(datain_file);
    $fclose(dataout_file);
    
    #(10*CLK_PERIOD);
    
    $finish;
  end

endmodule
