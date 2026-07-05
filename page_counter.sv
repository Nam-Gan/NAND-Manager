module page_counter(
	input logic clk,
	input logic rst,

	input logic s1,
	input logic s2,
	input logic s3,
	input logic s4,

	input logic [2:0] gnt, // 0 is idle, i.e. no request granted in the last cycle

	output logic [1:0] c1,
	output logic [1:0] c2,
	output logic [1:0] c3,
	output logic [1:0] c4);
	
	always_ff @(posedge clk) begin
		if (rst) begin
			c1 <= 0;
			c2 <= 0;
			c3 <= 0;
			c4 <= 0;
		end else begin
			if(gnt == 0) begin
				if (s1) begin
					c1 <= c1 + 1;
				end else if (s2) begin
					c2 <= c2 + 1;
				end else if (s3) begin 
					c3 <= c3 + 1;
				end else if (s4) begin
					c4 <= c4 + 1;
				end else begin
					c1 <= c1;
					c2 <= c2;
					c3 <= c3;
					c4 <= c4;
				end
					
			end
			else begin
				if (s1 | s2 | s3 | s4) begin
					if (s1) begin
						if (gnt == 1) begin
							c1 <= c1;
						end else begin
							c1 <= c1 + 1;
						end
					end else if (s2) begin
						if (gnt == 2) begin
							c2 <= c2;
						end else begin
							c2 <= c2 + 1;
						end
					end else if (s3) begin
						if (gnt == 3) begin
							c3 <= c3;
						end else begin
							c3 <= c3 + 1;
						end
					end else if (s4) begin
						if (gnt == 4) begin
							c4 <= c4;
						end else begin
							c4 <= c4 + 1;
						end
					end
				end
				else begin
					if (gnt == 1) begin
						c1 <= c1 - 1;
					end else if (gnt == 2) begin
						c2 <= c2 - 1; 
					end else if (gnt == 3) begin
						c3 <= c3 - 1;
					end else if (gnt == 4) begin
						c4 <= c4 - 1;
					end 
				end
			end
		end
	end
endmodule: page_counter
