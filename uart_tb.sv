`include "uart_rx.sv"
`timescale 1ns / 1ns
`define BAUD 115200
`define CLOCKSPEED 100_000_000
module uart_tb();
	logic clk;
	initial	clk = 0;
	always #5 clk = ~clk;
	logic data_in;
	logic rst;
	logic [7:0] data_out;
	logic rx_valid;
	logic rx_error;
    int fd;
    int byte_data;
	uart_rx dut (.*);
    bit err;
    localparam real BIT_PERIOD = (`CLOCKSPEED * 10) / `BAUD;
    localparam int BIT_TICKS = $ceil(BIT_PERIOD);
	task send_byte(input [7:0] data);
		data_in = 0; #BIT_TICKS; 
		for (int i = 0; i< 8; i++) begin
			data_in = data[i]; #BIT_TICKS;
		end
		data_in = 1; #BIT_TICKS;
	endtask
    initial begin
		$dumpfile("waves.vcd"); 
 		$dumpvars(0, uart_tb);      
	end
    assign err = data_out - byte_data;
    initial begin
        rst = 1; #10
        rst = 0;
        data_in = 1;
    end
   initial begin
        fd = $fopen("output_ascii.bin", "rb");
        if (fd == 0) begin
            $error("Failed to open file!");
            $finish;
        end
        while (!$feof(fd)) begin
            byte_data = $fgetc(fd);
            if (byte_data != -1) begin
                send_byte(byte_data[7:0]);
            end
        end
    
        $fclose(fd);
        $finish;
   end
	endmodule


