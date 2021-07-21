`include "../include/def.v"

module PE( 
	clk,
	rst,
	IF_w,
	W_w,
	IF_in,
	W_in,
	Result
);

	input  clk;
	input  rst;
	input  IF_w,W_w;
	input  [7:0] IF_in, W_in;  
	output [7:0] Result; 
	reg signed [7:0] weight  [0:4];
  reg signed [7:0] feature [0:4];
	reg signed [31:0] Result;
 	integer i; 
 	always@(posedge clk or posedge rst) begin
		if(rst) begin
			for(i = 0;i < 5; i=i+1) begin
				weight[i] <= 8'd0;
				feature[i] <= 8'd0;
			end
		end
		else begin
			if(W_w & IF_w) begin
				weight[0] <= W_in;
				weight[1] <= weight[0];
				weight[2] <= weight[1];
        weight[3] <= weight[2];
        weight[4] <= weight[3];

				feature[0] <= IF_in;
				feature[1] <= feature[0];
				feature[2] <= feature[1];
        feature[3] <= feature[2];
				feature[4] <= feature[3];
			end
			else if (W_w) begin
				weight[0] <= W_in;
				weight[1] <= weight[0];
				weight[2] <= weight[1];
        weight[3] <= weight[2];
        weight[4] <= weight[3];
			end
			else if (IF_w) begin
				feature[0] <= IF_in;
				feature[1] <= feature[0];
				feature[2] <= feature[1];
        feature[3] <= feature[2];
				feature[4] <= feature[3];
			end
		end
 	end

 	always@(*) begin
		Result = weight[0] * feature[0] + weight[1] * feature[1] + weight[2] * feature[2] + weight[3] * feature[3] + weight[4] * feature[4];
 	end

endmodule