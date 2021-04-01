#!/bin/bash
set -euo pipefail

if [ -z "$1" ]
  then
    echo "./local-loki.sh <path to unpacked must-gather>"
    exit 1
fi

# Create a pod
podman pod rm -f must-gather || true
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
  -e GF_AUTH_ANONYMOUS_ENABLED=true \
  -e GF_AUTH_ANONYMOUS_ORG_ROLE=Editor \
  -v $(pwd)/grafana/datasources:/etc/grafana/provisioning/datasources \
  -ti docker.io/grafana/grafana:7.5.0

# Start promtail
podman run -d \
  --pod must-gather \
  --name promtail \
  -v $(pwd)/promtail:/etc/promtail \
  -v "$1":"/logs" \
  -ti docker.io/grafana/promtail:2.2.0

echo "Grafana started at http://localhost:3000/explore"
echo "Run `podman pod rm -f must-gather` to stop all containers"
