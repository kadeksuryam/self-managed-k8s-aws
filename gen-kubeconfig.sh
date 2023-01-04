#! /bin/bash

gen_config_worker() {
    KUBERNETES_PUBLIC_ADDRESS=$(terraform output k8s_address)

    mkdir -p kubeconfig/worker-node/kubelet
    for instance in worker-0 worker-1 worker-2; do
        kubectl config set-cluster terraform-k8s \
            --certificate-authority=certs/ca/ca.pem \
            --embed-certs=true \
            --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
            --kubeconfig=kubeconfig/worker-node/kubelet/${instance}.kubeconfig

        kubectl config set-credentials system:node:${instance} \
            --client-certificate=certs/worker-node/kubelet/${instance}.pem \
            --client-key=certs/worker-node/kubelet/${instance}-key.pem \
            --embed-certs=true \
            --kubeconfig=kubeconfig/worker-node/kubelet/${instance}.kubeconfig

        kubectl config set-context default \
            --cluster=terraform-k8s \
            --user=system:node:${instance} \
            --kubeconfig=kubeconfig/worker-node/kubelet/${instance}.kubeconfig

        kubectl config use-context default --kubeconfig=kubeconfig/worker-node/kubelet/${instance}.kubeconfig
    done
}

gen_config_kube_proxy() {
  KUBERNETES_PUBLIC_ADDRESS=$(terraform output k8s_address)
  
  mkdir -p kubeconfig/worker-node/kube-proxy
  kubectl config set-cluster terraform-k8s \
    --certificate-authority=certs/ca/ca.pem  \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kubeconfig/worker-node/kube-proxy/kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=certs/worker-node/kube-proxy/kube-proxy.pem \
    --client-key=certs/worker-node/kube-proxy/kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kubeconfig/worker-node/kube-proxy/kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=terraform-k8s \
    --user=system:kube-proxy \
    --kubeconfig=kubeconfig/worker-node/kube-proxy/kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kubeconfig/worker-node/kube-proxy/kube-proxy.kubeconfig
}

gen_config_controller_manager() {
  mkdir -p kubeconfig/controller-node/controller-manager
  kubectl config set-cluster terraform-k8s \
    --certificate-authority=certs/ca/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kubeconfig/controller-node/controller-manager/kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=certs/controller-node/controller-manager/kube-controller-manager.pem \
    --client-key=certs/controller-node/controller-manager/kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kubeconfig/controller-node/controller-manager/kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=terraform-k8s \
    --user=system:kube-controller-manager \
    --kubeconfig=kubeconfig/controller-node/controller-manager/kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kubeconfig/controller-node/controller-manager/kube-controller-manager.kubeconfig
}

gen_config_kube_scheduler() {
  mkdir -p kubeconfig/controller-node/scheduler
  kubectl config set-cluster terraform-k8s \
    --certificate-authority=certs/ca/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kubeconfig/controller-node/scheduler/kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=certs/controller-node/scheduler/kube-scheduler.pem \
    --client-key=certs/controller-node/scheduler/kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kubeconfig/controller-node/scheduler/kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=terraform-k8s \
    --user=system:kube-scheduler \
    --kubeconfig=kubeconfig/controller-node/scheduler/kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kubeconfig/controller-node/scheduler/kube-scheduler.kubeconfig
}

gen_config_admin() {
    mkdir -p kubeconfig/admin-client
    kubectl config set-cluster terraform-k8s \
    --certificate-authority=certs/ca/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kubeconfig/admin-client/admin.kubeconfig
    
    kubectl config set-credentials admin \
    --client-certificate=certs/admin-client/admin.pem \
    --client-key=certs/admin-client/admin-key.pem \
    --embed-certs=true \
    --kubeconfig=kubeconfig/admin-client/admin.kubeconfig

    kubectl config set-context default \
    --cluster=terraform-k8s \
    --user=admin \
    --kubeconfig=kubeconfig/admin-client/admin.kubeconfig

    kubectl config use-context default --kubeconfig=kubeconfig/admin-client/admin.kubeconfig
}

main() {
    gen_config_worker
    gen_config_kube_proxy
    gen_config_controller_manager
    gen_config_kube_scheduler
    gen_config_admin
}

main