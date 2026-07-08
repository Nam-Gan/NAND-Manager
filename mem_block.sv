`include "params.svh"
`include "ring_buffer.sv"
module mem_block(
    // Sensor Inputs
    input logic i1,
    input logic i2,
    input logic i3,
    input logic i4,
    // Control Inputs
    input logic tick,
    input logic [`SENS_REG_W: 0] gnt,
    // Request Outputs
    output logic r1,
    output logic r2,
    output logic r3,
    output logic r4,
    // Universal Inputs
    input logic rst,
    input logic clk,
    // Output Bus
    output logic [7:0] output_bus);
    logic tick1, tick2, tick3, tick4;
    logic [7:0] out1, out2, out3, out4;
    ring_buffer #(.PAGES(3), .BAUD(3_000_000))sens1(.rst(rst), .clk(clk), .input_bus(i1), .output_bus(out1), .req(r1), .tick(tick1));
    ring_buffer sens2(.rst(rst), .clk(clk), .input_bus(i2), .output_bus(out2), .req(r2), .tick(tick2));
    ring_buffer sens3(.rst(rst), .clk(clk), .input_bus(i3), .output_bus(out3), .req(r3), .tick(tick3));
    ring_buffer sens4(.rst(rst), .clk(clk), .input_bus(i4), .output_bus(out4), .req(r4), .tick(tick4));
    always_comb begin
        tick1 = 0;
        tick2 = 0;
        tick3 = 0;
        tick4 = 0;
        case (gnt) 
            1: begin
                tick1 = tick;
                output_bus = out1;
            end
            2: begin
                tick2 = tick;
                output_bus = out2;
            end
            3: begin
                tick3 = tick;
                output_bus = out3;
            end
            4: begin
                tick4 = tick;
                output_bus = out4;
            end
            default: begin
                tick1 = 0;
                tick2 = 0;
                tick3 = 0;
                tick4 = 0;
                output_bus = 0;
            end
        endcase
    end
    endmodule: mem_block
