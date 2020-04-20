#!/bin/bash -e

kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin  --user minikube
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
kubectl apply -f template.yaml
kubectl apply -f allow-repo.yaml