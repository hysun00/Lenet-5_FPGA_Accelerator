`include "../include/def.v"

module Pooling(
	clk,
	rst,
	en,
	Data_in,
	Data_out
);

	input clk;
	input rst;
	input en;
	input  [`INTERNAL_BITS-1:0] Data_in;
	output [`INTERNAL_BITS-1:0] Data_out;
	reg    [`INTERNAL_BITS-1:0] temp;
	always@(posedge clk or posedge rst) begin
		if(rst) begin
			temp <= 0;
		end
		else begin
			if(en) begin
				if(Data_in > temp)
					temp <= Data_in;
				else 
					temp <= temp;
			end
			else
				temp <= 32'b0;
		end
	end
	assign Data_out = temp;
endmodule