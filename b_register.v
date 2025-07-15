module b_register (
	input clock,
	input br_in,
	input [7:0] bus_in,
	output [7:0] b_to_ula
);

	reg [7:0] data = 8'b00000000;
	
	always @(posedge clock) begin
		if(br_in) data <= bus_in;
	end
	
	assign b_to_ula = data;
	
endmodule

	
	