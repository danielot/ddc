// IE309 - Projetos de DSP em FPGA 2013
// Autores: Daniel de Oliveira Tavares - RA107455
//          Jaime Junior Luque Quispe  - RA144411
// Data: 26/05/2013

module rom
#(
  parameter ADDR_WIDTH = 10,
  parameter DATA_WIDTH = 8,
  parameter INIT_FILE = ""
)
(
  input                   clk_i,
  input                   en_i,
  input  [ADDR_WIDTH-1:0] addr_i,
  output [DATA_WIDTH-1:0] data_o
);

  reg [DATA_WIDTH-1:0] data_o;
  reg [DATA_WIDTH-1:0] rom [0:2**ADDR_WIDTH-1];

  initial
    $readmemh(INIT_FILE, rom, 0, 2**ADDR_WIDTH-1);
  
  always @ (posedge clk_i) begin
    if(en_i)
      data_o <= rom[addr_i];
  end

endmodule
