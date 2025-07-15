module mar (
	input clock, 
	input mar_in, 
	input prog_run, //1 = run
	input [3:0] bus_in,
	input [3:0] prog_address, //endereco das chaves
	output [3:0] mar_to_ram
);
	
	reg [3:0] data = 4'b0000;
	always @ (posedge clock) begin
		if(mar_in) data <= bus_in;
	end
	
	assign mar_to_ram = prog_run ? data : prog_address;
	
endmodule 