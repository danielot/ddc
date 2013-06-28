`timescale 1ns / 10ps

(*mult_style="dsp"*)
module mult
#(
  parameter A_WIDTH = 8,
  parameter B_WIDTH = 8,
  parameter O_WIDTH = A_WIDTH + B_WIDTH
)
(
  input  clk_i,
  input  en_i,
  input  [A_WIDTH-1:0] a_i,
  input  [B_WIDTH-1:0] b_i,
  output [O_WIDTH-1:0] mult_o
);
  reg [A_WIDTH-1:0] a_reg;
  reg [B_WIDTH-1:0] b_reg;
  reg [A_WIDTH+B_WIDTH-1:0] mult_reg0, mult_reg1, mult_reg2;
  reg [O_WIDTH-1:0] mult_o;
  
  always @(posedge clk_i) begin
    if (en_i) begin
      a_reg     <= a_i;
      b_reg     <= b_i;
      mult_reg0 <= a_reg*b_reg;
      mult_reg1 <= mult_reg0;
      mult_reg2 <= mult_reg1;
      mult_o    <= mult_reg2[(A_WIDTH+B_WIDTH-1):(A_WIDTH+B_WIDTH-O_WIDTH)];
    end
  end

endmodule
