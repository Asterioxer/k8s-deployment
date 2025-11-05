#!/usr/bin/env bash
set -e
# Builds backend & frontend into minikube dev profile and deploys manifests

PROFILE="minikube"   # your dev profile name (change if different)
echo "Using profile: $PROFILE"
minikube profile "$PROFILE"
eval "$(minikube -p "$PROFILE" docker-env)"

ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
cd "$ROOT"

# 1. Build images into minikube's Docker daemon
echo "Building backend:dev"
docker build -t backend:dev ./backend

echo "Building frontend:dev"
docker build -t frontend:dev ./frontend

# 2. Apply manifests
kubectl apply -f k8s-manifests/dev/namespace.yaml
kubectl apply -f k8s-manifests/dev/pv-pvc.yaml
kubectl apply -f k8s-manifests/dev/backend-deploy.yaml
kubectl apply -f k8s-manifests/dev/frontend-deploy.yaml

echo "Waiting for pods..."
kubectl -n dev wait --for=condition=available deployment/frontend --timeout=120s || true
kubectl -n dev get all
echo "DEV deployment done. To open frontend:"
minikube -p "$PROFILE" service frontend-svc -n dev --url
