`timescale 1ns/10ps

`define CYCLE 10
`include "cnn.v"
`include "bram.v"


module cnn_tb;
  reg clk;
  reg rst;
  reg start;
  reg mode;
  wire done;
  wire [7:0] result;

  integer err, i, j;
  wire [31:0] BRAM_IF1_ADDR, BRAM_W1_ADDR, BRAM_IF2_ADDR, BRAM_W2_ADDR, BRAM_W3_ADDR, BRAM_W4_ADDR, BRAM_W5_ADDR;
  wire [3:0] BRAM_IF1_WE, BRAM_W1_WE, BRAM_W2_WE, BRAM_IF2_WE, BRAM_W3_WE, BRAM_W4_WE, BRAM_W5_WE;
  wire BRAM_IF1_EN, BRAM_W1_EN, BRAM_W2_EN, BRAM_IF2_EN, BRAM_W3_EN, BRAM_W4_EN, BRAM_W5_EN;
  wire [31:0] BRAM_IF1_DOUT, BRAM_W1_DOUT, BRAM_W2_DOUT, BRAM_IF2_DOUT, BRAM_W3_DOUT, BRAM_W4_DOUT, BRAM_W5_DOUT;
  wire [31:0] BRAM_IF1_DIN, BRAM_W1_DIN, BRAM_W2_DIN, BRAM_IF2_DIN, BRAM_W3_DIN, BRAM_W4_DIN, BRAM_W5_DIN;

  cnn cnn(
    .clk(clk),
    .rst(rst),
    .start(start),
    .done(done),
    .mode(mode),
    .result(result),
    .BRAM_IF1_ADDR(BRAM_IF1_ADDR),
    .BRAM_IF2_ADDR(BRAM_IF2_ADDR),
    .BRAM_W1_ADDR(BRAM_W1_ADDR),
    .BRAM_W2_ADDR(BRAM_W2_ADDR),
    .BRAM_W3_ADDR(BRAM_W3_ADDR),
    .BRAM_W4_ADDR(BRAM_W4_ADDR),
    .BRAM_W5_ADDR(BRAM_W5_ADDR),
    .BRAM_IF1_WE(BRAM_IF1_WE),
    .BRAM_IF2_WE(BRAM_IF2_WE),
    .BRAM_W1_WE(BRAM_W1_WE),
    .BRAM_W2_WE(BRAM_W2_WE),
    .BRAM_W3_WE(BRAM_W3_WE),
    .BRAM_W4_WE(BRAM_W4_WE),
    .BRAM_W5_WE(BRAM_W5_WE),
    .BRAM_IF1_EN(BRAM_IF1_EN),
    .BRAM_IF2_EN(BRAM_IF2_EN),
    .BRAM_W1_EN(BRAM_W1_EN),
    .BRAM_W2_EN(BRAM_W2_EN),
    .BRAM_W3_EN(BRAM_W3_EN),
    .BRAM_W4_EN(BRAM_W4_EN),
    .BRAM_W5_EN(BRAM_W5_EN),
    .BRAM_IF1_DOUT(BRAM_IF1_DOUT),
    .BRAM_IF2_DOUT(BRAM_IF2_DOUT),
    .BRAM_W1_DOUT(BRAM_W1_DOUT),
    .BRAM_W2_DOUT(BRAM_W2_DOUT),
    .BRAM_W3_DOUT(BRAM_W3_DOUT),
    .BRAM_W4_DOUT(BRAM_W4_DOUT),
    .BRAM_W5_DOUT(BRAM_W5_DOUT),
    .BRAM_IF1_DIN(BRAM_IF1_DIN),
    .BRAM_IF2_DIN(BRAM_IF2_DIN),
    .BRAM_W1_DIN(BRAM_W1_DIN),
    .BRAM_W2_DIN(BRAM_W2_DIN),
    .BRAM_W3_DIN(BRAM_W3_DIN),
    .BRAM_W4_DIN(BRAM_W4_DIN),
    .BRAM_W5_DIN(BRAM_W5_DIN)
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

  bram bram_w3(
    .clk(clk),
    .rst(rst),
    .wen(BRAM_W3_WE),
    .addr(BRAM_W3_ADDR),
    .en(BRAM_W3_EN),
    .dout(BRAM_W3_DOUT),
    .din(BRAM_W3_DIN)
  );

  bram bram_w4(
    .clk(clk),
    .rst(rst),
    .wen(BRAM_W4_WE),
    .addr(BRAM_W4_ADDR),
    .en(BRAM_W4_EN),
    .dout(BRAM_W4_DOUT),
    .din(BRAM_W4_DIN)
  );

  bram bram_w5(
    .clk(clk),
    .rst(rst),
    .wen(BRAM_W5_WE),
    .addr(BRAM_W5_ADDR),
    .en(BRAM_W5_EN),
    .dout(BRAM_W5_DOUT),
    .din(BRAM_W5_DIN)
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
    `ifdef number
    for (i = 0; i < 10; i=i+1) begin
      if(cnn.psum_temp[1][i] !== GOLDEN[i])begin
        $display("DM[%4d] = %h, expect = %h", i, cnn.psum_temp[1][i], GOLDEN[i]);
        err = err + 1;
      end
      else begin
        $display("DM[%4d] = %h, pass", i, cnn.psum_temp[1][i]);
      end
    end
    `elsif letter
    for (i = 0; i < 27; i=i+1) begin
      if(cnn.psum_temp[1][i] !== GOLDEN[i])begin
        $display("DM[%4d] = %h, expect = %h", i, cnn.psum_temp[1][i], GOLDEN[i]);
        err = err + 1;
      end
      else begin
        $display("DM[%4d] = %h, pass", i, cnn.psum_temp[1][i]);
      end
    end
    `endif    

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
    $display("\nInference result = %d\n", result);

    $finish;
  end

  always #(`CYCLE/2) clk = ~clk;

  initial begin
    `ifdef number
      mode = 1;
      $readmemh("./number/number_conv1_32.hex", bram_w1.mem);
      $readmemh("./number/number_conv2_32.hex", bram_w2.mem);
      $readmemh("./number/number_conv3_32.hex", bram_w3.mem);
      $readmemh("./number/number_fc1_32.hex",   bram_w4.mem);
      $readmemh("./number/number_fc2_32.hex",   bram_w5.mem);
      $readmemh("./number/number_conv1_32_in.hex", bram_if1.mem);
      //$readmemh("./number/number_conv1_32_out.hex", GOLDEN, 0);
      $readmemh("./number/number_fc2_out.hex", GOLDEN, 0);
    `elsif letter
      mode = 0;
      $readmemh("./letter/letter_conv1_32.hex", bram_w1.mem);
      $readmemh("./letter/letter_conv2_32.hex", bram_w2.mem);
      $readmemh("./letter/letter_conv3_32.hex", bram_w3.mem);
      $readmemh("./letter/letter_fc1_32.hex",   bram_w4.mem);
      $readmemh("./letter/letter_fc2_32.hex",   bram_w5.mem);      
      $readmemh("./letter/letter_358_in_32.hex", bram_if1.mem);
      $readmemh("./letter/letter_fc2_out.hex", GOLDEN, 0);
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