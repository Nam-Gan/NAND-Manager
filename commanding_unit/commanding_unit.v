module commanding_unit(
    // Generic Signals
    input wire clk,
    input wire nrst,
    // nand_master interface
    output wire nreset,
    input  wire [7:0] from_nand,
    output reg [7:0] to_nand,
    input wire nand_busy,
    output reg activate,
    output reg [7:0] cmd_out,
    // addressing unit interface
    output reg [3:0] sens_id,
    output reg [1:0] oper, 
    input wire [19:0] addr,
    // control interface
    input wire [3:0] sens_id_in,
    inout wire [7:0] dq,
    input wire [1:0] control_in,
    output wire busy);

    // sequential elements
    reg [7:0] n_state; 
    reg [7:0] state;   
    reg [13:0] cycle_c;
    reg [1:0] opcode; 
    reg [3:0] sensor;
    reg [19:0] curr_addr;
    reg [3:0] t_delay;
    localparam
        NOOP = 2'b00,
        WRITE = 2'b01,
        READ = 2'b10;
    localparam 
        RESET = 8'd0,
        IDLE =  8'd1,
        WAIT = 8'd2,
        START1 = 8'd3,
        START2 = 8'd4,
        FETCH_ADDRESS = 8'd5,
        SET_ADDRESS = 8'd6,
        READ_PAGE = 8'd7,
        SET_DATA = 8'd8,
        WRITE_PAGE = 8'd9;



    //------------------------------
    // state        code
    // RESET        0
    // IDLE         1
    // WAIT         2
    // START1       3
    // START2       4
    // ADDRESS1     5
    // ADDRESS2     6
    // ADDRESS3     7
    // WRITE1       8
    // WRITE2       9
    // WRITE3       10
    //
    // 
    //
    // Combinational Logic

    
    always @(posedge clk) begin
        if (!nrst) 
        begin
            state <= RESET;
        end
        else
            case(state)
                RESET: begin
                    state <= IDLE;
                    n_state <= IDLE;
                    opcode <= NOOP;
                    sensor <= 4'b0000;
                    curr_addr <= 0;
                    t_delay <= 0;
                end
                IDLE: begin
                    case(control_in)
                        NOOP: begin
                            state <= IDLE;
                            opcode <= NOOP;
                        end
                        READ: begin
                            opcode <= READ;
                            state <= START1;
                        end
                        WRITE: begin
                            opcode <= WRITE;
                            state <= START1;
                        end
                        default: begin
                            state <= IDLE;
                            opcode <= NOOP;
                        end
                    endcase
                end
                WAIT: begin
                    state <= (nand_busy) ? WAIT : n_state;
                end
                START1: begin
                    activate <= 1;
                    cmd_out <= 8'd1; // M_NAND_RESET
                    state <= WAIT;
                    n_state <= START2;
                end
                START2: begin
                    activate <= 0;
                    case(opcode) 
                        READ: begin
                        end
                        WRITE: begin
                        end
                        default: begin
                        end
                    endcase
                end
                FETCH_ADDRESS: begin
                end
                SET_ADDRESS: begin
                end
                READ_PAGE: begin
                end
                SET_DATA: begin
                end
                WRITE_PAGE: begin
                end
                default: begin
                    state <= IDLE;
                end
            endcase
    end
endmodule




