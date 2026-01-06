`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2026 08:02:11 PM
// Design Name: 
// Module Name: TOP_VIEW
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


module TOP_VIEW(
    input axi_clk,
    input axi_rst_n,

    // slave
    input i_data_valid,
    input [7:0] i_data,
    output o_data_ready, // this is to DMA controller

    //master interface
    output o_data_valid, 
    output [7:0] o_data,
    input i_data_ready, // this is from DMA controller

    //interrupt
    output o_intr
    );

    wire [71:0] pixel_data;
    wire pixel_data_valid;
    wire axis_prog_full;
    wire [7:0] convolved_data;
    wire [7:0] convolved_data_ready;

    assign o_data_ready = !axis_prog_full;

    control_logic control_logic_inst(
        .i_clk(axi_clk),
        .i_rst_n(!axi_rst_n),
        .i_pixel_data(i_data),
        .i_pixel_data_valid(i_data_valid),
        .o_pixel_data(pixel_data),
        .o_pixel_data_valid(pixel_data_valid),
        .o_intr(o_intr)
    );

    Convolution convolution_inst(
        .i_clk(axi_clk),
        .i_pixel_data(pixel_data),
        .i_pixel_data_valid(pixel_data_valid),
        .convolved_data(convolved_data),
        .convolved_data_ready(convolved_data_ready)
        );
        
   outputBuffer output_buffer (
      .s_aclk(axi_clk),                  // input wire s_aclk
      .s_aresetn(axi_rst_n),            // input wire s_aresetn
      .s_axis_tvalid(convolved_data_ready),    // input wire s_axis_tvalid
      .s_axis_tready(),    // output wire s_axis_tready
      .s_axis_tdata(convolved_data),      // input wire [7 : 0] s_axis_tdata
      .m_axis_tvalid(o_data_valid),    // output wire m_axis_tvalid
      .m_axis_tready(i_data_ready),    // input wire m_axis_tready
      .m_axis_tdata(o_data),      // output wire [7 : 0] m_axis_tdata
      .axis_prog_full(axis_prog_full)  // output wire axis_prog_full
   );
    
    
    
endmodule


