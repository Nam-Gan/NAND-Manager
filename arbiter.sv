module arbiter (
	input logic req1,
	input logic req2,
	input logic req3,
	input logic req4,
	input logic busy;
	input logic rst;

	output logic gnt1,
	output logic gnt2,
	output logic gnt3,
	output logic gnt4);

	// Counters
	logic [1:0] num_reqs_1, num_reqs_2, num_reqs_3, num_reqs_4;
	always_ff @(posedge req1 or posedge rst) begin
		if (rst) begin
			num_reqs_1 <= 0;
			gnt1 <= 1'b0;
		end else begin
			num_reqs_1 <= num_reqs_1 + 1;
		end
	end
	always_ff @(posedge req2 or posedge rst) begin
		if (rst) begin
			num_reqs_2 <= 0;
		end else begin
			num_reqs_2 <= num_reqs_2 + 1;
		end
	end
	always_ff @(posedge req3 or posedge rst) begin
		if (rst) begin
			num_reqs_3 <= 0;
		end else begin
			num_reqs_3 <= num_reqs_3 + 1;
		end
	end
	always_ff @(posedge req4 or posedge rst) begin
		if (rst) begin
			num_reqs_4 <= 0;
		end else begin
			num_reqs_4 <= num_reqs_4 + 1;
		end
	end
