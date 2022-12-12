#! /bin/bash

# kubectl auth
KUBE_CONFIG="$(mktemp)"
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --kubeconfig "${KUBE_CONFIG}" --region "$REGION" --profile sandbox-darwin

# Security group for pod env configurations
kubectl --kubeconfig "${KUBE_CONFIG}" set env daemonset aws-node -n kube-system ENABLE_POD_ENI=true
kubectl --kubeconfig "${KUBE_CONFIG}" patch daemonset aws-node \
  -n kube-system \
  -p '{"spec": {"template": {"spec": {"initContainers": [{"env":[{"name":"DISABLE_TCP_EARLY_DEMUX","value":"true"}],"name":"aws-vpc-cni-init"}]}}}}'