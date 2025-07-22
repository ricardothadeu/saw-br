module clock_circuit (
    input  wire clock_fpga,
    input  wire prog_run,
    input  wire selecao_manual_auto,
    input  wire key0,       // botão ativo‑baixa
    input  wire hlt_sig,
    output wire clock_sap
);

    // armazena valor anterior
    reg key0_d;
    always @(posedge clock_fpga)
        key0_d <= key0;

    // detecta pressão do botão (1→0)
    wire key0_fall = key0_d && ~key0;

    assign clock_sap =
        (hlt_sig)              ? 1'b0 :    // se halt, sem clock
        (selecao_manual_auto)  ? clock_fpga: // modo auto
                                 key0_fall; // manual: pulso ao apertar
endmodule
