# Setup
zig init-exe
git init

mkdir -p deps
git submodule add https://github.com/ZigEmbeddedGroup/microchip-atmega deps/microchip-atmega
git submodule update --init --recursive

## Update
git submodule update --init --recursive

## Build
zig build -Doptimize=ReleaseSmall
TARGET=ACM0 && zig build -Doptimize=ReleaseSmall && avrdude -c arduino -p m328p -P /dev/tty$TARGET -U flash:w:zig-out/bin/my-executable:e && picocom --baud 115200 /dev/tty$TARGET
TARGET=USB0 && zig build -Doptimize=ReleaseSmall && avrdude -c arduino -p m328p -P /dev/tty$TARGET -U flash:w:zig-out/bin/my-executable:e && picocom --baud 115200 /dev/tty$TARGET
