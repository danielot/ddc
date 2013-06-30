
module dds
  #(parameter     
    DATA_WIDTH = 25,
    PHASE_WIDTH = 12,
    PHASE_ACC_WIDTH = 32,
    ADDR_WIDTH = 12
  )
  (
    input clk_i,
    input rst_i,
    input en_i,
    input [PHASE_WIDTH-1:0] phase_inc,
    
    output   [DATA_WIDTH-1:0]     sin_o,
    output   [DATA_WIDTH-1:0]     cos_o
    );

  reg [PHASE_ACC_WIDTH-1:0] phase_acc;
  
  
  always @(posedge clk_i)
  begin
    if (rst_i==1'b1)
      phase_acc <= {PHASE_ACC_WIDTH{1'b0}};
    else if (en_i ==1'b1)
      phase_acc <= phase_acc + phase_inc;
  end

  assign lut_addr = phase_acc[PHASE_ACC_WIDTH-1: PHASE_ACC_WIDTH-ADDR_WIDTH+1]; //endereco de memoria sin/cos lut
  
  sincos_lut
  lut(
    .clk_i(clk_i),
    .en_i(en_i),
    .addr_i(lut_addr),
    .sin_o(sin_o),
    .cos_o(cos_o)
  );
  
endmodule

