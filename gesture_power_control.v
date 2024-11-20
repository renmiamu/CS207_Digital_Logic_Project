module gesture_power_control (
    input clk,
    input reset,
    input left_key,
    input right_key,
    output reg power_state
);
typedef enum reg [1:0]{
    IDLE = 2'b00,
    LEFT_WAIT = 2'b01,
    RIGHT_WAIT = 2'B10
}state_t;

state_t current_state,next_state;
reg [31:0] countdown;

parameter COUNTDOWN_TIME = 32'd500000000;    //五秒倒计时



always @(posedge clk,posedge reset) begin
    if (reset) begin
        current_state <= IDLE;
        power_state <= 0;
        countdown <= 0;
    end else begin
        current_state <= next_state;
        if (current_state == LEFT_WAIT || current_state == RIGHT_WAIT) begin
            if (countdown >0) begin
                countdown <= countdown - 1;
            end
        end else begin
            countdown <= 0;
        end
    end
end

always @(*) begin
    next_state = current_state;
    case (current_state)
        IDLE:begin
            if (left_key && power_state ==0) begin
                next_state = LEFT_WAIT;
                countdown = COUNTDOWN_TIME;
            end else if (right_key && power_state == 1) begin
                next_state = RIGHT_WAIT;
                countdown = COUNTDOWN_TIME;
            end
        end
        LEFT_WAIT:begin
            if (right_key && countdown >0) begin
                next_state = IDLE;
                power_state = 1; 
            end else if (countdown == 0)begin
                next_state = IDLE;
            end
        end
        RIGHT_WAIT:begin
            if (left_key && countdown >0)begin
                next_state = IDLE;
                power_state = 0;
            end else if (countdown == 0)begin
                next_state = IDLE;
            end
        end
        default：next_state = IDLE; 
    endcase
end

endmodule