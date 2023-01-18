#! /bin/bash

gen_ca() {
    mkdir -p certs/ca
    cfssl gencert -initca pki-config/ca/ca-csr.json | cfssljson -bare certs/ca/ca
}

gen_admin_client_cert() {
    mkdir -p certs/admin-client
    cfssl gencert \
        -ca=certs/ca/ca.pem \
        -ca-key=certs/ca/ca-key.pem \
        -config=pki-config/ca/ca-config.json \
        -profile=kubernetes \
        pki-config/admin-client/admin-csr.json | cfssljson -bare certs/admin-client/admin

}

gen_controller_node_cert() {
    # gen api server cert
    KUBERNETES_PUBLIC_ADDRESS=$(terraform output k8s_address)

    KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local

    mkdir -p certs/controller-node/api-server
    cfssl gencert \
        -ca=certs/ca/ca.pem \
        -ca-key=certs/ca/ca-key.pem \
        -config=pki-config/ca/ca-config.json \
        -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
        -profile=kubernetes \
        pki-config/controller-node/api-server/api-server-csr.json | cfssljson -bare certs/controller-node/api-server/api-server

    # gen controller-manager cert
    mkdir -p certs/controller-node/controller-manager
    cfssl gencert \
        -ca=certs/ca/ca.pem \
        -ca-key=certs/ca/ca-key.pem \
        -config=pki-config/ca/ca-config.json \
        -profile=kubernetes \
        pki-config/controller-node/controller-manager/kube-controller-manager-csr.json | cfssljson -bare certs/controller-node/controller-manager/kube-controller-manager

    # gen scheduler cert
    mkdir -p certs/controller-node/scheduler
    cfssl gencert \
        -ca=certs/ca/ca.pem \
        -ca-key=certs/ca/ca-key.pem \
        -config=pki-config/ca/ca-config.json \
        -profile=kubernetes \
        pki-config/controller-node/scheduler/kube-scheduler-csr.json | cfssljson -bare certs/controller-node/scheduler/kube-scheduler

     # gen service account cert
    mkdir -p certs/controller-node/controller-manager/service-account
    cfssl gencert \
        -ca=certs/ca/ca.pem \
        -ca-key=certs/ca/ca-key.pem \
        -config=pki-config/ca/ca-config.json \
        -profile=kubernetes \
        pki-config/controller-node/controller-manager/service-account/service-account-csr.json | cfssljson -bare certs/controller-node/controller-manager/service-account/service-account
}

gen_worker_node_cert() {
    # gen kubelet cert
    mkdir -p certs/worker-node/kubelet
    for i in {0..2}; do
        EXTERNAL_IP=$(terraform output -json | jq -r ".worker_external_address.value[${i}]")
        INTERNAL_IP=$(terraform output -json | jq -r ".worker_internal_address.value[${i}]")

        cfssl gencert \
            -ca=certs/ca/ca.pem \
            -ca-key=certs/ca/ca-key.pem \
            -config=pki-config/ca/ca-config.json \
            -hostname=worker-${i},${EXTERNAL_IP},${INTERNAL_IP} \
            -profile=kubernetes \
            pki-config/worker-node/kubelet/worker-${i}-csr.json | cfssljson -bare certs/worker-node/kubelet/worker-${i}
    done
    
    # gen kube-proxy cert
    mkdir -p certs/worker-node/kube-proxy
    cfssl gencert \
        -ca=certs/ca/ca.pem \
        -ca-key=certs/ca/ca-key.pem \
        -config=pki-config/ca/ca-config.json \
        -profile=kubernetes \
        pki-config/worker-node/kube-proxy/kube-proxy-csr.json | cfssljson -bare certs/worker-node/kube-proxy/kube-proxy
}


main() {
    mkdir -p certs
    gen_ca
    gen_admin_client_cert
    gen_controller_node_cert
    gen_worker_node_cert
}

main