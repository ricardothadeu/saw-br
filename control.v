module control (
	input [3:0] instruction,
	input clock,
	input clear,
	output reg pc_inc, jmp, pc_out, acc_in, acc_out, mar_in, alu_out, add_sub, alu0_and, alu1_or, xor_not, ram_in, ram_out, br_in, ir_in, ir_out, opr_in, hlt_sig
);

	parameter LDA = 4'b0001;
	parameter LDI = 4'b0010;
	parameter STA = 4'b0011;
	parameter ADD = 4'b0100;
	parameter SUB = 4'b0101;
	parameter AND = 4'b0110;
	parameter OR  = 4'b0111;
	parameter XOR = 4'b1000;
	parameter NOT = 4'b1001;
	parameter JMP = 4'b1010;
	parameter OUT = 4'b1110;
	parameter HLT = 4'b1111;
	
	parameter T0 = 5'b00001;
	parameter T1 = 5'b00010;
	parameter T2 = 5'b00100;
	parameter T3 = 5'b01000;
	parameter T4 = 5'b10000;
	
	reg [4:0] ring_counter = T0;
	
always @(negedge clock or negedge clear) begin
	if (!clear) begin
		// Reset assíncrono
		ring_counter <= T0;
		hlt_sig <= 0;

		// Zerar todos os sinais de controle
		pc_inc <= 0; jmp <= 0; pc_out <= 0; acc_in <= 0; acc_out <= 0;
		mar_in <= 0; alu_out <= 0; add_sub <= 0; alu0_and <= 0; alu1_or <= 0;
		xor_not <= 0; ram_in <= 0; ram_out <= 0; br_in <= 0; ir_in <= 0;
		ir_out <= 0; opr_in <= 0;
	end else begin
		// Zera os sinais de controle a cada ciclo
		pc_inc <= 0; jmp <= 0; pc_out <= 0; acc_in <= 0; acc_out <= 0;
		mar_in <= 0; alu_out <= 0; add_sub <= 0; alu0_and <= 0; alu1_or <= 0;
		xor_not <= 0; ram_in <= 0; ram_out <= 0; br_in <= 0; ir_in <= 0;
		ir_out <= 0; opr_in <= 0; hlt_sig <= 0;

		if (instruction == HLT) begin
			hlt_sig <= 1;
		end else begin
			case (ring_counter)
				T0: begin
					pc_out <= 1;
					mar_in <= 1;
				end

				T1: begin
					pc_inc <= 1;
					ram_out <= 1;
					ir_in <= 1;
				end

				T2: begin
					case (instruction)
						LDA, STA, ADD, SUB, AND, OR, XOR: begin
							ir_out <= 1;
							mar_in <= 1;
						end
						LDI: begin
							ir_out <= 1;
							acc_in <= 1;
						end
						NOT: begin
							alu_out <= 1;
							acc_in <= 1;
							alu1_or <= 1;
							alu0_and <= 1;
							xor_not <= 1;
						end
						JMP: begin
							ir_out <= 1;
							jmp <= 1;
						end
						OUT: begin
							acc_out <= 1;
							opr_in <= 1;
						end
					endcase
				end

				T3: begin
					case (instruction)
						LDA: begin
							ram_out <= 1;
							acc_in <= 1;
						end
						STA: begin
							acc_out <= 1;
							ram_in <= 1;
						end
						ADD, SUB, AND, OR, XOR: begin
							ram_out <= 1;
							br_in <= 1;
						end
					endcase
				end

				T4: begin
					case (instruction)
						ADD: begin
							alu_out <= 1;
							acc_in <= 1;
						end
						SUB: begin
							alu_out <= 1;
							acc_in <= 1;
							add_sub <= 1;
						end
						AND: begin
							alu_out <= 1;
							acc_in <= 1;
							alu0_and <= 1;
						end
						OR: begin
							alu_out <= 1;
							acc_in <= 1;
							alu1_or <= 1;
						end
						XOR: begin
							alu_out <= 1;
							acc_in <= 1;
							alu1_or <= 1;
							alu0_and <= 1;
						end
					endcase
				end
			endcase
		end

		// Avança o ring counter
		if (ring_counter == T4)
			ring_counter <= T0;
		else
			ring_counter <= ring_counter << 1;
	end
end

endmodule
