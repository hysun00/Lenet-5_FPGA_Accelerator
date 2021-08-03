module PE(rst,
          clk,
          pe_out,
          relu_en,
          quan_en,
          psum,
          msb_ctrl,
          in_IF1,
          in_IF2,
          in_IF3,
          in_IF4,
          in_IF5,
          in_IF6,
          in_IF7,
          in_IF8,
          in_IF9,
          in_IF10,
          in_IF11,
          in_IF12,
          in_IF13,
          in_IF14,
          in_IF15,
          in_IF16,
          in_IF17,
          in_IF18,
          in_IF19,
          in_IF20,
          in_IF21,
          in_IF22,
          in_IF23,
          in_IF24,
          in_IF25,
          in_W1,
          in_W2,
          in_W3,
          in_W4,
          in_W5,
          in_W6,
          in_W7,
          in_W8,
          in_W9,
          in_W10,
          in_W11,
          in_W12,
          in_W13,
          in_W14,
          in_W15,
          in_W16,
          in_W17,
          in_W18,
          in_W19,
          in_W20,
          in_W21,
          in_W22,
          in_W23,
          in_W24,
          in_W25
);

  input rst;
  input clk;
  input relu_en;
  input quan_en;
  input msb_ctrl;
  output [31:0] pe_out; // if quantize, pe_out will be 8 bits ([14:7]) or 32 bits
  input  [31:0] psum;
  input  [7:0] in_IF1;
  input  [7:0] in_IF2;
  input  [7:0] in_IF3;
  input  [7:0] in_IF4;
  input  [7:0] in_IF5;
  input  [7:0] in_IF6;
  input  [7:0] in_IF7;
  input  [7:0] in_IF8;
  input  [7:0] in_IF9;
  input  [7:0] in_IF10;
  input  [7:0] in_IF11;
  input  [7:0] in_IF12;
  input  [7:0] in_IF13;
  input  [7:0] in_IF14;
  input  [7:0] in_IF15;
  input  [7:0] in_IF16;
  input  [7:0] in_IF17;
  input  [7:0] in_IF18;
  input  [7:0] in_IF19;
  input  [7:0] in_IF20;
  input  [7:0] in_IF21;
  input  [7:0] in_IF22;
  input  [7:0] in_IF23;
  input  [7:0] in_IF24;
  input  [7:0] in_IF25;

  input signed [7:0] in_W1;
  input signed [7:0] in_W2;
  input signed [7:0] in_W3;
  input signed [7:0] in_W4;
  input signed [7:0] in_W5;
  input signed [7:0] in_W6;
  input signed [7:0] in_W7;
  input signed [7:0] in_W8;
  input signed [7:0] in_W9;
  input signed [7:0] in_W10;
  input signed [7:0] in_W11;
  input signed [7:0] in_W12;
  input signed [7:0] in_W13;
  input signed [7:0] in_W14;
  input signed [7:0] in_W15;
  input signed [7:0] in_W16;
  input signed [7:0] in_W17;
  input signed [7:0] in_W18;
  input signed [7:0] in_W19;
  input signed [7:0] in_W20;
  input signed [7:0] in_W21;
  input signed [7:0] in_W22;
  input signed [7:0] in_W23;
  input signed [7:0] in_W24;
  input signed [7:0] in_W25;
 
  integer i;
  wire [31:0] relu_out;
  reg msb [0:24];
  reg signed [31:0] sum;
  reg [31:0] mul [0:24]; // 25 * 32 = 800

  always @(*) begin
    if(!msb_ctrl) begin
      for(i = 0; i < 25; i=i+1) begin
        msb[i] = 0;
      end
    end
    else begin
      msb[0]  = in_IF1[7];
      msb[1]  = in_IF2[7];
      msb[2]  = in_IF3[7];
      msb[3]  = in_IF4[7];
      msb[4]  = in_IF5[7];
      msb[5]  = in_IF6[7];
      msb[6]  = in_IF7[7]; 
      msb[7]  = in_IF8[7];
      msb[8]  = in_IF9[7];
      msb[9]  = in_IF10[7];
      msb[10] = in_IF11[7];
      msb[11] = in_IF12[7];
      msb[12] = in_IF13[7];
      msb[13] = in_IF14[7];
      msb[14] = in_IF15[7];
      msb[15] = in_IF16[7];
      msb[16] = in_IF17[7];
      msb[17] = in_IF18[7];
      msb[18] = in_IF19[7];
      msb[19] = in_IF20[7];
      msb[20] = in_IF21[7];
      msb[21] = in_IF22[7];
      msb[22] = in_IF23[7];
      msb[23] = in_IF24[7];
      msb[24] = in_IF25[7];
    end
  end 


  // 乘法器
  always @(posedge clk or posedge rst) begin
    if(rst) for(i = 0; i < 25; i=i+1) mul[i] <= 0;
    else begin
      mul[0]  <= $signed({msb[0], in_IF1 }) * in_W1;
      mul[1]  <= $signed({msb[1], in_IF2 }) * in_W2;
      mul[2]  <= $signed({msb[2], in_IF3 }) * in_W3;
      mul[3]  <= $signed({msb[3], in_IF4 }) * in_W4;
      mul[4]  <= $signed({msb[4], in_IF5 }) * in_W5;
      mul[5]  <= $signed({msb[5], in_IF6 }) * in_W6;
      mul[6]  <= $signed({msb[6], in_IF7 }) * in_W7;
      mul[7]  <= $signed({msb[7], in_IF8 }) * in_W8;
      mul[8]  <= $signed({msb[8], in_IF9 }) * in_W9;
      mul[9]  <= $signed({msb[9], in_IF10}) * in_W10;
      mul[10] <= $signed({msb[10],in_IF11}) * in_W11;
      mul[11] <= $signed({msb[11],in_IF12}) * in_W12;
      mul[12] <= $signed({msb[12],in_IF13}) * in_W13;
      mul[13] <= $signed({msb[13],in_IF14}) * in_W14;
      mul[14] <= $signed({msb[14],in_IF15}) * in_W15;
      mul[15] <= $signed({msb[15],in_IF16}) * in_W16;
      mul[16] <= $signed({msb[16],in_IF17}) * in_W17;
      mul[17] <= $signed({msb[17],in_IF18}) * in_W18;
      mul[18] <= $signed({msb[18],in_IF19}) * in_W19;
      mul[19] <= $signed({msb[19],in_IF20}) * in_W20;
      mul[20] <= $signed({msb[20],in_IF21}) * in_W21;
      mul[21] <= $signed({msb[21],in_IF22}) * in_W22;
      mul[22] <= $signed({msb[22],in_IF23}) * in_W23;
      mul[23] <= $signed({msb[23],in_IF24}) * in_W24;
      mul[24] <= $signed({msb[24],in_IF25}) * in_W25;
    end
  end

  // 加法器
  always @(posedge clk or posedge rst) begin
    if(rst) sum <= 0;
    else begin
      sum <= (((mul[1]  + mul[2])  + (mul[3]  + mul[4]) ) +
              ((mul[5]  + mul[6])  + (mul[7]  + mul[8]) ) +
              ((mul[9]  + mul[10]) + (mul[11] + mul[12])) +
              ((mul[13] + mul[14]) + (mul[15] + mul[16])) +
              ((mul[17] + mul[18]) + (mul[19] + mul[20])) +
              ((mul[21] + mul[22]) + (mul[23] + mul[24])) +
               (mul[0]  + psum));
    end
  end

  assign relu_out = (relu_en) ? ((sum < 0) ? 0 : sum) : sum;
  assign pe_out = (quan_en) ? (|(relu_out[31:15]) ? 255 : 
                  ((&relu_out[14:7]) ? relu_out[14:7] : 
                  (relu_out[14:7] + relu_out[6]))) : 
                  relu_out; 

endmodule