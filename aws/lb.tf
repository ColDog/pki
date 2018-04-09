resource "aws_lb" "pki" {
  name                             = "${var.namespace}-pki"
  subnets                          = ["${var.public_subnet_ids}"]
  internal                         = true
  enable_cross_zone_load_balancing = true
  ip_address_type                  = "ipv4"
  load_balancer_type               = "network"
  idle_timeout                     = 3600
}

resource "aws_lb_listener" "pki" {
  load_balancer_arn = "${aws_lb.pki.arn}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.pki.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "pki" {
  name     = "${var.namespace}-pki"
  port     = 8080
  protocol = "TCP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    port     = "8080"
    protocol = "TCP"
  }
}
