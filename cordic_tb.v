`timescale 1ns / 1ps

module cordic_all_modes_tb;

    reg clk, rst_n, start;
    reg [1:0] mode;
    reg signed [15:0] x_in, y_in, z_in;
    wire signed [15:0] x_out, y_out, z_out;
    wire done;

    cordic_top uut (
        .clk(clk), .rst_n(rst_n), .start(start), .mode(mode), 
        .x_in(x_in), .y_in(y_in), .z_in(z_in), 
        .x_out(x_out), .y_out(y_out), .z_out(z_out), .done(done)
    );

    always #5 clk = ~clk;

    // Helper task to run a test and print results
    task run_test(input [1:0] m, input [15:0] x, input [15:0] y, input [15:0] z, input [127:0] name);
        begin
            mode = m; x_in = x; y_in = y; z_in = z;
            start = 1; #10 start = 0;
            wait(done);
            #10;
            $display("TEST: %s", name);
            $display("OUT -> X: %h (%f), Y: %h (%f), Z: %h (%f)", 
                      x_out, $itor(x_out)/16384.0, 
                      y_out, $itor(y_out)/16384.0, 
                      z_out, $itor(z_out)/16384.0);
            $display("---------------------------------------");
            #50;
        end
    endtask

    initial begin
        clk = 0; rst_n = 0; start = 0;
        #20 rst_n = 1; #20;

        // 1. CIRCULAR ROTATION (Mode 00)
        // Rotate (0.607, 0) by 30 degrees. 30 deg in Q2.14 = 16'h2183
        // Expect: X = cos(30)*0.607*1.647 = 0.866, Y = sin(30) = 0.5
        run_test(2'b00, 16'h26DD, 16'h0000, 16'h2183, "Circular Rotation (30 deg)");

        // 2. CIRCULAR VECTORING (Mode 01)
        // Find Magnitude/Angle of X=0.5, Y=0.5 (16'h2000, 16'h2000)
        // Expect: X = Mag * Gain = 0.707 * 1.647 = 1.16, Z = 45 deg (16'h3243)
        run_test(2'b01, 16'h2000, 16'h2000, 16'h0000, "Circular Vectoring (0.5, 0.5)");

        // 3. LINEAR ROTATION (Mode 10) - Multiplication
        // y_out = y_in + (x_in * z_in). Let X=0.5, Z=0.5, Y=0
        // Expect: Y = 0.25 (16'h1000)
        run_test(2'b10, 16'h2000, 16'h0000, 16'h2000, "Linear Rotation (Multiply)");

        // 4. LINEAR VECTORING (Mode 11) - Division
        // z_out = z_in + (y_in / x_in). Let Y=0.25, X=0.5, Z=0
        // Expect: Z = 0.5 (16'h2000)
        run_test(2'b11, 16'h2000, 16'h1000, 16'h0000, "Linear Vectoring (Division)");

        #100 $finish;
    end

endmodule