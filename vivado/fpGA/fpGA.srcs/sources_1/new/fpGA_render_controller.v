`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Oklahoma
// Engineer: Skyler Riggle
// 
// Create Date: 02/19/2025 04:06 PM
// Design Name: Field-Programmable Graphics Application Render Controller
// Module Name: fpGA_render_controller
// Project Name: Application of FPGAs to Real-Time Graphics
// Target Devices: PYNQ Z2
// Description: A design created to drive the fpGA rendering pipeline
// 
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module fpGA_render_controller(
    input clk_125,
    
    output tmds_tx_clk_p,
    output tmds_tx_clk_n,
    output [2:0] tmds_tx_data_p,
    output [2:0] tmds_tx_data_n
);

wire pixel_clk;
wire serdes_clk;
wire rst;
reg [7:0] rst_cnt;
wire locked;

wire hsync, hblank, vsync, vblank, active, fsync;

wire [1:0] ctl [0:2];
wire [7:0] pixel_data [0:2];
wire [9:0] tmds_data [0:2];

clk_wiz clk_wiz_inst (
    .clk_in1    (clk_125),
    .clk_out1   (pixel_clk),
    .clk_out2   (serdes_clk),
    .locked     (locked)
);

video_timing video_timing_inst (
    .clk                (pixel_clk),
    .clken              (1'b1),
    .gen_clken          (1'b1),
    .sof_state          (1'b1),
    .hsync_out          (hsync),
    .hblank_out         (hblank),
    .vsync_out          (vsync),
    .vblank_out         (vblank),
    .active_video_out   (active),
    .resetn             (~rst),
    .fsync_out          (fsync)
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

assign rst = (rst_cnt == 8'hff) ? 1'b0 : 1'b1;

assign pixel_data[2] = 8'h00; // Red
assign pixel_data[1] = 8'h00; // Green
assign pixel_data[0] = 8'hff; // Blue

assign ctl[0] = { vsync, hsync };
assign ctl[1] = 2'b00;
assign ctl[2] = 2'b00;

generate
    genvar i;
    
    for (i = 0; i < 3; i = i + 1) begin
        tmds_encode tmds_encode_inst (
            .pixel_clk      (pixel_clk),
            .rst            (rst),
            .ctl            (ctl[i]),
            .active         (active),
            .pixel_data     (pixel_data[i]),
            .tmds_data      (tmds_data[i])
        );
        
        tmds_oserdes tmds_oserdes_inst (
            .pixel_clk      (pixel_clk),
            .serdes_clk     (serdes_clk),
            .rst            (rst),
            .tmds_data      (tmds_data[i]),
            .tmds_serdes_p  (tmds_tx_data_p[i]),
            .tmds_serdes_n  (tmds_tx_data_n[i]) 
        );
    end
endgenerate

tmds_oserdes tmds_oserdes_clock (
    .pixel_clk      (pixel_clk),
    .serdes_clk     (serdes_clk),
    .rst            (rst),
    .tmds_data      (10'b1111100000),
    .tmds_serdes_p  (tmds_tx_clk_p),
    .tmds_serdes_n  (tmds_tx_clk_n)
);

endmodule
