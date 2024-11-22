module timer (
    input clk,
    input reset,
    input power_state,
    input set_mode,
    input increase_key,
    output reg [7:0] hour_tub_control_1,
    output reg [7:0] hour_tub_control_2,
    output reg [7:0] minute_tub_control_1,
    output reg [7:0] minute_tub_control_2,
    output reg [7:0] second_tub_control_1,
    output reg [7:0] second_tub_control_2
);

    reg [4:0] hours;
    reg [5:0] minutes;
    reg [5:0] seconds;
    reg set_select;            // 0: minute, 1: hour
    reg inc_prev;              // 用于检测按键上升沿
    reg [31:0] counter;        // 用于计时的分频计数器

    parameter ONE_SECOND = 32'b100000000; // 假设100MHz时钟，需要分频到1Hz

    // 数码管段码查找表
    reg [7:0] segment_lut [0:9];
    initial begin
        segment_lut[0] = 8'b11000000; // 数字 0
        segment_lut[1] = 8'b11111001; // 数字 1
        segment_lut[2] = 8'b10100100; // 数字 2
        segment_lut[3] = 8'b10110000; // 数字 3
        segment_lut[4] = 8'b10011001; // 数字 4
        segment_lut[5] = 8'b10010010; // 数字 5
        segment_lut[6] = 8'b10000010; // 数字 6
        segment_lut[7] = 8'b11111000; // 数字 7
        segment_lut[8] = 8'b10000000; // 数字 8
        segment_lut[9] = 8'b10010000; // 数字 9
    end

    // 初始化信号
    initial begin
        hours = 0;
        minutes = 0;
        seconds = 0;
        set_select = 0;
        inc_prev = 0;
        counter = 0;
    end

    // 时间计时逻辑
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            hours <= 0;
            minutes <= 0;
            seconds <= 0;
            counter <= 0;
            set_select <=0;
        end else if (power_state && !set_mode) begin
            counter <= counter + 1;
            if (counter >= ONE_SECOND) begin
                counter <= 0;
                seconds <= seconds + 1;
                if (seconds == 59) begin
                    seconds <= 0;
                    minutes <= minutes + 1; // 唯一控制 minutes
                    if (minutes == 59) begin
                        minutes <= 0;
                        hours <= hours + 1;
                        if (hours == 23) begin
                            hours <= 0;
                        end
                    end
                end
            end
        end else if (power_state && set_mode) begin
            set_select <= (set_select+1)%2;
            if (increase_key && !inc_prev) begin
                case (set_select) 
                    0: minutes <= (minutes + 1) % 60; // 唯一控制 minutes
                    1: hours <= (hours + 1) % 24;    // 唯一控制 hours
                endcase
            end
            inc_prev <= increase_key; // 更新按键状态
        end
    end

    // 时间设置逻辑
    // always @(posedge clk or negedge reset) begin
    //     if (!reset) begin
    //         set_select <= 0;
    //     end else if (set_mode) begin
    //         if (increase_key && !inc_prev) begin
    //             case (set_select) 
    //                 0: minutes <= (minutes + 1) % 60; // 唯一控制 minutes
    //                 1: hours <= (hours + 1) % 24;    // 唯一控制 hours
    //             endcase
    //         end
    //         inc_prev <= increase_key; // 更新按键状态
    //     end
    // end

    // 数码管段码赋值逻辑
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            hour_tub_control_1 <= 8'b00000000;
            hour_tub_control_2 <= 8'b00000000;
            minute_tub_control_1 <= 8'b00000000;
            minute_tub_control_2 <= 8'b00000000;
            second_tub_control_1 <= 8'b00000000;
            second_tub_control_2 <= 8'b00000000;
        end else begin
            hour_tub_control_1 <= segment_lut[hours / 10];   // 小时十位
            hour_tub_control_2 <= segment_lut[hours % 10];   // 小时个位
            minute_tub_control_1 <= segment_lut[minutes / 10]; // 分钟十位
            minute_tub_control_2 <= segment_lut[minutes % 10]; // 分钟个位
            second_tub_control_1 <= segment_lut[seconds / 10]; // 秒十位
            second_tub_control_2 <= segment_lut[seconds % 10]; // 秒个位
        end
    end

