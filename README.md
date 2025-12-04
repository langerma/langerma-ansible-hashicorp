# HashiCorp Infrastructure Deployment

This repository contains Ansible playbooks to deploy a complete HashiCorp infrastructure stack with service discovery, workload orchestration, secret management, and observability.

The playbooks deploy Consul, Nomad, Vault, and Grafana Alloy across a cluster of servers and clients running Fedora CoreOS.

## Prerequisites

Before you begin, ensure you have the following:

- Ansible installed on your control machine
- SSH access to all target hosts with the `core` user
- A network with hosts configured according to the inventory file
- Fedora CoreOS or compatible Linux distribution on all nodes
- Sufficient permissions to install systemd services and binaries

## Architecture

The infrastructure consists of:

- **3 server nodes** (10.1.0.3-5): Run Consul servers, Nomad servers, and Vault servers
- **6 client nodes** (10.1.0.6-11): Run Nomad clients for workload execution

### Service Layout

```
┌─────────────────────────────────────────────────────────────┐
│                      Server Nodes (3)                       │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐               │
│  │ Consul   │    │  Nomad   │    │  Vault   │               │
│  │ Server   │    │ Server   │    │ Server   │               │
│  └──────────┘    └──────────┘    └──────────┘               │
│                                                             │
│  Vault uses Consul as storage backend for HA                │
└─────────────────────────────────────────────────────────────┘
                            │
                            ├──────────────────┐
                            ▼                  ▼
┌─────────────────────────────────┐  ┌─────────────────────────────────┐
│     Client Nodes (6)            │  │   Observability                 │
│  ┌──────────┐  ┌──────────┐     │  │  ┌──────────┐                   │
│  │  Nomad   │  │ Consul   │     │  │  │  Alloy   │                   │
│  │ Client   │  │ Client   │     │  │  │  Agent   │                   │
│  └──────────┘  └──────────┘     │  │  └──────────┘                   │
│                                 │  │                                 │
│  Run containerized workloads    │  │  Metrics & Logs collection      │
└─────────────────────────────────┘  └─────────────────────────────────┘
```

## Deployment Process

Deploy services in the following order to satisfy dependencies:

1. **Consul**: Deploy service discovery and key-value store
2. **Nomad**: Deploy workload orchestration platform
3. **Vault**: Deploy secret management (uses Consul as storage backend)
4. **Alloy**: Deploy observability agent for metrics and logs

### Deploy Consul

Deploy the Consul cluster for service discovery:

```sh
ansible-playbook -i inventory consul.yaml
```

Consul servers form a cluster and provide service discovery and configuration to all nodes.

### Deploy Nomad

Deploy the Nomad cluster for workload orchestration:

```sh
ansible-playbook -i inventory nomad.yaml
```

Nomad servers manage job scheduling across client nodes.

### Deploy Vault

Deploy the Vault cluster for secret management:

```sh
ansible-playbook -i inventory vault.yaml
```

After deployment, unseal Vault using the unseal playbook:

```sh
ansible-playbook -i inventory unseal-vault.yaml
```

Configure Vault admin user with appropriate policies:

```sh
ansible-playbook -i inventory vault-admin-user.yaml
```

### Deploy Alloy

Deploy Grafana Alloy for observability data collection:

```sh
ansible-playbook -i inventory alloy.yaml
```

Alloy collects metrics and logs from all nodes and forwards them to your observability backend.

## Configuration

### Inventory

The inventory file defines all cluster nodes. Modify the `inventory` file to match your infrastructure:

```ini
nomad-server-1 ansible_host='10.1.0.3'  ansible_user='core'
nomad-server-2 ansible_host='10.1.0.4'  ansible_user='core'
nomad-server-3 ansible_host='10.1.0.5'  ansible_user='core'
```

Update the IP addresses and hostnames for your environment.

### Service Configuration Files

Configuration files are stored in the `/files` directory:

- **Nomad**: `client.hcl` - Client configuration
- **Vault**: `vault.hcl` - Vault server configuration
- **Alloy**: `config.alloy` - Observability pipeline configuration
- **Systemd Units**: Service definitions for all components

### Installation Paths

Services are installed to standard paths:

- **Binaries**: `/opt/bin/`
- **Configurations**: `/etc/nomad.d/`, `/etc/vault.d/`, `/etc/consul.d/`
- **Systemd Units**: `/etc/systemd/system/`

## Additional Playbooks

### Update Systemd Services

Reload and restart systemd services after configuration changes:

```sh
ansible-playbook -i inventory update-systemd.yaml
```

### Configure Timezone

Set the system timezone across all nodes:

```sh
ansible-playbook -i inventory timezone.yml
```

## Verification

After deployment, verify each service is running:

Check Consul cluster status:

```sh
consul members
```

The output shows all Consul server and client nodes.

Check Nomad server status:

```sh
nomad server members
```

Check Nomad client status:

```sh
nomad node status
```

Check Vault status:

```sh
vault status
```

## Architecture Notes

- **High Availability**: Consul and Vault run in HA mode across 3 server nodes
- **Storage Backend**: Vault uses Consul as its storage backend for automatic HA
- **Service Discovery**: Consul provides service discovery for all components
- **Workload Management**: Nomad schedules and runs containerized workloads
- **Observability**: Alloy collects metrics and logs from all services

## Next Steps

After deploying the infrastructure:

- Deploy workloads using Nomad job specifications
- Configure Vault policies and secrets engines
- Deploy Mimir, Loki, and Tempo via Nomad for observability storage
- Configure Alloy to forward data to your observability backends
- Set up monitoring and alerting for the infrastructure

## Related Resources

- [Consul Documentation](https://www.consul.io/docs)
- [Nomad Documentation](https://www.nomadproject.io/docs)
- [Vault Documentation](https://www.vaultproject.io/docs)
- [Grafana Alloy Documentation](https://grafana.com/docs/alloy)

## License

Licensed under the MIT License. Refer to the [LICENSE](LICENSE) file for details.
