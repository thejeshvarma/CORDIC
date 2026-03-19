module cordic_control (
    input  clk,
    input   rst_n,
    input   start,
    output reg        ld_init,
    output reg        en_iter,
    output reg [3:0]  i_sel,
    output reg        done
);

    // State Encoding 
    localparam IDLE    = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam FINISH  = 2'b10;

    reg [1:0] state;
    reg [4:0] count; // 5 bits to handle the 0-15 range and exit condition

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state   <= IDLE;
            count   <= 5'd0;
            ld_init <= 1'b0;
            en_iter <= 1'b0;
            done    <= 1'b0;
            i_sel   <= 4'd0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        ld_init <= 1'b1;
                        count   <= 5'd0;
                        state   <= COMPUTE;
                    end else begin
                        ld_init <= 1'b0;
                    end
                end

                COMPUTE: begin
                    ld_init <= 1'b0;
                    en_iter <= 1'b1;
                    i_sel   <= count[3:0];
                    
                    if (count == 5'd15) begin
                        state <= FINISH;
                    end else begin
                        count <= count + 5'd1;
                    end
                end

                FINISH: begin
                    en_iter <= 1'b0;
                    done    <= 1'b1;
                    state   <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule