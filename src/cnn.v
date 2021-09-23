`define DATA_BITS 32
`define INTERNAL_BITS 8
`include "PE.v"
// pipeline X: remain the same
// pipeline O: modify
module cnn(clk, 
           rst, 
           start, 
           done,
           ready,
           result,
           BRAM_IF1_ADDR,  // IF1: for [conv1/conv3 input] & [conv2 output]
           BRAM_IF2_ADDR,  // IF2: for [conv2 input]       & [conv1/conv3 output]
           BRAM_W1_ADDR, 
           BRAM_W2_ADDR,
           BRAM_W3_ADDR,
           BRAM_W4_ADDR,
           BRAM_W5_ADDR,
           BRAM_IF1_WE, 
           BRAM_IF2_WE, 
           BRAM_W1_WE,
           BRAM_W2_WE, 
           BRAM_W3_WE,
           BRAM_W4_WE,
           BRAM_W5_WE,
           BRAM_IF1_EN, 
           BRAM_IF2_EN,
           BRAM_W1_EN,
           BRAM_W2_EN, 
           BRAM_W3_EN,
           BRAM_W4_EN,
           BRAM_W5_EN,
           BRAM_IF1_DOUT, 
           BRAM_IF2_DOUT, 
           BRAM_W1_DOUT,
           BRAM_W2_DOUT, 
           BRAM_W3_DOUT, 
           BRAM_W4_DOUT, 
           BRAM_W5_DOUT, 
           BRAM_IF1_DIN, 
           BRAM_IF2_DIN,
           BRAM_W1_DIN, 
           BRAM_W2_DIN,
           BRAM_W3_DIN,
           BRAM_W4_DIN,
           BRAM_W5_DIN
);
  input clk;
  input rst;
  input start;
  input ready;
  input  [`DATA_BITS-1:0] BRAM_IF1_DOUT, BRAM_W1_DOUT, BRAM_IF2_DOUT, BRAM_W2_DOUT, BRAM_W3_DOUT, BRAM_W4_DOUT, BRAM_W5_DOUT; // data out
  
  output done;
  output [7:0] result;
  output [`DATA_BITS-1:0] BRAM_IF1_ADDR, BRAM_W1_ADDR, BRAM_IF2_ADDR, BRAM_W2_ADDR, BRAM_W3_ADDR, BRAM_W4_ADDR, BRAM_W5_ADDR; // address
  output [3:0] BRAM_IF1_WE, BRAM_W1_WE, BRAM_IF2_WE, BRAM_W2_WE, BRAM_W3_WE, BRAM_W4_WE, BRAM_W5_WE; // write or read
  output BRAM_IF1_EN, BRAM_W1_EN, BRAM_IF2_EN, BRAM_W2_EN, BRAM_W3_EN, BRAM_W4_EN, BRAM_W5_EN; // enable
  output [`DATA_BITS-1:0] BRAM_IF1_DIN, BRAM_W1_DIN, BRAM_IF2_DIN, BRAM_W2_DIN, BRAM_W3_DIN, BRAM_W4_DIN, BRAM_W5_DIN; // data in

  integer i, j;
  wire [`DATA_BITS-1:0] L1_BRAM_IF1_ADDR_temp, L3_BRAM_IF1_ADDR_temp;
  wire [`DATA_BITS-1:0] L2_bram_IF2_addr;
  reg  [`DATA_BITS-1:0] BRAM_W1_ADDR_temp, BRAM_IF2_ADDR_temp;
  reg  [`DATA_BITS-1:0] BRAM_IF1_ADDR, BRAM_IF2_ADDR;
  reg  [`DATA_BITS-1:0] BRAM_W2_ADDR_temp, BRAM_W3_ADDR_temp, BRAM_W4_ADDR_temp, L2_BRAM_IF1_ADDR_temp, BRAM_W5_ADDR_temp;
  
  reg  [5:0]  state, n_state; // 0 ~ 63
  reg  [2:0]  layer; // 1 ~ 5
  reg  [7:0]  pe_pre_in       [0:24];
  reg  [7:0]  pe_in           [0:199]; // 200 * 8 = 1600
  reg  [31:0] pe_sram         [0:7][0:3]; // 32 * 32 = 1024
  wire [31:0] pe_out          [0:7];
  reg  [2:0]  pe_sram_indx_j;

  reg [7:0] i_cache     [0:47]; // 8 x 6 => 48 * 8 = 512
  reg [7:0] w_cache     [0:199];// 8 * 200 = 1600 
  reg [5:0] icache_indx;        // range: 0 ~ 63
  reg [7:0] wcache_indx;        // 0 ~ 255

  reg [31:0] psum_temp [0:7][0:99]; // 10 * 10 * 8
  reg [6:0]  psum_temp_indx; // 0 ~ 100
  reg signed [31:0] pe_out_sum_a;
  reg signed [31:0] pe_out_sum_b;

  reg [2:0] x, y; // 8 * 8
  reg [3:0] base_addr_r; 
  reg [7:0] base_addr_c;

  reg [2:0] cnt_rd_new;
  reg [5:0] counter; // 0 ~ 63
  reg [3:0] channel_cnt;

  reg [7:0] temp1;
  reg [7:0] temp2;
  reg [7:0] mx_pl_out;
  reg [7:0] mx_pl_reg [0:11];
  reg [3:0] mx_pl_reg_indx;
  reg [31:0] psum_in [0:7];
  reg [7:0] psum_in_indx;

  wire [7:0] L2_ifmp_indx; 
  wire [4:0] L3_ifmp_indx; 

  wire [31:0] pe_out_sum_a_relu;
  wire [31:0] pe_out_sum_b_relu;
  
  wire [31:0] pe_out_sum_a_quan;

  reg [4:0] bits_select;
  reg [1:0] bits_select_temp;

  reg [7:0] soft_max_indx;
  reg [31:0] soft_max_temp;

  // FSM:
  //==================== Layer 1 =======================================================
  parameter IDLE           = 0,
            L1_RD_BRTCH1   = 1,    // read bram to cache (16 cycle)
            L1_RD_BRTCH2   = 2,    // read bram to cache (34 cycle) total 50 cycle (weight)
            L1_RD_BRTCH3   = 3,    // read 6 * 8
            L1_READ24      = 4,
            L1_READ_TILE1  = 5,
            L1_READ_TILE2  = 6,
            L1_READ_TILE3  = 7,
            L1_READ_TILE4  = 8,
            L1_READ_TILE5  = 9,
            L1_READ_TILE6  = 10,
            L1_READ_TILE7  = 11,
            L1_READ_TILE8  = 12,
            L1_EXE1        = 13,
            L1_EXE2        = 14,
            L1_MX_PL1      = 15,
            L1_MX_PL2      = 16,
            L1_WRITE_TEMP  = 17;
            
  //==================== Layer 2 =======================================================
  parameter L2_RST        = 18,
            L2_RD_BRTCH1  = 19,
            L2_RD_BRTCH2  = 20,
            L2_RD_BRTCH3  = 21,
            L2_READ12     = 22,        
            L2_READ_TILE1 = 23,
            L2_READ_TILE2 = 24,
            L2_READ_TILE5 = 25,
            L2_READ_TILE6 = 26,
            L2_EXE        = 27,
            L2_MX_PL      = 28,
            L2_WRITE_TEMP = 29;

  //==================== Layer 3 =======================================================     
  parameter L3_RST        = 30,
            L3_RD_BRTCH1  = 31,
            L3_RD_BRTCH2  = 32,
            L3_RD_BRTCH3  = 33,
            L3_EXE        = 34,
            L3_DONE       = 35;

  //==================== Layer 4 =======================================================     
  parameter L4_RST        = 36,
            L4_RD_BRTCH1  = 37,
            L4_EXE        = 38,
            L4_SUM        = 39,
            L4_OUT        = 40;
  
  //==================== Layer 5 =======================================================     
  parameter L5_RST        = 41,
            L5_RD_BRTCH1  = 42,
            L5_RD_BRTCH2  = 43,
            L5_EXE        = 44,
            L5_SUM        = 45,
            L5_OUT        = 46,
            DONE          = 47;
            
  // next state logic
  /*
  READ TILE:   1  2  3  4 
               5  6  7  8 

  order: 1 2 5 6 -> 3 4 7 8 
  */  

  always @(*) begin
    case (state)
    //======================= Layer 1 ===========================================================================================================
      IDLE:          n_state = (start) ? L1_RD_BRTCH1 : IDLE;
      L1_RD_BRTCH1:  n_state = (counter == 12) ? L1_RD_BRTCH2 : L1_RD_BRTCH1; // 0 ~ 12
      L1_RD_BRTCH2:  n_state = (counter == 37) ? L1_READ_TILE1 : L1_RD_BRTCH2; // 0 ~ 50 
      L1_RD_BRTCH3:  n_state = (counter == 12) ? L1_READ_TILE1 : L1_RD_BRTCH3;
      L1_READ24:     n_state = (counter == 6)  ? L1_READ_TILE1 : L1_READ24;  // repeat 6 times -> L1_RD_BRTCH1
      L1_READ_TILE1: n_state = L1_READ_TILE2;
      L1_READ_TILE2: n_state = L1_READ_TILE5;
      L1_READ_TILE3: n_state = L1_READ_TILE4;
      L1_READ_TILE4: n_state = L1_READ_TILE7;
      L1_READ_TILE5: n_state = L1_READ_TILE6;
      L1_READ_TILE6: n_state = L1_EXE1;
      L1_READ_TILE7: n_state = L1_READ_TILE8; 
      L1_READ_TILE8: n_state = L1_EXE2;
      L1_EXE1:       n_state = (counter == 3) ? L1_MX_PL1 : L1_EXE1;
      L1_EXE2:       n_state = (counter == 3) ? L1_MX_PL2 : L1_EXE2;
      L1_MX_PL1:     n_state = (counter == 5) ? L1_READ_TILE3 : L1_MX_PL1;  // repeat 6 times -> L1_RD_BRTCH1
      L1_MX_PL2:     n_state = (counter == 5) ? L1_WRITE_TEMP : L1_MX_PL2;
      L1_WRITE_TEMP: n_state = (BRAM_IF2_ADDR_temp == 293) ? L2_RST : ((counter == 2) ? ((cnt_rd_new == 6) ? L1_RD_BRTCH3 : L1_READ24) : L1_WRITE_TEMP); // 6 * 2 = 4 * 3
     
    //======================= Layer 2 ===========================================================================================================
      L2_RST:        n_state = L2_RD_BRTCH1;//(start) ? L2_RD_BRTCH1 : L2_RST;
      L2_RD_BRTCH1:  n_state = (counter == 36) ? L2_RD_BRTCH2  : L2_RD_BRTCH1; // 0 ~ 36 ifmp & weight
      L2_RD_BRTCH2:  n_state = (counter == 13) ? L2_READ_TILE1 : L2_RD_BRTCH2; // 0 ~ 50 weight
      L2_RD_BRTCH3:  n_state = (counter == 36) ? L2_READ_TILE1 : L2_RD_BRTCH3; // ifmp
      L2_READ12:     n_state = (counter == 12) ? L2_READ_TILE1 : L2_READ12;
      L2_READ_TILE1: n_state = L2_READ_TILE2;
      L2_READ_TILE2: n_state = L2_READ_TILE5;
      L2_READ_TILE5: n_state = L2_READ_TILE6;
      L2_READ_TILE6: n_state = L2_EXE;
      L2_EXE:        n_state = (counter == 3) ? ((channel_cnt == 5) ? L2_MX_PL : ((psum_temp_indx == 99) ? L2_RD_BRTCH1 : ((cnt_rd_new == 4) ? L2_RD_BRTCH3 : L2_READ12))) : L2_EXE; // rd12 repeats 4 times
      L2_MX_PL:      n_state = (counter == 7) ? L2_WRITE_TEMP : L2_MX_PL;
      L2_WRITE_TEMP: n_state = (L2_BRAM_IF1_ADDR_temp == 99) ? L3_RST : ((counter == 1) ? ((psum_temp_indx == 0) ? L2_RD_BRTCH1 : ((cnt_rd_new == 4) ? L2_RD_BRTCH3 : L2_READ12)) : L2_WRITE_TEMP); // 8 = 4 * 2 // change condition

      //======================= Layer 3 ===========================================================================================================
      L3_RST:        n_state = L3_RD_BRTCH1;
      L3_RD_BRTCH1:  n_state = (counter == 25) ? L3_RD_BRTCH2  : L3_RD_BRTCH1; // weight + input
      L3_RD_BRTCH2:  n_state = (counter == 24) ? L3_EXE : L3_RD_BRTCH2; // weight 
      L3_RD_BRTCH3:  n_state = (counter == 50) ? L3_EXE : L3_RD_BRTCH3; // weight 
      L3_EXE:        n_state = (counter == 2)  ? ((psum_temp_indx == 14) ? ((channel_cnt == 15) ? L3_DONE : L3_RD_BRTCH1) : L3_RD_BRTCH3) : L3_EXE;
      L3_DONE:       n_state = L4_RST;

      //======================= Layer 4 ===========================================================================================================
      L4_RST:        n_state = L4_RD_BRTCH1;
      L4_RD_BRTCH1:  n_state = (counter == 30) ? L4_EXE : L4_RD_BRTCH1;
      L4_EXE:        n_state = (counter == 2) ? L4_SUM : L4_EXE;
      L4_SUM:        n_state = L4_OUT;
      L4_OUT:        n_state = (psum_temp_indx == 99) ? L5_RST : L4_RD_BRTCH1;
              
      //======================= Layer 5 ===========================================================================================================
      L5_RST:        n_state = L5_RD_BRTCH1;
      L5_RD_BRTCH1:  n_state = (counter == 21) ? L5_RD_BRTCH2 : L5_RD_BRTCH1;
      L5_RD_BRTCH2:  n_state = (counter == 21) ? L5_EXE : L5_RD_BRTCH2;
      L5_EXE:        n_state = (counter == 2)  ? L5_SUM : L5_EXE;
      L5_SUM:        n_state = L5_OUT;
      L5_OUT:        n_state = (psum_temp_indx == 46) ? DONE : L5_RD_BRTCH1; // mode = 1: number, mode = 0: letter
      DONE:          n_state = (ready) ? IDLE : DONE;

      default:       n_state = IDLE;
    endcase
  end

  always @(posedge clk, posedge rst) begin
    if(rst) state <= IDLE;
    else state <= n_state;
  end
  
  // layer 
  always @(*) begin
    case (state)
      //================================== Layer 1 ==================================================================
      L1_RD_BRTCH1, L1_RD_BRTCH2, L1_RD_BRTCH3, L1_READ24, L1_READ_TILE1, L1_READ_TILE2, L1_READ_TILE3, 
      L1_READ_TILE4, L1_READ_TILE5, L1_READ_TILE6, L1_READ_TILE7, L1_READ_TILE8, L1_EXE1, L1_EXE2, L1_MX_PL1, 
      L1_MX_PL2, L1_WRITE_TEMP: layer = 1;

      //================================== Layer 2 ==================================================================
      L2_RST, L2_RD_BRTCH1, L2_RD_BRTCH2, L2_RD_BRTCH3, L2_READ12, L2_READ_TILE1, L2_READ_TILE2, L2_READ_TILE5, 
      L2_READ_TILE6, L2_EXE, L2_MX_PL, L2_WRITE_TEMP: layer = 2;

      //================================== Layer 3 ==================================================================
      L3_RST, L3_RD_BRTCH1, L3_RD_BRTCH2, L3_RD_BRTCH3, L3_EXE, L3_DONE: layer = 3;

      //================================== Layer 4 ==================================================================
      L4_RST, L4_RD_BRTCH1, L4_EXE, L4_SUM, L4_OUT: layer = 4;

      //================================== Layer 5 ==================================================================
      L5_RST, L5_RD_BRTCH1, L5_RD_BRTCH2, L5_EXE, L5_SUM, L5_OUT: layer = 5;
      
      default: layer = 0;
    endcase
  end

  // =========================== address calculate begin =============================================================================
  always @(*) begin // for conv1/conv3 input & conv2 output
    if(layer == 1) BRAM_IF1_ADDR = L1_BRAM_IF1_ADDR_temp << 2;      // input addr
    else if(layer == 2) BRAM_IF1_ADDR = L2_BRAM_IF1_ADDR_temp << 2; // output addr
    else if(layer == 3) BRAM_IF1_ADDR = {(L3_BRAM_IF1_ADDR_temp >> 2), 2'b0}; // input addr
    else BRAM_IF1_ADDR = 0;
  end

  assign BRAM_W1_ADDR = BRAM_W1_ADDR_temp << 2;
  assign BRAM_W2_ADDR = BRAM_W2_ADDR_temp << 2;
  assign BRAM_W3_ADDR = BRAM_W3_ADDR_temp << 2;
  assign BRAM_W4_ADDR = BRAM_W4_ADDR_temp << 2;
  assign BRAM_W5_ADDR = BRAM_W5_ADDR_temp << 2;
  assign result = soft_max_indx;

  always @(*) begin
    if(layer == 1) BRAM_IF2_ADDR = BRAM_IF2_ADDR_temp << 2;
    else if(layer == 2) BRAM_IF2_ADDR = {(L2_bram_IF2_addr >> 2), 2'b0}; // * 4 / 4
    else BRAM_IF2_ADDR = 0;
  end

  assign L1_BRAM_IF1_ADDR_temp = base_addr_r + base_addr_c + {y, x}; // IF1: for conv1/conv3/fc2 input
  assign L3_BRAM_IF1_ADDR_temp = (L3_ifmp_indx << 4) + channel_cnt;  // # of pixel in this channel - 1 : L3_ifmp_indx;
  assign L3_ifmp_indx = counter;
  assign L2_ifmp_indx = (base_addr_r + base_addr_c) + ((y << 3) + (y << 2)) + ((y << 1) + x); // 14y + x
  assign L2_bram_IF2_addr = (L2_ifmp_indx << 2) + (L2_ifmp_indx << 1) + channel_cnt; // # of pixel in this channel - 1 : L2_ifmp_indx;

  // BRAM_IF2_ADDR (Get data READY in mxpl state) // IF2: for conv2/fc1 input
  always @(posedge clk or posedge rst) begin
    if(rst) BRAM_IF2_ADDR_temp <= 0;
    else begin
      if(state == IDLE) BRAM_IF2_ADDR_temp <= 0;
      else if(state == L1_WRITE_TEMP) BRAM_IF2_ADDR_temp <= BRAM_IF2_ADDR_temp + 1;
    end
  end

  // BRAM_IF1_ADDR
  // x
  always @(posedge clk or posedge rst) begin
    if(rst) x <= 0;
    else begin
      if(state == L1_RD_BRTCH1 || state == L1_RD_BRTCH3 || state == L2_READ12) begin
        if(x == 1) x <= 0;
        else x <= x + 1;
      end
      else if(state == L1_READ_TILE1 || state == L2_READ_TILE1 || state == IDLE) x <= 0;
      else if(state == L2_RD_BRTCH1 || state == L2_RD_BRTCH3) begin
        if(x == 5) x <= 0;
        else x <= x + 1;
      end
    end
  end

  //y
  always @(posedge clk or posedge rst) begin
    if(rst) y <= 0;
    else begin
      if(((state == L1_RD_BRTCH1 || state == L1_RD_BRTCH3) && x == 1) || state == L1_READ24 || (state == L2_READ12 && x == 1) || ((state == L2_RD_BRTCH1 || state == L2_RD_BRTCH3) && x == 5)) 
        y <= y + 1;
      else if(state == L1_READ_TILE1 || state == L2_READ_TILE1 || state == IDLE) y <= 0;
    end
  end

  always @(posedge clk or posedge rst) begin
    if(rst) base_addr_r <= 0;
    else begin
      if(state == L1_READ_TILE1) base_addr_r <= base_addr_r + 1;
      else if(n_state == L1_READ24 && cnt_rd_new == 0) base_addr_r <= 2; // L1_READ24 first time
      else if(state == L1_RD_BRTCH1 || state == L1_RD_BRTCH3 || state == L2_RST || base_addr_r == 14 || state == IDLE) base_addr_r <= 0; 
      else if(state == L2_READ_TILE1) base_addr_r <= base_addr_r + 2;
      else if(n_state == L2_READ12 && cnt_rd_new == 0) base_addr_r <= 6;
    end
  end

  always @(posedge clk or posedge rst) begin
    if(rst) base_addr_c <= 0;
    else begin
      if(state == L1_READ24 && cnt_rd_new == 6 && counter == 5) base_addr_c <= base_addr_c + 16;
      else if(state == L2_RST || base_addr_c == 140 || state == IDLE) base_addr_c <= 0; 
      else if(state == L2_READ12 && cnt_rd_new == 4 && counter == 11) base_addr_c <= base_addr_c + 28;
    end
  end

  // BRAM_W1_ADDR
  always @(posedge clk or posedge rst) begin
    if(rst) BRAM_W1_ADDR_temp <= 0;
    else begin
      if(state == IDLE) BRAM_W1_ADDR_temp <= 0;
      else if(state == L1_RD_BRTCH1 || state == L1_RD_BRTCH2) BRAM_W1_ADDR_temp <= BRAM_W1_ADDR_temp + 1;
    end
  end
  
  // BRAM_W2_ADDR 
  always @(posedge clk or posedge rst) begin
    if(rst) BRAM_W2_ADDR_temp <= 0;
    else begin
      if(state == IDLE) BRAM_W2_ADDR_temp <= 0;
      else if(state == L2_RD_BRTCH2 && counter == 13) BRAM_W2_ADDR_temp <= BRAM_W2_ADDR_temp + 50; 
      else if(state == L2_RD_BRTCH1 || state == L2_RD_BRTCH2) BRAM_W2_ADDR_temp <= BRAM_W2_ADDR_temp + 1;
      else if(state == L2_WRITE_TEMP && n_state == L2_RD_BRTCH1) BRAM_W2_ADDR_temp <= 50;
    end
  end

  always @(posedge clk or posedge rst) begin
    if(rst) BRAM_W3_ADDR_temp <= 0;
    else begin
      if(state == IDLE) BRAM_W3_ADDR_temp <= 0;
      else if(state == L3_RD_BRTCH1 || (state == L3_RD_BRTCH2 && counter <= 23) || (state == L3_RD_BRTCH3 && counter <= 49)) BRAM_W3_ADDR_temp <= BRAM_W3_ADDR_temp + 1;
    end
  end

  always @(posedge clk or posedge rst) begin
    if(rst) BRAM_W4_ADDR_temp <= 0;
    else begin
      if(state == IDLE) BRAM_W4_ADDR_temp <= 0;
      else if(state == L4_RD_BRTCH1 && counter <= 29) BRAM_W4_ADDR_temp <= BRAM_W4_ADDR_temp + 1;
    end
  end

  always @(posedge clk or posedge rst) begin
    if(rst) BRAM_W5_ADDR_temp <= 0;
    else begin
      if(state == IDLE) BRAM_W5_ADDR_temp <= 0;
      else if((state == L5_RD_BRTCH1 || state == L5_RD_BRTCH2) && counter <= 20) BRAM_W5_ADDR_temp <= BRAM_W5_ADDR_temp + 1;
    end
  end  

  always @(posedge clk or posedge rst) begin
    if(rst) L2_BRAM_IF1_ADDR_temp <= 0;
    else begin
      if(state == IDLE) L2_BRAM_IF1_ADDR_temp <= 0;
      else if(state == L2_WRITE_TEMP) begin
        if(counter == 0) L2_BRAM_IF1_ADDR_temp <= L2_BRAM_IF1_ADDR_temp + 1;
        else begin
          if(psum_temp_indx == 0) L2_BRAM_IF1_ADDR_temp <= 2;
          else L2_BRAM_IF1_ADDR_temp <= L2_BRAM_IF1_ADDR_temp + 3;
        end 
      end
    end
  end
  // =========================== address calculate end ===============================================================================

  // ============================= enable signal ===============================================================================================================
  assign done = (state == DONE);
  assign relu_en = (layer == 1 || (layer == 2 && channel_cnt == 5) || (layer == 3 && channel_cnt == 15 && !(counter == 0 && state == L3_RD_BRTCH1))) ? 1 : 0;
  assign quan_en = (layer == 1 || (layer == 2 && channel_cnt == 5) || (layer == 3 && channel_cnt == 15 && !(counter == 0 && state == L3_RD_BRTCH1))) ? 1 : 0;

  assign BRAM_W1_EN  = 1;
  assign BRAM_W2_EN  = 1;
  assign BRAM_W3_EN  = 1;
  assign BRAM_W4_EN  = 1;
  assign BRAM_W5_EN  = 1;
  assign BRAM_IF1_EN = 1;
  assign BRAM_IF2_EN = 1;

  assign BRAM_W1_WE  = 4'b0000;
  assign BRAM_W2_WE  = 4'b0000;
  assign BRAM_W3_WE  = 4'b0000;
  assign BRAM_W4_WE  = 4'b0000;
  assign BRAM_W5_WE  = 4'b0000;
  assign BRAM_IF1_WE = (state == L2_WRITE_TEMP) ? 4'b1111 : 4'b0000;
  assign BRAM_IF2_WE = (state == L1_WRITE_TEMP) ? 4'b1111 : 4'b0000;

  assign shift_sram_en = (state == L1_EXE1 || state == L1_EXE2 || (channel_cnt == 5 && state == L2_EXE)); // pipeline O

  assign sft_mx_pl_reg_en = (state == L1_MX_PL1 || state == L1_MX_PL2 || state == L2_MX_PL); 
  // ================================== enable signal end =====================================================================================================================


  // ============================================ counter =========================================================================================================
  always @(posedge clk or posedge rst) begin
    if(rst) cnt_rd_new <= 0; // for conv1: RD24, for conv2: RD12
    else begin
      if((state == L1_READ24 && counter == 1) || (state == L2_READ12 && counter == 1)) cnt_rd_new <= cnt_rd_new + 1;
      else if(state == L1_RD_BRTCH3 || state == L2_RD_BRTCH1 || state == L2_RD_BRTCH3 || state == IDLE) cnt_rd_new <= 0;
    end
  end

  assign L1_counter_flag = (state == L1_RD_BRTCH1 && counter <= 11) || (state == L1_RD_BRTCH2 && counter <= 36) || (state == L1_RD_BRTCH3 && counter <= 11) ||
                           (state == L1_READ24 && counter <= 5) || ((state == L1_MX_PL1 || state == L1_MX_PL2) && counter <= 4) ||
                           (state == L1_WRITE_TEMP && counter <= 1) || ((state == L1_EXE1 || state == L1_EXE2) && counter <= 2);
                           
  assign L2_counter_flag = (state == L2_RD_BRTCH1 && counter <= 35) || (state == L2_RD_BRTCH2 && counter <= 12) || (state == L2_RD_BRTCH3 && counter <= 35) ||
                           (state == L2_READ12 && counter <= 11) || (state == L2_MX_PL && counter <= 6) ||
                           (state == L2_EXE && counter <= 2) || (state == L2_WRITE_TEMP && counter <= 0);
  
  assign L3_counter_flag = (state == L3_RD_BRTCH1 && counter <= 24) || (state == L3_RD_BRTCH2 && counter <= 23) || (state == L3_RD_BRTCH3 && counter <= 49) || 
                           (state == L3_EXE && counter <= 1);
                           
  assign L4_counter_flag = (state == L4_RD_BRTCH1 && counter <= 29) || (state == L4_EXE && counter <= 1);
  
  assign L5_counter_flag = (state == L5_RD_BRTCH1 && counter <= 20) || (state == L5_RD_BRTCH2 && counter <= 20) || (state == L5_EXE && counter <= 1);

  always @(posedge clk or posedge rst) begin
    if(rst) counter <= 0;
    else begin
      if(L1_counter_flag || L2_counter_flag || L3_counter_flag || L4_counter_flag || L5_counter_flag) counter <= counter + 1;
      else counter <= 0; 
    end
  end

  always @(posedge clk or posedge rst) begin
    if(rst) channel_cnt <= 0;
    else begin
      if((state == L2_EXE && n_state == L2_RD_BRTCH1) || (state == L3_EXE && n_state == L3_RD_BRTCH1)) channel_cnt <= channel_cnt + 1;
      else if((state == L2_WRITE_TEMP && n_state == L2_RD_BRTCH1) || state == L3_RST || state == IDLE) channel_cnt <= 0;
    end
  end
  // ============================================== counter end =====================================================================================================
  
  // Layer1 & Layer2 input bits selection
  always @(posedge clk or posedge rst) begin
    if(rst) bits_select_temp <= 0;
    else begin
      if(layer == 2) bits_select_temp <= L2_bram_IF2_addr[1:0];
      else if(layer == 3) bits_select_temp <= L3_BRAM_IF1_ADDR_temp[1:0];
    end 
  end

  always @(*) begin // bits_select: choosing the 8 bits data we want from bram dout (32 bits)
    case (bits_select_temp[1:0])
      2'b00: bits_select = 31;
      2'b01: bits_select = 23;
      2'b10: bits_select = 15;
      2'b11: bits_select = 7;
      default: bits_select = 0;
    endcase
  end
  
  // ========================== i_cache/w_cache ================================================================================================
  always @(posedge clk or posedge rst) begin
    if(rst) for(i = 0; i < 48; i=i+1) i_cache[i] <= 0;
    else begin
      if(state == L1_READ24) begin
        if(counter == 0) begin
          for(i = 0; i < 41; i=i+8) i_cache[i] <= i_cache[i+4];
          for(i = 1; i < 42; i=i+8) i_cache[i] <= i_cache[i+4];
          for(i = 2; i < 43; i=i+8) i_cache[i] <= i_cache[i+4];
          for(i = 3; i < 44; i=i+8) i_cache[i] <= i_cache[i+4];
        end
        else if(counter == 1) {i_cache[4],  i_cache[5],  i_cache[6],  i_cache[7]}  <= BRAM_IF1_DOUT;
        else if(counter == 2) {i_cache[12], i_cache[13], i_cache[14], i_cache[15]} <= BRAM_IF1_DOUT;
        else if(counter == 3) {i_cache[20], i_cache[21], i_cache[22], i_cache[23]} <= BRAM_IF1_DOUT;
        else if(counter == 4) {i_cache[28], i_cache[29], i_cache[30], i_cache[31]} <= BRAM_IF1_DOUT;
        else if(counter == 5) {i_cache[36], i_cache[37], i_cache[38], i_cache[39]} <= BRAM_IF1_DOUT;
        else if(counter == 6) {i_cache[44], i_cache[45], i_cache[46], i_cache[47]} <= BRAM_IF1_DOUT;                             
      end 
      else if((state == L1_RD_BRTCH1 || state == L1_RD_BRTCH3) && counter != 0) 
        {i_cache[icache_indx], i_cache[icache_indx+1], i_cache[icache_indx+2], i_cache[icache_indx+3]} <= BRAM_IF1_DOUT; // 12 cycle 
      else if(state == L2_READ12) begin // 0 ~ 12
        if(counter == 0) begin
          for(i = 0; i < 41; i=i+8) i_cache[i] <= i_cache[i+2];
          for(i = 1; i < 42; i=i+8) i_cache[i] <= i_cache[i+2];
          for(i = 2; i < 43; i=i+8) i_cache[i] <= i_cache[i+2];
          for(i = 3; i < 44; i=i+8) i_cache[i] <= i_cache[i+2];
        end
        else i_cache[icache_indx] <= BRAM_IF2_DOUT[bits_select-:8];
      end
      else if((state == L2_RD_BRTCH1 || L2_RD_BRTCH3) && counter != 0)
        i_cache[icache_indx] <= BRAM_IF2_DOUT[bits_select-:8];
    end
  end

  // icache_indx
  always @(posedge clk or posedge rst) begin
    if(rst) icache_indx <= 0;
    else begin
      if((state == L1_RD_BRTCH1 || state == L1_RD_BRTCH3) && counter != 0) icache_indx <= icache_indx + 4;
      else if(state == L1_READ24) begin
        if(counter == 0) icache_indx <= 4;
        else icache_indx <= icache_indx + 8;
      end
      else if((state == L2_RD_BRTCH1 || state == L2_RD_BRTCH3) && counter != 0) begin
        if(icache_indx[2:0] == 3'b101) icache_indx <= icache_indx + 3;
        else icache_indx <= icache_indx + 1;
      end
      else if(state == L2_READ12) begin
        if(counter == 0) icache_indx <= 4;
        else if(counter == 1 || counter == 3 || counter == 5 || counter == 7 || counter == 9  || counter == 11) icache_indx <= icache_indx + 1;
        else if(counter == 2 || counter == 4 || counter == 6 || counter == 8 || counter == 10 || counter == 12) icache_indx <= icache_indx + 7;
      end
      else if(state == IDLE || state == L1_WRITE_TEMP || state == L2_RST || ((n_state == L2_RD_BRTCH1 || n_state == L2_RD_BRTCH3) && (state == L2_EXE || state == L2_WRITE_TEMP))) icache_indx <= 0;
    end
  end

  always @(posedge clk or posedge rst) begin
    if(rst) for(i = 0; i < 200; i=i+1) w_cache[i] <= 0; 
    else begin
      if((state == L1_RD_BRTCH1 && counter != 0) || state == L1_RD_BRTCH2) 
        {w_cache[wcache_indx], w_cache[wcache_indx+1], w_cache[wcache_indx+2], w_cache[wcache_indx+3]} <= BRAM_W1_DOUT; // 4 data in 1 row => 50 cycle
      else if((state == L2_RD_BRTCH1 && counter != 0) || state == L2_RD_BRTCH2) 
        {w_cache[wcache_indx], w_cache[wcache_indx+1], w_cache[wcache_indx+2], w_cache[wcache_indx+3]} <= BRAM_W2_DOUT; 
      else if((state == L3_RD_BRTCH1 && counter != 0) || state == L3_RD_BRTCH2 || (state == L3_RD_BRTCH3 && counter != 0)) 
        {w_cache[wcache_indx], w_cache[wcache_indx+1], w_cache[wcache_indx+2], w_cache[wcache_indx+3]} <= BRAM_W3_DOUT;
      else if(state == IDLE || state == L4_RST || state == L5_RST) for(i = 0; i < 200; i=i+1) w_cache[i] <= 0;
      else if(state == L4_RD_BRTCH1 && counter != 0) {w_cache[wcache_indx], w_cache[wcache_indx+1], w_cache[wcache_indx+2], w_cache[wcache_indx+3]} <= BRAM_W4_DOUT; 
      else if((state == L5_RD_BRTCH1 || state == L5_RD_BRTCH2) && counter != 0) {w_cache[wcache_indx], w_cache[wcache_indx+1], w_cache[wcache_indx+2], w_cache[wcache_indx+3]} <= BRAM_W5_DOUT; 
    end
  end

  // wcache_indx
  always @(posedge clk or posedge rst) begin
    if(rst) wcache_indx <= 0;
    else begin
      if(state == L5_RD_BRTCH2 && counter == 0) wcache_indx <= 100;
      else if(((state == L1_RD_BRTCH1 || state == L2_RD_BRTCH1 || state == L3_RD_BRTCH1 || state == L3_RD_BRTCH3 || state == L4_RD_BRTCH1 || state == L5_RD_BRTCH1 || state == L5_RD_BRTCH2) && counter != 0) || 
                state == L1_RD_BRTCH2 || state == L2_RD_BRTCH2 || state == L3_RD_BRTCH2) wcache_indx <= wcache_indx + 4;
      else wcache_indx <= 0;
    end
  end
  // =====================================================================================================================================================================================================


  // ======================================= maxpooling =====================================================================================
  // pe_sram: the output of the PE 
  always @(posedge clk or posedge rst) begin
    if(rst) begin
      for(j = 0; j < 8; j=j+1) begin
        for(i = 0; i < 4; i=i+1) begin
          pe_sram[j][i] <= 0;
        end
      end
    end
    else begin // shift register
      if(shift_sram_en) begin
        for(j = 0; j < 8; j=j+1) pe_sram[j][3] <= pe_out[j];
        for(j = 0; j < 8; j=j+1) begin
          for(i = 3; i > 0; i=i-1) begin
            pe_sram[j][i-1] <= pe_sram[j][i];
          end
        end
      end 
    end
  end
  
  always @(posedge clk or posedge rst) begin
    if(rst) pe_sram_indx_j <= 0;
    else begin
      if(state == L1_MX_PL1 || state == L1_MX_PL2 || state == L2_MX_PL) pe_sram_indx_j <= pe_sram_indx_j + 1;
      else pe_sram_indx_j <= 0; 
    end
  end
  
  // maxpool: compare the number stored in pe_sram
  always @(*) begin // 1 cycle
    temp1     = (pe_sram[pe_sram_indx_j][0] > pe_sram[pe_sram_indx_j][1]) ? pe_sram[pe_sram_indx_j][0] : pe_sram[pe_sram_indx_j][1];
    temp2     = (pe_sram[pe_sram_indx_j][2] > temp1) ? pe_sram[pe_sram_indx_j][2] : temp1;
    mx_pl_out = (pe_sram[pe_sram_indx_j][3] > temp2) ? pe_sram[pe_sram_indx_j][3] : temp2;
  end
  
  // max pool output
  always @(posedge clk or posedge rst) begin
    if(rst) for(i = 0; i < 8; i=i+1) mx_pl_reg[i] <= 0;
    else begin
      if(sft_mx_pl_reg_en) begin
        if(layer == 1) begin     // index used: 0 ~ 11 
          mx_pl_reg[11] <= mx_pl_out;
          for(i = 11; i >= 1; i=i-1) mx_pl_reg[i-1] <= mx_pl_reg[i]; 
        end
        else if(layer == 2) begin // index used: 0 ~ 7 
          mx_pl_reg[7] <= mx_pl_out;
          for(i = 7; i >= 1; i=i-1) mx_pl_reg[i-1] <= mx_pl_reg[i];           
        end
      end
    end
  end
  
  always @(posedge clk or posedge rst) begin
    if(rst) mx_pl_reg_indx <= 0;
    else begin
      if(state == L1_WRITE_TEMP || state == L2_WRITE_TEMP) mx_pl_reg_indx <= mx_pl_reg_indx + 4;
      else mx_pl_reg_indx <= 0;
    end
  end
  // ======================================================================================================================================================


  // ============================================== psum control =========================================================================================
  // ============================= pipeline X
  always @(posedge clk or posedge rst) begin
    if(rst) for(i = 0; i < 8; i=i+1) psum_in[i] <= 0;
    else begin 
      if(state == IDLE || layer == 1 || layer == 4 || layer == 5 || state == L3_RST) for(i = 0; i < 8; i=i+1) psum_in[i] <= 0;
      else if(state == L2_READ_TILE2 || state == L2_READ_TILE5 || state == L2_READ_TILE6 || (state == L2_EXE && counter == 0)) for(i = 0; i < 8; i=i+1) psum_in[i] <= psum_temp[i][psum_in_indx];
      else if(state == L3_EXE && counter == 0 && channel_cnt != 0) for(i = 0; i < 8; i=i+1) psum_in[i] <= psum_temp[i][psum_in_indx];
    end
  end
/*
 1 2  =>  1 2 5 6
 5 6 
*/
  always @(posedge clk or posedge rst) begin
    if(rst) psum_in_indx <= 0;
    else begin
      if(state == IDLE) psum_in_indx <= 0;
      else if(state == L2_READ_TILE2 || state == L2_READ_TILE5 || state == L2_READ_TILE6 || (state == L2_EXE && counter == 0)) begin // delay 1 cycle
        if(psum_in_indx == 99) psum_in_indx <= 0;
        else psum_in_indx <= psum_in_indx + 1;
      end
      else if(state == L3_EXE && counter == 0 && channel_cnt != 0) begin
        if(psum_in_indx == 14) psum_in_indx <= 0;
        else psum_in_indx <= psum_in_indx + 1;
      end
    end
  end
  // ============================= pipeline X
  // psum_temp
  // ============================= pipeline O
  always @(posedge clk or posedge rst) begin
    if(rst) psum_temp_indx <= 0;
    else begin
      if(state == L2_EXE) begin
        if(psum_temp_indx == 99) psum_temp_indx <= 0;
        else psum_temp_indx <= psum_temp_indx + 1;
      end
      else if(state == IDLE || state == L3_RST || state == L5_RST) psum_temp_indx <= 0;
      else if(counter == 0 && ((state == L3_RD_BRTCH1 && channel_cnt != 0) || state == L3_RD_BRTCH3)) begin
        if(psum_temp_indx == 14) psum_temp_indx <= 0;
        else psum_temp_indx <= psum_temp_indx + 1;
      end
      else if(state == L4_RST) psum_temp_indx <= 16;
      else if(state == L4_OUT) psum_temp_indx <= psum_temp_indx + 1;
      else if(state == L5_OUT) psum_temp_indx <= psum_temp_indx + 2;
    end
  end

  always @(posedge clk or posedge rst) begin
    if(rst) begin
      for(i = 0; i < 8; i=i+1) begin
        for(j = 0; j < 100; j=j+1)
          psum_temp[i][j] <= 0;
      end
    end
    else begin
      if(state == L3_RST || state == IDLE) begin
        for(i = 0; i < 8; i=i+1) begin
          for(j = 0; j < 100; j=j+1)
            psum_temp[i][j] <= 0;
        end
      end
      else if(state == L2_EXE || (counter == 0 && ((state == L3_RD_BRTCH1 && channel_cnt != 0) || state == L3_RD_BRTCH3)) || state == L3_DONE) 
        for(i = 0; i < 8; i=i+1) psum_temp[i][psum_temp_indx] <= pe_out[i];
      else if(state == L4_OUT) psum_temp[0][psum_temp_indx] <= pe_out_sum_a_quan;
      else if(state == L5_OUT) begin
        psum_temp[1][psum_temp_indx] <= pe_out_sum_a_relu;
        psum_temp[1][psum_temp_indx+1] <= pe_out_sum_b_relu;
      end
    end
  end
  // ============================= pipeline O
  // =====================================================================================================================================================

  
  // ========================================== Bram Din ======================================================================================== 
  // BRAM_IF2_DIN: for conv1/conv3/fc2 output
  assign BRAM_IF2_DIN = {mx_pl_reg[mx_pl_reg_indx], mx_pl_reg[mx_pl_reg_indx+1], mx_pl_reg[mx_pl_reg_indx+2], mx_pl_reg[mx_pl_reg_indx+3]};
  
  // BRAM_IF1_DIN: for conv2/fc1 output
  assign BRAM_IF1_DIN = {mx_pl_reg[mx_pl_reg_indx], mx_pl_reg[mx_pl_reg_indx+1], mx_pl_reg[mx_pl_reg_indx+2], mx_pl_reg[mx_pl_reg_indx+3]};
  // ==============================================================================================================================================
  


  
  // ============================= fc1/fc2 sum, relu and quantize ======================================================================
  always @(posedge clk or posedge rst) begin
    if(rst) pe_out_sum_a <= 0;
    else begin
      if(state == L4_SUM) pe_out_sum_a <= (pe_out[0] + pe_out[1]) + (pe_out[2] + pe_out[3] + pe_out[4]);
      else if(state == L5_SUM) pe_out_sum_a <= (pe_out[0] + pe_out[1]) + (pe_out[2] + pe_out[3]);
    end
  end

  always @(posedge clk or posedge rst) begin
    if(rst) pe_out_sum_b <= 0;
    else begin
      if(state == L5_SUM) pe_out_sum_b <= (pe_out[4] + pe_out[5]) + (pe_out[6] + pe_out[7]);
    end
  end
  assign pe_out_sum_a_relu = (pe_out_sum_a < 0) ? 0 : pe_out_sum_a;
  assign pe_out_sum_b_relu = (pe_out_sum_b < 0) ? 0 : pe_out_sum_b;

  // assign pe_out_sum_a_quan = (mode) ? ((|pe_out_sum_a_relu[31:15]) ? 255 : ((&pe_out_sum_a_relu[14:7]) ? pe_out_sum_a_relu[14:7] : (pe_out_sum_a_relu[14:7] + pe_out_sum_a_relu[6]))) :
  //                                     ((pe_out_sum_a[31]) ? ((pe_out_sum_a[14:7] == 8'b10000000) ? 8'b10000000 : ((&pe_out_sum_a[30:14]) ? (pe_out_sum_a[14:7] + pe_out_sum_a[6]) : 8'b10000000)) : 
  //                                                           ((pe_out_sum_a[14:7] == 8'b01111111) ? 8'b01111111 : ((|pe_out_sum_a[30:14]) ? 8'b01111111 : (pe_out_sum_a[14:7] + pe_out_sum_a[6]))));
  assign pe_out_sum_a_quan = ((|pe_out_sum_a_relu[31:15]) ? 255 : ((&pe_out_sum_a_relu[14:7]) ? pe_out_sum_a_relu[14:7] : (pe_out_sum_a_relu[14:7] + pe_out_sum_a_relu[6])));                     
  // ===================================================================================================================================================================
  
  // ===================================================== softmax ====================================================================================
  always @(posedge clk or posedge rst) begin
    if(rst) soft_max_indx <= 0;
    else begin
      if(state == L5_OUT) begin
        if(psum_temp_indx == 46) soft_max_indx <= (soft_max_temp > pe_out_sum_a_relu) ? soft_max_indx : psum_temp_indx;
        else soft_max_indx <= (soft_max_temp > pe_out_sum_a_relu) ? ((soft_max_temp > pe_out_sum_b_relu) ? soft_max_indx : psum_temp_indx + 1)
                                                                  : ((pe_out_sum_a_relu > pe_out_sum_b_relu) ? psum_temp_indx : psum_temp_indx + 1);
      end
    end
  end

  always @(posedge clk or posedge rst) begin
    if(rst) soft_max_temp <= 0;
    else begin
      if(state == IDLE) soft_max_temp <= 0;
      else if(state == L5_OUT) begin
        if(psum_temp_indx == 46) soft_max_temp <= (soft_max_temp > pe_out_sum_a_relu) ? soft_max_temp : pe_out_sum_a_relu;
        else soft_max_temp <= (soft_max_temp > pe_out_sum_a_relu) ? ((soft_max_temp > pe_out_sum_b_relu) ? soft_max_temp : pe_out_sum_b_relu)
                                                                  : ((pe_out_sum_a_relu > pe_out_sum_b_relu) ? pe_out_sum_a_relu : pe_out_sum_b_relu);
      end
    end
  end
  // ==========================================================================================================================================================
  
  /*        
    o o o o o o o o   0  1  2  3  4  5  6  7
    o o o o o o o o   8  9 10 11 12 13 14 15 
    o o o o o o o o  16 17 18 19 20 21 22 23 
    o o o o o o o o  24 25 26 27 28 29 30 31
    o o o o o o o o  32 33 34 35 36 37 38 39
    o o o o o o o o  40 41 42 43 44 45 46 47
  */

  // pe_pre_in: choose the 5 * 5 data from i_cache, whose size is 6 * 8 
  always @(posedge clk or posedge rst) begin
    if(rst) for(i = 0; i < 25; i=i+1) pe_pre_in[i] <= 0;
    else begin
      case(state)
        L1_READ_TILE1, L2_READ_TILE1: begin
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j];
            end
          end
        end
        L1_READ_TILE2, L2_READ_TILE2: begin
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+1];
            end
          end
        end
        L1_READ_TILE3: begin
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+2];
            end
          end        
        end
        L1_READ_TILE4: begin
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+3];
            end
          end
        end
        L1_READ_TILE5, L2_READ_TILE5: begin
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+8];
            end
          end
        end
        L1_READ_TILE6, L2_READ_TILE6: begin
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+9];
            end
          end
        end
        L1_READ_TILE7: begin
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+10];
            end
          end
        end
        L1_READ_TILE8: begin
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              pe_pre_in[i+5*j] <= i_cache[i+8*j+11];
            end
          end
        end
        L3_RD_BRTCH1: pe_pre_in[counter-1] <= BRAM_IF1_DOUT[bits_select-:8];
      endcase
    end
  end
  // make the PE's input data ready
  always @(*) begin
    if(layer == 1 || layer == 2 || layer == 3) begin
      for(j = 0; j < 176; j=j+25) begin
        for(i = 0; i < 25; i=i+1) begin
          pe_in[i+j] = pe_pre_in[i]; 
        end
      end
    end
    else if(layer == 4 && ~(state == L4_RST))begin
      for(j = 0; j < 15; j=j+1) begin
        for(i = 0; i < 8; i=i+1) begin
          pe_in[i+8*j] = psum_temp[i][j]; 
        end
      end 
      for(i = 120; i < 200; i=i+1) pe_in[i] = 0;
    end
    else if(layer == 5 && ~(state == L5_RST)) begin
      for(i = 16; i < 100; i=i+1) begin
        pe_in[i-16] = psum_temp[0][i];
        pe_in[i+84] = psum_temp[0][i];
      end
      for(i = 84; i < 100; i=i+1)  pe_in[i] = 0;
      for(i = 184; i < 200; i=i+1) pe_in[i] = 0;
    end
    else for(i = 0; i < 200; i=i+1) pe_in[i] = 0;
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
                  .psum(psum_in[a]),
                  .relu_en(relu_en),
                  .quan_en(quan_en),
                  .pe_out(pe_out[a])
                );	
    end
	endgenerate
  // ============================================================================================
endmodule