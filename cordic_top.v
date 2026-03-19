`timescale 1ns / 1ps

module cordic_top (
    input    clk,
    input    rst_n,
    input    start,
    input [1:0]  mode,   // 00:Circ-Rot, 01:Circ-Vec, 10:Lin-Rot, 11:Lin-Vec
    input  signed [15:0] x_in, y_in, z_in,
    output wire signed [15:0] x_out, y_out, z_out,
    output wire        done
);

    wire ld_init, en_iter;
    wire [3:0] i_sel;

    cordic_control control_unit (
        .clk(clk), .rst_n(rst_n), .start(start),
        .ld_init(ld_init), .en_iter(en_iter),
        .i_sel(i_sel), .done(done)
    );

    cordic_datapath #(.BW(16)) datapath_unit (
        .clk(clk), .rst_n(rst_n), .mode(mode),
        .ld_init(ld_init), .en_iter(en_iter), .i_sel(i_sel),
        .x_in(x_in), .y_in(y_in), .z_in(z_in),
        .x_out(x_out), .y_out(y_out), .z_out(z_out)
    );

endmodule