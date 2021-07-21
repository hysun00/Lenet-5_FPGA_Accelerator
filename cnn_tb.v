`timescale 1ns/10ps

`define CYCLE 10
`include "cnn.v"
`include "bram_w."
`include "bram_if.v"
`include "bram_tmp.v"

module cnn_tb;
  reg clk;
  reg rst;
  reg start;
  wire done;
  wire 

  cnn cnn(
    .clk(clk),
    .rst(rst),
    .start(),
    .done(),
    .BRAM_IF_ADDR(),
    .BRAM_W_ADDR(),
    .BRAM_TEMP_ADDR(),
    .BRAM_IF_WE(),
    .BRAM_W_WE(),
    .BRAM_TEMP_WE(),
    .BRAM_IF_EN(),
    .BRAM_W_EN(),
    .BRAM_TEMP_EN(),
    .BRAM_IF_RST(),
    .BRAM_W_RST(),
    .BRAM_TEMP_RST(),
    .BRAM_IF_DOUT(),
    .BRAM_W_DOUT(),
    .BRAM_TEMP_DOUT(),
    .BRAM_IF_DIN(),
    .BRAM_W_DIN(),
    .BRAM_TEMP_DIN()
  );

  bram bram_w(
    .clk(),
    .rst(),
    .wen(),
    .addr(),
    .en(),
    .dout(),
    .din()
  );


  bram bram_tmp(
    .clk(),
    .rst(),
    .wen(),
    .addr(),
    .en(),
    .dout(),
    .din()
  );

  bram bram_f(
    .clk(),
    .rst(),
    .wen(),
    .addr(),
    .en(),
    .dout(),
    .din()
  );

  reg [7:0] GOLDEN [0:293]
  initial begin
    clk = 0; rst = 1;
    start = 0;
    #1 rst = 0;
    #20 start = 1;
    #10 start = 0;
    wait(fin);
    #(`CYCLE*2)
    #20 
    $display("\nDone\n");
    err = 0;
    //num=6;
    for (i = 0; i < num; i=i+1)
    begin
      if(M1.bram[i] !== GOLDEN[i])begin
        $display("DM[%4d] = %h, expect = %h", i, M1.bram[i], GOLDEN[i]);
        err = err + 1;
      end
      
      
      else
      begin
        $display("DM[%4d] = %h, pass",  i, M1.bram[i]);
      end
      
    end
    result(err, num);
    $finish;
  end
  always #(`CYCLE/2) clk = ~clk;

  initial begin
		$readmemh("./number", bram_w.mem, 0);
    $readmemh("./number", bram_f.mem, 0);
    $readmemh("./number", GOLDEN, 0);
	end

  initial
  begin
    `ifdef FSDB
    $fsdbDumpfile("cnn.fsdb");
    $fsdbDumpvars("+struct", "+mda");
    `endif



endmodule