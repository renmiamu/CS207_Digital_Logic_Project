module mode_change(
    input clk,             // 时钟信号
    input reset,           // 复位信号
    input menu_btn,        // 菜单键输入
    input [2:0] speed_btn, // 速度按键输入 (000:无输入, 001:1档, 010:2档, 100:3档)
    input clean_btn,       // 自清洁按键输入
    output reg [2:0] mode, // 模式输出 (000:待机, 001:1档, 010:2档, 011:3档, 100:自清洁)
    output reg countdown   // 倒计时输出（1为倒计时中，0为不倒计时）
);

    // 状态定义
    parameter STANDBY = 3'b000;         // 待机模式
    parameter WAIT_FOR_SPEED = 3'b001;  // 等待速度按键模式
    parameter SUCTION_1 = 3'b010;       // 抽油烟1档
    parameter SUCTION_2 = 3'b011;       // 抽油烟2档
    parameter SUCTION_3 = 3'b100;       // 抽油烟3档
    parameter CLEANING = 3'b111;        // 自清洁模式
    parameter SUCTION_3_TIMER = 3'b101; // 抽油烟3档倒计时模式

    reg [2:0] current_state, next_state;
    reg [31:0] timer; // 倒计时计时器

    // 状态转换
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            current_state <= STANDBY;
            mode <= 3'b000;
        end else begin
            current_state <= next_state;
            
            // 更新模式输出
            case (next_state)
                STANDBY: mode <= 3'b000;
                WAIT_FOR_SPEED: mode <= 3'b000; // 等待输入时保持待机状态
                SUCTION_1: mode <= 3'b001;
                SUCTION_2: mode <= 3'b010;
                SUCTION_3: mode <= 3'b100;
                SUCTION_3_TIMER: mode <= 3'b101; // 保持3档模式，但处于倒计时状态
                CLEANING: mode <= 3'b111;
                default: mode <= 3'b000;
            endcase
        end
    end

    // 状态机逻辑
    always @(*) begin
        next_state = current_state; // 默认保持当前状态
        case(current_state)
            STANDBY: begin
                if (menu_btn) begin
                    next_state = WAIT_FOR_SPEED; // 按菜单键后进入等待速度按键模式
                end
            end
            WAIT_FOR_SPEED: begin
                if (speed_btn != 3'b000) begin
                    case(speed_btn)
                        3'b001: next_state = SUCTION_1;   // 按1档键，进入1档模式
                        3'b010: next_state = SUCTION_2;   // 按2档键，进入2档模式
                        3'b100: next_state = SUCTION_3;   // 按3档键，进入3档模式
                        default: next_state = WAIT_FOR_SPEED;
                    endcase
                end else if (clean_btn) begin
                    next_state = CLEANING; // 按清洁键，进入自清洁模式
                end
            end
            SUCTION_1: begin
                if (menu_btn) next_state = STANDBY;  // 按菜单键返回待机
            end
            SUCTION_2: begin
                if (menu_btn) next_state = STANDBY;  // 按菜单键返回待机
            end
            SUCTION_3: begin
                if (menu_btn) next_state = SUCTION_3_TIMER; // 按菜单键后开始60秒倒计时
            end
            SUCTION_3_TIMER: begin
                if (timer == 0) next_state = STANDBY;  // 倒计时结束后返回待机
            end
            CLEANING: begin
                if (timer > 0)
                    next_state = CLEANING;
                else if (timer == 0)
                    next_state = STANDBY;  // 倒计时结束后返回待机
            end
        endcase
    end

    // 计时器逻辑
    always @(posedge clk or negedge reset) begin
        if (!reset)
            timer <= 32'd300000000;
        else if (current_state == SUCTION_3_TIMER && timer > 0)
            timer <= timer - 1; // 3档倒计时中  // 3档倒计时中
        else if (current_state == SUCTION_3_TIMER && timer == 0)
            timer <= 32'd600000000; // 启动3档倒计时（60秒）  // 启动3档倒计时（60秒）
        else if (current_state == CLEANING && countdown == 1)
            timer <= timer - 1; // 自清洁模式倒计时  // 自清洁模式倒计时
        else if (current_state == CLEANING && timer == 0) timer <= 32'd300000000; // 启动自清洁倒计时（180秒） // 启动自清洁倒计时（180秒）
        else
            timer <= 0;  // 其他模式不计时
    end

    // 倒计时指示
    always @(current_state or timer) begin
        if ((current_state == SUCTION_3_TIMER || current_state == CLEANING) && timer > 0)
            countdown = 1;  // 倒计时中
        else
            countdown = 0;  // 不倒计时
    end

endmodule