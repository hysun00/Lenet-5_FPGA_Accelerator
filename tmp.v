case(state)
        READ_TILE1: 
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              PE_in[i+5*j] <= i_cache[i+8*j];
            end
          end
          // PE_in[0]  <= i_cache[0];
          // PE_in[1]  <= i_cache[1];
          // PE_in[2]  <= i_cache[2];
          // PE_in[3]  <= i_cache[3];
          // PE_in[4]  <= i_cache[4];

          // PE_in[5]  <= i_cache[8];
          // PE_in[6]  <= i_cache[9];
          // PE_in[7]  <= i_cache[10];
          // PE_in[8]  <= i_cache[11];
          // PE_in[9]  <= i_cache[12];

          // PE_in[10] <= i_cache[16]; 
          // PE_in[11] <= i_cache[17];
          // PE_in[12] <= i_cache[18];
          // PE_in[13] <= i_cache[19];
          // PE_in[14] <= i_cache[20];

          // PE_in[15] <= i_cache[24];
          // PE_in[16] <= i_cache[25];
          // PE_in[17] <= i_cache[26];
          // PE_in[18] <= i_cache[27];
          // PE_in[19] <= i_cache[28];
          
          // PE_in[20] <= i_cache[32];
          // PE_in[21] <= i_cache[33];
          // PE_in[22] <= i_cache[34];
          // PE_in[23] <= i_cache[35];
          // PE_in[24] <= i_cache[36];

        READ_TILE2:
          for(j = 0; j < 5; j=j+1) begin
            for(i = 0; i < 5; i=i+1) begin
              PE_in[i+5*j] <= i_cache[i+8*j];
            end
          end
          // PE_in[0]  <= i_cache[1];
          // PE_in[1]  <= i_cache[2];
          // PE_in[2]  <= i_cache[3];
          // PE_in[3]  <= i_cache[4];
          // PE_in[4]  <= i_cache[5];

          // PE_in[5]  <= i_cache[9];
          // PE_in[6]  <= i_cache[10];
          // PE_in[7]  <= i_cache[11];
          // PE_in[8]  <= i_cache[12];
          // PE_in[9]  <= i_cache[13];

          // PE_in[10] <= i_cache[17]; 
          // PE_in[11] <= i_cache[18];
          // PE_in[12] <= i_cache[19];
          // PE_in[13] <= i_cache[20];
          // PE_in[14] <= i_cache[21];

          // PE_in[15] <= i_cache[25];
          // PE_in[16] <= i_cache[26];
          // PE_in[17] <= i_cache[27];
          // PE_in[18] <= i_cache[28];
          // PE_in[19] <= i_cache[29];

          // PE_in[20] <= i_cache[33];
          // PE_in[21] <= i_cache[34];
          // PE_in[22] <= i_cache[35];
          // PE_in[23] <= i_cache[36];
          // PE_in[24] <= i_cache[37];

        READ_TILE3: 
          PE_in[0]  <= i_cache[2];
          PE_in[1]  <= i_cache[3];
          PE_in[2]  <= i_cache[4];
          PE_in[3]  <= i_cache[5];
          PE_in[4]  <= i_cache[6];

          PE_in[5]  <= i_cache[10];
          PE_in[6]  <= i_cache[11];
          PE_in[7]  <= i_cache[12];
          PE_in[8]  <= i_cache[13];
          PE_in[9]  <= i_cache[14];

          PE_in[10] <= i_cache[18]; 
          PE_in[11] <= i_cache[19];
          PE_in[12] <= i_cache[20];
          PE_in[13] <= i_cache[21];
          PE_in[14] <= i_cache[22];

          PE_in[15] <= i_cache[26];
          PE_in[16] <= i_cache[27];
          PE_in[17] <= i_cache[28];
          PE_in[18] <= i_cache[29];
          PE_in[19] <= i_cache[30];
          
          PE_in[20] <= i_cache[34];
          PE_in[21] <= i_cache[35];
          PE_in[22] <= i_cache[36];
          PE_in[23] <= i_cache[37];
          PE_in[24] <= i_cache[38];

        READ_TILE4: 
          PE_in[0]  <= i_cache[3];
          PE_in[1]  <= i_cache[4];
          PE_in[2]  <= i_cache[5];
          PE_in[3]  <= i_cache[6];
          PE_in[4]  <= i_cache[7];

          PE_in[5]  <= i_cache[11];
          PE_in[6]  <= i_cache[12];
          PE_in[7]  <= i_cache[13];
          PE_in[8]  <= i_cache[14];
          PE_in[9]  <= i_cache[15];

          PE_in[10] <= i_cache[19]; 
          PE_in[11] <= i_cache[20];
          PE_in[12] <= i_cache[21];
          PE_in[13] <= i_cache[22];
          PE_in[14] <= i_cache[23];

          PE_in[15] <= i_cache[27];
          PE_in[16] <= i_cache[28];
          PE_in[17] <= i_cache[29];
          PE_in[18] <= i_cache[30];
          PE_in[19] <= i_cache[31];
          
          PE_in[20] <= i_cache[35];
          PE_in[21] <= i_cache[36];
          PE_in[22] <= i_cache[37];
          PE_in[23] <= i_cache[38];
          PE_in[24] <= i_cache[39];

        READ_TILE5: 
          PE_in[0]  <= i_cache[8];
          PE_in[1]  <= i_cache[9];
          PE_in[2]  <= i_cache[10];
          PE_in[3]  <= i_cache[11];
          PE_in[4]  <= i_cache[12];

          PE_in[5]  <= i_cache[16];
          PE_in[6]  <= i_cache[17];
          PE_in[7]  <= i_cache[18];
          PE_in[8]  <= i_cache[19];
          PE_in[9]  <= i_cache[20];

          PE_in[10] <= i_cache[24]; 
          PE_in[11] <= i_cache[25];
          PE_in[12] <= i_cache[26];
          PE_in[13] <= i_cache[27];
          PE_in[14] <= i_cache[28];

          PE_in[15] <= i_cache[32];
          PE_in[16] <= i_cache[33];
          PE_in[17] <= i_cache[34];
          PE_in[18] <= i_cache[35];
          PE_in[19] <= i_cache[36];
          
          PE_in[20] <= i_cache[40];
          PE_in[21] <= i_cache[41];
          PE_in[22] <= i_cache[42];
          PE_in[23] <= i_cache[43];
          PE_in[24] <= i_cache[44];

        READ_TILE6: 
          PE_in[0]  <= i_cache[9];
          PE_in[1]  <= i_cache[10];
          PE_in[2]  <= i_cache[11];
          PE_in[3]  <= i_cache[12];
          PE_in[4]  <= i_cache[13];

          PE_in[5]  <= i_cache[17];
          PE_in[6]  <= i_cache[18];
          PE_in[7]  <= i_cache[19];
          PE_in[8]  <= i_cache[20];
          PE_in[9]  <= i_cache[21];

          PE_in[10] <= i_cache[25]; 
          PE_in[11] <= i_cache[26];
          PE_in[12] <= i_cache[27];
          PE_in[13] <= i_cache[28];
          PE_in[14] <= i_cache[29];

          PE_in[15] <= i_cache[33];
          PE_in[16] <= i_cache[34];
          PE_in[17] <= i_cache[35];
          PE_in[18] <= i_cache[36];
          PE_in[19] <= i_cache[37];
          
          PE_in[20] <= i_cache[41];
          PE_in[21] <= i_cache[42];
          PE_in[22] <= i_cache[43];
          PE_in[23] <= i_cache[44];
          PE_in[24] <= i_cache[45];

        READ_TILE7: 
          PE_in[0]  <= i_cache[10];
          PE_in[1]  <= i_cache[11];
          PE_in[2]  <= i_cache[12];
          PE_in[3]  <= i_cache[13];
          PE_in[4]  <= i_cache[14];

          PE_in[5]  <= i_cache[18];
          PE_in[6]  <= i_cache[19];
          PE_in[7]  <= i_cache[20];
          PE_in[8]  <= i_cache[21];
          PE_in[9]  <= i_cache[22];

          PE_in[10] <= i_cache[26]; 
          PE_in[11] <= i_cache[27];
          PE_in[12] <= i_cache[28];
          PE_in[13] <= i_cache[29];
          PE_in[14] <= i_cache[30];

          PE_in[15] <= i_cache[34];
          PE_in[16] <= i_cache[35];
          PE_in[17] <= i_cache[36];
          PE_in[18] <= i_cache[37];
          PE_in[19] <= i_cache[38];
          
          PE_in[20] <= i_cache[42];
          PE_in[21] <= i_cache[43];
          PE_in[22] <= i_cache[44];
          PE_in[23] <= i_cache[45];
          PE_in[24] <= i_cache[46];

        READ_TILE8: 
          PE_in[0]  <= i_cache[11];
          PE_in[1]  <= i_cache[12];
          PE_in[2]  <= i_cache[13];
          PE_in[3]  <= i_cache[14];
          PE_in[4]  <= i_cache[15];

          PE_in[5]  <= i_cache[19];
          PE_in[6]  <= i_cache[20];
          PE_in[7]  <= i_cache[21];
          PE_in[8]  <= i_cache[22];
          PE_in[9]  <= i_cache[23];

          PE_in[10] <= i_cache[27]; 
          PE_in[11] <= i_cache[28];
          PE_in[12] <= i_cache[29];
          PE_in[13] <= i_cache[30];
          PE_in[14] <= i_cache[31];

          PE_in[15] <= i_cache[35];
          PE_in[16] <= i_cache[36];
          PE_in[17] <= i_cache[37];
          PE_in[18] <= i_cache[38];
          PE_in[19] <= i_cache[39];
          
          PE_in[20] <= i_cache[43];
          PE_in[21] <= i_cache[44];
          PE_in[22] <= i_cache[45];
          PE_in[23] <= i_cache[46];
          PE_in[24] <= i_cache[47]; 

        READ_TILE9: 
          PE_in[0]  <= i_cache[16];
          PE_in[1]  <= i_cache[17];
          PE_in[2]  <= i_cache[18];
          PE_in[3]  <= i_cache[19];
          PE_in[4]  <= i_cache[20];

          PE_in[5]  <= i_cache[24];
          PE_in[6]  <= i_cache[25];
          PE_in[7]  <= i_cache[26];
          PE_in[8]  <= i_cache[27];
          PE_in[9]  <= i_cache[28];

          PE_in[10] <= i_cache[32]; 
          PE_in[11] <= i_cache[33];
          PE_in[12] <= i_cache[34];
          PE_in[13] <= i_cache[35];
          PE_in[14] <= i_cache[36];

          PE_in[15] <= i_cache[40];
          PE_in[16] <= i_cache[41];
          PE_in[17] <= i_cache[42];
          PE_in[18] <= i_cache[43];
          PE_in[19] <= i_cache[44];
          
          PE_in[20] <= i_cache[48];
          PE_in[21] <= i_cache[49];
          PE_in[22] <= i_cache[50];
          PE_in[23] <= i_cache[51];
          PE_in[24] <= i_cache[52];

        READ_TILE10: 
          PE_in[0]  <= i_cache[17];
          PE_in[1]  <= i_cache[18];
          PE_in[2]  <= i_cache[19];
          PE_in[3]  <= i_cache[20];
          PE_in[4]  <= i_cache[21];

          PE_in[5]  <= i_cache[25];
          PE_in[6]  <= i_cache[26];
          PE_in[7]  <= i_cache[27];
          PE_in[8]  <= i_cache[28];
          PE_in[9]  <= i_cache[29];

          PE_in[10] <= i_cache[33]; 
          PE_in[11] <= i_cache[34];
          PE_in[12] <= i_cache[35];
          PE_in[13] <= i_cache[36];
          PE_in[14] <= i_cache[37];

          PE_in[15] <= i_cache[41];
          PE_in[16] <= i_cache[42];
          PE_in[17] <= i_cache[43];
          PE_in[18] <= i_cache[44];
          PE_in[19] <= i_cache[45];
          
          PE_in[20] <= i_cache[49];
          PE_in[21] <= i_cache[50];
          PE_in[22] <= i_cache[51];
          PE_in[23] <= i_cache[52];
          PE_in[24] <= i_cache[53]; 

        READ_TILE11: 
          PE_in[0]  <= i_cache[18];
          PE_in[1]  <= i_cache[19];
          PE_in[2]  <= i_cache[20];
          PE_in[3]  <= i_cache[21];
          PE_in[4]  <= i_cache[22];

          PE_in[5]  <= i_cache[26];
          PE_in[6]  <= i_cache[27];
          PE_in[7]  <= i_cache[28];
          PE_in[8]  <= i_cache[29];
          PE_in[9]  <= i_cache[30];

          PE_in[10] <= i_cache[34]; 
          PE_in[11] <= i_cache[35];
          PE_in[12] <= i_cache[36];
          PE_in[13] <= i_cache[37];
          PE_in[14] <= i_cache[38];

          PE_in[15] <= i_cache[42];
          PE_in[16] <= i_cache[43];
          PE_in[17] <= i_cache[44];
          PE_in[18] <= i_cache[45];
          PE_in[19] <= i_cache[46];
          
          PE_in[20] <= i_cache[50];
          PE_in[21] <= i_cache[51];
          PE_in[22] <= i_cache[52];
          PE_in[23] <= i_cache[53];
          PE_in[24] <= i_cache[54];   

        READ_TILE12: 
          PE_in[0]  <= i_cache[19];
          PE_in[1]  <= i_cache[20];
          PE_in[2]  <= i_cache[21];
          PE_in[3]  <= i_cache[22];
          PE_in[4]  <= i_cache[23];

          PE_in[5]  <= i_cache[27];
          PE_in[6]  <= i_cache[28];
          PE_in[7]  <= i_cache[29];
          PE_in[8]  <= i_cache[30];
          PE_in[9]  <= i_cache[31];

          PE_in[10] <= i_cache[35]; 
          PE_in[11] <= i_cache[36];
          PE_in[12] <= i_cache[37];
          PE_in[13] <= i_cache[38];
          PE_in[14] <= i_cache[39];

          PE_in[15] <= i_cache[43];
          PE_in[16] <= i_cache[44];
          PE_in[17] <= i_cache[45];
          PE_in[18] <= i_cache[46];
          PE_in[19] <= i_cache[47];
          
          PE_in[20] <= i_cache[51];
          PE_in[21] <= i_cache[52];
          PE_in[22] <= i_cache[53];
          PE_in[23] <= i_cache[54];
          PE_in[24] <= i_cache[55];   

        READ_TILE13: 
          PE_in[0]  <= i_cache[24];
          PE_in[1]  <= i_cache[25];
          PE_in[2]  <= i_cache[26];
          PE_in[3]  <= i_cache[27];
          PE_in[4]  <= i_cache[28];

          PE_in[5]  <= i_cache[32];
          PE_in[6]  <= i_cache[33];
          PE_in[7]  <= i_cache[34];
          PE_in[8]  <= i_cache[35];
          PE_in[9]  <= i_cache[36];

          PE_in[10] <= i_cache[40]; 
          PE_in[11] <= i_cache[41];
          PE_in[12] <= i_cache[42];
          PE_in[13] <= i_cache[43];
          PE_in[14] <= i_cache[44];

          PE_in[15] <= i_cache[48];
          PE_in[16] <= i_cache[49];
          PE_in[17] <= i_cache[50];
          PE_in[18] <= i_cache[51];
          PE_in[19] <= i_cache[52];
          
          PE_in[20] <= i_cache[56];
          PE_in[21] <= i_cache[57];
          PE_in[22] <= i_cache[58];
          PE_in[23] <= i_cache[59];
          PE_in[24] <= i_cache[60]; 

        READ_TILE14: 
          PE_in[0]  <= i_cache[25];
          PE_in[1]  <= i_cache[26];
          PE_in[2]  <= i_cache[27];
          PE_in[3]  <= i_cache[28];
          PE_in[4]  <= i_cache[29];

          PE_in[5]  <= i_cache[33];
          PE_in[6]  <= i_cache[34];
          PE_in[7]  <= i_cache[35];
          PE_in[8]  <= i_cache[36];
          PE_in[9]  <= i_cache[37];

          PE_in[10] <= i_cache[41]; 
          PE_in[11] <= i_cache[42];
          PE_in[12] <= i_cache[43];
          PE_in[13] <= i_cache[44];
          PE_in[14] <= i_cache[45];

          PE_in[15] <= i_cache[49];
          PE_in[16] <= i_cache[50];
          PE_in[17] <= i_cache[51];
          PE_in[18] <= i_cache[52];
          PE_in[19] <= i_cache[53];
          
          PE_in[20] <= i_cache[57];
          PE_in[21] <= i_cache[58];
          PE_in[22] <= i_cache[59];
          PE_in[23] <= i_cache[60];
          PE_in[24] <= i_cache[61];     

        READ_TILE15: 
          PE_in[0]  <= i_cache[26];
          PE_in[1]  <= i_cache[27];
          PE_in[2]  <= i_cache[28];
          PE_in[3]  <= i_cache[29];
          PE_in[4]  <= i_cache[30];

          PE_in[5]  <= i_cache[34];
          PE_in[6]  <= i_cache[35];
          PE_in[7]  <= i_cache[36];
          PE_in[8]  <= i_cache[37];
          PE_in[9]  <= i_cache[38];

          PE_in[10] <= i_cache[42]; 
          PE_in[11] <= i_cache[43];
          PE_in[12] <= i_cache[44];
          PE_in[13] <= i_cache[45];
          PE_in[14] <= i_cache[46];

          PE_in[15] <= i_cache[50];
          PE_in[16] <= i_cache[51];
          PE_in[17] <= i_cache[52];
          PE_in[18] <= i_cache[53];
          PE_in[19] <= i_cache[54];
          
          PE_in[20] <= i_cache[58];
          PE_in[21] <= i_cache[59];
          PE_in[22] <= i_cache[60];
          PE_in[23] <= i_cache[61];
          PE_in[24] <= i_cache[62];   
          
        READ_TILE16: 
          PE_in[0]  <= i_cache[27];
          PE_in[1]  <= i_cache[28];
          PE_in[2]  <= i_cache[29];
          PE_in[3]  <= i_cache[30];
          PE_in[4]  <= i_cache[31];

          PE_in[5]  <= i_cache[35];
          PE_in[6]  <= i_cache[36];
          PE_in[7]  <= i_cache[37];
          PE_in[8]  <= i_cache[38];
          PE_in[9]  <= i_cache[39];

          PE_in[10] <= i_cache[43]; 
          PE_in[11] <= i_cache[44];
          PE_in[12] <= i_cache[45];
          PE_in[13] <= i_cache[46];
          PE_in[14] <= i_cache[47];

          PE_in[15] <= i_cache[51];
          PE_in[16] <= i_cache[52];
          PE_in[17] <= i_cache[53];
          PE_in[18] <= i_cache[54];
          PE_in[19] <= i_cache[55];
          
          PE_in[20] <= i_cache[59];
          PE_in[21] <= i_cache[60];
          PE_in[22] <= i_cache[61];
          PE_in[23] <= i_cache[62];
          PE_in[24] <= i_cache[63];                                                                 
        default: for(i = 0; i < 25; i=i+1) PE_in[i] = 0;
      endcase



