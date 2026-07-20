#!/bin/sh
set -eu

TASKS="$HOME/.local/share/pros-zed/tasks.json"

case "${1:-}" in
    init|bind)
        if [ ! -f project.pros ]; then
            echo "Error: this does not appear to be a PROS project."
            exit 1
        fi

        mkdir -p .zed
        cp "$TASKS" .zed/tasks.json

        echo "PROS Zed tasks installed."
        ;;
    update)
        curl -fsSL "https://raw.githubusercontent.com/skzidev/pros-for-zed/refs/heads/main/install.sh" | sh
        ;;

    ""|-h|--help|help)
        cat <<EOF
pros-zed

Usage:
  pros-zed [init] [help] [update]

Commands:
  init    Install PROS tasks into the current project
  update  Install the newest version of PROS-Zed
  help    Show this help menu
EOF
        ;;

    *)
        echo "Unknown command: $1"
        echo "Run 'pros-zed help' for usage."
        exit 1
        ;;
esac
