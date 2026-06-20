#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
NAMESPACE="${K8S_NAMESPACE:-ep03}"

to_millicores() {
  local value="$1"
  if [[ "$value" == *m ]]; then
    echo "${value%m}"
  elif [[ "$value" == *n ]]; then
    echo $(( ${value%n} / 1000000 ))
  else
    awk -v value="$value" 'BEGIN { printf "%.0f", value * 1000 }'
  fi
}

to_mebibytes() {
  local value="$1"
  if [[ "$value" == *Mi ]]; then
    echo "${value%Mi}"
  elif [[ "$value" == *Ki ]]; then
    awk -v value="${value%Ki}" 'BEGIN { printf "%.2f", value / 1024 }'
  elif [[ "$value" == *Gi ]]; then
    awk -v value="${value%Gi}" 'BEGIN { printf "%.2f", value * 1024 }'
  else
    echo "$value"
  fi
}

for service in backend frontend database; do
  cpu_total=0
  memory_total=0
  samples=0

  while read -r _ cpu memory; do
    [ -n "${cpu:-}" ] || continue
    cpu_total=$(awk -v a="$cpu_total" -v b="$(to_millicores "$cpu")" 'BEGIN { print a + b }')
    memory_total=$(awk -v a="$memory_total" -v b="$(to_mebibytes "$memory")" 'BEGIN { print a + b }')
    samples=$((samples + 1))
  done < <(kubectl top pods \
    --namespace "$NAMESPACE" \
    --selector "app=ep03-${service}" \
    --no-headers 2>/dev/null || true)

  replicas="$(kubectl get deployment "ep03-${service}" \
    --namespace "$NAMESPACE" \
    -o jsonpath='{.status.availableReplicas}' 2>/dev/null || echo 0)"
  replicas="${replicas:-0}"

  if [ "$samples" -gt 0 ]; then
    aws cloudwatch put-metric-data \
      --namespace "EP03/Kubernetes" \
      --metric-data \
        "MetricName=CPUUsageMillicores,Dimensions=[{Name=Service,Value=$service}],Value=$cpu_total,Unit=Count" \
        "MetricName=MemoryWorkingSetMiB,Dimensions=[{Name=Service,Value=$service}],Value=$memory_total,Unit=Megabytes" \
        "MetricName=AvailableReplicas,Dimensions=[{Name=Service,Value=$service}],Value=$replicas,Unit=Count" \
      --region "$REGION"
    echo "$service: cpu=${cpu_total}m memoria=${memory_total}Mi replicas=$replicas"
  fi
done
