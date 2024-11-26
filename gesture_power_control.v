module gesture_power_control (
    input clk,
    input reset,
    input left_key,
    input right_key,
    output reg power_state
);

parameter IDLE = 2'b00;
parameter LEFT_WAIT = 2'b01;
parameter RIGHT_WAIT = 2'b10;

reg [1:0] current_state, next_state;
reg [31:0] countdown, countdown_next;

parameter COUNTDOWN_TIME = 32'd500000000;    // 五秒倒计时

// 时序逻辑：更新状态、倒计时和电源状态
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        current_state <= IDLE;         // 初始状态
        power_state <= 0;              // 初始电源关闭
        countdown <= 0;                // 初始倒计时为 0
    end else begin
        current_state <= next_state;   // 更新状态
        countdown <= countdown_next;   // 更新倒计时
    end
end

// 组合逻辑：计算下一个状态和倒计时值
always @(*) begin
    next_state = current_state;       // 默认保持当前状态
    countdown_next = countdown;       // 默认保持当前倒计时值

    case (current_state)
        IDLE: begin
            if (left_key && power_state == 0) begin
                next_state = LEFT_WAIT;         // 进入等待右键状态
                countdown_next = COUNTDOWN_TIME; // 初始化倒计时
            end else if (right_key && power_state == 1) begin
                next_state = RIGHT_WAIT;        // 进入等待左键状态
                countdown_next = COUNTDOWN_TIME; // 初始化倒计时
            end
        end

        LEFT_WAIT: begin
            if (countdown > 0) begin
                countdown_next = countdown - 1; // 倒计时递减
            end else begin
                next_state = IDLE;              // 倒计时结束回到 IDLE
            end
            if (countdown > 0 && right_key) begin
                power_state = 1;               // 按右键开机
            end
        end

        RIGHT_WAIT: begin
            if (countdown > 0) begin
                countdown_next = countdown - 1; // 倒计时递减
            end else begin
                next_state = IDLE;              // 倒计时结束回到 IDLE
            end
            if (countdown > 0 && left_key) begin
                power_state = 0;               // 按左键关机
            end
        end

        default: begin
            next_state = IDLE;                  // 默认回到 IDLE
            countdown_next = 0;
        end
    endcase
end

endmodule
