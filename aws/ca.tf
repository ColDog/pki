resource "aws_s3_bucket" "pki" {
  bucket        = "${var.namespace}-pki"
  acl           = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "null_resource" "init_ca" {
  triggers {
    s3_bucket_arn = "${aws_s3_bucket.pki.arn}"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/certs && docker run -u 1000 -v ${path.module}/certs:/certs --rm -i ${var.pki_image} initca"
  }
}

resource "aws_s3_bucket_object" "config" {
  bucket       = "${aws_s3_bucket.pki.bucket}"
  key          = "config"
  content_type = "text/plain"
  depends_on   = ["null_resource.init_ca"]

  content = <<EOF
KUBERNETES_MASTER_KEY=${random_id.kubernetes_master.hex}
KUBERNETES_WORKER_KEY=${random_id.kubernetes_worker.hex}
ETCD_CLIENT_KEY=${random_id.etcd_client.hex}
ETCD_SERVER_KEY=${random_id.etcd_server.hex}
S3_PATH=${aws_s3_bucket.pki.bucket}
CA_HOST=${aws_lb.pki.dns_name}
CA_URL=https://${aws_lb.pki.dns_name}
EOF
}

resource "aws_s3_bucket_object" "etcd-ca-pem" {
  bucket       = "${aws_s3_bucket.pki.bucket}"
  key          = "certs/etcd-ca.pem"
  source       = "${path.module}/certs/etcd-ca.pem"
  content_type = "text/plain"
  depends_on   = ["null_resource.init_ca"]
}

resource "aws_s3_bucket_object" "kubernetes-ca-pem" {
  bucket       = "${aws_s3_bucket.pki.bucket}"
  key          = "certs/kubernetes-ca.pem"
  source       = "${path.module}/certs/kubernetes-ca.pem"
  content_type = "text/plain"
  depends_on   = ["null_resource.init_ca"]
}

resource "aws_s3_bucket_object" "pki-ca-pem" {
  bucket       = "${aws_s3_bucket.pki.bucket}"
  key          = "certs/pki-ca.pem"
  source       = "${path.module}/certs/pki-ca.pem"
  content_type = "text/plain"
  depends_on   = ["null_resource.init_ca"]
}

resource "aws_s3_bucket_object" "pki-ca-csr" {
  bucket       = "${aws_s3_bucket.pki.bucket}"
  key          = "certs/pki-ca.csr"
  source       = "${path.module}/certs/pki-ca.csr"
  content_type = "text/plain"
  depends_on   = ["null_resource.init_ca"]
}

resource "aws_s3_bucket_object" "etcd-ca-key-pem" {
  bucket       = "${aws_s3_bucket.pki.bucket}"
  key          = "certs/etcd-ca-key.pem"
  source       = "${path.module}/certs/etcd-ca-key.pem"
  content_type = "text/plain"
  depends_on   = ["null_resource.init_ca"]
}

resource "aws_s3_bucket_object" "kubernetes-ca-csr" {
  bucket       = "${aws_s3_bucket.pki.bucket}"
  key          = "certs/kubernetes-ca.csr"
  source       = "${path.module}/certs/kubernetes-ca.csr"
  content_type = "text/plain"
  depends_on   = ["null_resource.init_ca"]
}

resource "aws_s3_bucket_object" "ca-initialized-ca-initialized" {
  bucket       = "${aws_s3_bucket.pki.bucket}"
  key          = "certs/ca-initialized"
  source       = "${path.module}/certs/ca-initialized"
  content_type = "text/plain"
  depends_on   = ["null_resource.init_ca"]
}

resource "aws_s3_bucket_object" "pki-ca-key-pem" {
  bucket       = "${aws_s3_bucket.pki.bucket}"
  key          = "certs/pki-ca-key.pem"
  source       = "${path.module}/certs/pki-ca-key.pem"
  content_type = "text/plain"
  depends_on   = ["null_resource.init_ca"]
}

resource "aws_s3_bucket_object" "etcd-ca-csr" {
  bucket       = "${aws_s3_bucket.pki.bucket}"
  key          = "certs/etcd-ca.csr"
  source       = "${path.module}/certs/etcd-ca.csr"
  content_type = "text/plain"
  depends_on   = ["null_resource.init_ca"]
}

resource "aws_s3_bucket_object" "kubernetes-ca-key-pem" {
  bucket       = "${aws_s3_bucket.pki.bucket}"
  key          = "certs/kubernetes-ca-key.pem"
  source       = "${path.module}/certs/kubernetes-ca-key.pem"
  content_type = "text/plain"
  depends_on   = ["null_resource.init_ca"]
}
