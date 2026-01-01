#!/bin/bash

# Default to the VS Code path, but allow override
TOOLCHAIN_DIR="${PROS_TOOLCHAIN:-$HOME/.config/Code/User/globalStorage/sigbots.pros/install/pros-toolchain-linux/bin}"

if [ ! -d "$TOOLCHAIN_DIR" ]; then
    echo "Error: PROS toolchain not found at $TOOLCHAIN_DIR"
    echo "Please set PROS_TOOLCHAIN in your environment."
    exit 1
fi

echo "Found toolchain. Runner path = $TOOLCHAIN_DIR:/usr/bin"
sed -i "s|{TOOLCHAIN_PATH}|$TOOLCHAIN_DIR:/usr/bin|g" tasks.json
echo "Configured. You may now use 'tasks.json' in your project. Place it in {ProjectRoot}/.zed/tasks.json"
