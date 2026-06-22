[private]
default:
    just --list

# Install all tools
install-all:
    just install-rpi

# Install the local marketplace
install-marketplace:
    claude plugin marketplace add ./marketplace

# Install the "rpi" plugin
install-rpi: install-marketplace
    claude plugin install rpi@matts-marketplace
