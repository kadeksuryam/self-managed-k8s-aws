#! /bin/bash

main() {
    export KUBERNETES_PUBLIC_ADDRESS=$(terraform output k8s_address)
    kubectl config set-cluster terraform-k8s \
        --certificate-authority=certs/ca/ca.pem \
        --embed-certs=true \
        --server=https://${KUBERNETES_PUBLIC_ADDRESS}
    kubectl config set-credentials admin \
        --client-certificate=certs/admin-client/admin.pem \
        --client-key=certs/admin-client/admin-key.pem
    kubectl config set-context terraform-k8s \
        --cluster=terraform-k8s \
        --user=admin
    kubectl config use-context terraform-k8s
}
main