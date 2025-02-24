`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Oklahoma
// Engineer: Skyler Riggle
// 
// Create Date: 02/21/2025 04:02 PM
// Design Name: Frame Generator
// Module Name: frame_generator
// Project Name: Application of FPGAs to Real-Time Graphics
// Target Devices: PYNQ Z2
// Description: Given the resulting span data, this module generates the
// corresponding RGB stream
// 
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module frame_generator(
    input clk_in,
    input rst_in,
    
    input [23:0] pixel,
    
    output pixel_clk_out,
    output rst_out,
    output active_out,
    output fsync_out,
    output vsync_out,
    output reg [10:0] x_pos,
    output reg [9:0] y_pos,
    
    output tmds_tx_clk_p,
    output tmds_tx_clk_n,
    output [2:0] tmds_tx_data_p,
    output [2:0] tmds_tx_data_n
);

wire serdes_clk;
reg [7:0] rst_cnt;
wire locked;
reg active;
wire pixel_clk;

wire hblank, vblank;
wire hsync, vsync;
reg hsync_r, vsync_r;

wire [1:0] ctl [0:2];
wire [9:0] tmds_data [0:2];

clk_wiz clk_wiz_inst (
    .clk_in1    (clk_in),
    .reset      (~rst_in),
    .clk_out1   (pixel_clk),
    .clk_out2   (serdes_clk),
    .locked     (locked)
);

BUFG bufg_pixel_clk (
    .I  (pixel_clk),
    .O  (pixel_clk_out)
);

always @(posedge pixel_clk or negedge locked)
begin
    if (~locked) begin
        rst_cnt <= 0;
    end else begin
        if (rst_cnt != 8'hff) begin
            rst_cnt <= rst_cnt + 1;
        end
    end
end

assign rst_out = (rst_cnt == 8'hff) ? 1'b0 : 1'b1;

video_timing video_timing_inst (
    .clk                (pixel_clk),
    .clken              (1'b1),
    .gen_clken          (1'b1),
    .sof_state          (1'b0),
    .hsync_out          (hsync),
    .vsync_out          (vsync),
    .hblank_out         (hblank),
    .vblank_out         (vblank),
    .active_video_out   (active_out),
    .resetn             (~rst),
    .fsync_out          (fsync_out)
);

assign vsync_out = vsync && vsync_r;
assign hsync_out = hsync && hsync_r;

always @(posedge pixel_clk)
begin
    active <= active_out;
    vsync_r <= vsync;
    hsync_r <= hsync;
    
    if (rst_out || hsync_out) begin
        x_pos <= 0;
    end else begin
        x_pos <= x_pos + 1;
    end
    
    if (rst_out || vsync_out) begin
        y_pos <= 0;
    end else begin
        y_pos <= y_pos + 1;
    end
end

assign ctl[0] = { vsync, hsync };
assign ctl[1] = 2'b00;
assign ctl[2] = 2'b00;

generate
    genvar i;
    
    for (i = 0; i < 3; i = i + 1) begin
        tmds_encode tmds_encode_inst (
            .pixel_clk      (pixel_clk),
            .rst            (rst_out),
            .ctl            (ctl[i]),
            .active         (active_out),
            .pixel_data     (pixel[(i * 8) + 7:i * 8]),
            .tmds_data      (tmds_data[i])
        );
        
        tmds_oserdes tmds_oserdes_inst (
            .pixel_clk      (pixel_clk),
            .serdes_clk     (serdes_clk),
            .rst            (rst_out),
            .tmds_data      (tmds_data[i]),
            .tmds_serdes_p  (tmds_tx_data_p[i]),
            .tmds_serdes_n  (tmds_tx_data_n[i])
        );
    end
endgenerate

tmds_oserdes tmds_oserdes_clk (
    .pixel_clk      (pixel_clk),
    .serdes_clk     (serdes_clk),
    .rst            (rst_out),
    .tmds_data      (10'b0000011111),
    .tmds_serdes_p  (tmds_tx_clk_p),
    .tmds_serdes_n  (tmds_tx_clk_n)
);

endmodule
