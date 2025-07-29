// Modulo VGA com 10 retangulos de bordas brancas de 1 pixel e tela de fundo preto
// VGA 640x480@60Hz e divisor de clock de 50 MHz (o da placa) para o clock de 25 MHz necessario no VGA

module vga_top(
    input  wire       clk_50mhz,   
    input  wire       reset_n,     // reset ativo em zero
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
    // =================================
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
    // =========================
    assign hsync = ~((pixel_x >= H_DISPLAY + H_FRONT) &&
                     (pixel_x <  H_DISPLAY + H_FRONT + H_PULSE));
    assign vsync = ~((pixel_y >= V_DISPLAY + V_FRONT) &&
                     (pixel_y <  V_DISPLAY + V_FRONT + V_PULSE));

     // =======================
    // 5) Regiao Visivel
    // =======================
    wire video_on = (pixel_x < H_DISPLAY) && (pixel_y < V_DISPLAY);

     // =====================================
    // 6) Coordenadas dos retangulos maiores
    // ======================================
    
	 // Program Counter
    localparam PC_X0 = 53,  PC_Y0 = 24;
    localparam PC_X1 = 242, PC_Y1 = 96;
    // MAR
    localparam MAR_X0 = 53,   MAR_Y0 = 111;
    localparam MAR_X1 = 242,  MAR_Y1 = 183;
    // RAM
    localparam RAM_X0 = 53,   RAM_Y0 = 197;
    localparam RAM_X1 = 242,  RAM_Y1 = 380;
    // Instruction Register
    localparam IR_X0  = 53,   IR_Y0  = 393;
    localparam IR_X1  = 242,  IR_Y1  = 464;
    // Bus
    localparam BUS_X0 = 306,  BUS_Y0 = 24;
    localparam BUS_X1 = 335,  BUS_Y1 = 423;
    // Accumulator
    localparam ACC_X0 = 400,  ACC_Y0 = 24;
    localparam ACC_X1 = 589,  ACC_Y1 = 96;
    // ALU
    localparam ULA_X0 = 400,  ULA_Y0 = 111;
    localparam ULA_X1 = 589,  ULA_Y1 = 183;
    // B Register
    localparam B_X0   = 400,  B_Y0   = 197;
    localparam B_X1   = 589,  B_Y1   = 269;
    // Output Register
    localparam OUT_X0 = 400,  OUT_Y0 = 284;
    localparam OUT_X1 = 589,  OUT_Y1 = 355;
    // Control
    localparam CTRL_X0= 400,  CTRL_Y0= 371;
    localparam CTRL_X1= 592,  CTRL_Y1= 469;

	 // =========================================================
    // 7) Representa cada retangulo de acordo com as coordenadas
    // =========================================================
	 
	 //PROGRAM COUNTER
    wire b_pc  = (pixel_x >= PC_X0  && pixel_x <= PC_X1  && pixel_y >= PC_Y0  && pixel_y <= PC_Y1  &&
                 (pixel_x == PC_X0  || pixel_x == PC_X1  || pixel_y == PC_Y0  || pixel_y == PC_Y1));
					  
	//MAR
    wire b_mar = (pixel_x >= MAR_X0 && pixel_x <= MAR_X1 && pixel_y >= MAR_Y0 && pixel_y <= MAR_Y1 &&
                 (pixel_x == MAR_X0 || pixel_x == MAR_X1 || pixel_y == MAR_Y0 || pixel_y == MAR_Y1));
					  
	//RAM
    wire b_ram = (pixel_x >= RAM_X0 && pixel_x <= RAM_X1 && pixel_y >= RAM_Y0 && pixel_y <= RAM_Y1 &&
                 (pixel_x == RAM_X0 || pixel_x == RAM_X1 || pixel_y == RAM_Y0 || pixel_y == RAM_Y1));
					  
	//INSTRUCTION REGISTER
    wire b_ir  = (pixel_x >= IR_X0  && pixel_x <= IR_X1  && pixel_y >= IR_Y0  && pixel_y <= IR_Y1  &&
                 (pixel_x == IR_X0  || pixel_x == IR_X1  || pixel_y == IR_Y0  || pixel_y == IR_Y1));
					  
	//BUS
    wire b_bus = (pixel_x >= BUS_X0 && pixel_x <= BUS_X1 && pixel_y >= BUS_Y0 && pixel_y <= BUS_Y1 &&
                 (pixel_x == BUS_X0 || pixel_x == BUS_X1 || pixel_y == BUS_Y0 || pixel_y == BUS_Y1));
					  
	//ACCUMULATOR
    wire b_acc = (pixel_x >= ACC_X0 && pixel_x <= ACC_X1 && pixel_y >= ACC_Y0 && pixel_y <= ACC_Y1 &&
                 (pixel_x == ACC_X0 || pixel_x == ACC_X1 || pixel_y == ACC_Y0 || pixel_y == ACC_Y1));
					  
	//ALU
    wire b_ula = (pixel_x >= ULA_X0 && pixel_x <= ULA_X1 && pixel_y >= ULA_Y0 && pixel_y <= ULA_Y1 &&
                 (pixel_x == ULA_X0 || pixel_x == ULA_X1 || pixel_y == ULA_Y0 || pixel_y == ULA_Y1));
					  
	//B_REGISTER
    wire b_b   = (pixel_x >= B_X0   && pixel_x <= B_X1   && pixel_y >= B_Y0   && pixel_y <= B_Y1   &&
                 (pixel_x == B_X0   || pixel_x == B_X1   || pixel_y == B_Y0   || pixel_y == B_Y1));
					  
	//OUTPUT REGISTER
    wire b_out = (pixel_x >= OUT_X0 && pixel_x <= OUT_X1 && pixel_y >= OUT_Y0 && pixel_y <= OUT_Y1 &&
                 (pixel_x == OUT_X0 || pixel_x == OUT_X1 || pixel_y == OUT_Y0 || pixel_y == OUT_Y1));
					  
	//CONTROL
    wire b_ctrl= (pixel_x >= CTRL_X0&& pixel_x <= CTRL_X1&& pixel_y >= CTRL_Y0&& pixel_y <= CTRL_Y1&&
                 (pixel_x == CTRL_X0|| pixel_x == CTRL_X1|| pixel_y == CTRL_Y0|| pixel_y == CTRL_Y1));


	  // =======================
    // 8) Combinar as bordas
    // ========================
   
	//Se qualquer um deles for 1, significa que o pixel atual está na borda de algum bloco.
    wire any_border = b_pc | b_mar | b_ram | b_ir | b_bus |
                      b_acc | b_ula | b_b   | b_out| b_ctrl;
							 
	 // =============================================================
    // 9) Atribuir as cores dos pixels: bordas brancas, fundo preto
    // =============================================================
    
    wire [3:0] white = 4'b1111;
    wire [3:0] black = 4'b0000;

    assign red   = (video_on && any_border) ? white : black;
    assign green = (video_on && any_border) ? white : black;
    assign blue  = (video_on && any_border) ? white : black;

endmodule
