#!/bin/bash
set -e

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

user_can_sudo() {
  command_exists sudo || return 1
  ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}

install_lazygit() {
  echo "Installing lazygit..."
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  $RUN install lazygit /usr/local/bin
  rm lazygit.tar.gz lazygit
  echo "lazygit installed successfully"
}

install_lazydocker() {
  echo "Installing lazydocker..."
  LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazydocker.tar.gz lazydocker
  $RUN install lazydocker /usr/local/bin
  rm lazydocker.tar.gz lazydocker
  echo "lazydocker installed successfully"
}

main() {
  if [ $# -eq 0 ]; then
    echo "Usage: $0 [git] [docker]"
    echo "  git     install lazygit"
    echo "  docker  install lazydocker"
    exit 1
  fi

  RUN=$(user_can_sudo && echo "sudo" || echo "command")
  $RUN apt-get update

  for tool in "$@"; do
    case "$tool" in
      git)
        install_lazygit
        ;;
      docker)
        install_lazydocker
        ;;
      *)
        echo "Unknown tool: $tool (available: git, docker)"
        exit 1
        ;;
    esac
  done

  echo "Done!"
}

main "$@"