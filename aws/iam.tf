resource "aws_iam_instance_profile" "pki" {
  name = "${var.namespace}-pki"
  role = "${aws_iam_role.pki.name}"
}

resource "aws_iam_role" "pki" {
  name = "${var.namespace}-pki"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EtcdRole",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "pki" {
  name = "${var.namespace}-pki"
  role = "${aws_iam_role.pki.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnableLogs",
      "Action": "logs:*",
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Sid": "EnableS3",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${var.namespace}-pki",
        "arn:aws:s3:::${var.namespace}-pki/*"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF
}
