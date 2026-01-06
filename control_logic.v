`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2026 01:19:57 PM
// Design Name: 
// Module Name: Control_logic
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


module Control_logic(
        input i_clk,
        input i_rst,
        input [7:0] i_pixel_data,
        input i_pixel_data_valid,
        output reg [71:0] o_pixel_data,
        output reg o_pixel_data_valid
    );
    reg [8:0] pixel_counter; // 9 bit cause 111111111 = 511, and we will get 512 when we and it with i_pixel_data_valid 
    reg [8:0] rd_counter;
    reg rd_line_buffer;
    reg [1:0] currentWrLineBuffer; // To keep track of which line buffer to write to and also resets when exceeds 3 ie 11 --> 00
    reg [3:0] lineBuffDataValid;
    reg [1:0] currentRdLineBuffer; // same as above but for reading purpose
    wire [23:0] lb0data;
    wire [23:0] lb1data;
    wire [23:0] lb2data;
    wire [23:0] lb3data;
    reg [3:0] linebuff_rd_data;
    reg [11:0] total_pixel_counter; // 512*4 = 2048 = 1000 0000 0000 ; so 12 bit counter 
    reg rdState;
    localparam IDLE = 1'b0;
    localparam RD_BUFFER = 1'b1;

    always @(posedge i_clk)
    begin
        if (i_rst)
        begin
            total_pixel_counter <= 0; // WORKS FOR BOTH READING AND WRITING
        end
        else
        begin
            if (i_pixel_data_valid  & !rd_line_buffer)
                total_pixel_counter <= total_pixel_counter + 1;
            else if (!i_pixel_data_valid & rd_line_buffer)
                total_pixel_counter <= total_pixel_counter - 1;
        end
    end

    always @(posedge i_clk)
    begin
        if(i_rst)
        begin
            rdState <= IDLE;
            rd_line_buffer <= 0;
        end
        else
        begin
            case (rdState)
                IDLE:
                begin
                    if(total_pixel_counter >= 1536) //512*3 = 1536
                    begin 
                        rd_line_buffer <= 1;
                        rdState <= RD_BUFFER;
                    end
                end

                RD_BUFFER:
                begin
                    if(rd_counter == 511)
                    begin
                        rdState <= IDLE;
                        rd_line_buffer <= 1'b0;
                    end
                end
            endcase
        end
    end

    always @(posedge i_clk)
    begin
        if (i_rst)
        begin
            rd_line_buffer <= 0;
        end
        else
        begin
            if (total_pixel_counter == 2047) // 512*4 = 2048, so when we reach 2047, we start reading
                rd_line_buffer <= 1;
            else if (total_pixel_counter == 0)
                rd_line_buffer <= 0;
        end
    end

    always @(posedge i_clk)
    begin  
        if (i_rst) 
        begin
            pixel_counter <= 0;
        end
        else
        begin
            if (i_pixel_data_valid)
                pixel_counter <= pixel_counter + 1;
        end
    end

    always@(posedge i_clk) // This to address to which line buffer the incomig pixel data should go
    begin
        if (i_rst)
        begin
            currentWrLineBuffer <= 0;
        end
        else
        begin
            if (pixel_counter == 511 & i_pixel_data_valid) // & i_pixel_data_valid to increase the counting to 512
            begin
                currentWrLineBuffer <= currentWrLineBuffer + 1;
            end
        end
    end

    always @(*) begin
        lineBuffDataValid = 4'b0000;
        lineBuffDataValid[currentWrLineBuffer] = i_pixel_data_valid;
    end

    always @(posedge i_clk)
    begin
        if (i_rst)
            rd_counter <= 0;
        else
        begin
            if (rd_line_buffer)
                rd_counter <= rd_counter + 1;
        end
    end


    always@(posedge i_clk) // This to address to which line buffer the outgoing pixel data should come from
    begin
        if (i_rst)
        begin
            currentRdLineBuffer <= 0;
        end
        else
        begin
            if (rd_counter == 511 & rd_line_buffer) // & i_pixel_data_valid to increase the counting to 512
                currentRdLineBuffer <= currentRdLineBuffer + 1;
            
        end
    end

    always @(*) 
    begin
        case(currentRdLineBuffer)
            0: 
            begin
                o_pixel_data = {lb2data, lb1data, lb0data}; // ordesr similar as FIFO
            end

            1:
            begin
                o_pixel_data = {lb3data, lb2data, lb1data};
            end

            2:
            begin
                o_pixel_data = {lb0data, lb3data, lb2data};
            end

            3:
            begin
                o_pixel_data = {lb1data, lb0data, lb3data};
            end
        endcase    
    end

    always @(*)
    begin
        case(currentRdLineBuffer)
            0: linebuff_rd_data = 4'b0111; // reading from lb0, lb1, lb2
            1: linebuff_rd_data = 4'b1110; // reading from lb1, lb2, lb3
            2: linebuff_rd_data = 4'b1101; // reading from lb2, lb3, lb0
            3: linebuff_rd_data = 4'b1011; // reading from lb3, lb0, lb1  
        endcase    
    end

    // Create four line buffers so that it can prefetch the fourth line while processing the first three lines.
    linebuffer lB0(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(i_pixel_data),
    .i_valid(lineBuffDataValid[0]),
    .o_data(lb0data),
    .o_valid(),
    .i_rd_data(linebuff_rd_data[0])
    );

    linebuffer lB1(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(i_pixel_data),
        .i_valid(lineBuffDataValid[1]),
        .o_data(lb1data),
        .o_valid(),
        .i_rd_data(linebuff_rd_data[1])
    );

    linebuffer lB2(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(i_pixel_data),
        .i_valid(lineBuffDataValid[2]),
        .o_data(lb2data),
        .o_valid(),
        .i_rd_data(linebuff_rd_data[2])
    );

    linebuffer lB3(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(i_pixel_data),
        .i_valid(lineBuffDataValid[3]),
        .o_data(lb3data),
        .o_valid(),
        .i_rd_data(linebuff_rd_data[3])
    );


endmodule
