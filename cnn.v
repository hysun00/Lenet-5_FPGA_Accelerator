`define DATA_BITS 32
`define INTERNAL_BITS 8
`include "PE.v"
module cnn(clk, 
           rst, 
           start, 
           done, 
           BRAM_IF_ADDR, 
           BRAM_W_ADDR, 
           BRAM_TEMP_ADDR, 
           BRAM_IF_WE, 
           BRAM_W_WE, 
           BRAM_TEMP_WE, 
           BRAM_IF_EN, 
           BRAM_W_EN, 
           BRAM_TEMP_EN, 
           BRAM_IF_RST, 
           BRAM_W_RST, 
           BRAM_TEMP_RST, 
           BRAM_IF_DOUT, 
           BRAM_W_DOUT, 
           BRAM_TEMP_DOUT, 
           BRAM_IF_DIN, 
           BRAM_W_DIN, 
           BRAM_TEMP_DIN
);
  input clk;
  input rst;
  input start;
  output done;
  output [`DATA_BITS-1:0] BRAM_IF_ADDR, BRAM_W_ADDR, BRAM_TEMP_ADDR; // address
  output [3:0] BRAM_IF_WE, BRAM_W_WE, BRAM_TEMP_WE; // write or read
  output BRAM_IF_EN, BRAM_W_EN, BRAM_TEMP_EN; // enable
  output BRAM_IF_RST, BRAM_W_RST, BRAM_TEMP_RST;  // reset
  input  [`DATA_BITS-1:0] BRAM_IF_DOUT, BRAM_W_DOUT, BRAM_TEMP_DOUT; // data out
  output [`DATA_BITS-1:0] BRAM_IF_DIN, BRAM_W_DIN, BRAM_TEMP_DIN; // data in

  integer i, j;

  reg [`DATA_BITS-1:0] BRAM_W_ADDR, BRAM_TEMP_ADDR, BRAM_TEMP_DIN;

  reg [7:0] pe_pre_in [0:24];

  reg [7:0] i_cache [0:47]; // 8 x 6 => 48 * 8 = 512
  reg [7:0] w_cache [0:199]; // 8 * 200 = 1600 


  reg [5:0] icache_indx; // range: 0 ~ 63

  reg [7:0] wcache_indx;  // 0 ~ 255

  reg [4:0] state, n_state;

  reg [3:0] layer;

  reg w_ready;
  reg [2:0] x, y; // 8 * 8
  reg [2:0] base_addr_r; 
  reg [7:0] base_addr_c;


  reg [7:0] pe_in [0:199]; // 200 * 31 = 6200
  wire [31:0] pe_out  [0:7];

  reg [31:0] pe_sram [0:7][0:3]; // 32 * 32 = 1024
  reg [2:0] pe_sram_indx_j;

  reg [2:0] cnt_rd24;
  reg [5:0] counter;
  // layer
  // parameter conv1 = 1,
  //           conv2 = 2,
  //           conv3 = 3,
  //           fc1   = 4,
  //           fc2   = 5;

  // FSM:
  parameter IDLE        = 0,
            RD_BRTCH1   = 1,    // read bram to cache (16 cycle)
            RD_BRTCH2   = 2,    // read bram to cache (34 cycle) total 50 cycle (weight)
            READ24      = 3,
            READ_TILE1  = 4,
            READ_TILE2  = 5,
            READ_TILE3  = 6,
            READ_TILE4  = 7,
            READ_TILE5  = 8,
            READ_TILE6  = 9,
            READ_TILE7  = 10,
            READ_TILE8  = 11,
            EXE1        = 12,
            EXE2        = 13,
            MX_PL1      = 14,
            MX_PL2      = 15,
            WRITE_TEMP  = 16,
            DONE        = 17;

  assign done = (state == DONE);

  assign BRAM_IF_EN = (state == IDLE || state == RD_BRTCH1 || state == RD_BRTCH2 || state == READ24);
  assign BRAM_W_EN  = (state == IDLE || state == RD_BRTCH1 || state == RD_BRTCH2 || state == READ24);
  assign BRAM_TEMP_EN = (state == WRITE_TEMP);

  assign BRAM_IF_WE = 4'b0000;
  assign BRAM_W_WE = 4'b0000;
  assign BRAM_TEMP_WE = (state == WRITE_TEMP) ? 4'b1111 : 4'b0000;

/*
  READ TILE:   1  2  3  4 
               5  6  7  8 


  order: 1 2 5 6 -> 3 4 7 8 
*/  

  always @(posedge clk, posedge rst) begin
    if(rst) state <= IDLE;
    else state <= n_state;
  end

 // 1. 沒有跳到 3 4 7 8 
 // 2. write_temp 
  // next state logic
  always @(*) begin
    case (state)
      IDLE:        n_state = (start) ? RD_BRTCH1 : IDLE;
      RD_BRTCH1:   n_state = (counter == 11) ? ((w_ready) ? READ_TILE1 : RD_BRTCH2) : RD_BRTCH1;  
      RD_BRTCH2:   n_state = (counter == 37) ? READ_TILE1 : RD_BRTCH2;
      READ24:      n_state = (counter == 5)  ? READ_TILE1 : READ24;  // repeat 6 times -> RD_BRTCH1
      READ_TILE1:  n_state = READ_TILE2; 
      READ_TILE2:  n_state = READ_TILE5; 
      READ_TILE3:  n_state = READ_TILE4; 
      READ_TILE4:  n_state = READ_TILE7; 
      READ_TILE5:  n_state = READ_TILE6; 
      READ_TILE6:  n_state = EXE1;
      READ_TILE7:  n_state = READ_TILE8; 
      READ_TILE8:  n_state = EXE2;
      EXE1:        n_state = (counter == 2) ? MX_PL1 : EXE1;
      EXE2:        n_state = (counter == 2) ? MX_PL2 : EXE2;
      MX_PL1:      n_state = (counter == 5) ? READ_TILE3 : MX_PL1;  // repeat 6 times -> RD_BRTCH1
      MX_PL2:      n_state = (counter == 5) ? WRITE_TEMP : MX_PL2;
      WRITE_TEMP:  n_state = (BRAM_TEMP_ADDR == 293) ? DONE : ((counter == 2) ? ((cnt_rd24 == 6) ? RD_BRTCH1 : READ24) : WRITE_TEMP);
      DONE:        n_state = IDLE;
      default:     n_state = IDLE;
    endcase
  end

  always @(posedge clk or posedge rst) begin
    if(rst) w_ready <= 0;
    else begin
      if(state == RD_BRTCH2) w_ready <= 1;
    end
  end


  always @(posedge clk or posedge rst) begin
    if(rst) cnt_rd24 <= 0;
    else begin
      if(state == READ24 && counter == 1) cnt_rd24 <= cnt_rd24 + 1;
      else if(state == RD_BRTCH1) cnt_rd24 <= 0;
    end
  end

  always @(posedge clk or posedge rst) begin
    if(rst) counter <= 0;
    else begin
      if((state == RD_BRTCH1 && counter <= 10) || (state == RD_BRTCH2 && counter <= 36) || 
         (state == READ24 && counter <= 4) || ((state == MX_PL1 || state == MX_PL2) && counter <= 4) ||
         ((state == EXE1 || state == EXE2) && counter <= 1) || (state == WRITE_TEMP && counter <= 1)) 
        counter <= counter + 1;
      else counter <= 0; // (state == RD_BRTCH1 && counter == 11) || (state == RD_BRTCH2 && counter == 37)
    end
  end

  always @(posedge clk or posedge rst) begin
    if(rst) begin
      for(i = 0; i < 48; i=i+1) i_cache[i] <= 0;
    end 
    else begin
      if(state == READ24) begin
        if(counter == 0) begin
          for(i = 0; i < 41; i=i+8) i_cache[i] <= i_cache[i+4];
          for(i = 1; i < 42; i=i+8) i_cache[i] <= i_cache[i+4];
          for(i = 2; i < 43; i=i+8) i_cache[i] <= i_cache[i+4];
          for(i = 3; i < 44; i=i+8) i_cache[i] <= i_cache[i+4];
          i_cache[4]  <= BRAM_IF_DOUT[31-:8];
          i_cache[5]  <= BRAM_IF_DOUT[23-:8];
          i_cache[6]  <= BRAM_IF_DOUT[15-:8];
          i_cache[7]  <= BRAM_IF_DOUT[ 7-:8];
        end
        else if(counter == 1) begin
          i_cache[12] <= BRAM_IF_DOUT[31-:8];
          i_cache[13] <= BRAM_IF_DOUT[23-:8];
          i_cache[14] <= BRAM_IF_DOUT[15-:8];
          i_cache[15] <= BRAM_IF_DOUT[ 7-:8];
        end
        else if(counter == 2) begin
          i_cache[20] <= BRAM_IF_DOUT[31-:8];
          i_cache[21] <= BRAM_IF_DOUT[23-:8];
          i_cache[22] <= BRAM_IF_DOUT[15-:8];
          i_cache[23] <= BRAM_IF_DOUT[ 7-:8];
        end
        else if(counter == 3) begin
          i_cache[28] <= BRAM_IF_DOUT[31-:8];
          i_cache[29] <= BRAM_IF_DOUT[23-:8];
          i_cache[30] <= BRAM_IF_DOUT[15-:8];
          i_cache[31] <= BRAM_IF_DOUT[ 7-:8];
        end
        else if(counter == 4) begin
          i_cache[36] <= BRAM_IF_DOUT[31-:8];
          i_cache[37] <= BRAM_IF_DOUT[23-:8];
          i_cache[38] <= BRAM_IF_DOUT[15-:8];
          i_cache[39] <= BRAM_IF_DOUT[ 7-:8];
        end
        else if(counter == 5) begin
          i_cache[44] <= BRAM_IF_DOUT[31-:8];
          i_cache[45] <= BRAM_IF_DOUT[23-:8];
          i_cache[46] <= BRAM_IF_DOUT[15-:8];
          i_cache[47] <= BRAM_IF_DOUT[ 7-:8];
        end                              
      end 
      else if(state == RD_BRTCH1) {i_cache[icache_indx], i_cache[icache_indx+1], i_cache[icache_indx+2], i_cache[icache_indx+3]} <= BRAM_IF_DOUT; // 12 cycle (initial)
    end
  end

  // BRAM_TEMP_ADDR (在mxpl state 就要將data準備好)
  always @(posedge clk or posedge rst) begin
    if(rst) BRAM_TEMP_ADDR <= 0;
    else begin
      if(state == WRITE_TEMP) begin
        BRAM_TEMP_ADDR <= BRAM_TEMP_ADDR + 1;
      end
    end
  end

  // BRAM_IF_ADDR
  always @(posedge clk or posedge rst) begin
    if(rst) begin x <= 0; y <= 0; end
    else begin
      if(state == RD_BRTCH1 || state == READ24) begin
        x <= x + 1;
        if(x == 1) begin
          y <= y + 1;
          x <= 0;
        end
      end
    end
  end


  assign BRAM_IF_ADDR = base_addr_r + base_addr_c + {y, x};

  always @(posedge clk or posedge rst) begin
    if(rst) base_addr_r <= 0;
    else begin
      if(state == READ24 && counter == 0) base_addr_r <= base_addr_r + 1;
      else if(state == READ24 && cnt_rd24 < 6) base_addr_r <= 2;
      else if(state == RD_BRTCH1) base_addr_r <= 0;
    end
  end

  always @(posedge clk or posedge rst) begin
    if(rst) base_addr_c <= 0;
    else begin
      if(state == READ24 && cnt_rd24 == 6) base_addr_c <= base_addr_c + 16;
    end
  end


  always @(posedge clk or posedge rst) begin
    if(rst) begin
      for(i = 0; i < 200; i=i+1) w_cache[i] <= 0; 
    end
    else begin
      if(state == RD_BRTCH1 || state == RD_BRTCH2) {w_cache[wcache_indx], w_cache[wcache_indx+1], w_cache[wcache_indx+2], w_cache[wcache_indx+3]} <= BRAM_W_DOUT; // 改為4筆資料一行 => 50 cycle
    end
  end

  // BRAM_W_ADDR: 25 * 8
  always @(posedge clk or posedge rst) begin
    if(rst) BRAM_W_ADDR <= 0;
    else begin
      if(state == RD_BRTCH1 || state == RD_BRTCH2) BRAM_W_ADDR <= BRAM_W_ADDR + 1;
    end
  end

  // wcache_indx
  always @(posedge clk or posedge rst) begin
    if(rst) wcache_indx <= 0;
    else begin
      if(state == RD_BRTCH1 || state == RD_BRTCH2) wcache_indx <= wcache_indx + 4;
    end
  end

  // icache_indx
  always @(posedge clk or posedge rst) begin
    if(rst) icache_indx <= 0;
    else begin
      if(state == RD_BRTCH1) icache_indx <= icache_indx + 4;
    end
  end


  // layer
  // always @(*) begin
  //   case (state)
  //     : layer = 1; // conv1 
  //     : layer = 2; // conv2
  //     : layer = 3; // conv3
  //     : layer = 4; // fc1
  //     : layer = 5; // fc2
  //     default: 
  //   endcase
  // end

/*        
  o o o o o o o o   0  1  2  3  4  5  6  7
  o o o o o o o o   8  9 10 11 12 13 14 15 
  o o o o o o o o  16 17 18 19 20 21 22 23 
  o o o o o o o o  24 25 26 27 28 29 30 31
  o o o o o o o o  32 33 34 35 36 37 38 39
  o o o o o o o o  40 41 42 43 44 45 46 47
  o o o o o o o o  48 49 50 51 52 53 54 55
  o o o o o o o o  56 57 58 59 60 61 62 63
*/

  assign shift_sram_en = (state == READ_TILE6 || state == READ_TILE8 || state == EXE1 || state == EXE2);

  // pe_pre_in
  always @(posedge clk or posedge rst) begin
    if(rst) for(i = 0; i < 25; i=i+1) pe_pre_in[i] <= 0;
    else begin
      case(state)
        READ_TILE1: begin
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j];
            end
          end
        end
        READ_TILE2: begin
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+1];
            end
          end
        end
        READ_TILE3: begin
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+2];
            end
          end        
        end
        READ_TILE4: begin
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+3];
            end
          end
        end
        READ_TILE5: begin
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+8];
            end
          end
        end
        READ_TILE6: begin
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+9];
            end
          end
        end
        READ_TILE7: begin
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+10];
            end
          end
        end
        READ_TILE8: begin
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+11];
            end
          end
        end
        /*
        READ_TILE9: 
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+16];
            end
          end
        READ_TILE10: 
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+17];
            end
          end
        READ_TILE11: 
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+18];
            end
          end
        READ_TILE12: 
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+19];
            end
          end
        READ_TILE13: 
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+24];
            end
          end
        READ_TILE14: 
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+25];
            end
          end
        READ_TILE15: 
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+26];
            end
          end
        READ_TILE16: 
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+27];
            end
          end          
        */                                                      
        default: for(i = 0; i < 25; i=i+1) pe_pre_in[i] = 0;
      endcase
    end
  end

  
  always @(posedge clk or posedge rst) begin
    if(rst) begin
      for(j = 0; j < 8; j=j+1) begin
        for(i = 0; i < 4; i=i+1) begin
          pe_sram[j][i] <= 0;
        end
      end
    end
    else begin
      if(shift_sram_en) begin
        for(j = 0; j < 8; j=j+1) pe_sram[j][0] <= pe_out[j];
        for(j = 0; j < 8; j=j+1) begin
          for(i = 0; i < 3; i=i+1) begin
            pe_sram[j][i+1] <= pe_sram[j][i];
          end
        end
      end // if-end
    end
  end


  // ======================================= PE input control =========================================================

  always @(*) begin
    for(i = 0; i < 25; i=i+1) begin
      pe_in[i]     = pe_pre_in[i];
      pe_in[i+25]  = pe_pre_in[i];
      pe_in[i+50]  = pe_pre_in[i];
      pe_in[i+75]  = pe_pre_in[i];
      pe_in[i+100] = pe_pre_in[i];
      pe_in[i+125] = pe_pre_in[i];
      pe_in[i+150] = pe_pre_in[i];
      pe_in[i+175] = pe_pre_in[i];
    end
  end

  // ========================================= PE =====================================================================
  genvar a; 
	generate 
    for (a = 0; a < 8; a = a + 1) begin: pe_array 										
      PE PE_Array(.in_IF1 (pe_in[a*25+0] ), 
                  .in_IF2 (pe_in[a*25+1] ), 
                  .in_IF3 (pe_in[a*25+2] ), 
                  .in_IF4 (pe_in[a*25+3] ), 
                  .in_IF5 (pe_in[a*25+4] ), 
                  .in_IF6 (pe_in[a*25+5] ), 
                  .in_IF7 (pe_in[a*25+6] ), 
                  .in_IF8 (pe_in[a*25+7] ), 
                  .in_IF9 (pe_in[a*25+8] ), 
                  .in_IF10(pe_in[a*25+9] ), 
                  .in_IF11(pe_in[a*25+10]), 
                  .in_IF12(pe_in[a*25+11]), 
                  .in_IF13(pe_in[a*25+12]), 
                  .in_IF14(pe_in[a*25+13]), 
                  .in_IF15(pe_in[a*25+14]), 
                  .in_IF16(pe_in[a*25+15]), 
                  .in_IF17(pe_in[a*25+16]), 
                  .in_IF18(pe_in[a*25+17]), 
                  .in_IF19(pe_in[a*25+18]), 
                  .in_IF20(pe_in[a*25+19]), 
                  .in_IF21(pe_in[a*25+20]), 
                  .in_IF22(pe_in[a*25+21]), 
                  .in_IF23(pe_in[a*25+22]), 
                  .in_IF24(pe_in[a*25+23]), 
                  .in_IF25(pe_in[a*25+24]), 

                  .in_W1 (w_cache[a*25+0 ]), 
                  .in_W2 (w_cache[a*25+1 ]), 
                  .in_W3 (w_cache[a*25+2 ]), 
                  .in_W4 (w_cache[a*25+3 ]), 
                  .in_W5 (w_cache[a*25+4 ]), 
                  .in_W6 (w_cache[a*25+5 ]), 
                  .in_W7 (w_cache[a*25+6 ]), 
                  .in_W8 (w_cache[a*25+7 ]), 
                  .in_W9 (w_cache[a*25+8 ]), 
                  .in_W10(w_cache[a*25+9 ]), 
                  .in_W11(w_cache[a*25+10]), 
                  .in_W12(w_cache[a*25+11]), 
                  .in_W13(w_cache[a*25+12]), 
                  .in_W14(w_cache[a*25+13]), 
                  .in_W15(w_cache[a*25+14]), 
                  .in_W16(w_cache[a*25+15]), 
                  .in_W17(w_cache[a*25+16]), 
                  .in_W18(w_cache[a*25+17]), 
                  .in_W19(w_cache[a*25+18]), 
                  .in_W20(w_cache[a*25+19]), 
                  .in_W21(w_cache[a*25+20]), 
                  .in_W22(w_cache[a*25+21]), 
                  .in_W23(w_cache[a*25+22]), 
                  .in_W24(w_cache[a*25+23]), 
                  .in_W25(w_cache[a*25+24]),
                  .rst(rst), 
                  .clk(clk),
                  .relu_en(relu_en),
                  .quan_en(quan_en),
                  .pe_out(pe_out[a])
                );	
    end
	endgenerate
// ============================================================================================
  assign relu_en = 1;
  assign quan_en = 1;
  assign sft_mx_pl_reg = (state == MX_PL1 || state == MX_PL2);

  reg [7:0] temp1, temp2, mx_pl_out;
// maxpooling
  always @(*) begin // 1 cycle
    temp1     = (pe_sram[pe_sram_indx_j][0] > pe_sram[pe_sram_indx_j][1]) ? pe_sram[pe_sram_indx_j][0] : pe_sram[pe_sram_indx_j][1];
    temp2     = (pe_sram[pe_sram_indx_j][2] > temp1)         ? pe_sram[pe_sram_indx_j][2] : temp1;
    mx_pl_out = (pe_sram[pe_sram_indx_j][3] > temp2)         ? pe_sram[pe_sram_indx_j][3] : temp2;
  end

  reg [7:0] mx_pl_reg [0:11];
  always @(posedge clk or posedge rst) begin
    if(rst) for(i = 0; i < 8; i=i+1) mx_pl_reg[i] <= 0;
    else begin
      if(sft_mx_pl_reg) begin
        mx_pl_reg[0] <= mx_pl_out;
        for(i = 0; i < 11; i=i+1) begin
          mx_pl_reg[i+1] <= mx_pl_reg[i]; 
        end
      end
    end
  end
   
  reg [3:0] mx_pl_reg_indx;

  // BRAM_TEMP_DIN
  // assign  BRAM_TEMP_DIN = mx_pl_out; (4 個一組)
  always @(posedge clk or posedge rst) begin
    if(rst) BRAM_TEMP_DIN <= 0;
    else begin
      BRAM_TEMP_DIN <= {mx_pl_reg[mx_pl_reg_indx], mx_pl_reg[mx_pl_reg_indx+1], mx_pl_reg[mx_pl_reg_indx+2], mx_pl_reg[mx_pl_reg_indx+3]};
    end
  end
  

  always @(posedge clk or posedge rst) begin
    if(rst) mx_pl_reg_indx <= 0;
    else begin
      if(state == WRITE_TEMP) mx_pl_reg_indx <= mx_pl_reg_indx + 4;
    end
  end


  //========================================================================================================================
  always @(posedge clk or posedge rst) begin
    if(rst) pe_sram_indx_j <= 0;
    else begin
      if(state == MX_PL1 || state == MX_PL2) pe_sram_indx_j <= pe_sram_indx_j + 1;
    end
  end


endmodule
