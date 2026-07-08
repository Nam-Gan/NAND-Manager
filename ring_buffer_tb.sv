`include "params.svh"
`include "ring_buffer.sv"
module ring_buffer_tb();
    logic clk;
    logic rst;
    logic input_bus;
    logic tick;
    logic empty;
    logic full;
    logic req;
    logic [`WIDTH-1:0] output_bus;
    ring_buffer dut (.*);
    `include "send_byte.sv"
    
    initial clk = 0;
    always #5 clk = ~clk;

    int fd;
    int out_fd;
    int byte_data;
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, ring_buffer_tb);
    end
    initial begin
        #10 rst = 0;
        #10 rst = 1;
        #10 rst = 0;
        tick = 0;
        out_fd = $fopen("captured_output.bin", "wb");
        if (out_fd == 0) begin
            $error("Failed to open output file!");
            $finish;
        end
        fd = $fopen("output_ascii.bin", "rb");
        if (fd==0) begin
            $error("Failed to open file!");
            $finish;
        end
        while(!$feof(fd)) begin
            byte_data = $fgetc(fd);
            if (byte_data != -1) begin
                send_byte(byte_data[7:0]);
            end
        end
        $fclose(fd);
        for (int i = 0; i<8667; i++) begin
            tick = 1; #10; // 1 clock cycle
            tick = 0; #90; // 9 clock cycles
        end
        $finish;
    end
    logic tick_d;  // delayed tick, tracks previous cycle's tick

    always @(posedge clk) begin
        tick_d <= tick;
        if (tick_d) begin
            $fwrite(out_fd, "%c", output_bus);
        end
    end
    endmodule
