module timer (
    input clk,
    input reset,
    input power_state,
    input set_mode,
    input increase_key,
    output reg [7:0] hour_tub_control,
    output reg [7:0] minute_tub_control,
    output reg [7:0] second_tub_control
);

reg [4:0] hours;
reg [5:0] minutes,seconds;
reg [1:0] set_select;         // 0: 秒, 1: 分钟, 2: 小时
reg inc_prev;                 // 记录按键状态，用于检测上升沿





endmodule