module linebuffer(
    input i_clk,
    input i_rst,
    input [7:0] i_data,
    input i_valid,
    output [23:0] o_data,
    output o_valid
);

reg [7:0] line [511:0]; // We assume that the image width is 512px and of 8 bit.
reg [8:0] write_ptr; // Stores the location where to write the next pixel, the size is calculated as log2(image_width) 


always @(posedge i_clk)
begin
    if (i_rst)
    begin
        write_ptr <= 0;
    end
    else if (i_valid)
    begin
        line[write_ptr] <= i_data;
        write_ptr <= write_ptr + 1;
    end
end

endmodule