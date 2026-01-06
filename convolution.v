`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2026 10:22:23 PM
// Design Name: 
// Module Name: convolution
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


module convolution(
    input i_clk,
    input [71:0] i_pixel_data,
    input i_pixel_data_valid,
    output reg [7:0] convolved_data,
    output reg convolved_data_ready
    );
    
    integer i;
    reg [7:0] kernel [8:0];
    reg [15:0] multiplied_data[8:0];
    reg [15:0] sum_data;
    reg [15:0] sum_data_int;
    reg mul_datavalid;
    reg conv_datavalid;
    reg sum_datavalid;
    
    initial
    begin
        for(i=0;i<=9;i=i+1)
        begin
            kernel[i] = i;
        end
    end
    
    always @(posedge i_clk)
    begin
        for(i=0;i<9;i=i+1)
        begin
            multiplied_data[i] <= kernel[i]*i_pixel_data[i*8+:8];
        end
        mul_datavalid <= i_pixel_data_valid;
    end
    
    always @(*)
    begin
        sum_data = 0;
        for(i=0;i<9;i=i+1)
        begin
            sum_data_int = sum_data_int + multiplied_data[i]; 
        end
    end
    
    always @(posedge i_clk)
    begin
        sum_data <= sum_data_int;
        sum_datavalid <= mul_datavalid;
    end
    
    always @(posedge i_clk)
    begin
        convolved_data <= sum_data/9;
        convolved_data_ready <= sum_datavalid;
    end
    
endmodule
