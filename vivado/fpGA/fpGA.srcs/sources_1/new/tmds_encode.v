`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Oklahoma
// Engineer: Skyler Riggle
// 
// Create Date: 02/19/2025 04:12 PM
// Design Name: Transition-Minimized Differential Signaling Encoder
// Module Name: tmds_encode
// Project Name: Application of FPGAs to Real-Time Graphics
// Target Devices: PYNQ Z2
// Description: A module for encoding raw frame information into TMDS data
// 
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module tmds_encode(
    input pixel_clk,
    input rst,
    input [1:0] ctl,
    input active,
    input [7:0] pixel_data,
    
    output [9:0] tmds_data
);

reg [8:0] p_xor;
reg [8:0] p_xnor;

reg active_1;
reg ctl_bit;
reg [3:0] ones_1;
reg [3:0] ones_xor;
reg [3:0] ones_xnor;

reg active_2;
reg [8:0] pixel_data_2;
reg [3:0] ones_2;
reg signed [5:0] diff;

reg signed [5:0] disparity;
reg [9:0] t_data;

always @(*)
begin
    p_xor[0] = pixel_data[0];
    p_xnor[0] = pixel_data[0];
    
    p_xor[1] = p_xor[0] ^ pixel_data[1];
    p_xnor[1] = p_xnor[0] ~^ pixel_data[1];
    p_xor[2] = p_xor[1] ^ pixel_data[2];
    p_xnor[2] = p_xnor[1] ~^ pixel_data[2];
    p_xor[3] = p_xor[2] ^ pixel_data[3];
    p_xnor[3] = p_xnor[2] ~^ pixel_data[3];
    p_xor[4] = p_xor[3] ^ pixel_data[4];
    p_xnor[4] = p_xnor[3] ~^ pixel_data[4];
    p_xor[5] = p_xor[4] ^ pixel_data[5];
    p_xnor[5] = p_xnor[4] ~^ pixel_data[5];
    p_xor[6] = p_xor[5] ^ pixel_data[6];
    p_xnor[6] = p_xnor[5] ~^ pixel_data[6];
    p_xor[7] = p_xor[6] ^ pixel_data[7];
    p_xnor[7] = p_xnor[6] ~^ pixel_data[7];
    
    p_xor[8] = 1'b1;
    p_xnor[8] = 1'b0;
end

always @(posedge pixel_clk)
begin
    active_1 <= active;
    ctl_bit <= pixel_data[0];
    active_2 <= active_1;
    
    ones_1 <= (
        pixel_data[0] + pixel_data[1] + pixel_data[2] + pixel_data[3] +
        pixel_data[4] + pixel_data[5] + pixel_data[6] + pixel_data[7]
    );
    
    ones_xor <= (
        p_xor[0] + p_xor[1] + p_xor[2] + p_xor[3] +
        p_xor[4] + p_xor[5] + p_xor[6] + p_xor[7]
    );
    
    ones_xnor <= (
        p_xnor[0] + p_xnor[1] + p_xnor[2] + p_xnor[3] +
        p_xnor[4] + p_xnor[5] + p_xnor[6] + p_xnor[7]
    );
    
    if ((ones_1 > 4) || (ones_1 == 4 && ctl_bit == 1'b0)) begin
        pixel_data_2 <= p_xnor;
        ones_2 <= ones_xnor;
        diff <= $signed(ones_xnor) + $signed(ones_xnor) - 8;
    end else begin
        pixel_data_2 <= p_xor;
        ones_2 <= ones_xor;
        diff <= $signed(ones_xor) + $signed(ones_xor) - 8;
    end
    
    if (rst) begin
        t_data <= 10'b1101010100;
        disparity <= 0;
    end else if (~active_2) begin
        if (ctl == 2'b00) begin
            t_data <= 10'b1101010100;
        end else if (ctl == 2'b01) begin
            t_data <= 10'b0010101011;
        end else if (ctl == 2'b10) begin
            t_data <= 10'b0101010100;
        end else begin
            t_data <= 10'b1010101011;
        end
        
        disparity <= 0;
    end else begin
        if ((disparity == 0) || (ones_2 == 4)) begin
            if (pixel_data_2[8]) begin
                t_data <= { 1'b0, 1'b1, pixel_data_2[7:0] };
                disparity <= disparity + diff;
            end else begin
                t_data <= { 1'b1, 1'b0, ~pixel_data_2[7:0] };
                disparity <= disparity - diff;
            end
        end else begin
            if ((disparity > 0 && ones_2 > 4) || (disparity < 0 && ones_2 < 4)) begin
                if (pixel_data_2[8]) begin
                    t_data <= { 1'b1, 1'b1, ~pixel_data_2[7:0] };
                    disparity <= disparity - diff;
                end else begin
                    t_data <= { 1'b1, 1'b0, ~pixel_data_2[7:0] };
                    disparity <= disparity - diff;
                end
            end else begin
                if (pixel_data_2[8]) begin
                    t_data <= { 1'b0, 1'b1, pixel_data_2[7:0] };
                    disparity <= disparity + diff;
                end else begin
                    t_data <= { 1'b0, 1'b0, pixel_data_2[7:0] };
                    disparity <= disparity + diff - 2;
                end
            end
        end
    end
end

assign tmds_data = t_data;

endmodule