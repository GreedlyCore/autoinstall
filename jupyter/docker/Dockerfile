# Use the GPU-enabled PyTorch notebook image as the base
FROM quay.io/jupyter/pytorch-notebook:cuda12-latest

USER root

# Install system dependencies needed for OpenCV and YOLO
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# NVIDIA-Drivers should be pre-installed at the remote-machine side before 
RUN pip install --no-cache-dir \
    ultralytics \
    ipywidgets \
    jupyterlab-google-colab-theme \
    jupyterlab-git \
    jupyterlab-system-monitor \
    && jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build \
    && jupyter lab build --minimize=False

# (Optional) Set Colab theme as default
COPY --chown=${NB_UID}:${NB_GID} overrides.json /opt/conda/share/jupyter/lab/settings/overrides.json

# Set environment variable to ensure JupyterLab starts by default
ENV JUPYTER_ENABLE_LAB=yes