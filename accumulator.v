module accumulator (
	input [7:0] bus_in,
	input clock,
	input acc_in,
	input acc_out,
	output [7:0] bus_out,
	output [7:0] acc_to_ula
);

	reg [7:0] data = 8'b00000000;
	
	always @(posedge clock) begin
		if(acc_in) data <= bus_in;
	end
	
	assign bus_out = acc_out ? data : 8'bzzzzzzzz;
	assign acc_to_ula = data;

endmodule
	