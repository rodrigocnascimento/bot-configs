# TDD: Fix generate-installer.sh Issues

## Objective & Scope

- **What:** Fix bugs and improve code quality in `generate-installer.sh` (and the generated `dist/install-opencode.sh`)
- **Why:** The generated installer has a duplicated line (`TARGET_DIR` assigned twice), redundant/unnecessary guard clauses, a duplicate condition check, inconsistent variable usage (`INSTALL_DIR` vs `TARGET_DIR`), and an indentation inconsistency
- **File Target:** `specs/tdd-fix-generate-installer.md`

## Proposed Technical Strategy

- Fix the duplicated `TARGET_DIR="${INSTALL_DIR}"` on line 122
- Remove unnecessary `|| true` guards from shell assignments that cannot fail
- Remove redundant `TARGET_BASE` default assignment
- Deduplicate identical condition branches in the `.opencode` vs `opencode` path detection
- Consolidate `INSTALL_DIR` and `TARGET_DIR` into a single variable (`INSTALL_DIR`), eliminating confusion
- Fix the silent error suppression in `create_opencode_json`
- Normalize indentation of the comment before `mkdir -p "$INSTALL_DIR"`

### Impacted Files

- `generate-installer.sh` (template + generator)
- `dist/install-opencode.sh` (regenerated after fix)

### Language-Specific Guardrails

- **Shell:** Use `set -euo pipefail` (already in place). Avoid silent error suppression. Ensure backward compatibility — legacy `TARGET_DIR` kept as alias.

## Implementation Plan

1. **Line 122** — Remove duplicate `TARGET_DIR="${INSTALL_DIR}"`
2. **Lines 104-105** — Replace with single robust assignment: `TARGET_BASE="${PWD:-.}"`
3. **Line 109** — Remove `|| true`
4. **Line 114** — Remove redundant branch, keeping only `"$TARGET_BASE" == "$HOME_DIR/.config"`
5. **Lines 117-122** — Eliminate `TARGET_DIR` alias; use `INSTALL_DIR` everywhere; add legacy alias only if needed for external consumers (but none exist)
6. **Line 383** — Remove `|| true` or add proper error handling
7. **Line 569** — Fix indentation to match rest of file (4 spaces)
8. Regenerate installer: run `./generate-installer.sh`
9. Verify no regression: run `shellcheck` on both files

## Path Resolution

- Fixes apply directly to `generate-installer.sh` at repo root
- Generated output lands in `dist/install-opencode.sh` (same as current)

## Naming Standards

- Same as existing: kebab-case for files, UPPER_SNAKE for shell constants
