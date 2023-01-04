resource "aws_key_pair" "ssh_key_controller" {
  count      = 3
  key_name   = "controller-${count.index}"
  public_key = file("ssh-key/controller-${count.index}.pub")
}

resource "aws_key_pair" "ssh_key_worker" {
  count      = 3
  key_name   = "worker-${count.index}"
  public_key = file("ssh-key/worker-${count.index}.pub")
}
