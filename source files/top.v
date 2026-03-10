// top.v
`timescale 1ns/1ps
module top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [1:0]  workload_class,
    input  wire [7:0]  confidence_level,
    input  wire [7:0]  battery_level,
    input  wire        anomaly_flag,
    output wire [1:0]  mode,
    output wire [15:0] activity_level
);

    // Mode from controller
    wire [1:0] mode_int;

    // Processing enable from clock scaler
    wire proc_en;

    // POWER CONTROLLER
    power_controller u_power_controller (
        .clk(clk),
        .rst_n(rst_n),
        .workload_class(workload_class),
        .confidence_level(confidence_level),
        .battery_level(battery_level),
        .anomaly_flag(anomaly_flag),
        .mode(mode_int)
    );

    assign mode = mode_int;

    // CLOCK SCALER
    clock_scaler u_clock_scaler (
        .clk(clk),
        .rst_n(rst_n),
        .mode(mode_int),
        .proc_en(proc_en)
    );

    // MEDICAL BLOCK
    medical_block u_medical_block (
        .clk(clk),
        .rst_n(rst_n),
        .proc_en(proc_en),
        .activity_level(activity_level)
    );

endmodule
