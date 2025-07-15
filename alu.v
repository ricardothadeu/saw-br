module alu (

	input alu_out,
	input add_sub,
	input alu0_and,
	input alu1_or,
	input xor_not,
	input [7:0] acc_to_ula,
	input [7:0] b_to_ula,
	output [7:0] bus_out
);

	reg [7:0] data = 8'b00000000;
	wire [3:0] signal = {xor_not,add_sub,alu1_or,alu0_and};
	
	always@(*) begin
		casez(signal) 
				4'b?000: data = acc_to_ula + b_to_ula;
				4'b?100:	data = acc_to_ula - b_to_ula;
				4'b??01: data = acc_to_ula & b_to_ula;
				4'b??10: data = acc_to_ula | b_to_ula;
				4'b0?11: data = acc_to_ula ^ b_to_ula;
				4'b1?11: data = ~acc_to_ula;
			endcase
	end
	
	assign bus_out = alu_out ? data : 8'bzzzzzzzz;

endmodule	