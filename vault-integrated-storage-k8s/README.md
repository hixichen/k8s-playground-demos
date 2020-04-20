# hashicorp-vault-integrated-storage-k8s
deploy vault integrated storage on K8S


### Get yamls

```
git clone https://github.com/hixichen/hashicorp-vault-integrated-storage-k8s.git
brew install kustomize
cd hashicorp-vault-integrated-storage-k8s/vault
kustomize build -o generated/
```

How to get config.hcl:

docker-entrypoint.sh

	`envsubst < "/vault/config.hcl.template" > "vault/config/config.hcl"`