#!/bin/bash


if [ -n "$DEBUG" ]; then
	set -x
fi

set -o errexit
set -o nounset
set -o pipefail


DOCKER_IN_DOCKER_ENABLED=${DOCKER_IN_DOCKER_ENABLED:-false}
if ! command -v kind &> /dev/null; then
  echo "kind is not installed"
  echo "Use a package manager (i.e 'brew install kind') or visit the official site https://kind.sigs.k8s.io"
  exit 1
fi

if ! command -v kubectl &> /dev/null; then
  echo "Please install kubectl 1.15 or higher"
  exit 1
fi

if ! command -v helm &> /dev/null; then
  echo "Please install helm"
  exit 1
fi

HELM_VERSION=$(helm version 2>&1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+') || true
if [[ ${HELM_VERSION} < "v3.0.0" ]]; then
  echo "Please upgrade helm to v3.0.0 or higher"
  exit 1
fi

KUBE_CLIENT_VERSION=$(kubectl version --client --short | awk '{print $3}' | cut -d. -f2) || true
if [[ ${KUBE_CLIENT_VERSION} -lt 14 ]]; then
  echo "Please update kubectl to 1.15 or higher"
  exit 1
fi

export K8S_VERSION=${K8S_VERSION:-v1.19.11}

KIND_CLUSTER_NAME="kube-trial"

if [[ "$DOCKER_IN_DOCKER_ENABLED" == "true" ]]; then
  docker network create -d bridge kind || true
	export APISERVER=$(docker network inspect kind | jq -r '.[0].IPAM.Config[0].Gateway')
else
    export APISERVER="127.0.0.1";
fi

echo $APISERVER

if ! kind get clusters -q | grep -q ${KIND_CLUSTER_NAME}; then
echo "[create-cluster] creating Kubernetes cluster with kind"
cat <<EOF | kind create cluster --name ${KIND_CLUSTER_NAME} --image "kindest/node:${K8S_VERSION}" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: ${APISERVER}
  apiServerPort: 30002
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
        authorization-mode: "AlwaysAllow"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
EOF
else
  echo "[create-cluster] using existing Kubernetes kind cluster"
fi

INGRESS_IMG="k8s.gcr.io/ingress-nginx/controller:v1.0.4@sha256:545cff00370f28363dad31e3b59a94ba377854d3a11f18988f5f9e56841ef9ef"
docker pull $INGRESS_IMG
kind load docker-image --name="${KIND_CLUSTER_NAME}" $INGRESS_IMG
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml --validate=false

#mkdir -p ~/.kube
#kind get kubeconfig --name=${KIND_CLUSTER_NAME} > ~/.kube/config



