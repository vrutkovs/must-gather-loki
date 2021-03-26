#!/bin/bash
set -euo pipefail

if [ -z "$1" ]
  then
    echo "./local-loki.sh <path to unpacked must-gather>"
    exit 1
fi

# Start Loki container
docker rm -f loki || true
docker run -d --name=loki \
  -u 0 \
  -p 3100:3100 \
  -ti docker.io/grafana/loki:2.2.0

# Start Grafana
docker rm -f grafana || true
docker run -d --name=grafana \
  -p 3000:3000 \
  -ti docker.io/grafana/grafana:7.5.0

echo "Grafana started at http://localhost:3000"

docker rm -f promtail || true
docker run -d --name=promtail \
  -v $(pwd):/etc/promtail \
  -v "$1":"/logs" \
  -ti docker.io/grafana/promtail:2.2.0
