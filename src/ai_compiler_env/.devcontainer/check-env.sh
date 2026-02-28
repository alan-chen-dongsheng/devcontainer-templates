#!/usr/bin/env bash
# check-env.sh — AI Compiler Environment health check
# Runs automatically on container start; also callable manually at any time.
# Usage: bash .devcontainer/check-env.sh [--no-color]
# Output: coloured terminal report + ~/env-check-report.md

set -euo pipefail

# ── PATH: make sure user-level tools are reachable ───────────────────────────
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/lib/node_modules/.bin:$PATH"

# ── Colour helpers ────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--no-color" ]] || [[ ! -t 1 ]]; then
    GRN="" RED="" YLW="" BLD="" DIM="" RST=""
else
    GRN="\e[32m" RED="\e[31m" YLW="\e[33m" BLD="\e[1m" DIM="\e[2m" RST="\e[0m"
fi

PASS="${GRN}${BLD}✓${RST}"
FAIL="${RED}${BLD}✗${RST}"
WARN="${YLW}${BLD}!${RST}"
SEP="${DIM}$(printf '─%.0s' {1..60})${RST}"

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0
REPORT_FILE="$HOME/env-check-report.md"
REPORT=""   # accumulates markdown

# ── Helpers ───────────────────────────────────────────────────────────────────
section() {
    local title="$1"
    echo ""
    echo -e "${BLD}${title}${RST}"
    echo -e "$SEP"
    REPORT+="\n## ${title}\n\n"
}

# check_cmd <label> <command> [version-flag]
check_cmd() {
    local label="$1" cmd="$2" vflag="${3:---version}"
    local ver
    if ver=$(command -v "$cmd" &>/dev/null && "$cmd" $vflag 2>&1 | head -1); then
        ver=$(echo "$ver" | grep -oP '[\d]+\.[\d]+\.?[\d]*' | head -1 || echo "found")
        printf "  %b  %-34s %s\n" "$PASS" "$label" "${DIM}${ver}${RST}"
        REPORT+="| ✅ | \`${label}\` | ${ver} |\n"
        (( PASS_COUNT++ ))
    else
        printf "  %b  %-34s %s\n" "$FAIL" "$label" "${RED}NOT FOUND${RST}"
        REPORT+="| ❌ | \`${label}\` | NOT FOUND |\n"
        (( FAIL_COUNT++ ))
    fi
}

# check_file <label> <path>
check_file() {
    local label="$1" path="$2"
    if [[ -e "$path" ]]; then
        printf "  %b  %-34s %s\n" "$PASS" "$label" "${DIM}${path}${RST}"
        REPORT+="| ✅ | ${label} | \`${path}\` |\n"
        (( PASS_COUNT++ ))
    else
        printf "  %b  %-34s %s\n" "$FAIL" "$label" "${RED}${path} missing${RST}"
        REPORT+="| ❌ | ${label} | \`${path}\` missing |\n"
        (( FAIL_COUNT++ ))
    fi
}

# check_env <var> [expected_substring]
check_env() {
    local var="$1" expected="${2:-}"
    local val="${!var:-}"
    if [[ -z "$val" ]]; then
        printf "  %b  %-34s %s\n" "$FAIL" "\$${var}" "${RED}not set${RST}"
        REPORT+="| ❌ | \`\$${var}\` | not set |\n"
        (( FAIL_COUNT++ ))
    elif [[ -n "$expected" && "$val" != *"$expected"* ]]; then
        printf "  %b  %-34s %s\n" "$WARN" "\$${var}" "${YLW}${val} (expected '${expected}')${RST}"
        REPORT+="| ⚠️  | \`\$${var}\` | \`${val}\` (expected \`${expected}\`) |\n"
        (( WARN_COUNT++ ))
    else
        printf "  %b  %-34s %s\n" "$PASS" "\$${var}" "${DIM}${val}${RST}"
        REPORT+="| ✅ | \`\$${var}\` | \`${val}\` |\n"
        (( PASS_COUNT++ ))
    fi
}

# check_path_contains <label> <substring>
check_path_contains() {
    local label="$1" substr="$2"
    if echo "$PATH" | grep -q "$substr"; then
        printf "  %b  %-34s %s\n" "$PASS" "PATH ∋ ${label}" "${DIM}${substr}${RST}"
        REPORT+="| ✅ | PATH contains \`${label}\` | \`${substr}\` |\n"
        (( PASS_COUNT++ ))
    else
        printf "  %b  %-34s %s\n" "$WARN" "PATH ∋ ${label}" "${YLW}${substr} not in PATH${RST}"
        REPORT+="| ⚠️  | PATH contains \`${label}\` | \`${substr}\` not found |\n"
        (( WARN_COUNT++ ))
    fi
}

