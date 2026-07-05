//All signals with _n appended to their names are active low signals.
module nand_interface(
	// NAND Interface port declaration	
	output logic nand_ce1_n, // Target 1 chip enable
	output logic nand_ce2_n, // Target 2 chip enable 
	output logic nand_cle, // Command latch enable
	output logic nand_ale, // Address latch enable 
	output logic nand_we_n,// Write enable
	output logic nand_re_n, // Read enable
	inout logic [7:0] nand_dq, // Data/Command/Address Bus
	output logic nand_wp_n, // Write Protect
	input logic nand_rb1_n, // Ready/Busy for target 1
	input logic nand_rb2_n, // Ready/Busy for target 2
	
	// Component interface port declaration
	
	



