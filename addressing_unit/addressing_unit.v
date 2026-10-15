`include "../parameters/params.vh"
module addressing_unit(
    // generic signals
    input wire clk,
    input wire nrst,
    // commanding_unit interface
    input wire [3:0] sens_id,
    input wire [1:0] oper,
    output wire [19:0] addr);

    localparam
        NOOP = 2'b00,
        WRITE = 2'b01,
        READ = 2'b10;

    always @(*)
        case (sens_id) 
            `ATMOLITE: begin
                case(oper)
                    WRITE: begin
                        addr = 20'b0_0_00000000000_0000000; // LUN-select Plane-select Block-select Page-select
                    end
                    READ: begin
                        addr = 20'b0_0_00000000000_0000000; // LUN-select Plane-select Block-select Page-select
                    end
                endcase
            end
            `DFGM: begin
                case(oper)
                    WRITE: begin
                        addr = 20'b0_0_00000000000_0000000; // LUN-select Plane-select Block-select Page-select
                    end
                    READ: begin
                        addr = 20'b0_0_00000000000_0000000; // LUN-select Plane-select Block-select Page-select
                    end
                endcase
            end
            `DUMMY1: begin
                case(oper)
                    WRITE: begin
                        addr = 20'b0_0_00000000000_0000000; // LUN-select Plane-select Block-select Page-select
                    end
                    READ: begin
                        addr = 20'b0_0_00000000000_0000000; // LUN-select Plane-select Block-select Page-select
                    end
                endcase
            end
            `DUMMY2: begin
                case(oper)
                    WRITE: begin
                        addr = 20'b0_0_00000000000_0000000; // LUN-select Plane-select Block-select Page-select
                    end
                    READ: begin
                        addr = 20'b0_0_00000000000_0000000; // LUN-select Plane-select Block-select Page-select
                    end
                endcase
            end
        endcase
    end
endmodule

