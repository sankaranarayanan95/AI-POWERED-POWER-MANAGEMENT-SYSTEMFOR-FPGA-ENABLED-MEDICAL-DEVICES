// clock_scaler.v
`timescale 1ns/1ps
module clock_scaler (
    input  wire       clk,      // main clock
    input  wire       rst_n,
    input  wire [1:0] mode,     // 0,1,2,3
    output reg        proc_en   // processing enable pulse
);

    reg [7:0] cnt;

    // speed dividers (edit if needed)
    localparam ULTRA_SLOW = 8'd100;  // mode 0
    localparam MEDIUM     = 8'd40;   // mode 1
    localparam FAST       = 8'd10;   // mode 2
    localparam TURBO      = 8'd2;    // mode 3

    reg [7:0] threshold;

    always @(*) begin
        case (mode)
            2'd0: threshold = ULTRA_SLOW;
            2'd1: threshold = MEDIUM;
            2'd2: threshold = FAST;
            2'd3: threshold = TURBO;
            default: threshold = MEDIUM;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            proc_en <= 0;
        end else begin
            if (cnt >= threshold) begin
                cnt <= 0;
                proc_en <= 1;       // pulse
            end else begin
                cnt <= cnt + 1;
                proc_en <= 0;
            end
        end
    end

endmodule
