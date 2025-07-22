module program_counter (
	input pc_inc,
	input jmp,
	input clock,
	input pc_out,
	input clear,
	input [3:0] bus_in,
	output [3:0] bus_out
);

	reg [3:0] data = 4'b0000;
	
	always @(posedge clock) begin
    		if (clear)
        		data <= 4'b0000;
    		else if (pc_inc)
        		data <= data + 4'b0001;
    		else if (jmp)
        		data <= bus_in;
	end

	
	assign bus_out = pc_out ? data : 4'bzzzz;
	
endmodule
	
	
