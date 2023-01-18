resource "aws_lb" "k8s_lb" {
  name               = "k8s-lb"
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id     = aws_subnet.public_k8s_subnet[0].id
    allocation_id = aws_eip.k8s_address.id
  }
}

resource "aws_lb_listener" "k8s_lb_listener" {
  load_balancer_arn = aws_lb.k8s_lb.arn
  
  protocol = "TCP"
  port = 443

  default_action {
    type    = "forward"
    target_group_arn = aws_lb_target_group.k8s_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "k8s_lb_target_group" {
  port        = 6443
  protocol    = "TCP"
  vpc_id = aws_vpc.k8s_vpc.id
  target_type = "ip"
  # health_check {
  #   protocol = "HTTPS"
  #   port = 6443
  #   matcher = "200"
  #   path    = "/healthz"
  # }
}

resource "aws_lb_target_group_attachment" "k8s_lb_target_group_attachment" {
  count = length(aws_instance.k8s_controller[*])
  target_group_arn = aws_lb_target_group.k8s_lb_target_group.arn
  target_id        = element(aws_instance.k8s_controller[*].private_ip, count.index)
}