# check_ccache_unlimited
check_ccache_unlimited() {
    local val
    val=$(ccache --get-config max_size 2>/dev/null || echo "unknown")
    if [[ "$val" == "0" ]]; then
        printf "  %b  %-34s %s\n" "$PASS" "ccache max_size" "${DIM}unlimited (0)${RST}"
        REPORT+="| ✅ | ccache \`max_size\` | unlimited (0) |\n"
        (( PASS_COUNT++ ))
    else
        printf "  %b  %-34s %s\n" "$WARN" "ccache max_size" "${YLW}${val} (expected 0/unlimited)${RST}"
        REPORT+="| ⚠️  | ccache \`max_size\` | \`${val}\` (expected 0 = unlimited) |\n"
        (( WARN_COUNT++ ))
    fi
}

# check_zsh_plugin <name>
check_zsh_plugin() {
    local plugin="$1"
    if grep -qE "plugins=\(.*\b${plugin}\b" "$HOME/.zshrc" 2>/dev/null; then
        printf "  %b  %-34s %s\n" "$PASS" "zsh plugin: ${plugin}" "${DIM}enabled in .zshrc${RST}"
        REPORT+="| ✅ | zsh plugin: \`${plugin}\` | enabled in .zshrc |\n"
        (( PASS_COUNT++ ))
    else
        printf "  %b  %-34s %s\n" "$FAIL" "zsh plugin: ${plugin}" "${RED}not enabled in .zshrc${RST}"
        REPORT+="| ❌ | zsh plugin: \`${plugin}\` | not enabled in .zshrc |\n"
        (( FAIL_COUNT++ ))
    fi
}

# ── Header ────────────────────────────────────────────────────────────────────
NOW=$(date '+%Y-%m-%d %H:%M:%S')
HOSTNAME=$(hostname)

echo ""
echo -e "${BLD}╔══════════════════════════════════════════════════════════╗${RST}"
echo -e "${BLD}║     AI Compiler Environment — Health Check               ║${RST}"
echo -e "${BLD}╚══════════════════════════════════════════════════════════╝${RST}"
echo -e "  ${DIM}Host: ${HOSTNAME}   Time: ${NOW}${RST}"

REPORT="# AI Compiler Environment — Health Check Report\n\n"
REPORT+="> **Host:** \`${HOSTNAME}\`  \n> **Generated:** ${NOW}\n\n"
REPORT+="---\n"

# ─────────────────────────────────────────────────────────────────────────────
section "① LLVM / Clang Toolchain"
REPORT+="| Status | Tool | Version |\n|--------|------|---------|\n"
check_cmd "clang"              clang
check_cmd "clang++"            clang++
check_cmd "clangd"             clangd
check_cmd "clang-format"       clang-format
check_cmd "clang-tidy"         clang-tidy
check_cmd "lldb"               lldb
check_cmd "lld  (ld.lld)"      ld.lld
check_cmd "llvm-ar"            llvm-ar
check_cmd "llvm-cov"           llvm-cov
check_cmd "llvm-profdata"      llvm-profdata
check_cmd "llvm-symbolizer"    llvm-symbolizer
check_cmd "llvm-objdump"       llvm-objdump

# ─────────────────────────────────────────────────────────────────────────────
section "② Build Tools"
REPORT+="\n| Status | Tool | Details |\n|--------|------|---------|\n"
check_cmd "ccache"  ccache
check_ccache_unlimited
check_cmd "cmake"   cmake
check_cmd "make"    make
check_cmd "ninja"   ninja   "--version"

# ─────────────────────────────────────────────────────────────────────────────
section "③ Shell"
REPORT+="\n| Status | Item | Details |\n|--------|------|---------|\n"
check_cmd "zsh"       zsh
check_file "oh-my-zsh"  "$HOME/.oh-my-zsh"
check_file "plugin: zsh-syntax-highlighting (files)" \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
check_file "plugin: zsh-autosuggestions (files)" \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
check_zsh_plugin "git"
check_zsh_plugin "zsh-syntax-highlighting"
check_zsh_plugin "zsh-autosuggestions"
check_zsh_plugin "extract"

# Confirm zsh is the login shell
CURRENT_SHELL=$(getent passwd "$(whoami)" | cut -d: -f7)
if [[ "$CURRENT_SHELL" == *"zsh"* ]]; then
    printf "  %b  %-34s %s\n" "$PASS" "default shell" "${DIM}${CURRENT_SHELL}${RST}"
    REPORT+="| ✅ | default shell | \`${CURRENT_SHELL}\` |\n"
    (( PASS_COUNT++ ))
else
    printf "  %b  %-34s %s\n" "$WARN" "default shell" "${YLW}${CURRENT_SHELL} (expected zsh)${RST}"
    REPORT+="| ⚠️  | default shell | \`${CURRENT_SHELL}\` (expected zsh) |\n"
    (( WARN_COUNT++ ))
