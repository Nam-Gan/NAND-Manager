//##########################################
//
// file_name: ring_buffer.v
// author: @Nam-Gan
//
// #########################################
//
// Note: The clock is assumed to be at 100 MHz, timings would change if the
// clock speed is changed. 
//
`include "params.svh"
`define PAGESIZE 8640
`include "uart_rx.sv"
module ring_buffer #(
	parameter int WIDTH = 8, 
	parameter int PAGES = 2, // page size is 8192 + 448 bytes 
	parameter int BAUD = 115_200 // BAUD rate of the sensor
    )( 
	input wire clk, // Assuming the clock at 100 MHz
	input wire rst,
	input wire input_bus,
	input wire tick,
	output wire [WIDTH-1:0] output_bus,
	output wire full,
	output wire empty,
	output wire req);

	wire [7:0] data_from_rx;
	wire rx_valid, rx_error;

	//UART IP Instantiation
	uart_rx #(.CLOCKSPEED(`CLOCKSPEED))rx_module(.data_in(input_bus), .rst(rst), .clk(clk), .data_out(data_from_rx), .rx_valid(rx_valid), .rx_error(rx_error));

	// Definitions
	reg [7:0] mem [PAGES - 1 : 0][`PAGESIZE - 1 : 0];
	reg [$clog2(PAGES) - 1: 0] write_page_pointer;
	reg [$clog2(`PAGESIZE) - 1: 0] write_byte_offset;
	
	// Write FSM
	
    reg write_state;
    localparam 
        IDLE = 1'b0,
        BUSY = 1'b1;
	always @(posedge clk) begin
		if (rst) begin
			write_state <= IDLE;
			write_page_pointer <= 1'b0;
			write_byte_offset <= 0;
			req <= 1'b0;
		end else begin
			req <= 1'b0;
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
					if (write_byte_offset == `PAGESIZE - 1) begin
						if (write_page_pointer == PAGES - 1) begin
							write_page_pointer <= 0;
						end else begin
							write_page_pointer <= write_page_pointer + 1;
						end
						write_byte_offset <= 0;
						mem[write_page_pointer][write_byte_offset] <= data_from_rx;
						req <= 1'b1;
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
	reg read_state;
	reg [$clog2(PAGES) - 1: 0] read_page_pointer;
	reg [$clog2(`PAGESIZE) - 1: 0] read_byte_offset;
	always @(posedge clk) begin
		if (rst) begin
			read_state <= IDLE;
			read_page_pointer <= 0;
			read_byte_offset <= 0;
		end else begin
			case (read_state)
				IDLE: begin
					if(tick) begin
						read_state <= BUSY;
						output_bus <= mem[read_page_pointer][read_byte_offset];
						read_byte_offset <= 1;
					end else begin
						read_state <= IDLE;
					end
				end
				BUSY: begin
					if (tick) begin
						if (read_byte_offset == `PAGESIZE - 1) begin
							read_byte_offset <= 0;
							read_page_pointer <= read_page_pointer + 1;
							output_bus <= mem[read_page_pointer][read_byte_offset];
							read_state <= IDLE;
						end else begin
							read_byte_offset <= read_byte_offset + 1;
							output_bus <= mem[read_page_pointer][read_byte_offset];
                        end
                    end else begin
                        read_state <= BUSY;
				end
            end
				default: read_state <= IDLE;
			endcase
		end
	end
endmodule: ring_buffer 
