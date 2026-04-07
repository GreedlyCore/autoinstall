#!/bin/bash
set -e

sudo apt update
sudo apt upgrade -y

sudo apt install -y \
    build-essential cmake make htop git net-tools curl wget \
    software-properties-common apt-transport-https ca-certificates gnupg lsb-release \
    nmap tree gcc-9 g++-9 python3-pip python3-dev python3-venv gdb \
    libboost-all-dev libeigen3-dev libblas-dev liblapack-dev libatlas-base-dev \
    libomp-dev libtbb-dev libyaml-cpp-dev libconsole-bridge-dev libpcl-dev \
    ripgrep fuse \
    terminator nvtop iotop nload screen tmux openssh-server

sudo snap install code --classic
sudo snap install chromium

# VS Code extensions
code --install-extension ms-vscode-remote.remote-ssh --force
code --install-extension ms-vscode-remote.remote-ssh-edit --force
code --install-extension ms-vscode.remote-explorer --force
code --install-extension ms-python.python --force
code --install-extension ms-vscode.cmake-tools --force
code --install-extension ms-vscode.cpptools --force
code --install-extension ms-vscode.cpptools-extension-pack --force
code --install-extension ms-vscode.cpptools-themes --force
code --install-extension zchrissirhcz.cmake-highlight --force
code --install-extension twxs.cmake --force

# Related to ~Colcon (ROS2 build tool)
# sudo sh -c 'echo "deb [arch=amd64,arm64] http://repo.ros2.org/ubuntu/main `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'
# curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
# sudo apt update
# sudo apt install -y python3-colcon-common-extensions

# Python pip packages
# pip3 install --upgrade pip setuptools wheel
# pip3 install flake8 pytest pytest-cov mypy numpy scipy matplotlib jupyter
# pip3 install --user transforms3d pyquaternion opencv-python open3d pandas sympy scikit-learn pillow

# .bashrc additions
cat >> ~/.bashrc << 'EOF'

# Aliases
alias sb='source ~/.bashrc'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Colcon aliases
alias cb='colcon build --symlink-install'
alias cbp='colcon build --symlink-install --packages-select'

export PATH="$HOME/.local/bin:$PATH"
EOF

echo "Reboot probably recommended"