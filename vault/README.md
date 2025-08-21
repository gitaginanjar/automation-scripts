
---

# Vault Secret Exporter & Importer (KV v2)

This repository provides two BASH scripts to **export** and **import** all secrets stored in [HashiCorp Vault](https://www.vaultproject.io/) using the **KV v2 secrets engine**.

These scripts are helpful for:

- Backing up secrets
- Migrating secrets between Vault environments
- Auditing secrets

---

## Requirements

- `vault` CLI installed and authenticated
- `jq` installed (`yum install jq` or `apt install jq`)
- `curl` for the importer
- Access to Vault using a token with read/write permissions

---

## `vault-exporter.sh` Export All Secrets Recursively

### Description

Recursively lists all secrets under a base Vault path (e.g., `kubernetes`), then fetches and exports their key-values into a valid **JSON array** file.

This script:
- Works with KV v2 backends
- Skips non-secret folders
- Outputs valid JSON that can be imported later

### Usage

```bash
./vault-exporter.sh <vault-base-path> [output-file.json]
```

- `vault-base-path` required. Top-level path under your KV mount (e.g., `kubernetes`, `secret`, etc.)
- `output-file.json` optional. Default is `vault_export_<YYYY-MM-DD>.json`

### Example

```bash
./vault-exporter.sh kubernetes
```

Creates a file like `vault_export_2025-07-24.json` with contents like:

```json
[
  {
    "kubernetes/corp/crmecmiservice/corp-crmecmiservice-qa": {
      "username": "notadmin",
      "password": "9qf98qwhf98q23hfq98wej"
    }
  },
  {
    "kubernetes/devtools/app": {
      "api_key": "abc123",
      "env": "qa"
    }
  }
]
```

---

## `vault-importer.sh` Import Secrets from Exported JSON

### Description

Reads a previously exported JSON file (from `vault-exporter.sh`) and re-creates the same secret paths and values in another Vault instance using **Vault HTTP API** (compatible with KV v2).

Supports:
- JSON data
- Multiline values
- Certificates and binary-safe strings

### Usage

```bash
./vault-importer.sh <vault_export_file.json>
```

- `vault_export_file.json` required. JSON file from the exporter.

### Vault Authentication

Make sure `VAULT_TOKEN` is available in the environment or stored in `~/.vault-token`.

You may also set a custom Vault address:

```bash
export VAULT_ADDR=http://your-vault-server:8200
export VAULT_TOKEN=your-token
./vault-importer.sh vault_export_2025-07-24.json
```

### Example

```bash
VAULT_ADDR=http://10.0.0.1:8200 VAULT_TOKEN=root \
  ./vault-importer.sh vault_export_2025-07-24.json
```

Each secret will be created using the KV v2 API (`POST /v1/<mount>/data/<path>`).

---

## Files Included

| File                 | Description                                      |
|----------------------|--------------------------------------------------|
| `vault-exporter.sh`  | Export secrets from Vault into JSON              |
| `vault-importer.sh`  | Import JSON secrets back into Vault              |
| `vault-exporter.README.md` | Inline documentation for the exporter script |
| `vault-importer.README.md` | Inline documentation for the importer script |

---

## Notes

- These scripts are intended for KV **version 2** (check using `vault secrets list -detailed`)
- They do **not** preserve metadata like creation time, version history, or custom metadata
- Ensure your Vault policies allow read/write on paths you're operating on
- Tested on Vault 1.14.x with KV v2 engine.

---

## Example Workflow

```bash
# 1. Export secrets from Vault A
./vault-exporter.sh kubernetes backup.json

# 2. Copy JSON file to another host or environment

# 3. Import into Vault B
VAULT_ADDR=http://vault-b:8200 VAULT_TOKEN=... ./vault-importer.sh backup.json
```

---

## License

[MIT][link-license]

## Author Information

This role was created in 2025 by [G. Ginanjar](https://github.com/gitaginanjar)

---

[link-license]: https://raw.githubusercontent.com/gitaginanjar/automation-scripts/master/LICENSE
