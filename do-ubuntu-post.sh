# Do-ubuntu-post-install
# install kitty+nvim+zsh+fzf
# TODO: Swap Kitty with Ghostty, or make it optionable in the future.

# Check original repo for more info --> deubuntu things
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/polkaulfield/ubuntu-debullshit/main/ubuntu-debullshit.sh)"

git clone https://github.com/Juanfu224/Auto-Kitty-Workspace.git ~/Auto-Kitty-Workspace
cd ~/Auto-Kitty-Workspace
# Do a pull request from spanish to english or just make the fork ???
python3 main.py 