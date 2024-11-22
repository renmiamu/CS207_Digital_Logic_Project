`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/20 19:19:31
// Design Name: 
// Module Name: mode_change
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

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
    parameter STANDBY = 3'b000;          // 待机模式
    parameter WAIT_FOR_SPEED = 3'b001;   // 等待速度按键模式
    parameter SUCTION_1 = 3'b010;        // 抽油烟1档
    parameter SUCTION_2 = 3'b011;        // 抽油烟2档
    parameter SUCTION_3 = 3'b100;        // 抽油烟3档
    parameter CLEANING = 3'b111;         // 自清洁模式
    parameter SUCTION_3_TIMER = 3'b101;  // 抽油烟3档倒计时模式
    parameter RETURN_TO_STANDBY = 3'b110; // 返回待机的倒计时模式

    reg [2:0] current_state, next_state;
    reg [31:0] timer; // 倒计时计时器
    reg suction_3_used; // 标志风扇三级档位是否已经使用

    // 消抖逻辑信号
    reg menu_btn_sync_0, menu_btn_sync_1;
    reg [19:0] debounce_counter; // 20-bit计数器用于消抖
    reg menu_btn_stable;

    // 按键消抖逻辑
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            menu_btn_sync_0 <= 0;
            menu_btn_sync_1 <= 0;
            debounce_counter <= 0;
            menu_btn_stable <= 0;
        end else begin
            // 同步化处理，防止时钟域交叉带来的亚稳态
            menu_btn_sync_0 <= menu_btn;
            menu_btn_sync_1 <= menu_btn_sync_0;

            // 消抖计数逻辑
            if (menu_btn_sync_1 == menu_btn_stable) begin
                debounce_counter <= 0;
            end else begin
                debounce_counter <= debounce_counter + 1;
                if (debounce_counter == 20'd1000000) begin
                    menu_btn_stable <= menu_btn_sync_1;
                    debounce_counter <= 0;
                end
            end
        end
    end

    // 单次响应逻辑
    reg menu_btn_stable_last;
    wire menu_btn_pressed;

    assign menu_btn_pressed = (menu_btn_stable && !menu_btn_stable_last);

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            menu_btn_stable_last <= 0;
        end else begin
            menu_btn_stable_last <= menu_btn_stable;
        end
    end

    // 状态转换
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            current_state <= STANDBY;
            mode <= 3'b000;
            suction_3_used <= 0;
        end else begin
            current_state <= next_state;

            // 更新模式输出
            case (next_state)
                STANDBY: mode <= 3'b000;
                WAIT_FOR_SPEED: mode <= 3'b000; // 等待输入时保持待机状态
                SUCTION_1: mode <= 3'b001;
                SUCTION_2: mode <= 3'b010;
                SUCTION_3: mode <= 3'b100;
                SUCTION_3_TIMER: mode <= 3'b100; // 保持3档模式，但处于倒计时状态
                RETURN_TO_STANDBY: mode <= 3'b000; // 返回待机倒计时
                CLEANING: mode <= 3'b111;
                default: mode <= 3'b000;
            endcase
        end
    end

    // 标志位更新逻辑（同步逻辑）
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            suction_3_used <= 0;
        end else if (current_state == SUCTION_3 && next_state == SUCTION_3_TIMER) begin
            suction_3_used <= 1; // 当进入 SUCTION_3_TIMER 后标志位设置为 1
        end
    end

    // 状态机逻辑
    always @(*) begin
        next_state = current_state; // 默认保持当前状态
        case(current_state)
            STANDBY: begin
                if (menu_btn_pressed) begin
                    next_state = WAIT_FOR_SPEED; // 按菜单键后进入等待速度按键模式
                end
            end
            WAIT_FOR_SPEED: begin
                if (speed_btn != 3'b000) begin
                    case(speed_btn)
                        3'b001: next_state = SUCTION_1;   // 按1档键，进入1档模式
                        3'b010: next_state = SUCTION_2;   // 按2档键，进入2档模式
                        3'b100: begin
                            if (!suction_3_used) begin
                                next_state = SUCTION_3;   // 按3档键，进入3档模式（仅限第一次）
                            end
                        end
                        default: next_state = WAIT_FOR_SPEED;
                    endcase
                end else if (clean_btn) begin
                    next_state = CLEANING; // 按清洁键，进入自清洁模式
                end
            end
            SUCTION_1: begin
                if (menu_btn_pressed) next_state = STANDBY;  // 按菜单键返回待机
            end
            SUCTION_2: begin
                if (menu_btn_pressed) next_state = STANDBY;  // 按菜单键返回待机
            end
            SUCTION_3: begin
                next_state = SUCTION_3_TIMER; // 开始60秒倒计时
            end
            SUCTION_3_TIMER: begin
                if (timer == 0) next_state = SUCTION_2;  // 倒计时结束后进入二档模式
                else if (menu_btn_pressed) next_state = RETURN_TO_STANDBY;  // 按菜单键返回待机
            end
            RETURN_TO_STANDBY: begin
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
            timer <= 32'd1800000000; // 初始化为自清洁倒计时（180秒）
        else if (next_state == SUCTION_3_TIMER && timer > 0)
            timer <= timer - 1; // 3档倒计时中递减
        else if (next_state == SUCTION_3_TIMER && timer == 0)
            timer <= 32'd600000000; // 启动3档倒计时（60秒）
        else if (next_state == RETURN_TO_STANDBY && timer > 0)
            timer <= timer - 1; // 返回待机倒计时
        else if (next_state == RETURN_TO_STANDBY && timer == 0)
            timer <= 32'd600000000; // 启动返回待机倒计时（60秒）
        else if (next_state == CLEANING && countdown == 1)
            timer <= timer - 1; // 自清洁模式倒计时递减
        else if (next_state == CLEANING && timer == 0) 
            timer <= 32'd1800000000; // 启动自清洁倒计时（180秒）
        else
            timer <= 0;  // 其他模式不计时
    end

    // 倒计时指示
    always @(next_state or timer) begin
        if ((next_state == SUCTION_3_TIMER || next_state == RETURN_TO_STANDBY || next_state == CLEANING) && timer > 0)
            countdown = 1;  // 倒计时中
        else
            countdown = 0;  // 不倒计时
    end

endmodule
