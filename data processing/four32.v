module four32;
    reg [7:0] mem [0:10000];
    reg [31:0] mem1 [0:10000]; // 255
    integer scan_file, fp_r, i, j;
    reg [7:0] captured_data1;
    reg [7:0] captured_data2;
    reg [7:0] captured_data3;
    reg [7:0] captured_data4;
    initial begin
        $readmemh("./number/number_conv1_in.hex", mem);
        j = 0;
        for(i = 0; i < 256; i=i+1) begin
            mem1[i] = {mem[j], mem[j+1], mem[j+2], mem[j+3]};
            j=j+4;
        end 
        for(i = 0; i < 256; i=i+1) begin
            $display("%h", mem1[i]);
        end
        // fp_r = $fopen("./number/number_conv1.hex","r"); 
        // while(!$feof(fp_r)) begin
        //     scan_file = $fscanf(fp_r, "%h\n", captured_data1); 
        //     scan_file = $fscanf(fp_r, "%h\n", captured_data2); 
        //     scan_file = $fscanf(fp_r, "%h\n", captured_data3); 
        //     scan_file = $fscanf(fp_r, "%h\n", captured_data4); 

        //     $display("%h%h%h%h", captured_data1, captured_data2, captured_data3, captured_data4);
        // end
    end
endmodule