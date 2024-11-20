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

always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= IDLE;
        power_state <= 0;
        countdown <= 0;
    end else begin
        current_state <= next_state;
        countdown <= countdown_next;
    end
end

always @(*) begin
    // 默认保持当前状态和倒计时值
    next_state = current_state;
    countdown_next = countdown;

    case (current_state)
        IDLE: begin
            if (left_key && power_state == 0) begin
                next_state = LEFT_WAIT;
                countdown_next = COUNTDOWN_TIME; // 初始化倒计时
            end else if (right_key && power_state == 1) begin
                next_state = RIGHT_WAIT;
                countdown_next = COUNTDOWN_TIME; // 初始化倒计时
            end
        end

        LEFT_WAIT: begin
            if (right_key && countdown > 0) begin
                next_state = IDLE;
                power_state = 1; // 更新 power_state
            end else if (countdown == 0) begin
                next_state = IDLE; // 倒计时结束返回 IDLE
            end else begin
                countdown_next = countdown - 1; // 倒计时减一
            end
        end

        RIGHT_WAIT: begin
            if (left_key && countdown > 0) begin
                next_state = IDLE;
                power_state = 0; // 更新 power_state
            end else if (countdown == 0) begin
                next_state = IDLE; // 倒计时结束返回 IDLE
            end else begin
                countdown_next = countdown - 1; // 倒计时减一
            end
        end

        default: begin
            next_state = IDLE;
            countdown_next = 0;
        end
    endcase
end

endmodule
