`include "module_defs.sv"
`timescale 1ns / 1ps
module uart_tb();
	logic clk;
	initial	clk = 0;
	always #5 clk = ~clk;
	logic data_in;
	logic rst;
	logic [7:0] data_out;
	logic rx_valid;
	logic rx_error;
	uart_rx dut (.*);
	logic [7:0] payload = 8'hAA;
	task send_byte(input [7:0] data);
		data_in = 0; # 8681;
		for (int i = 0; i< 8; i++) begin
			data_in = data[i]; #8681;
		end
		data_in = 1; #8681;
	endtask
	initial begin
		rst = 1; #100;
		rst = 0; #100;
		send_byte(payload);
		#10000;
		send_byte(8'hfa);
		#10000;
		send_byte(8'hbb);
		#10000;
		$finish;
	end
	 initial begin
    		$dumpfile("waves.vcd"); 
    		$dumpvars(0, uart_tb);      
	end

		
	endmodule


