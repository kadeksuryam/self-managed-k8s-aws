main() {
    controller="[controllers]"
    worker="[workers]"
    for i in {0..2}; do
        EXTERNAL_IP_CONTROLLER=$(terraform output -json | jq -r ".controller_external_address.value[${i}]")
        EXTERNAL_IP_WORKER=$(terraform output -json | jq -r ".worker_external_address.value[${i}]")
        controller="${controller}\n${EXTERNAL_IP_CONTROLLER}    ansible_ssh_private_key_file=ssh-key/controller-${i}"
        worker="${worker}\n${EXTERNAL_IP_WORKER}    ansible_ssh_private_key_file=ssh-key/worker-${i}"
    done

    inventory="$controller\n\n$worker"

    echo $inventory > setup-k8s/inventory.ini
}

main