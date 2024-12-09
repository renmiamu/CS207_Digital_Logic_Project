module main(
    input clk,
    input reset,
    input key_input,            // 开关按钮
    input [1:0] time_select,       // 手势操作时间设置
    input left_key,        // 手势操作左
    input right_key,       // 手势操作右
    input set_mode,        // 时间设置
    input set_select,          // 外部输入控制调整分钟或小时
    input increase_key,        // 时间增加按钮
    input light_key,           // 照明开关
    input menu_btn,           // 菜单键
    input [2:0] speed_btn,    // 工作挡位
    input clean_btn,          // 清洁按钮
    input set_warning_mode,     // 提醒时间设置
    input display_mode,         // 显示工作时间或显示提醒时间
    input set_warning_select,      // 提醒时间调整分钟或小时
    input increase_warning_key,      // 提醒时间增加按钮
    input work_time_key,       // 工作时间切换按钮
    input gesture_time_key,    // 手势操作时间切换按钮
    output [7:0] tub_segments_gesture_time,   // 手势操作时间显示
    output tub_select_gesture_time,       // 手势操作数码管设置
    output [7:0] tub_segments_1,  // 开机时间显示
    output [7:0] tub_segments_2,  // 开机时间显示
    output [5:0] tub_select,       // 开机数码管设置
    output light_state,            // 照明灯
    output [2:0] mode,             // 工作模式
    output countdown,              // 倒计时显示灯
    output reminder,              // 提醒清洁灯
    output [7:0] tub_control_warning_1,   // 累计工作时间
    output [7:0] tub_control_warning_2,   // 累计工作时间
    output [7:0] tub_warning_select,              // 累计工作时间数码管设置
    output speaker,                // 扬声器
    output pwm                      // PWM信号
);

wire short_press,long_press;
key_press_detector key_press_detector(
    .clk(clk),
    .reset(reset),
    .key_input(key_input),
    .short_press(short_press),
    .long_press(long_press)
);

wire power_state;      // 电源开关
power_control power_control(
    .clk(clk),
    .reset(reset),
    .short_press(short_press),
    .long_press(long_press),
    .power_state(power_state)
);

wire [31:0] countdown_time;
gesture_power_control gesture_power_control(
    .clk(clk),
    .reset(reset),
    .left_key(left_key),
    .right_key(right_key),
    .time_select(time_select),
    .power_state(power_state),
    .tub_segments_gesture_time(tub_segments_gesture_time),
    .tub_select_gesture_time(tub_select_gesture_time)
);

timer_mode timer_mode(
    .clk(clk),
    .reset(reset),
    .power_state(power_state),
    .set_mode(set_mode),
    .set_select(set_select),
    .increase_key(increase_key),
    .tub_segments_1(tub_segments_1),
    .tub_segments_2(tub_segments_2),
    .tub_select(tub_select)
);

light light(
    .clk(clk),
    .reset(reset),
    .power_state(power_state),
    .light_key(light_key),
    .light_state(light_state)
);

wire cleaning_reminder;       
wire [2:0] suction;          

mode_change modechanger(
    .clk(clk),
    .reset(reset),
    .menu_btn(menu_btn),
    .speed_btn(speed_btn),
    .clean_btn(clean_btn),
    .set_mode(set_warning_mode),
    .display_mode(display_mode),
    .set_select(set_warning_select),
    .increase_key(increase_warning_key),
    .mode(suction),
    .countdown(countdown),
    .cleaning_reminder(cleaning_reminder),
    .tub_segments_1(tub_control_warning_1),  
    .tub_segments_2(tub_control_warning_2),
    .tub_select(tub_warning_select)     
);

sound_reminder u_sound_reminder (
    .cleaning_reminder(cleaning_reminder),
    .clk(clk),
    .suction(suction),
    .speaker(speaker)
);

assign reminder = cleaning_reminder; // 将 cleaning_reminder 信号赋给 reminder 输出
assign mode = suction;
assign pwm = 1'b0;

// 显示模式控制逻辑
reg [1:0] display_mode_select;  // 控制显示的时间类型

always @(posedge clk or posedge reset) begin
    if (reset) begin
        display_mode_select <= 2'b00;  // 默认显示开机时间
    end else begin
        if (work_time_key && gesture_time_key) begin
            display_mode_select <= 2'b00;  // 两个按键同时按下，显示开机时间
        end else if (work_time_key) begin
            display_mode_select <= 2'b01;  // 显示工作时间
        end else if (gesture_time_key) begin
            display_mode_select <= 2'b10;  // 显示手势操作时间
        end
    end
end

// 根据显示模式更新显示内容
always @(*) begin
    case (display_mode_select)
        2'b00: begin
            // 显示开机时间
            tub_segments_1 = tub_segments_1_value;
            tub_segments_2 = tub_segments_2_value;
        end
        2'b01: begin
            // 显示工作时间
            tub_segments_1 = work_time_segments_1;
            tub_segments_2 = work_time_segments_2;
        end
        2'b10: begin
            // 显示手势操作时间
            tub_segments_1 = gesture_time_segments_1;
            tub_segments_2 = gesture_time_segments_2;
        end
        default: begin
            // 默认显示开机时间
            tub_segments_1 = tub_segments_1_value;
            tub_segments_2 = tub_segments_2_value;
        end
    endcase
end

endmodule
