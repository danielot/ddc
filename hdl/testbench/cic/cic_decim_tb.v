`timescale 1ns / 1ps

module cic_decim_tb;

  parameter WIDTH = 25;
  parameter CLK_PERIOD = 100;
  parameter MAXRATE = 1000;

  // testbench signals
  integer in_data_file;
  integer out_data_file;
  integer dump;
  integer cnt = 0;
  integer data_out_int;
  
  // UUT inputs
  reg clk_i;
  reg rst_i;
  reg en_i;
  reg act_i;
  reg act_out_i;
  reg [WIDTH-1:0] data_i;

  // UUT outputs
  wire [WIDTH-1:0] data_o;
  wire val_o;

  // unit under test (UUT)
  cic_decim
  #(
    .DATAIN_WIDTH(WIDTH),
    .DATAOUT_WIDTH(WIDTH),
    .MAXRATE(MAXRATE)
  )
  uut
  (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .en_i(en_i),
    .data_i(data_i),
    .data_o(data_o),
    .act_i(act_i),
    .act_out_i(act_out_i),
    .val_o(val_o)
  );

  // clock
  always #(CLK_PERIOD/2) clk_i = !clk_i;

  always @(posedge clk_i) begin
    if (act_i)
      if (cnt < MAXRATE-1) begin
        act_out_i <= 1'b0;
        cnt <= cnt + 1;
      end
      else begin
        act_out_i <= 1'b1;
        cnt <= 0;
      end
    else
      act_out_i <= 1'b0;
  end

  initial begin
    // initialize inputs
    clk_i     = 1'b0;
    en_i      = 1'b1;
    data_i    = {WIDTH{1'd0}};
    act_i     = 1'd0;
    act_out_i = 1'd0;

    // reset
    rst_i = 1'b1;
    #(10*CLK_PERIOD);
    rst_i = 1'b0;

    // verification
    @(posedge clk_i);


    in_data_file = $fopen("in_data.txt", "r");
    if (!in_data_file) begin
      $display("Could not open \"in_data.txt\"");
      $finish;
    end

    out_data_file = $fopen("out_data.txt", "w");
    if (!out_data_file) begin
      $display("Could not open \"out_data.txt\"");
      $finish;
    end

    // load data files
    if (!in_data_file) begin
      $display("Could not open \"in_data.txt\"");
      $finish;
    end

    while (!$feof(in_data_file)) begin
      dump = $fscanf(in_data_file, "%d\n", data_i);
      
      data_out_int = {{(32-WIDTH){data_o[WIDTH-1]}},data_o};
      $fdisplay(out_data_file, "%d", data_out_int);
      
      act_i = #(CLK_PERIOD/100) 1'b1;
      @(posedge clk_i);
      act_i = #(CLK_PERIOD/100) 1'b0;;
      @(posedge clk_i);
      
      
    end
    
    $fclose(in_data_file);
    $fclose(out_data_file);
    
    #(10*CLK_PERIOD);
    
    $finish;
  end

endmodule
