#!/bin/sh
#
# Pros-Zed installer
#
set -eu

# Colors
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
RESET="\033[0m"

step() {
    printf "${BLUE}==>${RESET} %s\n" "$1"
}

success() {
    printf "${GREEN}✓${RESET} %s\n" "$1"
}

error() {
    printf "${RED}✗${RESET} %s\n" "$1" >&2
    exit 1
}

echo "Installing PROS tools..."
echo

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

PREFIX="$HOME/.local/share/pros-zed"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$PREFIX"
mkdir -p "$BIN_DIR"

# Fetch versions
step "Fetching latest versions..."

CLI_VERSION=$(curl -fsSL \
    "https://api.github.com/repos/purduesigbots/pros-cli/releases/latest" |
    sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p')

TOOLCHAIN_VERSION=$(curl -fsSL \
    "https://api.github.com/repos/purduesigbots/toolchain/releases/latest" |
    sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p')

VEXCOM_VERSION="1_0_0_23"

[ -n "$CLI_VERSION" ] || error "Could not determine CLI version"
[ -n "$TOOLCHAIN_VERSION" ] || error "Could not determine toolchain version"

success "CLI version: $CLI_VERSION"
success "Toolchain version: $TOOLCHAIN_VERSION"

# Detect platform
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Linux)
        cli_arch="lin-64bit"
        toolchain_arch="x86_64"
        vexcom_arch="linux-x64"
        ;;
    Darwin)
        cli_arch="macos-64bit"
        vexcom_arch="osx"

        case "$ARCH" in
            arm64|aarch64)
                toolchain_arch="darwin-arm64"
                ;;
            *)
                toolchain_arch="darwin-x86_64"
                ;;
        esac
        ;;
    *)
        error "Unsupported operating system: $OS"
        ;;
esac

# Convert toolchain version to ARM format
major=${TOOLCHAIN_VERSION%%.*}
rest=${TOOLCHAIN_VERSION#*.}
minor=${rest%%.*}
patch=${rest##*.}

toolchain_version="${major}.${minor}.rel${patch}"

# URLs
download_cli="https://github.com/purduesigbots/pros-cli/releases/download/${CLI_VERSION}/pros_cli-${CLI_VERSION}-${cli_arch}.zip"

download_toolchain="https://developer.arm.com/-/media/Files/downloads/gnu/${toolchain_version}/binrel/arm-gnu-toolchain-${toolchain_version}-${toolchain_arch}-arm-none-eabi.tar.xz"

download_vexcom="https://pros.cs.purdue.edu/v5/_static/releases/vexcom_${VEXCOM_VERSION}-${vexcom_arch}.zip"


# Toolchain
step "Installing ARM toolchain..."

mkdir -p "$PREFIX/toolchain"

curl -fsSL "$download_toolchain" \
    -o "$TMP_DIR/toolchain.tar.xz"

tar -xf "$TMP_DIR/toolchain.tar.xz" \
    -C "$PREFIX/toolchain" \
    --strip-components=1

[ -d "$PREFIX/toolchain/bin" ] || error "Toolchain extraction failed"

find "$PREFIX/toolchain/bin" -type f -exec chmod +x {} +

success "Toolchain installed"


# CLI
step "Installing PROS CLI..."

mkdir -p "$PREFIX/cli"

curl -fsSL "$download_cli" \
    -o "$TMP_DIR/pros-cli.zip"

unzip -q "$TMP_DIR/pros-cli.zip" \
    -d "$PREFIX/cli"

[ -f "$PREFIX/cli/pros" ] || error "PROS CLI binary not found"

chmod +x "$PREFIX/cli/pros"

success "PROS CLI installed"


# VEXCOM
step "Installing VEXCOM..."

mkdir -p "$PREFIX/vexcom"

curl -fsSL "$download_vexcom" \
    -o "$TMP_DIR/vexcom.zip"

unzip -q "$TMP_DIR/vexcom.zip" \
    -d "$PREFIX/vexcom"

[ -f "$PREFIX/vexcom/vexcom" ] || error "VEXCOM binary not found"

chmod +x "$PREFIX/vexcom/vexcom"

success "VEXCOM installed"

# PROS-Zed CLI
step "Installing PROS-Zed CLI..."

curl -fsSL "https://raw.githubusercontent.com/skzidev/pros-for-zed/refs/heads/main/pros-zed.sh" \
    -o "$PREFIX/pros-zed"

chmod +x "$PREFIX/pros-zed"

success "PROS-Zed CLI Installed."

# Download template
step "Downloading templates..."
curl -fsSL "https://raw.githubusercontent.com/skzidev/pros-for-zed/refs/heads/main/tasks.json" \
    -o "$PREFIX/tasks.json"
success "Templates installed"

# PATH setup
step "Configuring PATH..."

ln -sf "$PREFIX/cli/pros" "$BIN_DIR/pros"
ln -sf "$PREFIX/vexcom/vexcom" "$BIN_DIR/vexcom"

PATH_LINE='export PATH="$HOME/.local/bin:$HOME/.local/share/pros-zed/toolchain/bin:$PATH"'

case "$(basename "${SHELL:-}")" in
    bash)
        PROFILE="$HOME/.bashrc"
        ;;
    zsh)
        PROFILE="$HOME/.zshrc"
        ;;
    fish)
        PROFILE="$HOME/.config/fish/config.fish"
        PATH_LINE='set -gx PATH $HOME/.local/bin $HOME/.local/share/pros-zed/toolchain/bin $PATH'
        ;;
    *)
        PROFILE=""
        ;;
esac

if [ -n "$PROFILE" ]; then
    mkdir -p "$(dirname "$PROFILE")"

    if ! grep -q "pros-zed/toolchain/bin" "$PROFILE" 2>/dev/null; then
        printf "\n%s\n" "$PATH_LINE" >> "$PROFILE"
    fi

    success "PATH updated in $PROFILE"
else
    echo "Add this to your shell configuration:"
    echo "$PATH_LINE"
fi


# Verify
step "Verifying installation..."

if "$BIN_DIR/pros" --version >/dev/null 2>&1; then
    success "PROS CLI works"
else
    error "PROS CLI verification failed"
fi

if "$BIN_DIR/vexcom" --help >/dev/null 2>&1; then
    success "VEXCOM works"
else
    success "VEXCOM installed"
fi

echo
printf "${GREEN}PROS installation complete!${RESET}\n"
echo
echo "Restart your shell before using PROS."