fi

# ─────────────────────────────────────────────────────────────────────────────
section "④ Python"
REPORT+="\n| Status | Tool | Version |\n|--------|------|---------|\n"
check_cmd "uv"          uv
check_cmd "python3"     python3
check_cmd "pip3"        pip3

# Check at least one Python managed by uv
if uv python list 2>/dev/null | grep -q 'cpython'; then
    PY_VER=$(uv python list 2>/dev/null | grep 'cpython' | head -1 | awk '{print $1}')
    printf "  %b  %-34s %s\n" "$PASS" "uv-managed python" "${DIM}${PY_VER}${RST}"
    REPORT+="| ✅ | uv-managed python | ${PY_VER} |\n"
    (( PASS_COUNT++ ))
else
    printf "  %b  %-34s %s\n" "$WARN" "uv-managed python" "${YLW}none installed (run: uv python install 3.13)${RST}"
    REPORT+="| ⚠️  | uv-managed python | none installed |\n"
    (( WARN_COUNT++ ))
fi

# ─────────────────────────────────────────────────────────────────────────────
section "⑤ Node.js"
REPORT+="\n| Status | Tool | Version |\n|--------|------|---------|\n"
check_cmd "node"          node
check_cmd "npm"           npm
check_cmd "typescript (tsc)" tsc
check_cmd "typescript-language-server" typescript-language-server
check_cmd "eslint"        eslint

# ─────────────────────────────────────────────────────────────────────────────
section "⑥ Rust"
REPORT+="\n| Status | Tool | Version |\n|--------|------|---------|\n"
check_cmd "rustup"  rustup
check_cmd "cargo"   cargo
check_cmd "rustc"   rustc

# ─────────────────────────────────────────────────────────────────────────────
section "⑦ LSP Servers"
REPORT+="\n| Status | LSP Server | Language |\n|--------|------------|----------|\n"

check_cmd "clangd (C/C++ LSP)"                    clangd
check_cmd "typescript-language-server (TS/JS LSP)" typescript-language-server "--version"
check_cmd "pyright (Python LSP)"                  pyright
check_cmd "vscode-css-languageserver (CSS LSP)"   vscode-css-languageserver    "--version"
check_cmd "vscode-html-language-server (HTML LSP)" vscode-html-language-server "--version"
check_cmd "vscode-json-languageserver (JSON LSP)" vscode-json-languageserver   "--version"

# ─────────────────────────────────────────────────────────────────────────────
section "⑧ Environment Variables"
REPORT+="\n| Status | Variable | Value |\n|--------|----------|-------|\n"
check_env "CC"                "clang"
check_env "CXX"               "clang++"
check_env "CCACHE_CONFIGPATH" "/etc/ccache.conf"
check_path_contains "~/.local/bin"  "$HOME/.local/bin"
check_path_contains "~/.cargo/bin"  "$HOME/.cargo/bin"

# ─────────────────────────────────────────────────────────────────────────────
section "⑨ Workspace Config Files"
REPORT+="\n| Status | File | Path |\n|--------|------|------|\n"
check_file ".clangd"       ".clangd"
check_file "tsconfig.json" "tsconfig.json"
check_file ".prettierrc"   ".prettierrc"

# ── Footer ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BLD}╔══════════════════════════════════════════════════════════╗${RST}"
if (( FAIL_COUNT == 0 && WARN_COUNT == 0 )); then
    echo -e "${BLD}║  ${GRN}All checks passed${RST}${BLD}                                      ║${RST}"
elif (( FAIL_COUNT == 0 )); then
    echo -e "${BLD}║  ${YLW}${PASS_COUNT} passed  ${WARN_COUNT} warnings  ${FAIL_COUNT} failed${RST}${BLD}                          ║${RST}"
else
    echo -e "${BLD}║  ${RED}${PASS_COUNT} passed  ${WARN_COUNT} warnings  ${FAIL_COUNT} failed${RST}${BLD}                          ║${RST}"
fi
echo -e "${BLD}╚══════════════════════════════════════════════════════════╝${RST}"

# ── Write markdown report ─────────────────────────────────────────────────────
REPORT+="\n---\n\n"
REPORT+="## Summary\n\n"
REPORT+="| | Count |\n|---|---|\n"
REPORT+="| ✅ Passed  | ${PASS_COUNT} |\n"
REPORT+="| ⚠️  Warnings | ${WARN_COUNT} |\n"
REPORT+="| ❌ Failed  | ${FAIL_COUNT} |\n"

printf "%b" "$REPORT" > "$REPORT_FILE"
echo -e "  ${DIM}Report saved → ${REPORT_FILE}${RST}"
echo ""

# Exit non-zero only on hard failures (not warnings)
(( FAIL_COUNT == 0 ))
