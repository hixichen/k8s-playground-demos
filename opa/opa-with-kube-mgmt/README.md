# setup in minikube:

`./setup.sh`

# Test:
`kubectl apply -f test-registry.yaml`

Log:
`Error from server (invalid deployment, namespace="default", name="test", registry="busybox"): error when creating "fail-registry.yaml": admission webhook "validating-webhook.openpolicyagent.org" denied the request: invalid deployment, namespace="default", name="test", registry="busybox"`
