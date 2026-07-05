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
