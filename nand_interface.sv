/*
*   Author: @Nam-Gan
*   File name: nand_interface.sv
*/
module nand_interface(
    // Interface to NAND
    output nand_ce_n,
    output nand_cle,
    output nand_ale,
    output nand_we_n,
    output nand_re_n,
    output nand_wp_n,
    inout [7:0] nand_dq,
    input nand_rb_n,
    // Control Interface
    output tick,
    output status,
    inout data_bus,
    // Generic Signals
    input clk,
    input rst);
    

    
    

