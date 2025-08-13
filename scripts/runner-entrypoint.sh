



#!/bin/sh

# Create runner configuration
mkdir -p /data

#
NETWORK_NAME="gitea_gitea"  # fallback to default compose network name


# Create runner config with network settings
cat > /data/config.yaml <<EOF
log:
  level: info

runner:
  file: .runner
  capacity: 1
  environ: []
  env_file: .env
  timeout: 3h
  insecure: false
  fetch_timeout: 5s
  fetch_interval: 2s

cache:
  enabled: true
  dir: ""
  host: ""
  port: 0
  external_server: ""

container:
  network_mode: "$NETWORK_NAME"
  extra_hosts:
    - "gitea:host-gateway"
    - "host.docker.internal:host-gateway"
  privileged: false
  options: "--add-host=gitea:host-gateway --add-host=host.docker.internal:host-gateway"
  workdir_parent: "/tmp"
EOF

# Register and start the runner
if [ ! -f ".runner" ]; then
    echo "Registering runner..."
    act_runner register \
        --instance "http://gitea:3000" \
        --token "L1wPrq9d4r7Q3srnULedPArVqNs0w1uFiuaNb27S" \
        --name "runner01" \
        --labels "ubuntu-latest:docker://docker.gitea.com/runner-images:ubuntu-latest" \
        --config /data/config.yaml \
        --no-interactive
fi

echo "Starting runner..."
act_runner daemon --config /data/config.yaml