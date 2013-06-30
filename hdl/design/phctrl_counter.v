module phctrl_counter
#(
  parameter WIDTH = 16,
  parameter INC = 1,
  parameter UPTO = 10
)
(
  input              clk_i,
  input              rst_i,
  input              en_i,
//  input  phase_offset_i,
  output [WIDTH-1:0] count_o,
  output             pulse_o
);

  reg [WIDTH:0] count;
  reg           pulse;
  
  always @(posedge clk_i)
    if (rst_i) begin
      count <= {{1'b0}};
      pulse <= 1'b0;
    end
    else if (en_i)
      if (count >= UPTO) begin
        count <= count - UPTO;
        pulse <= 1'b1;
      end
      else begin
        count <= count + INC;
        pulse <= 1'b0;
      end

  assign count_o = count[WIDTH-1:0];
  assign pulse_o = pulse;
  
endmodule
