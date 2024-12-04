module sound_reminder(
    input wire cleaning_reminder,  // 用作使能信号，启用时播放音频
    input wire clk,                // FPGA时钟信号，100 MHz
    output wire speaker           // PWM信号输出到低通滤波器（音频输出）
    );

    reg [31:0]counter;
    reg pwm;
    
    parameter note = 440000;
    initial begin
        pwm = 0;
    end

    always @(posedge clk) begin
        if (cleaning_reminder) begin
            if (counter < note) begin
                counter <= counter + 1'b1;  // 输出高电平
            end else begin
                pwm = ~pwm;
                counter <= 0;
            end
        end
    end

    assign speaker = pwm;  // 将PWM信号输出到扬声器
    
endmodule
