//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.04.2021 22:43:09
// Design Name: 
// Module Name: alternate_MarchA_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module MarchY_tb;


parameter CAWIDTH = 2;
parameter RAWIDTH = 2;



reg clk;
reg Test;
reg rst;
wire status;



initial
begin
    clk = 0;
    forever
    #1 clk = ~clk;
end


// Instantiate MBIST Controller (which internally instantiates the memory)
MBIST_Controller #(
    .RAWIDTH(RAWIDTH),
    .CAWIDTH(CAWIDTH)
) controller_inst (
    .clk(clk),
    .rst(rst),
    .Test(Test),
    .status(status)
);

initial
begin
    Test = 0;
    rst = 1;  //forces all the cells to go to zero and takes controller to ideal state
    #4;
    Test = 1;
    rst = 0;
end

endmodule
