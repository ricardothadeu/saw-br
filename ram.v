module ram (
    input clock,          // pulso de 1 ciclo (mesmo usado no SAP)
    input ram_in,             // sinal de controle da UC (modo RUN)
    input ram_out,            // controle de leitura
    input prog_run,           // 0 = modo PROG, 1 = modo RUN
    input [3:0] mar_to_ram,   // endereço (MAR)
    input [7:0] bus_in,       // dado vindo do barramento
    input [7:0] switch_dados, // switches do usuário (modo PROG)
    output [7:0] bus_out
);

    reg [7:0] memory[0:15];
	 
//	 initial begin
//		$readmemb("ram.mem", memory);
//	 end

    always @(posedge clock) begin
        if (!prog_run) //MODO PROG
            memory[mar_to_ram] <= switch_dados;
        else if (prog_run && ram_in) //Modo RUN e sinal de controle RAM_IN
            memory[mar_to_ram] <= bus_in;

    end

    assign bus_out = ram_out ? memory[mar_to_ram] : 8'bzzzzzzzz;

endmodule 