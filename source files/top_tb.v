// top_tb.v
`timescale 1ns/1ps

module top_tb;

    reg clk;
    reg rst_n;

    // Inputs to top
    reg [1:0]  workload_class;
    reg [7:0]  confidence_level;
    reg [7:0]  battery_level;
    reg        anomaly_flag;

    // Outputs from top
    wire [1:0]  mode;
    wire [15:0] activity_level;

    // Instantiate DUT
    top dut (
        .clk(clk),
        .rst_n(rst_n),
        .workload_class(workload_class),
        .confidence_level(confidence_level),
        .battery_level(battery_level),
        .anomaly_flag(anomaly_flag),
        .mode(mode),
        .activity_level(activity_level)
    );

    // Clock generation
    always #5 clk = ~clk;  // 100MHz = 10ns period

    // ======================================================
    // READ MEMORY FILE
    // ======================================================
    integer f, r, i;
    reg [1:0]  workload_mem  [0:999];
    reg [7:0]  conf_mem      [0:999];
    reg [7:0]  battery_mem   [0:999];
    reg        anomaly_mem   [0:999];

    initial begin
        clk = 0;
        rst_n = 0;
        workload_class   = 0;
        confidence_level = 0;
        battery_level    = 0;
        anomaly_flag     = 0;

        // Dump waveform
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        // Read the file
        f = $fopen("workload_input.mem", "r");
        i = 0;
        while (!$feof(f)) begin
            $fscanf(f, "%d,%d,%d,%d\n",
                    workload_mem[i],
                    conf_mem[i],
                    battery_mem[i],
                    anomaly_mem[i]);
            i = i + 1;
        end
        $fclose(f);

        // Release reset after some cycles
        #50 rst_n = 1;

        // Apply values one by one
        for (r = 0; r < i; r = r + 1) begin
            workload_class   = workload_mem[r];
            confidence_level = conf_mem[r];
            battery_level    = battery_mem[r];
            anomaly_flag     = anomaly_mem[r];
            #100;   // hold each set of inputs for 100ns
        end

        #200;
        $finish;
    end

endmodule
