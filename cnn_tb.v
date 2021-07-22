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
  wire [31:0] BRAM_IF_ADDR, BRAM_W_ADDR, BRAM_TEMP_ADDR;
  wire [3:0] BRAM_IF_WE, BRAM_W_WE, BRAM_TEMP_WE;
  wire BRAM_IF_EN, BRAM_W_EN, BRAM_TEMP_EN;
  wire [31:0] BRAM_IF_DOUT, BRAM_W_DOUT, BRAM_TEMP_DOUT;
  wire [31:0] BRAM_IF_DIN, BRAM_W_DIN, BRAM_TEMP_DIN;

  cnn cnn(
    .clk(clk),
    .rst(rst),
    .start(start),
    .done(done),
    .BRAM_IF_ADDR(BRAM_IF_ADDR),
    .BRAM_W_ADDR(BRAM_W_ADDR),
    .BRAM_TEMP_ADDR(BRAM_TEMP_ADDR),
    .BRAM_IF_WE(BRAM_IF_WE),
    .BRAM_W_WE(BRAM_W_WE),
    .BRAM_TEMP_WE(BRAM_TEMP_WE),
    .BRAM_IF_EN(BRAM_IF_EN),
    .BRAM_W_EN(BRAM_W_EN),
    .BRAM_TEMP_EN(BRAM_TEMP_EN),
    .BRAM_IF_RST(),
    .BRAM_W_RST(),
    .BRAM_TEMP_RST(),
    .BRAM_IF_DOUT(BRAM_IF_DOUT),
    .BRAM_W_DOUT(BRAM_W_DOUT),
    .BRAM_TEMP_DOUT(BRAM_TEMP_DOUT),
    .BRAM_IF_DIN(BRAM_IF_DIN),
    .BRAM_W_DIN(BRAM_W_DIN),
    .BRAM_TEMP_DIN(BRAM_TEMP_DIN)
  );

  bram bram_w(
    .clk(clk),
    .rst(rst),
    .wen(BRAM_W_WE),
    .addr(BRAM_W_ADDR),
    .en(BRAM_W_EN),
    .dout(BRAM_W_DOUT),
    .din(BRAM_W_DIN)
  );


  bram bram_tmp(
    .clk(clk),
    .rst(rst),
    .wen(BRAM_TEMP_WE),
    .addr(BRAM_TEMP_ADDR),
    .en(BRAM_TEMP_EN),
    .dout(BRAM_TEMP_DOUT),
    .din(BRAM_TEMP_DIN)
  );

  bram bram_f(
    .clk(clk),
    .rst(rst),
    .wen(BRAM_IF_WE),
    .addr(BRAM_IF_ADDR),
    .en(BRAM_IF_EN),
    .dout(BRAM_IF_DOUT),
    .din(BRAM_IF_DIN)
  );

  reg [31:0] GOLDEN [0:293];
  reg [31:0] mem1 [0:50];
  reg [31:0] mem2 [0:255];
  initial begin
    clk = 0; rst = 1;
    start = 0;
    #1 rst = 0;
    #20 start = 1;
    #10 start = 0;
    wait(done);
    #(`CYCLE*2)
    #20 
    $display("\n============ Done ===================\n");
    $display("\n======== Check start ================\n");
    err = 0;

    for (i = 0; i < 294; i=i+1) begin
      if(bram_tmp.mem[i] !== GOLDEN[i])begin
        $display("DM[%4d] = %h, expect = %h", i, bram_tmp.mem[i], GOLDEN[i]);
        err = err + 1;
      end
      else begin
        $display("DM[%4d] = %h, pass",  i, bram_tmp.mem[i]);
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
		$readmemh("./number/number_conv1_32.hex", mem1, 0);
    for(i = 0; i < 38; i=i+1) bram_w.mem[i] = mem1[i];
  end
  initial begin
    $readmemh("./number/number_conv1_32_in.hex", mem2, 0);
    for(i = 0; i < 256; i=i+1) bram_f.mem[i] = mem2[i]; 
  end
  initial begin  
    $readmemh("./number/number_conv1_32_out.hex", GOLDEN, 0);
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