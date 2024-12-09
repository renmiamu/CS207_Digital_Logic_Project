`timescale 1ns / 1ps

module main(
    input clk,
    input reset,
    input menu_btn,
    input [2:0] speed_btn,
    input clean_btn,
    input set_mode,
    input display_mode,
    input set_select,    
    input increase_key,
    output [2:0] mode,
    output countdown,
    output reminder,
    output [7:0] tub_control_1,
    output [7:0] tub_control_2,
    output [7:0] tub_select,
    output speaker,
    output pwm
);
    wire cleaning_reminder;
    wire [2:0] suction;
    
    // 实例化 mode_change 模块
    mode_change modechanger(
        .clk(clk),
        .reset(reset),
        .menu_btn(menu_btn),
        .speed_btn(speed_btn),
        .clean_btn(clean_btn),
        .set_mode(set_mode),
        .display_mode(display_mode),
        .set_select(set_select),
        .increase_key(increase_key),
        .mode(suction),
        .countdown(countdown),
        .cleaning_reminder(cleaning_reminder),
        .tub_segments_1(tub_control_1),  // 连接小时段码
        .tub_segments_2(tub_control_2),  // 连接小时段码（可以根据需要修改连接或添加其他信号）
        .tub_select(tub_select)      // 连接分钟段码（同样可以更改为实际需要的信号）
    );

    // 实例化 sound_reminder 模块
    sound_reminder u_sound_reminder (
        .cleaning_reminder(cleaning_reminder),  // 从 mode_change 模块传来的 cleaning_reminder 信号
        .clk(clk),                             // 时钟信号
        .suction(suction),
        .speaker(speaker)                      // 输出到蜂鸣器的 PWM 信号
    );
    
    assign reminder = cleaning_reminder;  // 将 cleaning_reminder 信号赋给 reminder 输出
    assign mode = suction;
    assign pwm = 1'b0;

endmodule
