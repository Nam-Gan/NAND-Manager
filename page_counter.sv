`include "params.svh"
module page_counter(
	input logic clk,
	input logic rst,

	input logic s1,
	input logic s2,
	input logic s3,
	input logic s4,

	input logic [`SENS_REG_W:0] gnt, // 0 is idle, i.e. no request granted in the last cycle

	output logic [1:0] c1,
	output logic [1:0] c2,
	output logic [1:0] c3,
	output logic [1:0] c4);

    always_ff @(posedge clk) begin
        if (rst) begin
            c1 <= 0;
        end else begin
            if (s1) begin
                if (gnt == 1) begin
                    c1 <= c1;
                end
                else begin
                    c1 <= c1 + 1;
            end else begin
                if (gnt == 1) begin
                    c1 <= c1 - 1;
                end
                else begin
                    c1 <= c1;
                end
            end
        end
    end
	
    always_ff @(posedge clk) begin
        if (rst) begin
            c2 <= 0;
        end else begin
            if (s2) begin
                if (gnt == 2) begin
                    c2 <= c2;
                end
                else begin
                    c2 <= c2 + 1;
            end else begin
                if (gnt == 2) begin
                    c2 <= c2 - 1;
                end
                else begin
                    c2 <= c2;
                end
            end
        end
    end
    
    always_ff @(posedge clk) begin
        if (rst) begin
            c3 <= 0;
        end else begin
            if (s3) begin
                if (gnt == 3) begin
                    c3 <= c3;
                end
                else begin
                    c3 <= c3 + 1;
            end else begin
                if (gnt == 3) begin
                    c3 <= c3 - 1;
                end
                else begin
                    c3 <= c3;
                end
            end
        end
    end
            
    always_ff @(posedge clk) begin
        if (rst) begin
            c4 <= 0;
        end else begin
            if (s4) begin
                if (gnt == 4) begin
                    c4 <= c4;
                end
                else begin
                    c4 <= c4 + 1;
            end else begin
                if (gnt == 4) begin
                    c4 <= c4 - 1;
                end
                else begin
                    c4 <= c4;
                end
            end
        end
    end
    endmodule: page_counter
