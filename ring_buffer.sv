//##########################################
//
// file_name: module_defs.sv
// author: @Nam-Gan
//
// Module definitions for writing UART data from multiple payloads to the
// high-speed NAND Flash, using ring buffers and a weighted round robin
// arbiter. 
// Modules defined, ring buffer, pointer storage.
// #########################################
//
// Note: The clock is assumed to be at 100 MHz, timings would change if the
// clock speed is changed. 
//
// Note: The packets from the sensors must be 8-bit little endian.
`define PAGE_SIZE 8640
module ring_buffer #(
	parameter int WIDTH = 8, //because the NAND Flash supports byte wise addressing 
	parameter int PAGES = 2, // page size is 8192 + 448 bytes 
	parameter int BAUD = 115_200, // BAUD rate of the sensor
	parameter int CLOCKSPEED = 100_000_000)( 
	input logic clk, // Assuming the clock at 100 MHz
	input logic rst,
	input logic input_bus,
	input logic arbiter_ping,
	output logic [WIDTH-1:0] output_bus,
	output logic full,
	output logic empty,
	output logic page_ping);
	//UART IP Instantiation
	uart_rx #(CLOCKSPEED = CLOCKSPEED, BAUD = BAUD) rx_module(.data_in(input_bus), .rst(rst), .clk(clk), .data_out(data_from_rx), .rx_valid(rx_valid), .rx_error(.rx_error));
	logic [7:0] data_from_rx;
	logic rx_valid, rx_error;
	// Definitions
	logic [7:0] mem [PAGES - 1 : 0][PAGE_SIZE - 1 : 0];
	logic [$clog2(PAGES) - 1: 0] write_page_pointer;
	logic [$clog2(PAGE_SIZE) - 1: 0] write_byte_offset;
	
	// Write FSM
	
	typedef enum logic [1:0] {
		IDLE,
		BUSY} state_t;
	state_t write_state;
	always_ff @(posedge clk) begin
		if (rst) begin
			write_state <= IDLE;
			write_page_pointer <= 1'b0;
			write_byte_offset <= 0;
			page_ping <= 1'b0;
		end else begin
			page_ping <= 1'b0;
			// add error handling for rx_error
			case (write_state)
				IDLE: begin
					if (rx_valid) begin
						write_state <= BUSY;
					end else begin
						write_state <= IDLE;
					end
				end
				BUSY: begin
					if (write_byte_offset == PAGE_SIZE - 1) begin
						if (write_page_pointer == PAGES - 1) begin
							write_page_pointer <= 0;
						end else begin
							write_page_pointer <= write_page_pointer + 1;
						end
						write_byte_offset <= 0;
						mem[write_page_pointer][write_byte_offset] <= data_from_rx;
						page_ping <= 1'b1;
					end else begin
						write_byte_offset <= write_byte_offset + 1;
						mem[write_page_pointer][write_byte_offset] <= data_from_rx;
					end
					write_state <= IDLE;
				end
				default: write_state <= IDLE;
			endcase
		end
	end

	// read fsm
	state_t read_state;
	logic [$clog2(PAGES) - 1: 0] read_page_pointer;
	logic [$clog2(PAGE_SIZE) - 1: 0] read_byte_offset;
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			read_state <= IDLE;
			read_page_pointer <= 0;
			read_byte_offset <= 0;
		end else begin
			case (read_state)
				IDLE: begin
					if(arbiter_ping) begin
						read_state <= BUSY;
					end else begin
						read_state <= IDLE;
					end
				end
				BUSY: begin
					// add page programming logic
				end
				default: read_state <= IDLE;
			endcase
		end
	end
endmodule: ring_buffer 
