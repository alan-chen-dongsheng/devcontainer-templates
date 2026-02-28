# Dev Container Templates

A collection of reusable [Dev Container](https://containers.dev/) templates for quick project setup.

## Usage

### With VS Code

1. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open the Command Palette (`F1`) → **Dev Containers: Add Dev Container Configuration Files...**
3. Select **Show All Definitions** and search for templates from this repository

### With the devcontainer CLI

```bash
devcontainer templates apply -t ghcr.io/sexjun/devcontainer-templates/python
```

## Available Templates

| Template | Description |
|----------|-------------|
| [python](src/python) | Python 3 development environment |
| [ai_compiler_env](src/ai_compiler_env) | LLVM/Clang + ccache + zsh + Python (uv) + Node.js + Rust |

## Contributing

### Adding a New Template

1. Create a new folder under `src/` with the template name (e.g., `src/my-template/`)
2. Add a `.devcontainer/devcontainer.json` inside it
3. Add a `devcontainer-template.json` with template metadata
4. Add a `README.md` describing the template
5. Add a test folder under `test/` with a `test.sh` script

See the [Dev Container Templates specification](https://containers.dev/implementors/templates/) for full details.

## Publishing

Templates are automatically published to the GitHub Container Registry (`ghcr.io`) when changes are pushed to `main`, using the [devcontainers/action](https://github.com/devcontainers/action).
