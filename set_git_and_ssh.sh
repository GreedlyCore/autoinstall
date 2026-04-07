#!/bin/bash
set -e

# Install git and openssh-server if not already installed
sudo apt update
sudo apt install -y git openssh-server

# Enable and start SSH service forever
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl status ssh --no-pager

# Configure Git
git config --global user.name "GreedlyCore"
git config --global user.email naganariselves@gmail.com
git config --global init.defaultBranch main
git config --global commit.gpgSign true
git config --global core.editor "code --wait"
git config --global color.ui auto
git config --global core.autocrlf input  # Correct for Linux/macOS

# Generate SSH key (4096-bit RSA)
ssh-keygen -t rsa -b 4096 -C "naganariselves@gmail.com" -N "" -f ~/.ssh/id_rsa <<< y

# Display public key to add to GitHub
echo ""
echo "========== COPY THIS PUBLIC KEY TO GITHUB =========="
echo "Go to: https://github.com/settings/ssh/new"
echo ""
cat ~/.ssh/id_rsa.pub
echo ""
echo "===================================================="
