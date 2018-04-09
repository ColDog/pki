variable "vpc_id" {}

variable "private_subnet_ids" {
  type = "list"
}

variable "public_subnet_ids" {
  type = "list"
}

variable "namespace" {}

variable "security_groups" {
  default = []
}

variable "min" {
  default = 1
}

variable "max" {
  default = 1
}

variable "desired" {
  default = 1
}

variable "instance_type" {
  default = "t2.small"
}

variable "ssh_key" {
  default = "default"
}

variable "pki_image" {
  default = "coldog/pki:latest"
}

variable "root_volume_size" {
  default = "12"
}

output "kubernetes_master_key" {
  value = "${random_id.kubernetes_master.hex}"
}

output "kubernetes_worker_key" {
  value = "${random_id.kubernetes_worker.hex}"
}

output "etcd_client_key" {
  value = "${random_id.etcd_client.hex}"
}

output "etcd_server_key" {
  value = "${random_id.etcd_server.hex}"
}

output "url" {
  value = "https://${aws_lb.pki.dns_name}"
}
