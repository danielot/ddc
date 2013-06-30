// IE309 - Projetos de DSP em FPGA 2013
// Autores: Daniel de Oliveira Tavares - RA107455
//          Jaime Junior Luque Quispe  - RA144411
// Data: 27/06/2013

module ddc
#(
  parameter DATAIN_WIDTH     = 16,
  parameter DATAOUT_WIDTH    = DATAIN_WIDTH,
  parameter NCO_PHASE_WIDTH  = 12,
  parameter NCO_PHASE_INC    = 60,
  parameter NCO_WIDTH        = 25,
  parameter NCO_COS_LUT_FILE = "",
  parameter NCO_SIN_LUT_FILE = "",
  parameter NCO_EOTABLE      = 17*240,
  parameter CIC_M            = 2,
  parameter CIC_N            = 5,
  parameter CIC_MAXRATE      = 64,
  parameter RECT2POL_NSTAGES = 20,
  parameter DATAMIXED_WIDTH = DATAIN_WIDTH+NCO_WIDTH
)
(
  input                        clk_i,
  input                        rst_i,
  input                        en_i,
  input  [DATAIN_WIDTH-1:0]    data_i,
  output [DATAOUT_WIDTH-1:0]   data_amplitude_o,
  output [DATAOUT_WIDTH-1:0]   data_phase_o,
  output [DATAOUT_WIDTH-1:0]   idata_o,
  output [DATAOUT_WIDTH-1:0]   qdata_o,
  output [DATAMIXED_WIDTH-1:0] idata_undecim_o,
  output [DATAMIXED_WIDTH-1:0] qdata_undecim_o,
//  input  [NCO_PHASE_WIDTH-1:0] phase_offset_i,
  input                        act_i,
  input                        act_out_i,
  output                       val_o
);

  wire [DATAOUT_WIDTH-1:0]   idata;
  wire [DATAOUT_WIDTH-1:0]   qdata;
  wire [DATAMIXED_WIDTH-1:0] idata_undecim;
  wire [DATAMIXED_WIDTH-1:0] qdata_undecim;
  reg  [RECT2POL_NSTAGES:0]  val_shift_reg;
  wire                       val_cic;
  wire [NCO_PHASE_WIDTH-1:0] acc_phase;
  
  // Phase accumulator
  phctrl_counter
  #(
    .WIDTH(NCO_PHASE_WIDTH),
    .INC(NCO_PHASE_INC),
    .UPTO(NCO_EOTABLE)
  )
  pac
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_i),
    .count_o(acc_phase)
  );
  
  // Delay line for val_o synchronization
  always @(posedge clk_i)
    if (en_i)
      val_shift_reg <= {val_shift_reg[RECT2POL_NSTAGES-1:0], val_cic};

  assign val_o = val_shift_reg[RECT2POL_NSTAGES];

  ddc_subch
  #(
    .DATAIN_WIDTH(DATAIN_WIDTH),
    .DATAOUT_WIDTH(DATAOUT_WIDTH),
    .DATAMIXED_WIDTH(DATAMIXED_WIDTH),
    .NCO_PHASE_WIDTH(NCO_PHASE_WIDTH),
    .NCO_WIDTH(NCO_WIDTH),
    .NCO_LUT_FILE(NCO_COS_LUT_FILE),
    .CIC_M(CIC_M),
    .CIC_N(CIC_N),
    .CIC_MAXRATE(CIC_MAXRATE)
  )
  i_ch
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_i),
    .data_i(data_i),
    .data_undecim_o(idata_undecim),
    .data_o(idata),
    .phase_i(acc_phase),
    .act_i(act_i),
    .act_out_i(act_out_i),
    .val_o(val_cic)
  );

  ddc_subch
  #(
    .DATAIN_WIDTH(DATAIN_WIDTH),
    .DATAOUT_WIDTH(DATAOUT_WIDTH),
    .DATAMIXED_WIDTH(DATAMIXED_WIDTH),
    .NCO_PHASE_WIDTH(NCO_PHASE_WIDTH),
    .NCO_WIDTH(NCO_WIDTH),
    .NCO_LUT_FILE(NCO_SIN_LUT_FILE),
    .CIC_M(CIC_M),
    .CIC_N(CIC_N),
    .CIC_MAXRATE(CIC_MAXRATE)
  )
  q_ch
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_i),
    .data_i(data_i),
    .data_undecim_o(qdata_undecim),
    .data_o(qdata),
    .phase_i(acc_phase),
    .act_i(act_i),
    .act_out_i(act_out_i),
    .val_o()
  );
  
  cordicg
  #(
    .width(DATAOUT_WIDTH)
  )
  rect2pol
  (
    .clk(clk_i),
    .opin(2'b01),
    .xin(idata),
    .yin(qdata),
    .phasein({(DATAOUT_WIDTH+1){1'b0}}),
    .xout(data_amplitude_o),
    .yout(),
    .phaseout(data_phase_o)
  );

  assign idata_o = idata;
  assign qdata_o = qdata;
  assign idata_undecim_o = idata_undecim;
  assign qdata_undecim_o = qdata_undecim;
  
endmodule
