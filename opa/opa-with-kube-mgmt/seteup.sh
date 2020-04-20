
# seteup TLS, required for connecting k8s api server
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -days 100000 -out ca.crt -subj "/CN=admission_ca"
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=opa.opa.svc" -config server.conf
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 100000 -extensions v3_req -extfile server.conf

kubectl create secret tls opa-server --cert=server.crt --key=server.key -n opa
kubectl apply -f admission-controller.yaml

#grant permision to kube-mgmt
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=opa:default

export OPA_CA_DATA=$(cat ca.crt | base64 | tr -d '\n')
envsubst < ./webhook.template > webhook.yaml
kubectl apply -f webhook.yaml
kubectl label ns kube-system openpolicyagent.org/webhook=ignore
kubectl label ns opa openpolicyagent.org/webhook=ignore

kubectl create configmap test-configmap --from-file=allow-registry.rego -n opa
