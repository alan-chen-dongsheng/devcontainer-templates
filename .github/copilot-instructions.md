# GitHub Copilot Instructions — devcontainer-templates

## Repository purpose
This repo contains reusable [Dev Container](https://containers.dev/) templates published to
`ghcr.io/sexjun/devcontainer-templates`. Each template lives under `src/<template-id>/`.

---

## Mandatory checks after every change

### Step 1 — Static validation (always)

After ANY change to files inside `src/`, run and fix all errors before proceeding:

```bash
bash validate.sh <template-id>
# e.g. bash validate.sh ai_compiler_env
```

Checks: hadolint (Dockerfile), bash -n (shell scripts), JSON parse (*.json).

### Step 2 — Docker build (when Dockerfile or devcontainer.json changes)

**Every time you modify `Dockerfile` or `devcontainer.json`, you MUST build the Docker image
and confirm it succeeds before committing.** Do not skip this step.

```bash
docker build \
  --build-arg LLVM_VERSION=20 \
  --build-arg NODE_VERSION=22 \
  -t ai-compiler-env-test \
  src/ai_compiler_env/.devcontainer/
```

- If the build fails, **read the full error output**, fix the root cause, and rebuild.
- Keep rebuilding until `docker build` exits with code 0.
- Only commit after a successful build.

**Do not rely on validate.sh alone** — static checks cannot catch runtime errors such as:
- Missing apt packages required by installer scripts
- Broken download URLs
- Shell commands that fail inside the container
- Wrong file paths or permissions

### Step 3 — Commit

Only after both steps above pass:

```bash
git add . && git commit -m "<message>

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```

---

## Hadolint ignored rules (intentional)
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
- Always install prerequisite tools (e.g. `software-properties-common`, `gnupg`) before
  running third-party installer scripts that depend on them

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
5. Run `docker build` — fix any build failures
6. Commit with a descriptive message

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
