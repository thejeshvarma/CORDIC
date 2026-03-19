`timescale 1ns / 1ps

module cordic_top_tb();

    // Inputs
    reg clk;
    reg rst_n;
    reg start;
    reg mode;
    reg signed [15:0] x_in;
    reg signed [15:0] y_in;
    reg signed [15:0] z_in;

    // Outputs
    wire signed [15:0] x_out;
    wire signed [15:0] y_out;
    wire signed [15:0] z_out;
    wire done;

    // Instantiate the Unit Under Test (UUT)
    cordic_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .mode(mode),
        .x_in(x_in),
        .y_in(y_in),
        .z_in(z_in),
        .x_out(x_out),
        .y_out(y_out),
        .z_out(z_out),
        .done(done)
    );

    // Clock Generation: 100 MHz (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 0;
        start = 0;
        mode = 0;
        x_in = 0;
        y_in = 0;
        z_in = 0;

        // Reset system
        #100;
        rst_n = 1;
        #20;

        // --- OPERATION 1: CIRCULAR ROTATION (Sine/Cosine) ---
        // Target: Calculate Sin(30) and Cos(30)
        // x_in = 1/Gain (0.607) = 16'h26DD
        // z_in = 30 degrees (Q2.14) = 16'h2183
        $display("STARTING TEST 1: Circular Rotation (30 Degrees)");
        mode = 1'b0; 
        x_in = 16'h26DD; 
        y_in = 16'h0000;
        z_in = 16'h2183;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        // Wait for hardware to finish 16 iterations
        @(posedge done);
        #10;
        $display("RESULT 1: Cos(30)=%f, Sin(30)=%f", $itor(x_out)/16384.0, $itor(y_out)/16384.0);
        
        #100;

        // --- OPERATION 2: LINEAR VECTORING (Division) ---
        // Target: Calculate 0.25 / 0.50
        // y_in (Dividend) = 0.25 = 16'h1000
        // x_in (Divisor)  = 0.50 = 16'h2000
        // Result expected in z_out: 0.50 (16'h2000)
        $display("STARTING TEST 2: Linear Vectoring (Division: 0.25 / 0.5)");
        mode = 1'b1;
        x_in = 16'h2000; 
        y_in = 16'h1000; 
        z_in = 16'h0000;

        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        @(posedge done);
        #10;
        $display("RESULT 2: Division Result = %f", $itor(z_out)/16384.0);

        #100;
        $display("ALL TESTS COMPLETED.");
        $finish;
    end

endmodule