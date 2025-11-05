#!/usr/bin/env bash
set -e
# Builds backend & frontend into minikube prod profile and deploys manifests

PROFILE="cluster2"   # your prod profile name (change if different)
echo "Using profile: $PROFILE"
minikube profile "$PROFILE"
eval "$(minikube -p "$PROFILE" docker-env)"

ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
cd "$ROOT"

# 1. Build images into minikube's Docker daemon (prod tags)
echo "Building backend:prod"
docker build -t backend:prod ./backend

echo "Building frontend:prod"
docker build -t frontend:prod ./frontend

# 2. Apply manifests
kubectl apply -f k8s-manifests/prod/namespace.yaml
kubectl apply -f k8s-manifests/prod/backend-deploy.yaml
kubectl apply -f k8s-manifests/prod/frontend-deploy.yaml

echo "Waiting for pods..."
kubectl -n prod wait --for=condition=available deployment/frontend --timeout=120s || true
kubectl -n prod get all
echo "PROD deployment done. To open frontend:"
minikube -p "$PROFILE" service frontend-svc -n prod --url
