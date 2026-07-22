# Feasibility Study: Converting DRS to a Zero-Dependency Go Binary

This document analyzes the feasibility, pros, cons, and architectural changes required to rewrite DRS from a collection of Bash scripts into a compiled, single-binary command-line application written in **Go (Golang)**.

---

## Executive Summary

* **Feasibility Rating**: **9.5 / 10** (Extremely feasible, standard CLI migration path).
* **Target Architecture**: A single static binary (`drs` or `git-drs`) written in Go, cross-compiled for Linux, macOS, and Windows.
* **Core Dependency Reductions**:
  * Removes `jq` dependency (uses Go `encoding/json`).
  * Removes `uuidgen` dependency (uses `github.com/google/uuid`).
  * Removes `bash` runtime dependency (works natively on Windows Command Prompt / PowerShell without Git-Bash).
  * Optionally removes local `git` CLI client dependency (via `github.com/go-git/go-git`).

---

## Dependency Mapping & Replacements

Currently, DRS acts as an orchestrator for various CLI tools. Below is how these dependencies translate to Go packages:

| Current CLI Dependency | Go Package Replacement | Impact / Details |
| :--- | :--- | :--- |
| **Bash Shell** | Native Go Runtime | No shell environment required; runs natively on Windows, macOS, Linux. |
| **jq** | `encoding/json` | Native JSON parsing. Extremely fast and eliminates JSON syntax variations. |
| **uuidgen** | `github.com/google/uuid` | Standard UUID generation directly in memory. No platform-specific CLI checks. |
| **rsync** | `github.com/rclone/rclone` (library) or native copy | We can import `rclone` core libraries directly into the Go binary to sync files, avoiding sub-process overhead. |
| **ssh** | `golang.org/x/crypto/ssh` | Native SSH connection client built into the binary. No reliance on the local SSH config or client. |
| **git** | `github.com/go-git/go-git` | Pure Go implementation of Git. Allows reading commit logs and ref tracking without spawning `git` subprocesses. |

---

## Pros & Cons

### Pros

1. **Zero External Dependencies**:
   * Users only need to download a single executable file.
   * Eliminates the client prerequisites check script (`check-client-prerequisites.sh`).
2. **First-Class Windows Support**:
   * Currently, Windows users must install Git-Bash, Scoop, and custom builds of `rsync` (e.g. `rsync-for-git-bash`).
   * A Go binary runs natively on Windows cmd/PowerShell without virtual shell setups.
3. **Higher Performance**:
   * Bash incurs substantial process-spawning overhead (especially on Windows) when calling sub-processes like `git`, `jq`, and `ssh` repeatedly.
   * Go executes operations in-memory (JSON parsing, UUID generation, SSH protocols), resulting in near-instantaneous command response times.
4. **Platform-Agnostic Behaviors**:
   * Solves OS compatibility issues like GNU vs. BSD flags for `stat` and `date`. Go standard library handles file metadata and time zones consistently across operating systems.
5. **Modern Testing Framework**:
   * Replaces manual Docker-based playground testing with standard unit, integration, and mock tests (`go test`).

### Cons

1. **Compilation Overhead**:
   * Changes cannot be tested instantly by editing the script on-the-fly; the binary must be compiled. (Can be automated with hot-reload tools like `air` during development).
2. **Increased Codebase Footprint**:
   * Rewriting from Bash to Go will increase code line count from ~500 lines of shell scripts to ~1,500 lines of Go code due to Go's explicit error handling and structure definitions.
3. **Loss of Simple "Hacking" Accessibility**:
   * Shell scripts are readable and editable by almost any sysadmin. Go requires acquaintance with compiled programming languages.

---

## Architectural Design for the Go Binary

### 1. Unified CLI Command Structure
Instead of relying on Git aliases (`git drs-put`), the application can be run directly:
```bash
drs put [-v] [--sequence <num>] [src_dir]
drs get [--latest] [target_dir]
drs usage [-v]
```
*(Git integration can still be preserved by letting the installer optionally write simple Git aliases pointing to the `drs` binary).*

### 2. Configuration Abstraction
The backend transport layer is abstracted behind a clean interface:
```go
type StorageBackend interface {
    Put(srcDir, uuid string) error
    Get(uuid, destDir string) error
    Exists(uuid string) (bool, error)
    Size() (int64, error)
    List() ([]Revision, error)
}
```
This design makes it extremely simple to add support for multiple storage providers (e.g. `SSHBackend`, `RcloneBackend`, or direct `S3Backend` using AWS SDK) without changing the core business logic.

---

## Migration Plan & Effort Estimation

1. **Phase 1: Structs & Configuration (2 days)**:
   * Setup Go module structure.
   * Implement `drs.json` configuration parser and struct mapping.
2. **Phase 2: Transport & SSH client (3 days)**:
   * Build SSH client abstraction using `golang.org/x/crypto/ssh`.
   * Implement file transfer protocols (SFTP or native rsync libraries).
3. **Phase 3: Git Integration (4 days)**:
   * Write parser using `go-git` to walk ref branches/remotes, parse JSON commit messages, and filter UUID structures.
4. **Phase 4: CLI Interface (2 days)**:
   * Implement CLI flag parsing (using standard `flag` library or popular frameworks like `spf13/cobra`).
5. **Phase 5: Testing & CI/CD (3 days)**:
   * Write unit tests for local folder operations and mock SSH servers.
   * Configure GitHub Actions workflow to cross-compile and publish release assets for `darwin`, `linux`, and `windows`.

**Total Estimate**: 2-3 weeks of active development for a production-ready rewrite.
