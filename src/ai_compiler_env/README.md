# AI Compiler Environment

## Summary

*Full-featured compiler / AI development environment with LLVM/Clang, Python, Node.js, and Rust.*

| Metadata | Value |
|----------|-------|
| *Base image* | `mcr.microsoft.com/devcontainers/cpp:2-ubuntu24.04` |
| *Categories* | C++, Python, Rust, Node.js, Compilers |
| *Shell* | zsh + oh-my-zsh |

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `llvmVersion` | LLVM/Clang version | `20` |
| `nodeVersion` | Node.js major version | `22` |

## What's included

### LLVM / Clang toolchain
- `clang` / `clang++` — C/C++ compiler
- `clangd` — Language server (LSP)
- `clang-format` / `clang-tidy` / `clang-query` — Code quality tools
- `lldb` — Debugger
- `lld` — Fast linker
- `llvm-ar`, `llvm-cov`, `llvm-profdata`, `llvm-symbolizer`, and more

### Build acceleration
- **ccache** with **unlimited cache size** (`max_size = 0`)
- `CC` and `CXX` are pre-set to `clang` / `clang++` and transparently intercepted by ccache

### Shell
- **zsh** (default shell) + **oh-my-zsh**
- Plugins enabled:
  - `git` — Git aliases and prompt info
  - `zsh-syntax-highlighting` — Real-time command syntax highlighting
  - `zsh-autosuggestions` — Fish-like history-based suggestions
  - `extract` — Universal archive extraction with `x <file>`

### Language runtimes & tooling
| Tool | Details |
|------|---------|
| **Python** | via `uv` — installs to `~/.local/bin` |
| **Node.js** | LTS via NodeSource (configurable version) |
| **Rust** | via `rustup` — stable toolchain |

## Usage

### Python
```bash
# Install a Python version
uv python install 3.13

# Create a virtual environment
uv venv && source .venv/bin/activate

# Add packages
uv add numpy torch
```

### ccache
```bash
# Show cache stats
ccache -s

# The cache is already configured with unlimited size.
# To set a limit: ccache --set-config=max_size=50G
```

### Rust
```bash
# rustup and cargo are available after opening a new shell
cargo new my-project
```
