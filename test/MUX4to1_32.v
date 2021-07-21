`include "../include/def.v"

module MUX4to1_32b(
	Data_in1,
	Data_in2,
	Data_in3,
	Data_in4,
	sel,
	Data_out
);

	input [`INTERNAL_BITS-1:0] Data_in1,Data_in2,Data_in3,Data_in4;
	input [1:0] sel;
	output reg [`INTERNAL_BITS-1:0] Data_out;

//complete your design here

	always@(*) begin
		case(sel)
			2'b00: Data_out = Data_in1; 
			2'b01: Data_out = Data_in2;
			2'b10: Data_out = Data_in3;
			default: Data_out = Data_in4;
		endcase
	end

endmodule
