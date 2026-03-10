// power_controller.v
`timescale 1ns/1ps
module power_controller (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [1:0]  workload_class,   // 0/1/2
    input  wire [7:0]  confidence_level, // 0..255
    input  wire [7:0]  battery_level,    // 0..255
    input  wire        anomaly_flag,     // 0/1
    output reg  [1:0]  mode              // 0..3 (3 = turbo)
);

    // parameters (tweak if needed)
    localparam integer BATTERY_THRESH = 50;  // scaled value ~20%
    localparam integer CONF_HIGH      = 200;
    localparam integer CONF_LOW       = 150;
    localparam integer TURBO_CYCLES   = 3;

    // Trend registers
    reg [1:0] prev2, prev1;
    reg [1:0] turbo_cnt;

    // update history
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prev2 <= 2'd0;
            prev1 <= 2'd0;
            turbo_cnt <= 0;
            mode <= 2'd0;
        end else begin
            // shift workload history
            prev2 <= prev1;
            prev1 <= workload_class;

            // Turbo handling: if anomaly, set turbo counter
            if (anomaly_flag) begin
                turbo_cnt <= TURBO_CYCLES;
            end else if (turbo_cnt != 0) begin
                turbo_cnt <= turbo_cnt - 1;
            end

            // Priority decision (ordered)
            if (turbo_cnt != 0) begin
                mode <= 2'd3; // turbo active
            end else if (battery_level < BATTERY_THRESH) begin
                mode <= 2'd0; // ultra-low
            end else if ((confidence_level > CONF_HIGH) && (workload_class == 2)) begin
                mode <= 2'd2; // high
            end else if (confidence_level < CONF_LOW) begin
                mode <= 2'd0; // low confidence -> safe mode
            end else if ((prev2 <= prev1) && (prev1 <= workload_class) && (prev2 != prev1 || prev1 != workload_class)) begin
                // simple rising trend check
                mode <= 2'd2;
            end else begin
                // fallback: direct mapping workload -> mode (0/1/2)
                mode <= {1'b0, workload_class[0]}; // temporary default mapping below
                // better mapping:
                // workload 0 -> mode 0
                // workload 1 -> mode 1
                // workload 2 -> mode 2
                if (workload_class == 2) mode <= 2'd2;
                else if (workload_class == 1) mode <= 2'd1;
                else mode <= 2'd0;
            end
        end
    end

endmodule
