module debouncer (
    input  wire clk,        // clock do FPGA (50 MHz)
    input  wire btn_in,     // botão (ativo-baixo no DE10-Lite)
    output wire btn_out     // pulso único, já "debounced"
);

    // Sinais internos
    reg [19:0] cnt = 0;     // contador para gerar atraso (~20 ms)
    reg        btn_sync_0, btn_sync_1;
    reg        btn_state = 1'b1;  // estado anterior (começa solto: 1)
    wire       btn_pressed;

    // Sincroniza entrada com clock
    always @(posedge clk) begin
        btn_sync_0 <= btn_in;
        btn_sync_1 <= btn_sync_0;
    end

    // Gera atraso se houver mudança
    always @(posedge clk) begin
        if (btn_sync_1 != btn_state) begin
            cnt <= cnt + 1;
            if (cnt == 20'd1_000_000) begin  // ~20 ms @ 50 MHz
                btn_state <= btn_sync_1;
                cnt <= 0;
            end
        end else begin
            cnt <= 0;
        end
    end

    // Detecta transição de 1 → 0 (botão pressionado)
    assign btn_pressed = (btn_state == 1'b0);

    // Saída: pulso de 1 ciclo quando botão é pressionado
    reg btn_out_reg = 0;
    always @(posedge clk) begin
        btn_out_reg <= btn_pressed & ~btn_out_reg;
    end

    assign btn_out = btn_out_reg;
endmodule
