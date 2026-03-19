module cordic_datapath #(
    parameter BW = 16
)(
    input       clk,
    input       rst_n,
    input [1:0]  mode,      // [1]: Linear(1)/Circ(0), [0]: Vec(1)/Rot(0)
    input     ld_init,
    input    en_iter,
    input [3:0]  i_sel,     // 0 to 15
    input  signed [BW-1:0] x_in, y_in, z_in,
    output signed [BW-1:0] x_out, y_out, z_out
);

    reg signed [BW-1:0] x, y, z;
    wire signed [BW-1:0] x_shift, y_shift, lut_val;
    reg di;

    // Circular LUT: atan(2^-i) in Q2.14 fixed point repr
    function [15:0] get_atan(input [3:0] idx);
        case(idx)
            4'd0:  get_atan = 16'h3243; // 45.0 deg
            4'd1:  get_atan = 16'h1DAC; // 26.56 deg
            4'd2:  get_atan = 16'h0FAD; // 14.03 deg
            4'd3:  get_atan = 16'h07F5; // 7.12 deg
            4'd4:  get_atan = 16'h03FE; // 3.57 deg
            4'd5:  get_atan = 16'h01FF; // 1.79 deg
            4'd6:  get_atan = 16'h00FF; // 0.89 deg
            4'd7:  get_atan = 16'h007F; // 0.44 deg
            4'd8:  get_atan = 16'h003F; // ...
            4'd9:  get_atan = 16'h001F;
            4'd10: get_atan = 16'h000F;
            4'd11: get_atan = 16'h0007;
            4'd12: get_atan = 16'h0003;
            4'd13: get_atan = 16'h0001;
            4'd14: get_atan = 16'h0000;
            4'd15: get_atan = 16'h0000;
            default: get_atan = 16'h0000;
        endcase
    endfunction

    assign lut_val = mode[1] ? (16'h4000 >>> i_sel) : get_atan(i_sel);
    assign x_shift = x >>> i_sel;
    assign y_shift = y >>> i_sel;

    // Control Decision
    always @(*) begin
        if (mode[0]) di = (y < 0);  // Vectoring: target y to 0
        else         di = (z >= 0); // Rotation: target z to 0
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x <= 0; y <= 0; z <= 0;
        end else if (ld_init) begin
            x <= x_in; y <= y_in; z <= z_in;
        end else if (en_iter) begin
            // Linear Mode (mode[1]=1) bypasses X update
            x <= mode[1] ? x : (di ? x - y_shift : x + y_shift);
            y <= di ? y + x_shift : y - x_shift;
            z <= di ? z - lut_val : z + lut_val;
        end
    end

    assign x_out = x; 
    assign y_out = y; 
    assign z_out = z;

endmodule