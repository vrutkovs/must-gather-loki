#!/bin/bash
set -euo pipefail

if [ -z "$1" ]
  then
    echo "./local-loki.sh <path to unpacked must-gather>"
    exit 1
fi

# Create a pod
podman pod stop must-gather && podman pod rm must-gather || true
podman pod create --name must-gather -p 3000:3000

# Start Loki container
# podman rm -f loki || true
podman run -d \
  --pod must-gather \
  --name loki \
  -u 0 \
  -ti docker.io/grafana/loki:2.2.0

# Start Grafana
podman run -d \
  --pod must-gather \
  --name grafana \
  -ti docker.io/grafana/grafana:7.5.0

# Start promtail
podman run -d \
  --pod must-gather \
  --name promtail \
  -v $(pwd):/etc/promtail \
  -v "$1":"/logs" \
  -ti docker.io/grafana/promtail:2.2.0

echo "Grafana started at http://localhost:3000"
