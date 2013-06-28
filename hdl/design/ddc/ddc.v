// IE309 - Projetos de DSP em FPGA 2013
// Autores: Daniel de Oliveira Tavares - RA107455
//          Jaime Junior Luque Quispe  - RA144411
// Data: 27/06/2013

module ddc
#(
  parameter DATAIN_WIDTH     = 16,
  parameter DATAOUT_WIDTH    = DATAIN_WIDTH,
  parameter NCO_PHASE_WIDTH  = 12,
  parameter NCO_PHASE_INC    = 240,
  parameter NCO_WIDTH        = 24,
  parameter NCO_COS_LUT_FILE = "",
  parameter NCO_SIN_LUT_FILE = "",
  parameter NCO_EOTABLE      = 17,
  parameter CIC_M            = 2,
  parameter CIC_N            = 5,
  parameter CIC_MAXRATE      = 64,
  parameter RECT2POL_NSTAGES = 20
)
(
  input                      clk_i,
  input                      rst_i,
  input                      en_i,
  input  [DATAIN_WIDTH-1:0]  data_i,
  output [DATAOUT_WIDTH-1:0] data_amplitude_o,
  output [DATAOUT_WIDTH-1:0] data_phase_o,
//  input  [NCO_PHASE_WIDTH-1:0] phase_offset_i,
  input                     act_i,
  input                     act_out_i,
  output                    val_o
);

  wire [DATAOUT_WIDTH-1:0]  data_decimated_i_o;
  wire [DATAOUT_WIDTH-1:0]  data_decimated_q_o;
  reg  [NCO_PHASE_WIDTH:0]  acc_phase;
  reg  [RECT2POL_NSTAGES:0] val_shift_reg;
  wire                      val_cic;
  
  // Phase accumulator
  always @(posedge clk_i)
    if (rst_i)
      acc_phase <= {{1'b0}};
    else if (en_i)
      if (acc_phase >= NCO_EOTABLE)
        acc_phase <= acc_phase - NCO_EOTABLE;
      else
        acc_phase <= acc_phase + NCO_PHASE_INC;

  // Delay line for synchronizing val_o
  always @(posedge clk_i)
    if (en_i)
      val_shift_reg <= {val_shift_reg[RECT2POL_NSTAGES-1:0], val_cic};

  assign val_o = val_shift_reg[RECT2POL_NSTAGES];

  ddc_subch
  #(
    .DATAIN_WIDTH(DATAIN_WIDTH),
    .DATAOUT_WIDTH(DATAOUT_WIDTH),
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
    .data_decimated_o(data_decimated_i_o),
    .phase_i(acc_phase[NCO_PHASE_WIDTH-1:0]),
    .act_i(act_i),
    .act_out_i(act_out_i),
    .val_o(val_cic)
  );

  ddc_subch
  #(
    .DATAIN_WIDTH(DATAIN_WIDTH),
    .DATAOUT_WIDTH(DATAOUT_WIDTH),
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
    .data_decimated_o(data_decimated_q_o),
    .phase_i(acc_phase[NCO_PHASE_WIDTH-1:0]),
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
    .xin(data_decimated_i_o),
    .yin(data_decimated_q_o),
    .phasein(),
    .xout(data_amplitude_o),
    .yout(),
    .phaseout(data_phase_o)
  );
  
endmodule