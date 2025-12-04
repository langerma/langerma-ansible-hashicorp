curl -s $NOMAD_ADDR/v1/operator/scheduler/configuration | \
  jq '.SchedulerConfig | .MemoryOversubscriptionEnabled=true' | \
  curl -X PUT $NOMAD_ADDR/v1/operator/scheduler/configuration -d @-

