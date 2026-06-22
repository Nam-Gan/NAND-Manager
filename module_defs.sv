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
						write_page_pointer <= write_page_pointer + 1;
						write_byte_offset <= 0;
						mem[write_page_pointer][write_byte_offset] <= data_from_rx;
						page_ping <= 1'b1;
					end else begin
						write_page_pointer <= write_page_pointer + 1;
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
module uart_rx#(
	parameter int CLOCKSPEED = 100_000_000,  
	parameter int BAUD = 115_200)( // in bps

	input logic data_in,
	input logic rst,
	input logic clk,

	output logic [7:0] data_out,
	output logic rx_valid,
	output logic rx_error);

	localparam int DIVISOR = CLOCKSPEED/(BAUD * 16);
	logic [$clog2(DIVISOR) - 1 : 0] tick_counter;
	logic baud_tick;
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			tick_counter <= 0;
			baud_tick <= 1'b0;
		end else begin
			if (tick_counter == DIVISOR - 1) begin
				tick_counter <= 0;
				baud_tick <= 1'b1;
			end
			else begin
				tick_counter <= tick_counter + 1;
				baud_tick <= 0;
			end
		end
	end
	// syncing logic, improve metastability
	logic rx_sync0, rx_sync1;
	always_ff @(posedge clk or posedge rst) begin
    		if (rst) begin
        		rx_sync0 <= 1'b1;
        		rx_sync1 <= 1'b1;
    		end else begin
			rx_sync0 <= data_in;
        		rx_sync1 <= rx_sync0;
    		end
	end
	typedef enum logic [1:0] {
		RX_IDLE,
		RX_START,
		RX_DATA,
		RX_STOP
	}rx_state_t;
	rx_state_t state;
	logic [3:0] sampling_counter; //counts till 15
	logic [2:0] bit_counter; // which position 0-7?
	logic [7:0] shift_reg;
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			state <= RX_IDLE;
			sampling_counter <= 0;
			bit_counter <= 0;
			shift_reg <= 0;
			data_out <= 0;
			rx_valid <= 1'b0;
			rx_error<= 1'b0;
		end else begin
			rx_valid <= 1'b0;
			rx_error<= 1'b0;
			case(state)
				RX_IDLE: begin
					if (rx_sync1 == 1'b0) begin
						sampling_counter <= 0;
						state <= RX_START;
					end
					else state <= RX_IDLE;
				end  
				RX_START: begin
					if (baud_tick) begin
						if(sampling_counter == 7) begin
							if (rx_sync1 == 1'b0) begin
								sampling_counter <= 0;
								bit_counter <= 0;
								state <= RX_DATA;
							end else begin
								state <= RX_IDLE;
							end
						end
						else begin
							sampling_counter <= sampling_counter+1;
						end
					end
				end
				RX_DATA: begin
					if (baud_tick) begin
						if (sampling_counter == 15) begin
							sampling_counter <= 0;
							shift_reg <= {rx_sync1, shift_reg[7:1]};
							if (bit_counter == 7) begin
								state <= RX_STOP;
							end else begin
								bit_counter <= bit_counter + 1;
							end
						end else begin
							sampling_counter <= sampling_counter + 1;
						end
					end
				end
				RX_STOP: begin
					if (baud_tick) begin
						if (sampling_counter == 15) begin
							if(rx_sync1 == 1'b1) begin
								rx_valid <= 1'b1;
								data_out <= shift_reg;
								state<= RX_IDLE;
							end else begin
								rx_error<= 1'b1;
								state <= RX_IDLE;
							end
						end else 
							sampling_counter <= sampling_counter + 1;
					end
				end
				default: state <= RX_IDLE;
			endcase
		end
	end
	endmodule: uart_rx 
