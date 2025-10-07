const microzig = @import("microzig");
const rp2040 = microzig.hal;
const time = rp2040.time;
const gpio = rp2040.gpio;

const led_pin = 25; // Onboard LED on Pico

pub fn main() !void {
    // Initialize the onboard LED pin
    const led = gpio.num(led_pin);
    led.set_function(.sio);
    led.set_direction(.out);

    // Blink loop
    while (true) {
        led.put(1);
        time.sleep_ms(500);
        led.put(0);
        time.sleep_ms(500);
    }
}
