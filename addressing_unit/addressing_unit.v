`include "../parameters/params.vh"
module addressing_unit(
    // generic signals
    input wire clk,
    input wire nrst,
    // commanding_unit interface
    input wire [3:0] sens_id,
    input wire [1:0] oper,
    output wire [19:0] addr);

    reg [39:0] mem [N_SENSORS-1:0];
    case (oper) 
        NOOP: begin
            assign addr = 20'd0;
        end
        WRITE: begin
            assign addr = mem[39:20][sens_id - 1];
        end
        READ: begin
            assign addr = mem[19:0][sens_id - 1];
        end
        default: begin
            assign addr = 20'd0;
        end
    endcase
    endmodule

