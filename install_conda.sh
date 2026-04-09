#!/bin/bash
set -e

MODE=$1
AUTO_BASE=${2:-false}

if [ "$MODE" == "mini" ]; then
    curl --output miniconda3.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash miniconda3.sh
elif [ "$MODE" == "full" ]; then
    curl --output anaconda.sh https://repo.anaconda.com/archive/Anaconda3-2022.05-Linux-x86_64.sh
    bash anaconda.sh
else
    echo "Usage: $0 [mini|full] [auto_base]"
    exit 1
fi

source ~/.bashrc

if [ "$AUTO_BASE" == "true" ]; then
    conda config --set auto_activate_base True
else
    conda config --set auto_activate_base False
fi


# ./install_conda.sh full/mini auto_base