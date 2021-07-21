`include "../include/def.v"

module MUX2to1_32b(
	Data_in1,
	Data_in2,
	sel,
	Data_out
);

	input [`INTERNAL_BITS-1:0] Data_in1,Data_in2;
	input sel;
	output reg [`INTERNAL_BITS-1:0] Data_out;

//complete your design here

	always@(*) begin
		case(sel)
			1'b0: Data_out = Data_in1; 
			default: Data_out = Data_in2;
		endcase
	end

endmodule