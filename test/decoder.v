`include "../include/def.v"

module Decoder(
	clk,
	rst,
	en,
	Data_in,
	Index
);
 	input clk;
	input rst;
	input en;
	input signed [`INTERNAL_BITS-1:0] Data_in;
	output [`INTERNAL_BITS-1:0] Index;
	reg [`INTERNAL_BITS-1:0] index_temp;
	reg signed[`INTERNAL_BITS-1:0] big;
	reg [3:0] counter;

	integer i;
	always@(posedge clk or posedge rst) begin
		if(rst) begin
			index_temp <= 32'b0;
			big <= 32'b0;
			counter <= 4'b0;
		end
		else begin 
			if(en) begin
				index_temp <= counter;
				counter <= counter + 1;
				if (Data_in > big) begin
					big <= Data_in;
					index_temp <= counter;
				end
				else begin
					big <= big;
					index_temp <= index_temp;
				end // end else
			end // end if 
			else 
				index_temp <= 32'b0;
		end // end else
  	end
	assign Index = index_temp;
endmodule