module sap (
	input manual_auto, //isso vai ser um switch que permite escolher entre clock manual ou automatico
	input clock_manual, //isso vai ser um push button
	input [3:0] switch_enderecos, //chaves do fpga.
	input [7:0] switch_dados, //chaves da placa
	input clock_fpga, //MAX10_CLK1_50 (PIN_P11)
	input clear,
	input prog_run, //chave do fpga
	output [7:0] saida //leds
	//output o_clock_sap, o_sig_hlt, o_pc_inc, o_pc_out, o_mar_in, o_ram_out, o_ir_in, o_acc_in, o_acc_out, //PARA VISUALIZACAO
   //output [3:0]o_instrucao //PARA VISUALIZACAO 
);

	wire [7:0] bus;
	
	
	wire sig_pc_out, sig_pc_inc, sig_jmp, sig_acc_in, sig_acc_out, sig_mar_in, sig_ram_in, sig_ram_out, sig_alu_out,
	sig_alu0, sig_alu1, sig_add_sub, sig_xor_not, sig_br_in, sig_ir_in, sig_ir_out, sig_opr_in, sig_hlt;
	
	wire [3:0] ir_to_control;
	wire [3:0] mar_to_ram;
	wire [7:0] acc_to_alu;
	wire [7:0] b_to_alu;
	
	wire clock;
	
//	assign o_clock_sap = clock;
//	assign o_sig_hlt = sig_hlt;
//	assign o_pc_inc = sig_pc_inc;
//	assign o_instrucao = ir_to_control;
//	assign o_acc_in = sig_acc_in;
//	assign o_ir_in = sig_ir_in;
//	assign o_ram_out = sig_ram_out;
//	assign o_pc_out = sig_pc_out;
//	assign o_mar_in = sig_mar_in;
//	assign o_acc_out = sig_acc_out;
	
	
	clock_circuit clock_circuit (
		.prog_run (prog_run),
		.selecao_manual_auto (manual_auto),
		.clock_fpga (clock_fpga),
		.key0 (clock_manual),
		.hlt_sig (sig_hlt),
		.clock_sap (clock)
	);
	
	program_counter program_counter (
		.clock (clock),
		.pc_inc (sig_pc_inc),
		.pc_out (sig_pc_out),
		.clear (clear),
		.jmp (sig_jmp),
		.bus_in (bus),
		.bus_out (bus)
	);
	
	mar mar (
		.clock (clock),
		.mar_in (sig_mar_in),
		.prog_run (prog_run),
		.bus_in (bus),
		.prog_address(switch_enderecos),
		.mar_to_ram (mar_to_ram)
	);
	
	ram ram (
		.clock (clock),
		.ram_in (sig_ram_in),
		.ram_out (sig_ram_out),
		.prog_run (prog_run),
		.mar_to_ram (mar_to_ram),
		.bus_in (bus),
		.switch_dados (switch_dados),
		.bus_out (bus)
	);
	
	accumulator accumulator (
		.bus_in (bus),
		.clock (clock),
		.acc_in (sig_acc_in),
		.acc_out (sig_acc_out),
		.bus_out (bus),
		.acc_to_ula (acc_to_alu)
	);
	
	b_register b_register (
		.clock (clock),
		.br_in (sig_br_in),
		.bus_in (bus),
		.b_to_ula (b_to_alu)
	);
	
	alu alu (
		.alu_out (sig_alu_out),
		.add_sub (sig_add_sub),
		.alu0_and (sig_alu0),
		.alu1_or (sig_alu1),
		.xor_not (sig_xor_not),
		.acc_to_ula (acc_to_alu),
		.b_to_ula (b_to_alu),
		.bus_out (bus)
	);
	
	output_reg output_reg (
		.clock (clock),
		.clear (clear),
		.opr_in (sig_opr_in),
		.bus_in (bus),
		.saida_sap (saida)
	);
	
	instruction_reg instruction_reg (
		.bus_in (bus),
		.clear (clear),
		.clock (clock),
		.ir_in (sig_ir_in),
		.ir_out (sig_ir_out),
		.bus_out (bus),
		.instruction_to_control (ir_to_control)
	);
	
	control control (
		.instruction (ir_to_control),
		.clock (clock),
		.clear (clear),
		.pc_inc (sig_pc_inc), 
		.jmp (sig_jmp), 
		.pc_out (sig_pc_out), 
		.acc_in (sig_acc_in), 
		.acc_out (sig_acc_out), 
		.mar_in (sig_mar_in), 
		.alu_out (sig_alu_out), 
		.add_sub(sig_add_sub),
		.alu0_and (sig_alu0),
		.alu1_or (sig_alu1), 
		.xor_not (sig_xor_not), 
		.ram_in (sig_ram_in), 
		.ram_out (sig_ram_out), 
		.br_in (sig_br_in), 
		.ir_in (sig_ir_in), 
		.ir_out (sig_ir_out), 
		.opr_in (sig_opr_in), 
		.hlt_sig(sig_hlt)
	);
	
endmodule
	