endmodule



// module timer_mode (
//     input clk,
//     input reset,
//     input power_state,
//     input set_mode,
//     input increase_key,
//     output reg [7:0] hour_tub_control_1,
//     output reg [7:0] hour_tub_control_2,
//     output reg [7:0] minute_tub_control_1,
//     output reg [7:0] minute_tub_control_2,
//     output reg [7:0] second_tub_control_1,
//     output reg [7:0] second_tub_control_2,
// );

// reg [4:0] hours;
// reg [5:0] minutes,seconds;
// reg set_select;         // 0: minute, 1: hour
// reg inc_prev;                 // 记录按键状态，用于检测上升沿
// reg [31:0] counter;

// parameter ONE_SECOND = 32'b100000000;


// reg [7:0] segment_lut [0:9];
// initial begin
//     segment_lut[0] = 8'b11111100;
//     segment_lut[1] = 8'b01100000;
//     segment_lut[2] = 8'b11011010;
//     segment_lut[3] = 8'b11110010;
//     segment_lut[4] = 8'b01100110;
//     segment_lut[5] = 8'b10110110;
//     segment_lut[6] = 8'b10111110;
//     segment_lut[7] = 8'b11100000;
//     segment_lut[8] = 8'b11111110;
//     segment_lut[9] = 8'b11100110;
// end

// initial begin
//     hours = 0;
//     minutes = 0;
//     seconds = 0;
//     set_select = 0;
//     inc_prev = 0;
//     counter = 0;
// end

// always @(posedge clk,negedge reset) begin
//     if (!reset) begin
//         hours <= 0;
//         minutes <= 0;
//         seconds <= 0;
//         counter <=0;
//     end else if (power_state && !set_mode) begin
//         counter <= counter +1;
//         if (counter==ONE_SECOND) begin
//             seconds<= seconds+1;
//             if (seconds == 59) begin
//                 seconds <= 0;
//                 minutes <= minutes + 1;
//                 if (minutes == 59) begin
//                     minutes <= 0;
//                     hours <= hours + 1;
//                     if (hours == 23) begin
//                         hours <= 0;
//                     end
//                 end
//             end
//         end 
//     end
// end

// always @(posedge clk,negedge reset) begin
//     if (!reset) begin
//         set_select <= 0;
//     end else if (set_mode) begin
//         if (increase_key && !inc_prev) begin
//             case (set_select) 
//                 0:begin
//                     minutes <= (minutes + 1)%60;
//                 end
//                 1:begin
//                     hours <= (hours + 1)%24;
//                 end
//             endcase
//         end
//     end
//     inc_prev <= increase_key;
// end

// always @(posedge clk,negedge reset) begin
//     if (!reset) begin
//         set_select <= 0;
//     end else if (set_mode) begin
//         set_select <= (set_select + 1)%2;
//     end
// end

// always @(posedge clk,negedge reset) begin
//     if (!reset) begin
//         hour_tub_control_1 <= 8'b00000000;
//         minute_tub_control_1 <= 8'b00000000;
//         second_tub_control_1 <= 8'b00000000;
//         hour_tub_control_2 <= 8'b00000000;
//         minute_tub_control_2 <= 8'b00000000;
//         second_tub_control_2 <= 8'b00000000;
//     end else begin
//         hour_tub_control_1 <= segment_lut[hours/10];
//         hour_tub_control_2 <= segment_lut[hours%10];
//         minute_tub_control_1 <= segment_lut[minutes/10];
//         minute_tub_control_2 <= segment_lut[minutes%10];
//         second_tub_control_1 <= segment_lut[seconds/10];
//         second_tub_control_2 <= segment_lut[seconds%10];
//     end
// end

// endmodule