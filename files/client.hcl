client {
  host_volume "nomad-alloc" {
    path      = "/opt/nomad"
    read_only = true
  }
}

options = {
  "docker.privileged.enabled" = "True"
  "docker.volumes.enabled"    = "True"
}

plugin "docker" {
  config {
    extra_labels     = ["job_name", "job_id", "task_group_name", "task_name", "namespace", "node_name", "node_id"]
    allow_privileged = true
    allow_caps       = ["CHOWN", "DAC_OVERRIDE", "FSETID", "FOWNER", "MKNOD", "NET_RAW", "NET_ADM", "NET_ADMIN", "SETGID", "SETUID", "SETFCAP", "SETPCAP", "NET_BIND_SERVICE", "SYS_CHROOT", "KILL", "AUDIT_WRITE"]
  }
}
