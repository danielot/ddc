module div_fixedpoint
#(
  parameter WIDTH     = 48,
  parameter PRECISION = 47
)
(
  input                clk_i,
  input                en_i,
  input                act_i,
  input  [WIDTH-1:0]   n_i,
  input  [WIDTH-1:0]   d_i,
  output [PRECISION:0] q_o,
  output [WIDTH-1:0]   r_o,
  output               val_o
);

  localparam MAX_COUNT = PRECISION+1;

  reg n_reg [WIDTH-1:0];
  reg d_reg [WIDTH-1:0];

  wire init;
  wire finished;

  //Iteration counter
  reg [5:0] cnt;
  
  //Entity outputs (auxiliary signals)
  reg [PRECISION:0] slv_q;
  reg [WIDTH-1:0] slv_r;
  reg sl_err;

  // Iteration counter and start/stop division control
  always @(posedge(clk_i)) begin
    // Register numerator and denominator
    if (act_i) begin
      n_reg <= i_n;
      d_reg <= d_i;
    end
    
    if (cnt == 0) begin
      //Assert data ready ("val_o") for one clock cycle
      if (!finished)
        val_o <= 1'b1;
      else
        val_o <= 1'b0;

      // Start division
      if (act_i) begin
        cnt <= MAX_COUNT;
        init <= 1'b1;
        finished <= 1'b0;
      end
      else
        finished <= 1'b1;
    end
    else begin
      cnt <= cnt - 1;
      init <= 1'b0;
      val_o <= 1'b0;
    end
  end
    
  // Builds quotient bit vector
  always @(posedge(clk_i))
    o_q <= {slv_q[PRECISION-1:0], slv_carryout[3]};

  // Sets next remainder (current remainder shifted to the left by 2) (or initialization)
  assign slv_r = init ? n_reg : {slv_r_fb[WIDTH-2:0], 1'b0};
                                      
  // Sets next operation (add or subtract) based on carry bit (or initialization)
  assign slv_alumode = init ? slv_alumode_init : {2'b00, slv_carryout[3], slv_carryout[3]};
                     
endmodule
