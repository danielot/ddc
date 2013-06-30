module ddc_top
#(
  parameter DATAIN_WIDTH     = 16,
  parameter DATAMIXED_WIDTH  = 32,
  parameter DATAOUT_WIDTH    = 25,
  parameter NCO_WIDTH        = 24,
  parameter NCO_PHASE_WIDTH  = 12,
  parameter NCO_PHASE_INC    = 240,
  parameter NCO_COS_LUT_FILE = "coslut.mem",
  parameter NCO_SIN_LUT_FILE = "sinlut.mem",
  parameter NCO_EOTABLE      = (17-1)*NCO_PHASE_INC,
  parameter CIC_M            = 2,
  parameter CIC_N            = 5,
  parameter CIC_MAXRATE      = 5,
  parameter RECT2POL_NSTAGES = 20
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
  input                        act_i,
  input                        act_out_i,
  output                       val_o
);

  ddc
  #(
    .DATAIN_WIDTH(DATAIN_WIDTH),
    .DATAOUT_WIDTH(DATAOUT_WIDTH),
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
  ddc_inst
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_i),
    .data_i(data_i),
    .data_amplitude_o(data_amplitude_o),
    .data_phase_o(data_phase_o),
    .idata_o(idata_o),
    .qdata_o(qdata_o),
    .act_i(act_i),
    .act_out_i(act_out_i),
    .val_o(val_o)
  );
  
endmodule
