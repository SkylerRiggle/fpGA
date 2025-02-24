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
    output [2:0] tmds_tx_data_n,
    output hdmi_hpd
);

wire [23:0] pixel;

assign pixel = 24'hff0000;
assign hdmi_hpd = 1'b1;

frame_generator frame_generator_inst (
    .clk_in         (clk_125),
    .rst_in         (1'b1),
    .pixel          (pixel),
    .pixel_clk_out  (),
    .rst_out        (),
    .active_out     (),
    .fsync_out      (),
    .vsync_out      (),
    .x_pos          (),
    .y_pos          (),
    .tmds_tx_clk_p  (tmds_tx_clk_p),
    .tmds_tx_clk_n  (tmds_tx_clk_n),
    .tmds_tx_data_p (tmds_tx_data_p),
    .tmds_tx_data_n (tmds_tx_data_n)
);

endmodule
