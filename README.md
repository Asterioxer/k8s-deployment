# k8s-multi-cluster-demo

Demo: deploy the same app to two Minikube clusters (dev & prod) on a single host.

## Pre-reqs
- Ubuntu VM (your environment)
- Minikube installed and two profiles created:
  - default dev profile name: `minikube` (or change in scripts)
  - second profile name: `cluster2` (or change in scripts)
- Docker, kubectl installed and working
- Make scripts executable: `chmod +x scripts/*.sh`

## Create second minikube cluster (if not already)
# dev cluster usually exists; create prod:
minikube start -p cluster2 --driver=docker

## Build & deploy to DEV (run inside VM)
# switch to dev and deploy
./scripts/build_and_deploy_dev.sh

This script:
- sets docker env to dev minikube
- builds backend:dev and frontend:dev images into minikube's docker
- applies dev manifests
- prints the URL to open frontend (NodePort or minikube service)

## Build & deploy to PROD
./scripts/build_and_deploy_prod.sh

This script:
- sets docker env to cluster2
- builds backend:prod, frontend:prod
- applies prod manifests
- prints the URL to open frontend for prod

## Accessing frontends
- Dev frontend NodePort (on VM): `http://<VM_IP>:30007/`
- Prod frontend NodePort (on VM): `http://<VM_IP>:30008/`
Alternatively, use:
minikube -p minikube service frontend-svc -n dev --url
minikube -p cluster2 service frontend-svc -n prod --url

## Notes
- The backend is reachable inside cluster at `backend-svc.<namespace>.svc.cluster.local:5000`.
- The frontend makes requests to backend via the internal service DNS; no external proxy needed.
- Dev includes a hostPath PV + PVC (for demo persistence). Ensure `/tmp/dev-pv` exists on host (Minikube host or VM).
