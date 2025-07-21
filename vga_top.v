module vga_top (
    input wire clk_50mhz,       // Clock de 50MHz da placa
    output wire hsync,
    output wire vsync,
    output wire [3:0] red,
    output wire [3:0] green,
    output wire [3:0] blue
);

    // ===== Clock Divider: 50 MHz → 25 MHz =====
    reg clk_25mhz = 0;
    always @(posedge clk_50mhz) begin
        clk_25mhz <= ~clk_25mhz;
    end

  
    // Parâmetros VGA 640x480 @60Hz
    localparam H_VISIBLE = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = H_VISIBLE + H_FRONT + H_SYNC + H_BACK;

    localparam V_VISIBLE = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = V_VISIBLE + V_FRONT + V_SYNC + V_BACK;

    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    always @(posedge clk_25mhz) begin
        if (h_count == H_TOTAL - 1) begin
            h_count <= 0;
            if (v_count == V_TOTAL - 1) v_count <= 0;
            else v_count <= v_count + 1;
        end else begin
            h_count <= h_count + 1;
        end
    end

    assign hsync = ~(h_count >= (H_VISIBLE + H_FRONT) && h_count < (H_VISIBLE + H_FRONT + H_SYNC));
    assign vsync = ~(v_count >= (V_VISIBLE + V_FRONT) && v_count < (V_VISIBLE + V_FRONT + V_SYNC));

    wire visible_area = (h_count < H_VISIBLE) && (v_count < V_VISIBLE);

    // Retângulo central (por ex., 200x50 px centralizado)
    wire in_rect = (h_count >= 220 && h_count < 420 && v_count >= 200 && v_count < 250);

    // Posição do texto "PROGRAM COUNTER" — começando em (240, 210)
    wire [7:0] text[0:14] = {
        "P","R","O","G","R","A","M"," ",
        "C","O","U","N","T","E","R"
    };

    wire [3:0] char_idx = (h_count - 240) >> 3;
    wire [2:0] row_idx  = (v_count - 210) % 8;
    wire [2:0] bit_idx  = 7 - ((h_count - 240) % 8);

    wire [7:0] char_code = text[char_idx];

    wire [7:0] font_pixels;
    font_rom font_inst (
        .char_code(char_code),
        .row(row_idx),
        .pixels(font_pixels)
    );

    wire text_pixel = (v_count >= 210 && v_count < 218 && h_count >= 240 && h_count < (240 + 8*15)) ?
                      font_pixels[bit_idx] : 1'b0;

    // Cor
    assign red   = visible_area && (in_rect || text_pixel) ? 4'hF : 4'h0;
    assign green = visible_area && (in_rect || text_pixel) ? 4'hF : 4'h0;
    assign blue  = visible_area && (in_rect || text_pixel) ? 4'hF : 4'h0;

endmodule
