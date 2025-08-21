# Automation Scripts Repository

This repository contains a collection of automation scripts and tools for DevOps, infrastructure, Kubernetes, Git operations, database management, GCP tasks, and other general-purpose utilities. It is organised into multiple directories based on use cases.

## Repository Structure

```
gcp/                        # GCP-related automation (VM migration, autostart)
generic/                    # General-purpose helper scripts
git/                        # Git-related automation (backup, clone, docker builds)
go-yaml-extractor/          # Go-based YAML extractor utility
kubernetes/                 # Kubernetes helper scripts and panic button tools
redpanda/                   # Redpanda/Kafka automation scripts
vault/                      # Vault import/export automation
```

## Getting Started

### Requirements

* Linux/Unix environment
* Bash shell
* Python 3 (for Python-based utilities)
* Go (for go-yaml-extractor)
* Required CLIs: `kubectl`, `gcloud`, `git`, `docker`, depending on the scripts being used.

### Usage

Each directory contains its own `README.md` (when applicable) that explains specific usage. Common usage patterns:

```bash
# Run go-yaml-extractor
./go-yaml-extractor/go-yaml-extractor.sh
```

### Examples

* **GCP**: Automate VM migration and startup scripts.
* **Generic**: File permissions, replacements, sleep progress bar.
* **Git**: Backup repositories, clone Bitbucket repos, automate docker build & push.
* **Kubernetes**: Apply manifests, manage pods, secrets, panic-button scripts to delete orders.
* **Redpanda**: Exporter scripts, delete consumer groups, lag monitoring.
* **Vault**: Import/export secrets to HashiCorp Vault.

## Contribution

* Follow existing coding styles.
* Place new scripts in the most relevant subdirectory.
* Add a `README.md` if creating a new module or directory.

## License

Some modules include their own license files. Refer to each subdirectory (e.g., `git/`, `go-yaml-extractor/`) for details.

---

## Author
- [G. Ginanjar](https://github.com/gitaginanjar)
