#!/usr/bin/env bash
# validate.sh — Static validation for all devcontainer templates.
# Run automatically after every change, or manually: bash validate.sh [template-id]
#
# Checks:
#   1. hadolint  — Dockerfile best-practices
#   2. bash -n   — shell script syntax
#   3. python -m json.tool — devcontainer.json / devcontainer-template.json syntax
#
# Exit code: 0 = all pass, 1 = any failure

set -euo pipefail

# ── Colour helpers ────────────────────────────────────────────────────────────
GRN="\e[32m" RED="\e[31m" YLW="\e[33m" BLD="\e[1m" DIM="\e[2m" RST="\e[0m"
PASS="${GRN}${BLD}✓${RST}" FAIL="${RED}${BLD}✗${RST}" WARN="${YLW}${BLD}!${RST}"
SEP="${DIM}$(printf '─%.0s' {1..60})${RST}"

PASS_COUNT=0; FAIL_COUNT=0
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

section() { echo ""; echo -e "${BLD}${1}${RST}"; echo -e "$SEP"; }

ok()   { echo -e "  ${PASS}  ${DIM}${1}${RST}"; PASS_COUNT=$(( PASS_COUNT + 1 )); }
fail() { echo -e "  ${FAIL}  ${RED}${1}${RST}"; FAIL_COUNT=$(( FAIL_COUNT + 1 )); }
warn() { echo -e "  ${WARN}  ${YLW}${1}${RST}"; }

# ── Scope: all templates or just one ─────────────────────────────────────────
FILTER="${1:-}"
if [[ -n "$FILTER" ]]; then
    TEMPLATES=("$REPO_ROOT/src/$FILTER")
else
    TEMPLATES=("$REPO_ROOT"/src/*)
fi

# ── Tool availability ─────────────────────────────────────────────────────────
section "Tool availability"
HADOLINT_OK=false
PYTHON_OK=false

if command -v hadolint &>/dev/null; then
    ok "hadolint $(hadolint --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
    HADOLINT_OK=true
else
    warn "hadolint not found — install with: brew install hadolint"
fi

if command -v python3 &>/dev/null; then
    ok "python3 (JSON validation)"
    PYTHON_OK=true
else
    warn "python3 not found — JSON validation skipped"
fi

if command -v bash &>/dev/null; then
    ok "bash $(bash --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1) (shell syntax check)"
fi

# ── Per-template validation ───────────────────────────────────────────────────
for TMPL_DIR in "${TEMPLATES[@]}"; do
    [[ -d "$TMPL_DIR" ]] || continue
    TMPL_ID=$(basename "$TMPL_DIR")
    DEVCONTAINER_DIR="$TMPL_DIR/.devcontainer"

    section "Template: ${BLD}${TMPL_ID}${RST}"

    # ── 1. Dockerfile (hadolint) ──────────────────────────────────────────────
    DOCKERFILE="$DEVCONTAINER_DIR/Dockerfile"
    if [[ -f "$DOCKERFILE" ]]; then
        if $HADOLINT_OK; then
            # Capture output; don't let non-zero exit kill the script (set -e).
            OUTPUT=$(hadolint \
                --ignore DL3008 \
                --ignore DL3009 \
                --ignore SC2086 \
                "$DOCKERFILE" 2>&1) || true
            if [[ -z "$OUTPUT" ]]; then
                ok "Dockerfile — hadolint clean"
            else
                fail "Dockerfile — hadolint issues:"
                echo "$OUTPUT" | sed 's/^/       /'
            fi
        else
            warn "Dockerfile — hadolint skipped (not installed)"
        fi
    else
        warn "No Dockerfile found in $DEVCONTAINER_DIR"
    fi

    # ── 2. Shell scripts (bash -n) ────────────────────────────────────────────
    while IFS= read -r -d '' SH_FILE; do
        REL="${SH_FILE#"$REPO_ROOT/"}"
        OUTPUT=$(bash -n "$SH_FILE" 2>&1)
        if [[ -z "$OUTPUT" ]]; then
            ok "${REL} — syntax OK"
        else
            fail "${REL} — syntax error:"
            echo "$OUTPUT" | sed 's/^/       /'
        fi
    done < <(find "$TMPL_DIR" -name "*.sh" -print0)

    # ── 3. JSON files ─────────────────────────────────────────────────────────
    while IFS= read -r -d '' JSON_FILE; do
        REL="${JSON_FILE#"$REPO_ROOT/"}"
        if $PYTHON_OK; then
            # Strip // comments before parsing (devcontainer.json allows them)
            OUTPUT=$(python3 -c "
import sys, re, json
raw = open('$JSON_FILE').read()
# Strip // comments but NOT :// in URLs (negative lookbehind)
stripped = re.sub(r'(?<![:/])//[^\n]*', '', raw)
try:
    json.loads(stripped)
    print('ok')
except json.JSONDecodeError as e:
    print(f'ERROR: {e}', file=sys.stderr)
    sys.exit(1)
" 2>&1) || true
            if [[ "$OUTPUT" == "ok" ]]; then
                ok "${REL} — JSON valid"
            else
                fail "${REL} — JSON invalid:"
                echo "$OUTPUT" | sed 's/^/       /'
            fi
        else
            warn "${REL} — JSON check skipped"
        fi
    done < <(find "$TMPL_DIR" -name "*.json" -print0)
done

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BLD}╔══════════════════════════════════════════════════════════╗${RST}"
if (( FAIL_COUNT == 0 )); then
    echo -e "${BLD}║  ${GRN}All checks passed${RST} ${DIM}(${PASS_COUNT} passed, ${FAIL_COUNT} failed)${RST}${BLD}                   ║${RST}"
else
    echo -e "${BLD}║  ${RED}${FAIL_COUNT} check(s) failed${RST} ${DIM}(${PASS_COUNT} passed, ${FAIL_COUNT} failed)${RST}${BLD}                 ║${RST}"
fi
echo -e "${BLD}╚══════════════════════════════════════════════════════════╝${RST}"
echo ""

(( FAIL_COUNT == 0 ))
