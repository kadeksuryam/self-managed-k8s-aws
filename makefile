all: infra setup

infra:
	./gen-ssh-key.sh
	terraform apply -var-file="aws_keys.tfvars" -auto-approve
	./gen-certs.sh
	./gen-kubeconfig.sh
	./gen-encryption-config.sh
	./gen-inventory.sh

setup:
	ansible-playbook -i setup-k8s/inventory.ini setup-k8s/copy-certs.yaml
	ansible-playbook -i setup-k8s/inventory.ini setup-k8s/copy-kubeconfig.yaml
	ansible-playbook -i setup-k8s/inventory.ini setup-k8s/copy-encryption-config.yaml
	ansible-playbook -i setup-k8s/inventory.ini setup-k8s/bootstrap-etcd.yaml
	ansible-playbook -i setup-k8s/inventory.ini setup-k8s/bootstrap-control-plane.yaml
	ansible-playbook -i setup-k8s/inventory.ini setup-k8s/bootstrap-worker-node.yaml

destroy:
	rm -rf certs encryption-config kubeconfig ssh-key
	terraform destroy -var-file="aws_keys.tfvars" -auto-approve
