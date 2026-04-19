#!/bin/bash
# install.sh - Run everytime you need

REMOTE_HOST="$1"
REMOTE_USER="$2"
NOTEBOOK_DIR="${3:-jupyter_work}"

if [ -z "$REMOTE_HOST" ] || [ -z "$REMOTE_USER" ]; then
    echo "Usage: ./setup.sh <remote_host> <remote_user> [notebook_dir]"
    exit 1
fi

ssh -t "$REMOTE_USER@$REMOTE_HOST" "bash -s" << 'ENDSSH'
mkdir -p ~/jupyter_work && cd ~/jupyter_work

python3 -m venv jupyter_env
source jupyter_env/bin/activate

pip install --upgrade pip
pip install jupyter notebook ultralytics torch torchvision

jupyter notebook --generate-config
echo "c.NotebookApp.ip = '0.0.0.0'" >> ~/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.allow_origin = '*'" >> ~/.jupyter/jupyter_notebook_config.py

echo "Setup complete. Use ./start.sh to launch"
ENDSSH