#!/usr/bin/env bash
# Ghostty variant of Juanfu224/Auto-Kitty-Workspace.
# Run as your desktop user: bash do-ghossty.sh
set -euo pipefail

if [[ ${1:-} == --help ]]; then
    cat <<'HELP'
Usage: bash do-ghossty.sh
Installs Ghostty + Catppuccin Macchiato, Zsh, Starship, bat, lsd, fzf,
Hack Nerd Font and Neovim/NvChad using the inspected Auto-Kitty baseline.
Requires Ubuntu, git, curl, Python 3.10+, sudo and internet access.
Uses an existing Ghostty install, then apt, then mkasberg/ghostty-ubuntu.
The community installer currently supports Ubuntu 24.04 and 26.04.
IMPORTANT: baseline replaces user/root Zsh and Starship configuration,
changes both login shells, and deletes existing user/root Neovim data.
Ghostty config is backed up before replacement. Default terminal is unchanged.
HELP
    exit 0
fi
if (( $# )); then
    echo 'Unknown argument. Use --help.' >&2
    exit 2
fi
if (( EUID == 0 )); then
    echo 'Run as your desktop user, without sudo; individual steps use sudo.' >&2
    exit 1
fi
source /etc/os-release
if [[ ${ID:-} != ubuntu ]]; then
    echo 'This installer targets Ubuntu.' >&2
    exit 1
fi
for dependency in git python3 sudo curl; do
    command -v "$dependency" >/dev/null || {
        echo "Missing dependency: $dependency" >&2
        exit 1
    }
done
python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else "Python 3.10+ is required")'

# Resolve the terminal before cloning or changing the workspace.
if ! command -v ghostty >/dev/null; then
    sudo apt-get update
    candidate=$(apt-cache policy ghostty | awk '/Candidate:/ {print $2}')
    if [[ -n "$candidate" && "$candidate" != '(none)' ]]; then
        sudo apt-get install -y ghostty
    else
        echo 'Installing Ghostty using the mkasberg/ghostty-ubuntu community installer…'
        # Download separately so curl failures cannot become a successful empty command.
        ghostty_installer=$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)
        if ! /bin/bash -c "$ghostty_installer"; then
            echo 'Ghostty installation failed. The community installer currently supports Ubuntu 24.04 and 26.04, not 22.04. Workspace configuration has not been changed.' >&2
            exit 1
        fi
    fi
fi
command -v ghostty >/dev/null || { echo 'Ghostty executable not found after installation.' >&2; exit 1; }

# Keep the inspected baseline reproducible without modifying the Kitty checkout.
baseline_revision=20731f79baf32092d545d1691d48cfd24497c867
workspace=$(mktemp -d -t auto-ghostty-workspace.XXXXXXXX)
trap 'rm -rf -- "$workspace"' EXIT
git clone --quiet --no-checkout https://github.com/Juanfu224/Auto-Kitty-Workspace.git "$workspace/baseline"
git -C "$workspace/baseline" checkout --quiet --detach "$baseline_revision"

# Required by the baseline font installation, but absent from its package list.
sudo apt-get install -y fontconfig

python3 - "$workspace/baseline" <<'PY'
import importlib.util
import os
from pathlib import Path
import shutil
import sys
import tempfile

root = Path(sys.argv[1])
spec = importlib.util.spec_from_file_location("workspace_baseline", root / "main.py")
baseline = importlib.util.module_from_spec(spec)
spec.loader.exec_module(baseline)

def configure_ghostty():
    config_dir = Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config") / "ghostty"
    config_dir.mkdir(parents=True, exist_ok=True)
    config = config_dir / "config"
    if config.exists() or config.is_symlink():
        # Unique backups also preserve earlier configurations across reruns.
        fd, backup = tempfile.mkstemp(prefix="config.backup-", dir=config_dir)
        os.close(fd)
        shutil.copy2(config, backup)
        print(f"Ghostty configuration backup: {backup}")
        config.unlink()
    config.write_text(
        "# Managed by do-ghossty.sh\n"
        "theme = Catppuccin Macchiato\n"
        "font-family = Hack Nerd Font\n"
        "font-size = 12\n"
        "background-opacity = 0.90\n"
        "cursor-style = bar\n"
        "command = /usr/bin/zsh\n"
        "keybind = ctrl+shift+enter=new_split:auto\n"
        "keybind = ctrl+shift+t=new_tab\n"
        "keybind = ctrl+left=goto_split:left\n"
        "keybind = ctrl+right=goto_split:right\n"
        "keybind = ctrl+up=goto_split:top\n"
        "keybind = ctrl+down=goto_split:bottom\n",
        encoding="utf-8",
    )

# Retain upstream workspace components; skip all Kitty-specific operations.
baseline.apply_kitty_font = lambda: None
baseline.DISTRO = baseline.detect_distro()
baseline.ensure_user_path()
steps = (
    ("System packages", baseline.pkg_install),
    ("Zsh", baseline.install_zsh),
    ("bat", lambda: baseline.install_rust_tool("bat", "sharkdp/bat")),
    ("lsd", lambda: baseline.install_rust_tool("lsd", "lsd-rs/lsd")),
    ("fzf", baseline.install_fzf),
    ("Hack Nerd Font", baseline.install_fonts),
    ("Starship", baseline.install_starship),
    ("Neovim + NvChad", baseline.install_nvim),
    ("Ghostty + Catppuccin Macchiato", configure_ghostty),
)
for label, action in steps:
    print(f"\nInstalling {label}…", flush=True)
    action()
print("\nDone. Launch with: ghostty. Log out and back in to apply the login shell change.")
PY
