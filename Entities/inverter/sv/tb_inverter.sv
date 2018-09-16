module tb_inverter #( parameter g_infile  = "./A.txt",
                    parameter g_outfile = "./Z.txt",
                    parameter g_Rs      = 100.0e6
                  );
//timescale 1ps this should probably be a global model parameter 
parameter c_Ts=1/(g_Rs*1e-12);


reg iptr_A;
reg clk;

wire Z;
integer StatusI, StatusO, infile, outfile;

initial clk = 1'b0;
always #(c_Ts)clk = !clk ;

inverter DUT( .A(iptr_A), .Z(Z) );


initial #0 begin
    infile = $fopen(g_infile,"r"); // For reading
    outfile = $fopen(g_outfile,"w"); // For writing
    while (!$feof(infile)) begin
            @(posedge clk) StatusI=$fscanf(infile,"%b\n",iptr_A);
            @(negedge clk) $fwrite(outfile,"%b\n",Z);
    end
    $finish;
end
endmodule

