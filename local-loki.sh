#!/bin/bash
set -euo pipefail

if [ -z "$1" ]
  then
    echo "./local-loki.sh <path to unpacked must-gather>"
    exit 1
fi

# Create a pod
sed "s;REPLACE_ME;$1;g" grafana-stack-template.yaml > grafana-stack.yaml
podman play kube grafana-stack.yaml

echo "Grafana started at http://localhost:3000/explore"
echo "Run `podman pod rm -f must-gather` to stop all containers"
