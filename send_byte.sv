`define BIT_PERIOD (1_000_000_000.0 / `BAUD)
parameter int BIT_TICKS = int'($ceil(`BIT_PERIOD));

task send_byte(input [7:0] data);
    input_bus = 0; #BIT_TICKS;
    for (int i = 0; i < 8; i++) begin
        input_bus = data[i]; #BIT_TICKS;
    end
    input_bus = 1; #BIT_TICKS;
endtask
