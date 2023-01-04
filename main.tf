resource "aws_instance" "k8s_controller" {
  count                       = 3
  ami                         = "ami-09f03fa5572692399"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.k8s_node_sg.id]
  subnet_id                   = aws_subnet.public_k8s_subnet[0].id
  associate_public_ip_address = true
  key_name                    = element(aws_key_pair.ssh_key_controller[*].key_name, count.index)
  private_ip                  = "10.240.0.1${count.index}"

  tags = {
    Name = "controller-${count.index}"
  }
}

resource "aws_instance" "k8s_worker" {
  count                       = 3
  ami                         = "ami-09f03fa5572692399"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.k8s_node_sg.id]
  subnet_id                   = aws_subnet.public_k8s_subnet[0].id
  associate_public_ip_address = true
  key_name                    = element(aws_key_pair.ssh_key_worker[*].key_name, count.index)
  private_ip                  = "10.240.0.2${count.index}"

  tags = {
    Name     = "worker-${count.index}"
    pod-cidr = "10.200.${count.index}.0/24"
  }
}
