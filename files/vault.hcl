cluster_name = "vault-morsegasse"
max_lease_ttl = "10h"
default_lease_ttl = "10h"

ui = true

# Auto-unseal disabled for now - using default Shamir sealing

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  cluster_address = "{{ GetPrivateInterfaces | include \"network\" \"10.0.0.0/24\" | attr \"address\" }}:8201"
  tls_disable   = 1
}

cluster_addr = "http://{{ GetPrivateInterfaces | include \"network\" \"10.0.0.0/24\" | attr \"address\" }}:8201"
api_addr = "http://{{ GetPrivateInterfaces | include \"network\" \"10.0.0.0/24\" | attr \"address\" }}:8200"

log_level = "INFO"
log_format = "standard"

# Telemetry for observability
telemetry {
  prometheus_retention_time = "30s"
  disable_hostname = true
}

# Audit logging to journald
audit {
  syslog {
    tag = "vault-audit"
    facility = "LOCAL0"
  }
}