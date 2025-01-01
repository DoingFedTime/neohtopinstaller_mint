#!/bin/bash

# Enable strict error checking
set -euo pipefail
IFS=$'\n\t'

# Error handling function
handle_error() {
    echo "Error occurred in line $1"
    echo "Error message: $2"
    cleanup
    exit 1
}
trap 'handle_error ${LINENO} "$BASH_COMMAND"' ERR

# Cleanup function
cleanup() {
    echo "Cleaning up..."
    rm -rf "$BUILD_DIR"
}

echo "Installing NeoHtop and all dependencies..."

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "Please don't run as root/sudo. The script will ask for elevation when needed."
    exit 1
fi

# Check internet connection
if ! ping -c 1 google.com > /dev/null 2>&1; then
    echo "No internet connection"
    exit 1
fi

# Check disk space (need at least 2GB)
FREE_SPACE=$(df /home | awk 'NR==2 {print $4}')
if [ "$FREE_SPACE" -lt 2000000 ]; then
    echo "Not enough space in /home (need at least 2GB)"
    exit 1
fi

# Install base requirements first
echo "Installing base dependencies..."
sudo apt update
sudo apt install -y \
    curl wget git build-essential pkg-config gcc g++ cmake \
    libssl-dev libsoup2.4-dev libjavascriptcoregtk-4.1-dev \
    xdg-utils libglib2.0-dev libatk1.0-dev libgdk-pixbuf-2.0-dev \
    libcairo2-dev libpango1.0-dev libwebkit2gtk-4.1-dev libgtk-3-dev \
    libayatana-appindicator3-dev librsvg2-dev patchelf || {
        echo "Failed to install system dependencies"
        exit 1
    }

# Install Node.js if not present or outdated
if ! command -v node &> /dev/null || [ "$(node -v | cut -d'v' -f2 | cut -d'.' -f1)" -lt 16 ]; then
    echo "Installing/Updating Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs npm || {
        echo "Failed to install Node.js"
        exit 1
    }
fi

# Verify npm installation
if ! command -v npm &> /dev/null; then
    echo "npm installation failed"
    exit 1
fi

# Install Rust
if ! command -v rustc &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Verify Rust installation
if ! command -v rustc &> /dev/null; then
    echo "Rust installation failed"
    exit 1
fi

# Create build directory
BUILD_DIR="$HOME/.neohtop-build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
trap cleanup EXIT

# Clone and build NeoHtop
echo "Cloning and building NeoHtop..."
cd "$BUILD_DIR"
git clone https://github.com/Abdenasser/neohtop.git || {
    echo "Failed to clone repository"
    exit 1
}
cd neohtop

# NPM install with retry and fallback
echo "Installing npm dependencies..."
if ! npm install; then
    echo "Retrying npm install with --legacy-peer-deps..."
    if ! npm install --legacy-peer-deps; then
        echo "npm install failed"
        exit 1
    fi
fi

echo "Building NeoHtop..."
npm run tauri build || {
    echo "Build failed"
    exit 1
}

# Verify build succeeded
if [ ! -f "src-tauri/target/release/NeoHtop" ]; then
    echo "Build failed - executable not found"
    exit 1
fi

# Create symlink
echo "Creating system-wide command..."
sudo rm -f /usr/local/bin/neohtop
sudo ln -sf "$(pwd)/src-tauri/target/release/NeoHtop" /usr/local/bin/neohtop

# Verify installation
if command -v neohtop &> /dev/null; then
    echo "NeoHtop installed successfully! Run 'neohtop' to start."
else
    echo "Installation failed - command not found"
    exit 1
fi
