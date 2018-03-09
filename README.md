# PKI Infrastructure for Kubernetes using CFSSL

This is a docker container with a basic setup for providing a PKI infrastructure for Kubernetes.

## Usage

Run CA server, we'll use `--net=host` for the example.

```
docker run --net host --env-file .env --rm -it coldog/pki
```

Sign a certificate using a provided profile.

```
docker run --net host --rm -it --env-file .env -v $PWD/certs:/certs coldog/pki gencert etcd client
```

Available profiles:

- `kubernetes cni`
- `kubernetes master`
- `kubernetes proxy`
- `kubernetes worker`
- `etcd-client`
- `etcd-server`
- `pki-server`

Profiles can be added by including a new folder under `csr/<ca-name>-<profile>` with a `csr.json` and a `profile.json`.

## Configuration

The profile and CSR json files may be modified with additional environment variables.

```bash
# These are hex encoded secret keys.
KUBERNETES_MASTER_KEY=0123456789ABCDEF0123456789ABCDEF
KUBERNETES_WORKER_KEY=0123456789ABCDEF0123456789ABCDEF
ETCD_CLIENT_KEY=0123456789ABCDEF0123456789ABCDEF
ETCD_SERVER_KEY=0123456789ABCDEF0123456789ABCDEF

# The URL of the CA server.
CA_URL=https://127.0.0.1:8080

# Instance hostname.
INSTANCE_HOSTNAME=testing.local
INSTANCE_IP=192.168.0.11
INSTANCE_ID=1-local

# Some master and internal urls.
KUBERNETES_MASTER_PUBLIC=k8s.test.com
KUBERNETES_MASTER_INTERNAL=k8s.internal
```
