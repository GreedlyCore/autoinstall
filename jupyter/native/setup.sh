#!/bin/bash
# setup.sh - Run once on remote machine

REMOTE_HOST="$1"
REMOTE_USER="$2"
LOCAL_PORT="${3:-8888}"
REMOTE_PORT="${4:-8888}"

if [ -z "$REMOTE_HOST" ] || [ -z "$REMOTE_USER" ]; then
    echo "Usage: ./start.sh <remote_host> <remote_user> [local_port] [remote_port]"
    exit 1
fi

echo "[1/6] Killing existing sessions..."
pkill -f "ssh -L $LOCAL_PORT:localhost" 2>/dev/null
ssh -o ConnectTimeout=5 "$REMOTE_USER@$REMOTE_HOST" "pkill -f jupyter" 2>/dev/null
sleep 2
echo "Done."

echo "[2/6] Starting Jupyter server on remote machine..."
ssh -o ConnectTimeout=5 -f "$REMOTE_USER@$REMOTE_HOST" "cd ~/jupyter_work && source jupyter_env/bin/activate && nohup jupyter notebook --port=$REMOTE_PORT --no-browser --ip=0.0.0.0 > jupyter.log 2>&1 &"
echo "Jupyter start command sent"
sleep 5

echo "[3/6] Waiting for Jupyter to initialize..."
for i in {1..10}; do
    echo "   Attempt $i/10..."
    TOKEN=$(ssh -o ConnectTimeout=5 "$REMOTE_USER@$REMOTE_HOST" "cd ~/jupyter_work && cat jupyter.log 2>/dev/null | grep -o 'token=[a-f0-9]*' | head -1 | cut -d'=' -f2")
    if [ ! -z "$TOKEN" ]; then
        echo "   Token found!"
        break
    fi
    sleep 2
done

if [ -z "$TOKEN" ]; then
    echo "[4/6] Token not found in log. Trying alternative method..."
    TOKEN=$(ssh -o ConnectTimeout=5 "$REMOTE_USER@$REMOTE_HOST" "cd ~/jupyter_work && source jupyter_env/bin/activate && jupyter notebook list 2>/dev/null | grep -o 'token=[a-f0-9]*' | head -1 | cut -d'=' -f2")
fi

if [ -z "$TOKEN" ]; then
    echo "ERROR: Could not get token. Debug info:"
    echo "--- Remote log content ---"
    ssh -o ConnectTimeout=5 "$REMOTE_USER@$REMOTE_HOST" "cd ~/jupyter_work && ls -la && cat jupyter.log 2>/dev/null || echo 'No log file found'"
    echo "--- End of log ---"
    exit 1
fi

echo "[5/6] Token obtained: $TOKEN"

echo "[6/6] Creating SSH tunnel..."
ssh -f -N -L "$LOCAL_PORT:localhost:$REMOTE_PORT" "$REMOTE_USER@$REMOTE_HOST"
if [ $? -eq 0 ]; then
    echo "Tunnel established successfully."
else
    echo "ERROR: Failed to create tunnel."
    exit 1
fi

echo ""
echo "=========================================="
echo "Open in Chrome: http://localhost:$LOCAL_PORT/?token=$TOKEN"
echo "=========================================="
echo ""
echo "Press Ctrl+C to stop"

trap 'echo ""; echo "Cleaning up..."; ssh "$REMOTE_USER@$REMOTE_HOST" "pkill -f jupyter"; pkill -f "ssh -L $LOCAL_PORT"; echo "Done."; exit' INT
while true; do sleep 1; done