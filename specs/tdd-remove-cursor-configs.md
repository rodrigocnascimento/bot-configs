# TDD: Remove Cursor Configurations

## Objective & Scope

- **What:** Retire all Cursor-specific configuration from this repository and update repository-facing documentation and metadata to present OpenCode as the sole supported agent configuration.
- **Why:** The project is pivoting to OpenCode-only configuration. Leaving `.cursor/` assets or Cursor references would make the supported integration ambiguous and could cause users to install or maintain an unsupported setup.
- **File Target:** This document is intended for `specs/tdd-remove-cursor-configs.md`.

## Proposed Technical Strategy

### Logic Flow

1. Inventory the `.cursor/` directory and every repository reference to Cursor.
2. Compare each Cursor rule and skill with its `.opencode/` counterpart to identify rules that are absent or materially incomplete in OpenCode.
3. Migrate each still-applicable Cursor-only rule to `.opencode/`, adapting its location and wording to the existing OpenCode configuration conventions. Do not migrate Cursor-specific MCP settings or Cursor-only operational instructions.
4. Run the OpenCode compiler immediately after every `.opencode/` change, then verify the migrated rules are represented in the compiled `AGENTS.md`.
5. Remove the complete `.cursor/` configuration tree only after the parity audit and migrations succeed.
6. Update root documentation to describe an OpenCode-only repository and remove Cursor from usage, repository layout, and documentation links.
7. Remove Cursor-specific package metadata, if it no longer represents a supported capability.
8. Search the repository again to confirm no active Cursor configuration or documentation references remain, excluding historical Git data.

### Impacted Files

- Create or modify `.opencode/rules/` and `.opencode/skills/` entries only where the parity audit identifies applicable Cursor-only content.
- Regenerate `AGENTS.md` after each `.opencode/` change.
- Delete `.cursor/` and all nested configuration files after migration verification.
- Modify `README.md` to remove Cursor support descriptions, layout entries, and links.
- Modify `package.json` to remove obsolete Cursor metadata.
- Regenerate `AGENTS.md` only if `npm run opencode:compile` changes it.
- Create `specs/tdd-remove-cursor-configs.md`.

No `doc/` directory will be created; documentation remains in the existing `docs/` directory.

### Language-Specific Guardrails

- This repository contains configuration and Markdown rather than application TypeScript; no runtime interfaces, DTOs, or unsafe types will be introduced.
- Shell commands will be non-interactive and checked for a successful exit status. Any required generated artifact will be validated after generation.
- Rule migration will preserve the policy intent while avoiding duplicate OpenCode rules. The source and compiled configurations will be inspected together before removal.
- No secrets, credentials, or external MCP endpoints will be copied into OpenCode configuration as part of this removal.

## Implementation Plan

1. Create a rule-by-rule parity matrix for `.cursor/rules/` and `.cursor/skills/` against `.opencode/`.
2. Migrate only still-applicable, missing rules and skills to `.opencode/`.
3. Run `npm run opencode:compile` immediately after each `.opencode/` edit and verify `AGENTS.md` includes the migration.
4. Delete `.cursor/` as a complete, self-contained unsupported integration after parity verification.
5. Edit user-facing references so OpenCode is the only supported configuration path.
6. Remove `cursor` from the package keyword list while preserving valid OpenCode scripts and dependencies.
7. Inspect `git diff` plus a repository text search for residual Cursor references.

Pseudocode:

```text
compare Cursor rules and skills against OpenCode equivalents
migrate applicable missing policy to ".opencode"
compile OpenCode configuration and verify generated AGENTS.md
remove directory ".cursor" after migration verification
remove Cursor documentation and metadata references
assert no tracked path begins with ".cursor/"
assert no supported-documentation reference names Cursor
```

### Path Resolution

- The TDD is at `specs/tdd-remove-cursor-configs.md`; it refers to the repository root using one `../` segment where a relative shell path is needed.
- Files under `.cursor/` will be removed by their repository-root-relative paths. No import paths are introduced.

### Naming Standards

- The work branch is `chore/BOT-CONFIG-001-remove-cursor-configs`.
- The design document follows the existing kebab-case `specs/tdd-<feature-slug>.md` convention.
