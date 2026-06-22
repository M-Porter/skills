[private]
default:
    just --list

# Install all tools
install-all:
    just install-rpi

install-rpi:
    claude --plugin-dir ./rpi
