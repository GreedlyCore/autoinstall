#!/bin/bash
set -e

install_docker() {
  command_exists() {
    command -v "$@" >/dev/null 2>&1
  }

  user_can_sudo() {
    command_exists sudo || return 1
    ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
  }

  if user_can_sudo; then
    SUDO="sudo"
  else
    SUDO="" # To support docker environment
  fi

  # Remove old Docker packages
  $SUDO apt remove -y $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc 2>/dev/null | cut -f1) 2>/dev/null || true

  # Install prerequisites
  $SUDO apt update
  $SUDO apt install -y ca-certificates curl

  # Add Docker's official GPG key
  $SUDO install -m 0755 -d /etc/apt/keyrings
  $SUDO curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  $SUDO chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources
  $SUDO tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

  # Update and install Docker
  $SUDO apt update
  $SUDO apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # Start Docker and test with sudo
  $SUDO systemctl start docker
  echo "Running with sudo..."
  $SUDO docker run hello-world

  # Add user to docker group
  $SUDO groupadd docker 2>/dev/null || true
  $SUDO usermod -aG docker $USER
  
  # Test without sudo using sg command
  echo "Running without sudo..."
  sg docker -c "docker run hello-world"
  
  echo "All tests passed!"
}

install_docker
