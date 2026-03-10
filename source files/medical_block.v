// medical_block.v
`timescale 1ns/1ps
module medical_block (
    input  wire clk,
    input  wire rst_n,
    input  wire proc_en,   // clock enable from clock_scaler
    output reg [15:0] activity_level
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            activity_level <= 0;
        else if (proc_en)
            activity_level <= activity_level + 1;  // increments only when enabled
    end

endmodule
