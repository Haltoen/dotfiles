#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADOPT=false

if [[ "${1:-}" == "--adopt" ]]; then
    ADOPT=true
elif [[ $# -gt 0 ]]; then
    echo "Usage: $0 [--adopt]"
    exit 1
fi

link() {
    local source="$1"
    local target="$2"

    mkdir -p "$(dirname "$target")"

    # Already a symlink
    if [[ -L "$target" ]]; then
        if [[ "$(readlink -f "$target")" == "$(readlink -f "$source")" ]]; then
            echo "Already linked: $target"
        elif [[ "$ADOPT" == true ]]; then
            echo "Replacing symlink: $target"
            rm "$target"
            ln -s "$source" "$target"
            echo "Linked: $target -> $source"
        else
            echo "Skipping existing symlink: $target"
        fi
        return
    fi

    # Existing file/directory
    if [[ -e "$target" ]]; then
        if [[ "$ADOPT" == true ]]; then
            local backup="${target}.backup"

            if [[ -e "$backup" || -L "$backup" ]]; then
                echo "Backup already exists: $backup"
                echo "Refusing to overwrite it."
                return 1
            fi

            echo "Backing up: $target -> $backup"
            mv "$target" "$backup"

            ln -s "$source" "$target"
            echo "Linked: $target -> $source"
        else
            echo "Skipping existing: $target"
        fi
        return
    fi

    # Doesn't exist
    ln -s "$source" "$target"
    echo "Linked: $target -> $source"
}

link "$DOTFILES/hypr" "$HOME/.config/hypr"
link "$DOTFILES/kitty" "$HOME/.config/kitty"
link "$DOTFILES/htop" "$HOME/.config/htop"
link "$DOTFILES/vimrc" "$HOME/.vimrc"
