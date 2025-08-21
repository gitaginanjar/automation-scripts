#!/bin/bash

# =============================
# Import Vault KVv2 secrets via Vault HTTP API
# Handles multiline, JSON, certificates, etc.
# =============================

INPUT_FILE="$1"

if [[ -z "$INPUT_FILE" ]]; then
  echo "Usage: $0 <vault_export_file.json>"
  exit 1
fi

# Vault config
VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"  # or your real Vault address
VAULT_TOKEN="${VAULT_TOKEN:-$(cat ~/.vault-token)}"

if [[ -z "$VAULT_TOKEN" ]]; then
  echo "âŒ VAULT_TOKEN not set or ~/.vault-token missing"
  exit 1
fi

# Function to write secret using Vault API
Function_PutSecret() {
  local full_path="$1"
  local data_json="$2"

  # Split 'secret/path' into mount and path
  local mount_path
  mount_path=$(echo "$full_path" | cut -d'/' -f1)
  local sub_path
  sub_path=$(echo "$full_path" | cut -d'/' -f2-)

  # Build URL for KV v2 API
  local api_url="${VAULT_ADDR}/v1/${mount_path}/data/${sub_path}"

  # Payload format for KV v2
  local payload
  payload=$(jq -n --argjson data "$data_json" '{ data: $data }')

  # Execute API call
  curl -sS -X POST "$api_url" \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$payload" \
    -w "\nâœ… Imported: $full_path\n"
}

# Read and import each secret
jq -c '.[]' "$INPUT_FILE" | while read -r item; do
  path=$(echo "$item" | jq -r 'keys[0]')
  data=$(echo "$item" | jq -c '.[keys[0]]')
  echo "Importing: $path"
  Function_PutSecret "$path" "$data"
done
