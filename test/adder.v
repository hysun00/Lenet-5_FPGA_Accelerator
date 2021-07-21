`include "../include/def.v"

module Adder(
	Data_in1,
	Data_in2,
	Data_in3,
	Psum,
	Bias,
	Mode,
	Result
);

	input [`INTERNAL_BITS-1:0] Data_in1,Data_in2,Data_in3;
	input signed [`INTERNAL_BITS-1:0] Psum;
	input signed [`DATA_BITS-1:0] Bias;
	input [1:0] Mode;
	output [`INTERNAL_BITS-1:0] Result;
	reg signed [`INTERNAL_BITS-1:0] Result;

//complete your design here
  always@(*) begin
	  case(Mode)
	  	2'b00: Result = $signed(Data_in1) + $signed(Data_in2) + $signed(Data_in3); 
		2'b01: Result = $signed(Data_in1) + $signed(Data_in2) + $signed(Data_in3) + Psum;
		2'b10: Result = $signed(Data_in1) + $signed(Data_in2) + $signed(Data_in3) + Psum + Bias;
		default: Result = 32'b0;
	  endcase
  end


endmodule