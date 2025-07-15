//module clock_circuit (
//    
//	 input prog_run, 
//    input manual_auto,        // quando 1 = automático (clock do FPGA), 0 = manual (botão)
//    input clock_auto,         // clock do proprio FPGA
//    input clock_manual,       // pulso único vindo do botão
//    input hlt_sig,            // sinal de controle que interrompe o processamento quando for 1
//    output clock_sap          // clock final que alimenta o SAP-1
//);
//
//    assign clock_sap = (prog_run && ((manual_auto && clock_auto) || (!manual_auto && clock_manual)) && !hlt_sig);
//
//endmodule

module clock_circuit (
    input  clock_fpga,
    input  prog_run,
    input  selecao_manual_auto,
    input  key0,
    input  hlt_sig,
    output clock_sap
);

    reg  key0_d;
    wire key0_rise = (key0_d == 1'b0) && (key0 == 1'b1);

    // Sincroniza o botão
    always @(posedge clock_fpga) begin
        key0_d <= key0;
    end

    // Gera clock_sap combinacionalmente
    assign clock_sap = //(!prog_run || hlt_sig) ? 1'b0 : 
							  (hlt_sig) ? 1'b0 :
                       (selecao_manual_auto) ? clock_fpga :
                       key0_rise;
endmodule