(counter == 3) ? READ_TILE2 : READ_TILE1;
(counter == 3) ? READ_TILE5 : READ_TILE2;
(counter == 3) ? READ_TILE4 : READ_TILE3;
(counter == 3) ? READ_TILE7 : READ_TILE4;
(counter == 3) ? READ_TILE6 : READ_TILE5;
;
(counter == 3) ? READ_TILE8 : READ_TILE7;
;
(counter == 3) ? READ_TILE10 : READ_TILE9;
(counter == 3) ? READ_TILE13 : READ_TILE10;
(counter == 3) ? READ_TILE12 : READ_TILE11;
(counter == 3) ? READ_TILE15 : READ_TILE12;
(counter == 3) ? READ_TILE14 : READ_TILE13;
;
(counter == 3) ? READ_TILE16 : READ_TILE15;      



        if(counter == 0) begin // 上到下
          // ==================================================
          for(i = 0; i < 32; i=i+1) i_cache[i] <= i_cache[i+16];
          i_cache[32] <= BRAM_IF_DOUT[31-:8];
          i_cache[33] <= BRAM_IF_DOUT[23-:8];
          i_cache[34] <= BRAM_IF_DOUT[15-:8];
          i_cache[35] <= BRAM_IF_DOUT[ 7-:8];
        end
        else if(counter == 1) begin
          i_cache[36] <= BRAM_IF_DOUT[31-:8];
          i_cache[37] <= BRAM_IF_DOUT[23-:8];
          i_cache[38] <= BRAM_IF_DOUT[15-:8];
          i_cache[39] <= BRAM_IF_DOUT[ 7-:8];
        end
        else if(counter == 2) begin
          i_cache[40] <= BRAM_IF_DOUT[31-:8];
          i_cache[41] <= BRAM_IF_DOUT[23-:8];
          i_cache[42] <= BRAM_IF_DOUT[15-:8];
          i_cache[43] <= BRAM_IF_DOUT[ 7-:8];
        end
        else if(counter == 3) begin
          i_cache[44] <= BRAM_IF_DOUT[31-:8];
          i_cache[45] <= BRAM_IF_DOUT[23-:8];
          i_cache[46] <= BRAM_IF_DOUT[15-:8];
          i_cache[47] <= BRAM_IF_DOUT[ 7-:8];
        end
        else if(counter == 4) begin
          i_cache[48] <= BRAM_IF_DOUT[31-:8];
          i_cache[49] <= BRAM_IF_DOUT[23-:8];
          i_cache[50] <= BRAM_IF_DOUT[15-:8];
          i_cache[51] <= BRAM_IF_DOUT[ 7-:8];
        end
        else if(counter == 5) begin
          i_cache[52] <= BRAM_IF_DOUT[31-:8];
          i_cache[53] <= BRAM_IF_DOUT[23-:8];
          i_cache[54] <= BRAM_IF_DOUT[15-:8];
          i_cache[55] <= BRAM_IF_DOUT[ 7-:8];
        end
        else if(counter == 6) begin
          i_cache[56] <= BRAM_IF_DOUT[31-:8];
          i_cache[57] <= BRAM_IF_DOUT[23-:8];
          i_cache[58] <= BRAM_IF_DOUT[15-:8];
          i_cache[59] <= BRAM_IF_DOUT[ 7-:8];
        end
        else if(counter == 7) begin
          i_cache[60] <= BRAM_IF_DOUT[31-:8];
          i_cache[61] <= BRAM_IF_DOUT[23-:8];
          i_cache[62] <= BRAM_IF_DOUT[15-:8];
          i_cache[63] <= BRAM_IF_DOUT[ 7-:8];
        end                                