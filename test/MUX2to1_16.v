`include "../include/def.v"

module MUX2to1_16b(
	Data_in1,
	Data_in2,
	sel,
	Data_out
);

	input [`DATA_BITS-1:0] Data_in1,Data_in2;
	input sel;
	output reg [`DATA_BITS-1:0] Data_out;
	always@(*) begin
		case(sel)
			1'b0: Data_out = Data_in1; 
			default: Data_out = Data_in2;
		endcase
	end


endmodule