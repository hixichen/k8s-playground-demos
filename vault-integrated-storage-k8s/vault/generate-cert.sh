#!/bin/bash
set -ex

brew install cfssl
brew install cfssljson

cfssl gencert  -ca=certs/ca.pem  -ca-key=certs/ca-key.pem \
   -config=certs/config/ca-config.json  -profile=default  certs/config/vault-csr.json | cfssljson -bare certs/vault