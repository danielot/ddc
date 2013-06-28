// IE309 - Projetos de DSP em FPGA 2013
// Autores: Daniel de Oliveira Tavares - RA107455
//          Jaime Junior Luque Quispe  - RA144411
// Data: 27/06/2013

// Notes:
//    Reset must be asserted and kept high for XX clock cycles
module poscalc_fofb
#(
  parameter DATAIN_WIDTH     = 16,
  parameter DATAOUT_WIDTH    = DATAIN_WIDTH,
  parameter NCO_PHASE_WIDTH  = 12,
  parameter NCO_WIDTH        = 24,
  parameter NCO_PHASE_INC    = 1,
  parameter NCO_COS_LUT_FILE = "coslut.mem",
  parameter NCO_SIN_LUT_FILE = "sinlut.mem",
  parameter NCO_EOTABLE      = 17,
  parameter CIC_M            = 2,
  parameter CIC_N            = 5,
  parameter CIC_MAXRATE      = 64,
  parameter RECT2POL_NSTAGES = 20
)
(
  input                        clk_i,
  input                        rst_i,
  input                        en_i,
  input  [DATAIN_WIDTH-1:0]    data_a_i,
  input  [DATAIN_WIDTH-1:0]    data_b_i,
  input  [DATAIN_WIDTH-1:0]    data_c_i,
  input  [DATAIN_WIDTH-1:0]    data_d_i,
  output [DATAOUT_WIDTH-1:0]   data_x_o,
  output [DATAOUT_WIDTH-1:0]   data_y_o,
  output [DATAOUT_WIDTH-1:0]   data_sum_o,
//  input  [NCO_PHASE_WIDTH-1:0] phase_offset_a_i,
//  input  [NCO_PHASE_WIDTH-1:0] phase_offset_b_i,
//  input  [NCO_PHASE_WIDTH-1:0] phase_offset_c_i,
//  input  [NCO_PHASE_WIDTH-1:0] phase_offset_d_i,
  input                        act_i,
  input                        act_out_i,
  output                       val_o
);

  ddc
  #(
    .DATAIN_WIDTH(DATAIN_WIDTH),
    .DATAOUT_WIDTH(DATAOUT_WIDTH),
    .NCO_PHASE_WIDTH(NCO_PHASE_WIDTH),
    .NCO_PHASE_INC(NCO_PHASE_INC),
    .NCO_WIDTH(NCO_WIDTH),
    .NCO_COS_LUT_FILE(NCO_COS_LUT_FILE),
    .NCO_SIN_LUT_FILE(NCO_SIN_LUT_FILE),
    .NCO_EOTABLE(NCO_EOTABLE),
    .CIC_M(CIC_M),
    .CIC_N(CIC_N),
    .CIC_MAXRATE(CIC_MAXRATE),
    .RECT2POL_NSTAGES(RECT2POL_NSTAGES)
  )
  ddc_a
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_i),
    .data_i(data_a_i),
    .data_amplitude_o(data_x_o),
    .data_phase_o(),
//    .phase_offset_i(phase_offset_a_i),
    .act_i(act_i),
    .act_out_i(act_out_i),
    .val_o(val_o)
  );

  ddc
  #(
    .DATAIN_WIDTH(DATAIN_WIDTH),
    .DATAOUT_WIDTH(DATAOUT_WIDTH),
    .NCO_PHASE_WIDTH(NCO_PHASE_WIDTH),
    .NCO_PHASE_INC(NCO_PHASE_INC),
    .NCO_WIDTH(NCO_WIDTH),
    .NCO_COS_LUT_FILE(NCO_COS_LUT_FILE),
    .NCO_SIN_LUT_FILE(NCO_SIN_LUT_FILE),
    .NCO_EOTABLE(NCO_EOTABLE),
    .CIC_M(CIC_M),
    .CIC_N(CIC_N),
    .CIC_MAXRATE(CIC_MAXRATE),
    .RECT2POL_NSTAGES(RECT2POL_NSTAGES)
  )
  ddc_b
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_i),
    .data_i(data_b_i),
    .data_amplitude_o(),
    .data_phase_o(),
//    .phase_offset_i(phase_offset_b_i),
    .act_i(act_i),
    .act_out_i(act_out_i),
    .val_o(val_o)
  );

  ddc
  #(
    .DATAIN_WIDTH(DATAIN_WIDTH),
    .DATAOUT_WIDTH(DATAOUT_WIDTH),
    .NCO_PHASE_WIDTH(NCO_PHASE_WIDTH),
    .NCO_PHASE_INC(NCO_PHASE_INC),
    .NCO_WIDTH(NCO_WIDTH),
    .NCO_COS_LUT_FILE(NCO_COS_LUT_FILE),
    .NCO_SIN_LUT_FILE(NCO_SIN_LUT_FILE),
    .NCO_EOTABLE(NCO_EOTABLE),
    .CIC_M(CIC_M),
    .CIC_N(CIC_N),
    .CIC_MAXRATE(CIC_MAXRATE),
    .RECT2POL_NSTAGES(RECT2POL_NSTAGES)
  )
  ddc_c
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_i),
    .data_i(data_c_i),
    .data_amplitude_o(),
    .data_phase_o(),
//    .phase_offset_i(phase_offset_c_i),
    .act_i(act_i),
    .act_out_i(act_out_i),
    .val_o(val_o)
  );

  ddc
  #(
    .DATAIN_WIDTH(DATAIN_WIDTH),
    .DATAOUT_WIDTH(DATAOUT_WIDTH),
    .NCO_PHASE_WIDTH(NCO_PHASE_WIDTH),
    .NCO_PHASE_INC(NCO_PHASE_INC),
    .NCO_WIDTH(NCO_WIDTH),
    .NCO_COS_LUT_FILE(NCO_COS_LUT_FILE),
    .NCO_SIN_LUT_FILE(NCO_SIN_LUT_FILE),
    .NCO_EOTABLE(NCO_EOTABLE),
    .CIC_M(CIC_M),
    .CIC_N(CIC_N),
    .CIC_MAXRATE(CIC_MAXRATE),
    .RECT2POL_NSTAGES(RECT2POL_NSTAGES)
  )
  ddc_d
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_i),
    .data_i(data_d_i),
    .data_amplitude_o(),
    .data_phase_o(),
//    .phase_offset_i(phase_offset_d_i),
    .act_i(act_i),
    .act_out_i(act_out_i),
    .val_o(val_o)
  );

endmodule