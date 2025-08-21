#!/bin/bash

# ==========================
# Script to export all Vault KV v2 secrets under a base path
# Recursively lists all subpaths using `vault kv list`, 
# then fetches each secret using `vault kv get -format=json`.
# Output is saved in a valid JSON array.
# ==========================

# Base path (e.g., "kubernetes")
ROOT_PATH="$1"

# Output file name (optional), default: vault_export_<YYYY-MM-DD>.json
OUTPUT_FILE="${2:-vault_export_$(date +%F).json}"

# Validate input
if [[ -z "$ROOT_PATH" ]]; then
  echo "Usage: $0 <vault-base-path> [output-file.json]"
  exit 1
fi

# Use a temporary file to collect individual JSON objects
# This avoids problems like trailing commas in the final output
TEMP_FILE=$(mktemp)

# ======================================
# Function to recursively list secrets and export them
# Arguments:
#   $1 - The Vault KV path to process
# ======================================
Function_ExportSecretsRecursively() {
  local path="$1"

  # List all keys under the given path
  local keys
  keys=$(vault kv list "$path" 2>/dev/null | sed '/^Keys$/d' | sed '/^----$/d' | sed '/^\s*$/d')

  # Iterate through each item returned by 'vault kv list'
  while IFS= read -r key; do
    if [[ "$key" == */ ]]; then
      # If the key ends with '/', it's a folder â€” recurse deeper
      Function_ExportSecretsRecursively "${path}/${key%/}"
    else
      # It's a secret â€” get its full path and export it
      full_secret_path="${path}/${key}"
      echo "Exporting: $full_secret_path"

      # Export the secret using `vault kv get -format=json`
      # Extract only the 'data.data' part using jq, and wrap it as: {"full/path": {...}}
      vault kv get -format=json "$full_secret_path" \
        | jq -c --arg path "$full_secret_path" '{($path): .data.data}' \
        >> "$TEMP_FILE"
    fi
  done <<< "$keys"
}

# Start the recursive export from the root path
Function_ExportSecretsRecursively "$ROOT_PATH"

# Merge all JSON lines (each line is an object) into one array
# Produces a clean, parseable JSON file
jq -s '.' "$TEMP_FILE" > "$OUTPUT_FILE"

# Clean up temporary file
rm "$TEMP_FILE"

# Final message
echo "Export completed. File saved: $OUTPUT_FILE"
