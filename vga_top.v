module vga_top (
    input  wire       clk_50mhz,   
    input  wire       reset_n,     // reset ativo em zero
	 
	 input  wire [3:0] pc_ascii,
	 input  wire [3:0] mar_ascii,
	 input  wire [7:0] ir_ascii,
	 input  wire [7:0] acc_ascii,
	 input  wire [7:0] alu_ascii,
	 input  wire [7:0] breg_ascii,
	 input  wire [7:0] output_reg_ascii,
	 
    output wire       hsync,       
    output wire       vsync,      
    output wire [3:0] red,         
    output wire [3:0] green,       
    output wire [3:0] blue         
);

    // ==================================
    // 1) Divisor de clock 50MHz -> 25MHz
    // ==================================
    reg clk_25mhz_reg = 0;
    always @(posedge clk_50mhz or negedge reset_n) begin
        if (!reset_n)
            clk_25mhz_reg <= 0;
        else
            clk_25mhz_reg <= ~clk_25mhz_reg;
    end
    wire clk_25mhz = clk_25mhz_reg;

    // ================================
    // 2) Parâmetros do VGA 640x480 @60Hz
    // ================================
    localparam H_DISPLAY = 640;
    localparam H_FRONT   = 16;
    localparam H_PULSE   = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = H_DISPLAY + H_FRONT + H_PULSE + H_BACK;

    localparam V_DISPLAY = 480;
    localparam V_FRONT   = 10;
    localparam V_PULSE   = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = V_DISPLAY + V_FRONT + V_PULSE + V_BACK;

    // ===================================
    // 3) Contadores horizontal e vertical
    // ===================================
    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;
    always @(posedge clk_25mhz or negedge reset_n) begin
        if (!reset_n) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                if (v_count == V_TOTAL - 1)
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end
        end
    end
    wire [9:0] pixel_x = h_count;
    wire [9:0] pixel_y = v_count;

    // =======================
    // 4) Sinais HSYNC e VSYNC
    // =======================
    assign hsync = ~((pixel_x >= H_DISPLAY + H_FRONT) &&
                     (pixel_x <  H_DISPLAY + H_FRONT + H_PULSE));
    assign vsync = ~((pixel_y >= V_DISPLAY + V_FRONT) &&
                     (pixel_y <  V_DISPLAY + V_FRONT + V_PULSE));

    // =======================
    // 5) Região Visível
    // =======================
    wire video_on = (pixel_x < H_DISPLAY) && (pixel_y < V_DISPLAY);

    // =====================================
    // 6) Coordenadas dos retângulos maiores
    // ======================================
    localparam PC_X0   = 53,  PC_Y0   = 24,  PC_X1   = 242, PC_Y1   = 96;
    localparam MAR_X0  = 53,  MAR_Y0  = 111, MAR_X1  = 242, MAR_Y1  = 183;
    localparam RAM_X0  = 53,  RAM_Y0  = 197, RAM_X1  = 242, RAM_Y1  = 380;
    localparam IR_X0   = 53,  IR_Y0   = 393, IR_X1   = 242, IR_Y1   = 464;
    localparam BUS_X0  = 306, BUS_Y0  = 24,  BUS_X1  = 335, BUS_Y1  = 423;
    localparam ACC_X0  = 400, ACC_Y0  = 24,  ACC_X1  = 589, ACC_Y1  = 96;
    localparam ULA_X0  = 400, ULA_Y0  = 111, ULA_X1  = 589, ULA_Y1  = 183;
    localparam B_X0    = 400, B_Y0    = 197, B_X1    = 589, B_Y1    = 269;
    localparam OUT_X0  = 400, OUT_Y0  = 284, OUT_X1  = 589, OUT_Y1  = 355;
    localparam CTRL_X0 = 400, CTRL_Y0 = 371, CTRL_X1 = 592, CTRL_Y1 = 469;

    wire b_pc   = (pixel_x >= PC_X0   && pixel_x <= PC_X1   && pixel_y >= PC_Y0   && pixel_y <= PC_Y1   &&
                  (pixel_x == PC_X0   || pixel_x == PC_X1   || pixel_y == PC_Y0   || pixel_y == PC_Y1));
    wire b_mar  = (pixel_x >= MAR_X0  && pixel_x <= MAR_X1  && pixel_y >= MAR_Y0  && pixel_y <= MAR_Y1  &&
                  (pixel_x == MAR_X0  || pixel_x == MAR_X1  || pixel_y == MAR_Y0  || pixel_y == MAR_Y1));
    wire b_ram  = (pixel_x >= RAM_X0  && pixel_x <= RAM_X1  && pixel_y >= RAM_Y0  && pixel_y <= RAM_Y1  &&
                  (pixel_x == RAM_X0  || pixel_x == RAM_X1  || pixel_y == RAM_Y0  || pixel_y == RAM_Y1));
    wire b_ir   = (pixel_x >= IR_X0   && pixel_x <= IR_X1   && pixel_y >= IR_Y0   && pixel_y <= IR_Y1   &&
                  (pixel_x == IR_X0   || pixel_x == IR_X1   || pixel_y == IR_Y0   || pixel_y == IR_Y1));
    wire b_bus  = (pixel_x >= BUS_X0  && pixel_x <= BUS_X1  && pixel_y >= BUS_Y0  && pixel_y <= BUS_Y1  &&
                  (pixel_x == BUS_X0  || pixel_x == BUS_X1  || pixel_y == BUS_Y0  || pixel_y == BUS_Y1));
    wire b_acc  = (pixel_x >= ACC_X0  && pixel_x <= ACC_X1  && pixel_y >= ACC_Y0  && pixel_y <= ACC_Y1  &&
                  (pixel_x == ACC_X0  || pixel_x == ACC_X1  || pixel_y == ACC_Y0  || pixel_y == ACC_Y1));
    wire b_ula  = (pixel_x >= ULA_X0  && pixel_x <= ULA_X1  && pixel_y >= ULA_Y0  && pixel_y <= ULA_Y1  &&
                  (pixel_x == ULA_X0  || pixel_x == ULA_X1  || pixel_y == ULA_Y0  || pixel_y == ULA_Y1));
    wire b_b    = (pixel_x >= B_X0    && pixel_x <= B_X1    && pixel_y >= B_Y0    && pixel_y <= B_Y1    &&
                  (pixel_x == B_X0    || pixel_x == B_X1    || pixel_y == B_Y0    || pixel_y == B_Y1));
    wire b_out  = (pixel_x >= OUT_X0  && pixel_x <= OUT_X1  && pixel_y >= OUT_Y0  && pixel_y <= OUT_Y1  &&
                  (pixel_x == OUT_X0  || pixel_x == OUT_X1  || pixel_y == OUT_Y0  || pixel_y == OUT_Y1));
    wire b_ctrl = (pixel_x >= CTRL_X0 && pixel_x <= CTRL_X1 && pixel_y >= CTRL_Y0 && pixel_y <= CTRL_Y1 &&
                  (pixel_x == CTRL_X0 || pixel_x == CTRL_X1 || pixel_y == CTRL_Y0 || pixel_y == CTRL_Y1));

    wire any_border = b_pc | b_mar | b_ram | b_ir | b_bus | b_acc | b_ula | b_b | b_out | b_ctrl;

    // ===================================================
    // 7) Textos - usando arrays para otimizar
    // ===================================================
    
	 //Esses serao fonte 8x16
	 localparam NUM_TEXTS = 18;
	 localparam NUM_TEXTS_8x16 = 18;
	 //localparam NUM_TEXTS_8x8 = NUM_TEXTS - NUM_TEXTS_8x16;
	 
	 
    reg [9:0] text_x [0:NUM_TEXTS-1];
    reg [9:0] text_y [0:NUM_TEXTS-1];
    reg [4:0] text_len [0:NUM_TEXTS-1];
    reg [8*20-1:0] text_data [0:NUM_TEXTS-1]; // até 20 chars cada
	 
	  // Fonte
    reg [7:0] char_code;
    reg [3:0] row;
    wire [7:0] font_data;
	 
	 font_rom_8x16 font_inst(
        .char_code(char_code),
        .row(row),
        .data(font_data)
    );
	 
	 
	 reg pixel_on_text; //pixel dos textos
    integer i; //usado para iteracao no for
    integer char_index; //
    integer bit_index; //


    initial begin
		  //textos fixos 
        text_x[0] = 68; text_y[0] = 40;  text_len[0] = 15; text_data[0] = "PROGRAM COUNTER";
        text_x[1] = 68; text_y[1] = 127; text_len[1] = 3;  text_data[1] = "MAR";
        text_x[2] = 68; text_y[2] = 408; text_len[2] = 19; text_data[2] = "INSTRUCTION REGISTER";
        text_x[3] = 415; text_y[3] = 379; text_len[3] = 7;  text_data[3] = "CONTROL";
        text_x[4] = 415; text_y[4] = 299; text_len[4] = 15; text_data[4] = "OUTPUT REGISTER";
        text_x[5] = 415; text_y[5] = 213; text_len[5] = 10; text_data[5] = "B REGISTER";
        text_x[6] = 415; text_y[6] = 127; text_len[6] = 3;  text_data[6] = "ALU";
        text_x[7] = 415; text_y[7] = 40;  text_len[7] = 11; text_data[7] = "ACCUMULATOR";
		  text_x[8] = 127; text_y[8] = 207; text_len[8] = 3; text_data[8] = "RAM";
		  text_x[9] = 78;  text_y[9] = 232; text_len[9] = 7; text_data[9] = "ADDRESS";
		  text_x[10] = 150; text_y[10] = 232; text_len[10] = 4; text_data[10] = "DATA";
		  
		  //conteudo da RAM. FONTE 8x8
		  text_x[18] = 78; text_y[18] = 250; text_len[18] = 4; text_data[11] = "0000";
		  text_x[19] = 78; text_y[19] = 258; text_len[19] = 4; text_data[12] = "0001";
		  text_x[20] = 78; text_y[20] = 266; text_len[20] = 4; text_data[13] = "0010";
		  text_x[21] = 78; text_y[21] = 274; text_len[21] = 4; text_data[14] = "0011";
		  text_x[22] = 78; text_y[22] = 282; text_len[22] = 4; text_data[15] = "0100";
		  text_x[23] = 78; text_y[23] = 290; text_len[23] = 4; text_data[16] = "0101";
		  text_x[24] = 78; text_y[24] = 298; text_len[24] = 4; text_data[17] = "0110";
		  text_x[25] = 78; text_y[25] = 306; text_len[18] = 4; text_data[18] = "0111";
		  text_x[26] = 78; text_y[26] = 314; text_len[19] = 4; text_data[19] = "1000";
		  text_x[27] = 78; text_y[27] = 320; text_len[20] = 4; text_data[20] = "1001";
		  text_x[28] = 78; text_y[28] = 328; text_len[21] = 4; text_data[21] = "1010";
		  text_x[29] = 78; text_y[29] = 336; text_len[22] = 4; text_data[22] = "1011";
		  text_x[30] = 78; text_y[30] = 344; text_len[23] = 4; text_data[23] = "1100";
		  text_x[31] = 78; text_y[31] = 352; text_len[24] = 4; text_data[24] = "1101";
		  text_x[32] = 78; text_y[32] = 360; text_len[25] = 4; text_data[25] = "1110";
		  text_x[33] = 78; text_y[33] = 368; text_len[26] = 4; text_data[26] = "1111";
		  
		end
		
		always @(*) begin
	  // textos dinâmicos:
	  text_x[11] = 68; text_y[11] = 66; text_len[11] = 4; text_data[11] = { {(20-4){8'h20}}, pc_ascii };
	  text_x[12] = 68; text_y[12] = 153; text_len[12] = 4; text_data[12] = { {(20-4){8'h20}}, mar_ascii };
	  text_x[13] = 68; text_y[13] = 433; text_len[13] = 8; text_data[13] = { {(20-8){8'h20}}, ir_ascii };
	  text_x[14] = 415; text_y[14] = 66; text_len[14] = 8; text_data[14] = { {(20-8){8'h20}}, acc_ascii };
	  text_x[15] = 415; text_y[15] = 153; text_len[15] = 8; text_data[15] = { {(20-8){8'h20}}, alu_ascii };
	  text_x[16] = 415; text_y[16] = 239; text_len[16] = 8; text_data[16] = { {(20-8){8'h20}}, breg_ascii };
	  text_x[17] = 415; text_y[17] = 325; text_len[17] = 8; text_data[17] = { {(20-8){8'h20}}, output_reg_ascii };
	  

	  // Renderiza todos os textos (fixos + dinâmicos)
	  pixel_on_text = 0;
	  char_code     = 8'h20;
	  row           = 0;
	  for (i = 0; i < NUM_TEXTS_8x16; i = i + 1) begin
		 if (pixel_x >= text_x[i] && pixel_x < text_x[i] + 8 * text_len[i] &&
			  pixel_y >= text_y[i] && pixel_y < text_y[i] + 16) begin

			char_index = (pixel_x - text_x[i]) / 8;
			bit_index  = (pixel_x - text_x[i]) % 8;
			row = (pixel_y - text_y[i]) % 16;

			char_code     = text_data[i][8*(text_len[i]-char_index)-1 -: 8];
			pixel_on_text = font_data[7 - bit_index];
		 end
	  end
	end

    // =============================================================
    // 8) Combinar texto + borda + fundo
    // =============================================================
    wire [3:0] white = 4'b1111;
    wire [3:0] black = 4'b0000;

    assign red   = (video_on && (any_border || pixel_on_text)) ? white : black;
    assign green = (video_on && (any_border || pixel_on_text)) ? white : black;
    assign blue  = (video_on && (any_border || pixel_on_text)) ? white : black;

endmodule