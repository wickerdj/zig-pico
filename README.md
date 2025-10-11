# Zig + Raspberry Pi Pico DevContainer (RP2040)

This repo provides a VS Code DevContainer configured for building Zig programs for the Raspberry Pi Pico (RP2040). It includes:

- Zig v0.15.1 (configurable)
- zls (Zig language server)
- Pico C SDK and pico-examples cloned to `/opt`
- `zig build` driven workflow that produces `build/pico_app` and `build/pico_app.uf2`
- OpenOCD + GDB for debugging using a second Pico programmed as a picoprobe


## Quick start (once repo is open in VS Code)

1. Open the repository in VS Code.
2. When prompted, **Reopen in Container**. VS Code will build the Docker image (first time may take a few minutes).
3. After the container finishes building, open a terminal in VS Code (it will be inside the container) and run:

```bash
# Build the project (produces ELF and then UF2)
zig build

# The build products will be under `build/`:
ls -l build/pico_app build/pico_app.uf2
```

## Debugging with second Pico as probe
1. Program your second Pico with the picoprobe firmware (see Raspberry Pi docs):
    - The second Pico should run the picoprobe firmware so it acts as a CMSIS-DAP probe.
2. Connect the probe Pico to the target Pico via SWD (wires for SWDIO, SWCLK, GND and optional RESET).
3. Start OpenOCD inside the container:
``` bash
openocd -f /workspace/openocd-rp2040.cfg
```
4. In another terminal (container), start GDB:
``` bash
gdb-multiarch -x .gdbinit
```
5. Use GDB commands (e.g., monitor reset halt, break main, continue).



## Troubleshooting

- If elf2uf2.py path doesn't exist, check that /opt/pico-sdk exists inside the container and that the repo clone completed.

- If OpenOCD cannot find target/rp2040.cfg you may need an OpenOCD build with RP2040 support or supply the correct script path.