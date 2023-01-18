output "k8s_address" {
  value = aws_eip.k8s_address.public_ip
}

output "worker_internal_address" {
    value = aws_instance.k8s_worker[*].private_ip
}

output "worker_external_address" {
    value = aws_instance.k8s_worker[*].public_ip
}

output "controller_external_address" {
    value = aws_instance.k8s_controller[*].public_ip
}
