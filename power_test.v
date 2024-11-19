module main (
    input clk,
    input reset,
    input key_input,
    output LED
);

wire short_press,long_press;
wire power_state;
wire LED_state;

key_press_detector press(
    .clk(clk),
    .reset(reset),
    .key_input(key_input),
    .short_press(short_press),
    .long_press(long_press)
);

power_control control(
    .clk(clk),
    .reset(reset),
    .short_press(short_press),
    .long_press(long_press),
    .power_state(LED_state)
);

assign LED = LED_state;
    
endmodule