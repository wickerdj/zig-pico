target remote :3333
monitor reset halt
monitor halt
set mem inaccessible-by-default off
file build/pico_app
