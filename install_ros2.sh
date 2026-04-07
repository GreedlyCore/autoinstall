#!/bin/bash
set -e

# Usage: ./install_ros.sh <distro> <shell>
# distro: humble (22.04) or jazzy (24.04)
# shell: bash or zsh
# Example: ./install_ros.sh humble bash

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

user_can_sudo() {
  command_exists sudo || return 1
  ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}

get_ubuntu_version() {
  . /etc/os-release
  echo "$VERSION_ID"
}

validate_distro() {
  local distro="$1"
  local ubuntu_version=$(get_ubuntu_version)
  
  case "$distro" in
    humble)
      if [[ "$ubuntu_version" != "22.04" ]]; then
        echo "Error: Humble requires Ubuntu 22.04 (Jammy). You have $ubuntu_version"
        exit 1
      fi
      echo "humble"
      ;;
    jazzy)
      if [[ "$ubuntu_version" != "24.04" ]]; then
        echo "Error: Jazzy requires Ubuntu 24.04 (Noble). You have $ubuntu_version"
        exit 1
      fi
      echo "jazzy"
      ;;
    *)
      echo "Error: Invalid distribution '$distro'. Use 'humble' or 'jazzy'"
      exit 1
      ;;
  esac
}

get_ros_version() {
  local distro="$1"
  case "$distro" in
    humble) echo "humble" ;;
    jazzy)  echo "jazzy" ;;
  esac
}

main() {
  # Parse arguments
  local distro="${1:-humble}"
  local shell_type="${2:-bash}"
  
  # Validate inputs
  distro=$(validate_distro "$distro")
  
  if [[ "$shell_type" != "bash" && "$shell_type" != "zsh" ]]; then
    echo "Error: Invalid shell '$shell_type'. Use 'bash' or 'zsh'"
    exit 1
  fi
  
  local ros_version=$(get_ros_version "$distro")
  local ubuntu_codename=$(. /etc/os-release && echo "$UBUNTU_CODENAME")
  
  echo "Installing ROS 2 $ros_version on Ubuntu $ubuntu_codename"
  echo "Shell configuration: $shell_type"
  
  RUN=$(user_can_sudo && echo "sudo" || echo "command")
  
  # Install prerequisites
  $RUN apt-get update && $RUN apt-get install -y lsb-release curl gnupg && $RUN apt-get clean all
  
  # Add ROS 2 repository
  $RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
  
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $ubuntu_codename main" | $RUN tee /etc/apt/sources.list.d/ros2.list > /dev/null
  
  # Update and install ROS 2
  $RUN apt update -y
  $RUN apt install -y "ros-$ros_version-desktop-full"
  
  # Install development tools
  $RUN apt install -y python3-rosdep python3-colcon-common-extensions python3-vcstool python3-argcomplete build-essential
  
  # Setup rosdep
  $RUN rosdep init 2>/dev/null || echo "rosdep already initialized"
  rosdep update
  
  # Source setup files
  local setup_file="/opt/ros/$ros_version/setup.$shell_type"
  local rc_file="$HOME/.${shell_type}rc"
  
  if [[ -f "$setup_file" ]]; then
    echo "source $setup_file" >> "$rc_file"
    echo "ROS 2 $ros_version setup sourced in $rc_file"
    
    # Also source in current session
    source "$setup_file"
  else
    echo "Warning: Setup file not found at $setup_file"
  fi
  
  # Optional: Add colcon autocompletion
  if [[ "$shell_type" == "bash" ]]; then
    echo "source /usr/share/colcon-argcomplete/hooks/colcon-argcomplete.bash" >> "$rc_file"
  elif [[ "$shell_type" == "zsh" ]]; then
    echo "source /usr/share/colcon-argcomplete/hooks/colcon-argcomplete.zsh" >> "$rc_file"
  fi
  
  echo ""
  echo "ROS 2 $ros_version installation complete!"
  echo "Please restart your terminal or run: source $rc_file"
  echo ""
  echo "Quick test:"
  echo "  ros2 --version"
  echo "  ros2 run demo_nodes_cpp talker"
}


main "$@"