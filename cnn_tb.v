`timescale 1ns/10ps

`define CYCLE 10
`include "cnn.v"
`include "bram.v"


module cnn_tb;
  reg clk;
  reg rst;
  reg start;
  wire done;

  integer err, i;
  wire [31:0] BRAM_IF1_ADDR, BRAM_W1_ADDR, BRAM_IF2_ADDR, BRAM_W2_ADDR;
  wire [3:0] BRAM_IF1_WE, BRAM_W1_WE, BRAM_W2_WE, BRAM_IF2_WE;
  wire BRAM_IF1_EN, BRAM_W1_EN, BRAM_W2_EN, BRAM_IF2_EN;
  wire [31:0] BRAM_IF1_DOUT, BRAM_W1_DOUT, BRAM_W2_DOUT, BRAM_IF2_DOUT;
  wire [31:0] BRAM_IF1_DIN, BRAM_W1_DIN, BRAM_W2_DIN, BRAM_IF2_DIN;

  cnn cnn(
    .clk(clk),
    .rst(rst),
    .start(start),
    .done(done),
    .BRAM_IF1_ADDR(BRAM_IF1_ADDR),
    .BRAM_IF2_ADDR(BRAM_IF2_ADDR),
    .BRAM_W1_ADDR(BRAM_W1_ADDR),
    .BRAM_W2_ADDR(BRAM_W2_ADDR),
    .BRAM_IF1_WE(BRAM_IF1_WE),
    .BRAM_IF2_WE(BRAM_IF2_WE),
    .BRAM_W1_WE(BRAM_W1_WE),
    .BRAM_W2_WE(BRAM_W2_WE),
    .BRAM_IF1_EN(BRAM_IF1_EN),
    .BRAM_IF2_EN(BRAM_IF2_EN),
    .BRAM_W1_EN(BRAM_W1_EN),
    .BRAM_W2_EN(BRAM_W2_EN),
    .BRAM_IF1_DOUT(BRAM_IF1_DOUT),
    .BRAM_IF2_DOUT(BRAM_IF2_DOUT),
    .BRAM_W1_DOUT(BRAM_W1_DOUT),
    .BRAM_W2_DOUT(BRAM_W2_DOUT),
    .BRAM_IF1_DIN(BRAM_IF1_DIN),
    .BRAM_IF2_DIN(BRAM_IF2_DIN),
    .BRAM_W1_DIN(BRAM_W1_DIN),
    .BRAM_W2_DIN(BRAM_W2_DIN)
  );

  bram bram_w1(
    .clk(clk),
    .rst(rst),
    .wen(BRAM_W1_WE),
    .addr(BRAM_W1_ADDR),
    .en(BRAM_W1_EN),
    .dout(BRAM_W1_DOUT),
    .din(BRAM_W1_DIN)
  );

  
  bram bram_w2(
    .clk(clk),
    .rst(rst),
    .wen(BRAM_W2_WE),
    .addr(BRAM_W2_ADDR),
    .en(BRAM_W2_EN),
    .dout(BRAM_W2_DOUT),
    .din(BRAM_W2_DIN)
  );


  bram bram_if2(
    .clk(clk),
    .rst(rst),
    .wen(BRAM_IF2_WE),
    .addr(BRAM_IF2_ADDR),
    .en(BRAM_IF2_EN),
    .dout(BRAM_IF2_DOUT),
    .din(BRAM_IF2_DIN)
  );

  bram bram_if1(
    .clk(clk),
    .rst(rst),
    .wen(BRAM_IF1_WE),
    .addr(BRAM_IF1_ADDR),
    .en(BRAM_IF1_EN),
    .dout(BRAM_IF1_DOUT),
    .din(BRAM_IF1_DIN)
  );

  reg [31:0] GOLDEN [0:293];
  // reg [31:0] mem1 [0:50];
  // reg [31:0] mem2 [0:255];
  initial begin
    clk = 0; rst = 1;
    start = 0;
    #1 rst = 0;
    #20 start = 1;
    #10 start = 0;
    wait(done);
    $display("\n============ Done ===================\n");
    $timeformat(-9, 2, " ns", 10); 
    $display("\nSimulation time = %t\n",$time);
    #(`CYCLE*2)
    $display("\n======== Check start ================\n");
    err = 0;

    for (i = 0; i < 100; i=i+1) begin // 100 
      if(bram_if1.mem[i] !== GOLDEN[i])begin
        $display("DM[%4d] = %h, expect = %h", i, bram_if1.mem[i], GOLDEN[i]);
        err = err + 1;
      end
      else begin
        $display("DM[%4d] = %h, pass",  i, bram_if1.mem[i]);
      end
      
    end
    if (err === 0) begin
        $display("\n");
        $display("\n");
        $display("        ****************************               ");
        $display("        **                        **       |\__||  ");
        $display("        **  Congratulations !!    **      / ^.^  | ");
        $display("        **                        **    /_____   | ");
        $display("        **  Simulation PASS!!     **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w| ");
        $display("        ****************************   \\m___m__|_|");
        $display("\n");
      end
      else begin
        $display("\n");
        $display("\n");
        $display("        ****************************               ");
        $display("        **                        **       |\__||  ");
        $display("        **  OOPS!!                **      / X,X  | ");
        $display("        **                        **    /_____   | ");
        $display("        **  Simulation Failed!!   **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w| ");
        $display("        ****************************   \\m___m__|_|");
        $display("         Totally has %d errors                     ", err); 
        $display("\n");
      end
    $finish;
  end

  always #(`CYCLE/2) clk = ~clk;

  initial begin
    `ifdef number
      $readmemh("./number/number_conv1_32.hex", bram_w1.mem);
      $readmemh("./number/number_conv2_32.hex", bram_w2.mem);
      $readmemh("./number/number_conv1_32_in.hex", bram_if1.mem);
      //$readmemh("./number/number_conv1_32_out.hex", GOLDEN, 0);
      $readmemh("./number/number_conv2_32_out.hex", GOLDEN, 0);
    `elsif letter
      $readmemh("./letter/letter_conv1_32_w.hex", bram_w1.mem);
      $readmemh("./letter/letter_conv2_32_w.hex", bram_w2.mem);
      $readmemh("./letter/letter_conv1_32_in.hex", bram_if1.mem);
      $readmemh("./letter/letter_conv2_32_out.hex", GOLDEN, 0);
    `endif
  end
	
  initial begin
    // `ifdef FSDB
    // $fsdbDumpfile("cnn.fsdb");
    // $fsdbDumpvars("+mda");
    // `elsif VCD
    $dumpfile("cnn.vcd");
    $dumpvars;
    // `endif 
  end


endmodule