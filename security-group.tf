resource "aws_security_group" "k8s_node_sg" {
  vpc_id = aws_vpc.k8s_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow ssh to node"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all"
  }
}


resource "aws_security_group_rule" "allow_ingress_lb_HTTPS" {
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_node_sg.id
  type              = "ingress"
}

resource "aws_security_group_rule" "allow_ingress_lb_6443" {
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_node_sg.id
  type              = "ingress"
}

resource "aws_security_group_rule" "allow_internal_ingress" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.240.0.0/24", "10.200.0.0/16"]
  security_group_id = aws_security_group.k8s_node_sg.id
  type              = "ingress"
}
