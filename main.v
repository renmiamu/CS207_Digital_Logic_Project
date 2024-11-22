module main (
    input clk,
    input reset,
    input key_input,
    input left_key,
    input right_key,
    input light_key,
    input set_mode,
    input increase_key,
    output LED1,
    output LED2,
    output [7:0] hour_tub_control_1,
    output [7:0] hour_tub_control_2,
    output [7:0] minute_tub_control_1,
    output [7:0] minute_tub_control_2,
    output [7:0] second_tub_control_1,
    output [7:0] second_tub_control_2
);

wire short_press,long_press;
wire power_state;
wire LED_state1;
wire light_state;

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

light light_control(
    .clk(clk),
    .reset(reset),
    .power_state(LED_state1),
    .light_key(light_key),
    .light_state(light_state)
);

timer time(
    .clk(clk),
    .reset(reset),
    .power_state(LED_state1),
    .set_mode(set_mode),
    .increase_key(increase_key),
    .hour_tub_control_1(hour_tub_control_1),
    .hour_tub_control_2(hour_tub_control_2),
    .minute_tub_control_1(minute_tub_control_1),
    .minute_tub_control_2(minute_tub_control_2),
    .second_tub_control_1(second_tub_control_1),
    .second_tub_control_2(second_tub_control_2)
);

assign LED1 = LED_state1;
assign LED2 =light_state;

endmodule