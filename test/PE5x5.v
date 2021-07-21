`include "PE.v"

module PE5x5(
  clk,
  rst,
  PE1_IF_w,
  PE2_IF_w,
  PE3_IF_w,
  PE4_IF_w,
  PE5_IF_w,
  PE1_W_w,
  PE2_W_w,
  PE3_W_w,
  PE4_W_w,
  PE5_W_w,
  IF_in,
  W_in,
  Result
);

  input clk, rst;
  input PE1_IF_w, PE2_IF_w, PE3_IF_w, PE4_IF_w, PE5_IF_w;
  input PE1_W_w, PE2_W_w, PE3_W_w, PE4_W_w, PE5_W_w;
  input [7:0] IF_in;
  input [7:0] W_in;
  wire  [31:0] PE1_result, PE2_result, PE3_result, PE4_result, PE5_result;
  output [31:0] Result;

	PE PE1(
		.clk(clk),
		.rst(rst),
		.IF_w(PE1_IF_w),
		.W_w(PE1_W_w),
		.IF_in(IF_in),
		.W_in(W_in),
		.Result(PE1_result)
	);

	PE PE2(
		.clk(clk),
		.rst(rst),
		.IF_w(PE2_IF_w),
		.W_w(PE2_W_w),
		.IF_in(IF_in),
		.W_in(W_in),
		.Result(PE2_result)
	);

	PE PE3(
		.clk(clk),
		.rst(rst),
		.IF_w(PE3_IF_w),
		.W_w(PE3_W_w),
		.IF_in(IF_in),
		.W_in(W_in),
		.Result(PE3_result)
	);
  
	PE PE4(
		.clk(clk),
		.rst(rst),
		.IF_w(PE4_IF_w),
		.W_w(PE4_W_w),
		.IF_in(IF_in),
		.W_in(W_in),
		.Result(PE4_result)
	);

	PE PE5(
		.clk(clk),
		.rst(rst),
		.IF_w(PE5_IF_w),
		.W_w(PE5_W_w),
		.IF_in(IF_in),
		.W_in(W_in),
		.Result(PE5_result)
	);

  assign Result = PE1_result + PE2_result + PE3_result + PE4_result + PE5_result;

endmodule