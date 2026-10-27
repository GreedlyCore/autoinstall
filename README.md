# Hyungtae's Ubuntu Auto-Installation

Auto-installation of Ubuntu environments (tested on 20.04 and Ubuntu 22.04) to reduce the time taken to set up a new computer.

# (Important) Requirements

What we only need is curl. Install `curl` before you run the command.

```
sudo apt-get update && sudo apt-get install curl git wget lsb-release -y
```

In case of the **docker** case:

```
apt-get update && apt-get install curl git wget lsb-release -y
```

# All Things are ready!

For a Ghostty variant of [Auto-Kitty-Workspace](https://github.com/Juanfu224/Auto-Kitty-Workspace), run as your desktop user:

```bash
bash do-ghossty.sh
```

This installs Ghostty with **Catppuccin Macchiato**, Hack Nerd Font, Zsh,
Starship, bat, lsd, fzf, and Neovim/NvChad. Requires Ubuntu, Git, Python 3.10+,
sudo, curl, and internet access. Ghostty uses an existing native install, apt,
or the [mkasberg/ghostty-ubuntu installer](https://github.com/mkasberg/ghostty-ubuntu).
No Snap or Flatpak is required. The community installer currently supports Ubuntu
24.04 and 26.04; Ubuntu 22.04 is unsupported. Installer failures stop the script
before workspace configuration changes.
The inspected baseline is pinned to `20731f79baf32092d545d1691d48cfd24497c867`
and cloned into a temporary directory. Kitty is not installed. Existing Ghostty
config is backed up alongside its file, respecting `XDG_CONFIG_HOME`.
The default terminal is unchanged. The original `do-ubuntu-post.sh` remains the Kitty version.

**Before running:** the baseline replaces user/root Zsh and Starship configuration,
changes both login shells, and deletes existing user/root Neovim configuration,
data, and cache. Back up your workspace first. See `bash do-ghossty.sh --help`.

Just run the below command to bootstrap your Ubuntu setting. I recommend using this script in your local computer, not server.

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/LimHyungTae/autoinstall/main/install_dev_packages.sh)"
```

(Optional. Only for desktop, not docker environment!)

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/LimHyungTae/autoinstall/main/install_util_packages.sh)"
```

By doing so, below things are installed (update: Mar 10th, 2023)
* git
* wget
* vim
* chrome (**NOTE**: It requires typing `enter` key, so automatic installation may breaks)
* dconf-editor (to place favorite icons in an optimal way)
* Notion (https://shanepark.tistory.com/265)
* Some C++ libraries
* Video utils for playing mkv file
* terminator (**WARNING**: it may change your cmd's color theme)
* xpad
* simplescreenrecorder
* Inkscape
* pip3
* Docker
---

If you don't want to install something, `git clone` this repository and comment those lines by `#`. Then, just run it like `sh ${DIR}/install_independent_packages.sh`

---

## Additional packages

**If you want to install ROS-Noetic (for Ubuntu 20.04)**:

**NOTE** the you have to use `bash`, not `sh` in front of the command (because Ubuntu's shell is [dash](https://velog.io/@jiyeong3141592/binsh-%EC%9D%98%EB%AF%B8)). 

You can check it by typing `ls -ahl /bin/sh` in your cmd (then, you can show that `sh` is linked to `dash`, i.e. `/bin/sh -> dash`).

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/LimHyungTae/autoinstall/main/install_ros_noetic.sh)${YOUR BASH}" 
```

### If you use `bash`, 

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/LimHyungTae/autoinstall/main/install_ros_noetic.sh)bash" 
```

### If you use `zsh`, 

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/LimHyungTae/autoinstall/main/install_ros_noetic.sh)zsh" 
```

No space seems to be weird, but it works!

## Other package

### Anaconda

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/LimHyungTae/autoinstall/main/install_anaconda3.sh)"
```

After the installation, rune the below command to update conda:

```
conda update -n base -c defaults conda --repodata-fn=repodata.json
```

### ROS2 in Ubuntu 24.04

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/LimHyungTae/autoinstall/main/install_ros2_jazzy.sh)"
```

### VIM & VIM Vundle

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/LimHyungTae/autoinstall/main/install_vim_and_vundle.sh)"
```

### Oh-My-ZSH

* Install zsh
 
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/LimHyungTae/autoinstall/main/install_zsh.sh)"
```

* Install zsh plugins

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/LimHyungTae/autoinstall/main/install_zsh_plugins.sh)"
```






## NOTE (Minor)

* Rather using `$(lsb_release -sc)`, I used `$(. /etc/os-release && echo $UBUNTU_CODENAME)`.


