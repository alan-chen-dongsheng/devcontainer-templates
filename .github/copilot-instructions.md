# GitHub Copilot Instructions — devcontainer-templates

## Repository purpose
This repo contains reusable [Dev Container](https://containers.dev/) templates published to
`ghcr.io/sexjun/devcontainer-templates`. Each template lives under `src/<template-id>/`.

---

## Mandatory validation after every change

**After making ANY change to files inside `src/`**, you MUST run the validation script and fix
all reported errors before finishing:

```bash
bash validate.sh [template-id]
# e.g. bash validate.sh ai_compiler_env
```

The script checks:
1. **Dockerfile** — `hadolint` (best-practices, common mistakes)
2. **Shell scripts** — `bash -n` syntax check
3. **JSON files** — comment-stripped JSON parse (`devcontainer.json`, `devcontainer-template.json`)

If any check fails, **fix the issue and re-run** until all checks pass before committing.

### Hadolint ignored rules (intentional)
| Rule | Reason |
|------|--------|
| DL3008 | Pin apt versions — too strict for dev templates |
| DL3009 | `apt-get clean` — base image handles this |
| SC2086 | Unquoted variables — intentional in some shell loops |

---

## Template structure

Every template must follow this layout:

```
src/<id>/
├── .devcontainer/
│   ├── Dockerfile           # required if not using a plain image
│   ├── devcontainer.json    # required
│   ├── post-create.sh       # first-run setup
│   ├── check-env.sh         # health check, hooked to postStartCommand
│   └── .clangd              # (C++ templates only)
├── devcontainer-template.json  # required — id, version, options
└── README.md                   # required
test/<id>/
└── test.sh                     # required smoke test
```

---

## Dockerfile rules

- Base image: `mcr.microsoft.com/devcontainers/cpp:2-ubuntu24.04` (for `ai_compiler_env`)
- Always use `--no-install-recommends` with `apt-get install`
- Always clean apt cache: `&& rm -rf /var/lib/apt/lists/*`
- Root-level system setup first, then `USER vscode` for user-level installs
- Return to `USER root` at end of Dockerfile
- Use `ARG` for configurable versions (LLVM_VERSION, NODE_VERSION) matching `devcontainer-template.json` options

---

## devcontainer.json rules

- Always restore `${templateOption:<name>}` placeholders in build args after testing
  (testing substitutes real values; the template file must always have placeholders)
- `postCreateCommand` → `bash .devcontainer/post-create.sh`
- `postStartCommand` → `bash .devcontainer/check-env.sh`
- `remoteUser` → `"vscode"`
- Disable `C_Cpp.intelliSenseEngine` when clangd is the C++ LSP

---

## When adding a new template

1. Create `src/<id>/` following the structure above
2. Add the template ID to `.github/workflows/test-pr.yaml` filters
3. Add a row to the `README.md` template table
4. Run `bash validate.sh <id>` — fix any issues
5. Commit with a descriptive message

## When removing a template

1. Delete `src/<id>/` and `test/<id>/`
2. Remove the ID from `.github/workflows/test-pr.yaml` filters
3. Remove the row from `README.md`

---

## Commit message format

```
<short summary>

- Bullet describing change 1
- Bullet describing change 2

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```
