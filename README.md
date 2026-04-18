# Diodonfrost Gentoo Overlay

An experimental Gentoo package overlay providing ebuilds for DevOps, infrastructure, and desktop tools not available in the main Gentoo repository.

## Quick Start

```bash
emerge --ask app-eselect/eselect-repository
eselect repository add diodonfrost git https://github.com/diodonfrost/gentoo-overlay.git
emerge --sync diodonfrost
```

## Available Packages

| Category | Package | Description |
|----------|---------|-------------|
| app-accessibility | [handy](https://handy.computer) | Offline speech-to-text desktop application |
| app-admin | [helm](https://helm.sh) | Kubernetes package manager |
| app-admin | [kubectl](https://kubernetes.io) | Kubernetes command-line tool |
| app-admin | [packer](https://www.packer.io) | Automated machine image builder |
| app-admin | [pulumi](https://www.pulumi.com) | Infrastructure as Code SDK |
| app-admin | [terraform](https://www.terraform.io) | Infrastructure as Code tool |
| app-admin | [terragrunt](https://terragrunt.gruntwork.io) | Thin wrapper for Terraform |
| app-admin | [vagrant](https://www.vagrantup.com) | Development environment manager |
| app-crypt | [sops](https://github.com/getsops/sops) | Encrypted file editor for secrets |
| dev-build | [just](https://just.systems) | Command runner (alternative to Make) |
| dev-node | [bun-bin](https://bun.sh) | JavaScript runtime and toolkit (pre-built binary) |
| dev-util | [github-cli](https://cli.github.com) | GitHub CLI |
| dev-util | [glab](https://gitlab.com/gitlab-org/cli) | GitLab CLI |
| dev-util | [inspec](https://www.inspec.io) | Infrastructure compliance testing |
| net-im | [discord-bin](https://discord.com) | Discord chat client (pre-built binary) |
| www-client | [servo](https://servo.org) | Independent web rendering engine |

## Testing Builds

Ebuilds are tested inside a Gentoo stage3 Docker container, so you don't need a Gentoo host to contribute. The `justfile` wraps the Docker commands.

### Prerequisites

- [Docker](https://docs.docker.com/engine/install/)
- [just](https://just.systems) (available in this overlay as `dev-build/just`)

### Commands

```bash
just build                               # Build the Docker test image (Dockerfile.test)
just test                                # Run pkgcheck QA lint (alias for test-lint)
just test-lint                           # pkgcheck scan --net on the whole overlay
just test-pretend <category/package-ver> # Dry-run emerge — resolves deps without building
just test-build <category/package-ver>   # Full emerge of a single package
just test-shell <category/package-ver>   # Emerge then drop into an interactive shell
just test-shell                          # Shell only, for manual debugging
just clean                               # Remove the Docker test image
```

The package argument is the exact `category/package-version` triple, without the `=` prefix (just adds it). Examples:

```bash
just test-pretend app-admin/helm-4.1.3
just test-build dev-build/just-1.43.0
just test-shell www-client/servo-0.1.0
```
