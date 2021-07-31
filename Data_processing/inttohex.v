module inttohex();
    reg [7:0] mem [0:149];
    integer scan_file, fp_r;
    reg [7:0] captured_data;
    initial begin
        fp_r = $fopen("./number/number_conv1_out.csv","r"); 
        while(!$feof(fp_r)) begin
            scan_file = $fscanf(fp_r, "%d\n", captured_data); 
            $display("%h", captured_data);
        end
    end
endmodule