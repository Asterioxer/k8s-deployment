#!/usr/bin/env bash
set -e
if [ -z "$1" ]; then
  echo "Usage: $0 <minikube-profile-name>"
  echo "Example: $0 minikube"
  exit 1
fi
PROFILE="$1"
echo "Switching to profile: $PROFILE"
minikube profile "$PROFILE"
eval "$(minikube -p "$PROFILE" docker-env)"
kubectl config use-context "$PROFILE"
kubectl get nodes
