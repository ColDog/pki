data "aws_ami" "coreos_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CoreOS-stable-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-id"
    values = ["595879546273"]
  }
}

resource "aws_launch_configuration" "pki" {
  name                 = "${var.namespace}-pki-${substr(sha256(data.ignition_config.pki.rendered), 0, 8)}"
  image_id             = "${data.aws_ami.coreos_ami.image_id}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.ssh_key}"
  iam_instance_profile = "${aws_iam_instance_profile.pki.id}"
  security_groups      = ["${aws_security_group.pki_instance.id}"]

  associate_public_ip_address = false
  user_data                   = "${data.ignition_config.pki.rendered}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "${var.root_volume_size}"
  }

  lifecycle {
    ignore_changes        = ["name"]
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "pki" {
  name                 = "${var.namespace}-pki"
  max_size             = "${var.max}"
  min_size             = "${var.min}"
  desired_capacity     = "${var.desired}"
  launch_configuration = "${aws_launch_configuration.pki.id}"
  force_delete         = true
  vpc_zone_identifier  = ["${var.private_subnet_ids}"]
  termination_policies = ["OldestLaunchConfiguration"]

  health_check_grace_period = 30
  health_check_type         = "EC2"

  target_group_arns = ["${aws_lb_target_group.pki.arn}"]

  tag {
    key                 = "Name"
    value               = "${var.namespace}-pki"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
