# Dev Container Templates

A collection of reusable [Dev Container](https://containers.dev/) templates for quick project setup.
Published to `ghcr.io/alan-chen-dongsheng/devcontainer-templates`.

## Available Templates

| Template | Description |
|----------|-------------|
| [ai_compiler_env](src/ai_compiler_env) | LLVM/Clang + ccache + zsh + Python (uv) + Node.js + Rust + full LSP |

---

## Usage

### 方式一：直接复制（最快，无需任何工具）

把 `.devcontainer/` 文件夹直接复制到你的项目里：

```bash
cp -r /path/to/devcontainer-templates/src/ai_compiler_env/.devcontainer /your/project/
```

然后在 VS Code 里：`Cmd+Shift+P` → **"Dev Containers: Reopen in Container"**

---

### 方式二：通过 devcontainer CLI（需要安装 npm 包）

**1. 安装 CLI 工具**

```bash
npm install -g @devcontainers/cli
```

**2. 应用模板**

```bash
cd /your/project

devcontainer templates apply \
  -t ghcr.io/alan-chen-dongsheng/devcontainer-templates/ai_compiler_env \
  -a llvmVersion=20 \
  -a nodeVersion=22
```

CLI 会自动在当前目录生成 `.devcontainer/` 配置文件。

**3. 用 VS Code 打开容器**

```bash
code .
# Cmd+Shift+P → "Dev Containers: Reopen in Container"
```

---

### 方式三：通过 VS Code 界面

1. 安装 [Dev Containers 扩展](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. 打开你的项目，`Cmd+Shift+P` → **"Dev Containers: Add Dev Container Configuration Files"**
3. 选择 **"Show All Definitions"**，搜索框输入：
   ```
   ghcr.io/alan-chen-dongsheng/devcontainer-templates/ai_compiler_env
   ```
4. 选择版本选项 → VS Code 自动生成 `.devcontainer/`
5. `Cmd+Shift+P` → **"Dev Containers: Reopen in Container"**

> **注意**：方式三需要模板已收录到官方索引，或手动输入完整 ghcr.io 地址。

---

## 将模板加入 containers.dev 官方索引

提交 PR 到 [devcontainers/devcontainers.github.io](https://github.com/devcontainers/devcontainers.github.io)，在 `_data/collection-index.yml` 末尾添加：

```yaml
- name: AI Compiler Environment Templates
  maintainer: alan-chen-dongsheng
  contact: https://github.com/alan-chen-dongsheng/devcontainer-templates/issues
  repository: https://github.com/alan-chen-dongsheng/devcontainer-templates
  ociReference: ghcr.io/alan-chen-dongsheng/devcontainer-templates
```

PR 合并后，模板将出现在 [containers.dev/templates](https://containers.dev/templates)，全球开发者可以直接搜索使用。

---

## Publishing

Templates are automatically published to `ghcr.io` on every push to `main` via [devcontainers/action](https://github.com/devcontainers/action).

To publish a new version, bump the `version` field in `devcontainer-template.json`.

## Contributing

### Adding a New Template

1. Create a new folder under `src/` with the template name (e.g., `src/my-template/`)
2. Add a `.devcontainer/devcontainer.json` inside it
3. Add a `devcontainer-template.json` with template metadata
4. Add a `README.md` describing the template
5. Add a test folder under `test/` with a `test.sh` script

See the [Dev Container Templates specification](https://containers.dev/implementors/templates/) for full details.
