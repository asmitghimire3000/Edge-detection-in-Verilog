module linebuffer(
    input i_clk,
    input i_rst,
    input [7:0] i_data,
    input i_valid,
    output [23:0] o_data,
    output o_valid
    input i_rd_data
);

reg [7:0] line [511:0]; // We assume that the image width is 512px and of 8 bit.
reg [8:0] write_ptr; // Stores the location where to write the next pixel, the size is calculated as log2(image_width) 
reg [8:0] read_ptr;  // Pointer for reading data

always @(posedge i_clk)
begin
    if (i_valid)
    begin
        line[write_ptr] <= i_data;
    end
end

always @(posedge i_clk)
begin
    if (i_rst) 
    begin
        write_ptr <= 'd0;
    end
    else if(i_valid)
    begin
        write_ptr <= write_ptr + 'd1;
    end
end

assign o_data = {line[read_ptr], line[read_ptr + 1], line[read_ptr + 2]};

always @(posedge i_clk)
begin
    if (i_rst)

        read_ptr <= 'd0;
    else if(i_rd_data)
    begin
        read_ptr <= read_ptr + 'd1;
    end
end

endmodule