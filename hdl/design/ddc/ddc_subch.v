// IE309 - Projetos de DSP em FPGA 2013
// Autores: Daniel de Oliveira Tavares - RA107455
//          Jaime Junior Luque Quispe  - RA144411
// Data: 27/06/2013

module ddc_subch
#(
  parameter DATAIN_WIDTH    = 16,
  parameter DATAOUT_WIDTH   = DATAIN_WIDTH,
  parameter NCO_PHASE_WIDTH = 12,
  parameter NCO_WIDTH       = 24,
  parameter NCO_LUT_FILE    = "",
  parameter CIC_M           = 2,
  parameter CIC_N           = 5,
  parameter CIC_MAXRATE     = 64
)
(
  input                        clk_i,
  input                        rst_i,
  input                        en_i,
  input  [DATAIN_WIDTH-1:0]    data_i,
  output [DATAOUT_WIDTH-1:0]   data_decimated_o,
  input  [NCO_PHASE_WIDTH-1:0] phase_i,
  input                        act_i,
  input                        act_out_i,
  output                       val_o
);
  
  wire [NCO_WIDTH-1:0]    nco;
  wire [DATAIN_WIDTH-1:0] data_mixed;
  
  // Mixer
  mult
  #(
    .A_WIDTH(DATAIN_WIDTH),
    .B_WIDTH(NCO_WIDTH),
    .O_WIDTH(DATAIN_WIDTH)
  )
  mixer
  (
    .clk_i(clk_i),
    .en_i(en_i),
    .a_i(data_i),
    .b_i(nco),
    .mult_o(data_mixed)
  );

  // NCO
  rom
  #(
    .ADDR_WIDTH(NCO_PHASE_WIDTH),
    .DATA_WIDTH(NCO_WIDTH),
    .INIT_FILE(NCO_LUT_FILE)
  )
  nco_lut
  (
    .clk_i(clk_i),
    .en_i(en_i),
    .addr_i(phase_i),
    .data_o(nco)
  );
  
  // Decimation filter
  cic_decim
  #(
    .DATAIN_WIDTH(DATAIN_WIDTH),
    .DATAOUT_WIDTH(DATAOUT_WIDTH),
    .M(CIC_M),
    .N(CIC_N),
    .MAXRATE(CIC_MAXRATE)
  )
  decim
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_i),
    .data_i(data_mixed),
    .data_o(data_decimated_o),
    .act_i(act_i),
    .act_out_i(act_out_i),
    .val_o(val_o)
  );
      
endmodule