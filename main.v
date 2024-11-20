module main (
    input clk,
    input reset,
    input key_input,
    input left_key,
    input right_key,
    output LED1,
    output LED2
);

wire short_press,long_press;
wire power_state;
wire LED_state1;
wire LED_state2;

key_press_detector press(
    .clk(clk),
    .reset(reset),
    .key_input(key_input),
    .short_press(short_press),
    .long_press(long_press)
);

power_control control1(
    .clk(clk),
    .reset(reset),
    .short_press(short_press),
    .long_press(long_press),
    .power_state(LED_state1)
);

gesture_power_control control2(
    .clk(clk),
    .reset(reset),
    .left_key(left_key),
    .right_key(right_key),
    .power_state(LED_state2)
);

assign LED1 = LED_state1;
assign LED2 = LED_state2;
    
endmodule