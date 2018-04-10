data "ignition_config" "pki" {
  systemd = [
    "${data.ignition_systemd_unit.pki_server.id}",
  ]

  files = [
    "${data.ignition_file.keys.id}",
  ]
}

resource "random_id" "kubernetes_master" {
  byte_length = 16
}

resource "random_id" "kubernetes_worker" {
  byte_length = 16
}

resource "random_id" "etcd_client" {
  byte_length = 16
}

resource "random_id" "etcd_server" {
  byte_length = 16
}

data "ignition_file" "keys" {
  path       = "/etc/pki/config"
  mode       = 0644
  filesystem = "root"

  content {
    content = <<EOF
KUBERNETES_MASTER_KEY=${random_id.kubernetes_master.hex}
KUBERNETES_WORKER_KEY=${random_id.kubernetes_worker.hex}
ETCD_CLIENT_KEY=${random_id.etcd_client.hex}
ETCD_SERVER_KEY=${random_id.etcd_server.hex}
S3_PATH=${var.namespace}-pki/certs
CA_HOST=${aws_lb.pki.dns_name}
CA_URL=https://${aws_lb.pki.dns_name}
EOF
  }
}

data "ignition_systemd_unit" "pki_server" {
  name    = "pki-server.service"
  enabled = true

  content = <<EOF
[Unit]
Description=PKIServer
Requires=coreos-metadata.service
After=coreos-metadata.service

[Service]
EnvironmentFile=/run/metadata/coreos
ExecStartPre=-/usr/bin/docker pull ${var.pki_image}
ExecStart=/usr/bin/docker run --rm -i \
  --net host \
  --env-file=/etc/pki/config \
  -e INSTANCE_IP=$${COREOS_EC2_IPV4_LOCAL} \
  -e INSTANCE_ID=$${COREOS_EC2_INSTANCE_ID} \
  -e INSTANCE_HOSTNAME=$${COREOS_EC2_HOSTNAME} \
  -v /etc/pki/certs/:/certs \
  ${var.pki_image}
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF
}
