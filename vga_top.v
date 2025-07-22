module vga_top (
    input wire clk_50mhz,
    output wire hsync,
    output wire vsync,
    output wire [3:0] red,
    output wire [3:0] green,
    output wire [3:0] blue
);

    // Clock divider: 50 MHz → 25 MHz
    reg clk_25mhz = 0;
    always @(posedge clk_50mhz) begin
        clk_25mhz <= ~clk_25mhz;
    end

    // VGA 640x480 @60Hz timing parameters
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

    // Central rectangle (for visual block)
    wire in_rect = (h_count >= 220 && h_count < 420 && v_count >= 200 && v_count < 250);

    // ========== Linha 1: "PROGRAM COUNTER" ==========
    wire [7:0] text1[0:14] = {
        "P","R","O","G","R","A","M"," ",
        "C","O","U","N","T","E","R"
    };
    wire [3:0] char_idx1 = (h_count - 240) >> 3;
    wire [2:0] row_idx1  = (v_count - 210) % 8;
    wire [2:0] bit_idx1  = 7 - ((h_count - 240) % 8);
    wire [7:0] char_code1 = text1[char_idx1];

    wire [7:0] font_pixels1;
    font_rom font1 (
        .char_code(char_code1),
        .row(row_idx1),
        .pixels(font_pixels1)
    );

    wire text_pixel1 = (v_count >= 210 && v_count < 218 && h_count >= 240 && h_count < (240 + 8*15)) ?
                       font_pixels1[bit_idx1] : 1'b0;

    // ========== Linha 2: "1010" ==========
    wire [7:0] text2[0:3] = { "1", "0", "1", "0" };
    wire [2:0] row_idx2  = (v_count - 233) % 8;
    wire [3:0] char_idx2 = (h_count - 240) >> 3;
    wire [2:0] bit_idx2  = 7 - ((h_count - 240) % 8);
    wire [7:0] char_code2 = text2[char_idx2];

    wire [7:0] font_pixels2;
    font_rom font2 (
        .char_code(char_code2),
        .row(row_idx2),
        .pixels(font_pixels2)
    );

    wire text_pixel2 = (v_count >= 233 && v_count < 241 && h_count >= 240 && h_count < (240 + 8*4)) ?
                       font_pixels2[bit_idx2] : 1'b0;

    // ===== Cor final =====
    wire pixel_on = visible_area && (in_rect || text_pixel1 || text_pixel2);
    assign red   = pixel_on ? 4'hF : 4'h0;
    assign green = pixel_on ? 4'hF : 4'h0;
    assign blue  = pixel_on ? 4'hF : 4'h0;

endmodule
