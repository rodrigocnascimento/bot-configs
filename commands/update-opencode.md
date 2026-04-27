---
description: Check for updates and update OpenCode AGENT configuration files (NOT application code)
mode: subagent
tools:
  bash: true
---

# OpenCode Configuration Self-Update

**IMPORTANT: This command is EXCLUSIVELY for updating OpenCode agent configuration files.**

This command does NOT update application code, business logic, or any project-specific files. It ONLY updates OpenCode configuration artifacts such as:
- AGENTS.md
- Rules (*.md files in rules/)
- Commands (*.md files in commands/)
- Skills (*.md files in skills/)
- Other OpenCode configuration files

## Workflow

### 1. Check current version

**IMPORTANT:** Search in both locations:
- Global: `~/.config/opencode/opencode.version`
- Local (project): `.opencode/opencode.version`

Read the installed version from the first location found in this order.

If neither file exists, report that OpenCode configuration is not installed in this project (checked both global and local).

### 2. Fetch latest version

Use GitHub API to fetch the latest release tag:

```bash
curl -sf https://api.github.com/repos/rodrigocnascimento/bot-configs/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//'
```

If the releases API fails, fall back to reading `package.json` version:

```bash
curl -sf https://raw.githubusercontent.com/rodrigocnascimento/bot-configs/main/package.json | grep '"version"' | head -1 | cut -d'"' -f4
```

### 3. Compare versions

Compare the local version (semver) with the latest version.

Present the comparison to the user:

- If up to date: inform and stop
- If update available: show what version → what version and ask for confirmation

### 4. Update

If the user confirms, execute the installer with the `--update` flag:

```bash
curl -fsSL https://raw.githubusercontent.com/rodrigocnascimento/bot-configs/main/dist/install-opencode.sh | bash -s -- --update
```

If the user wants a forced reinstall:

```bash
curl -fsSL https://raw.githubusercontent.com/rodrigocnascimento/bot-configs/main/dist/install-opencode.sh | bash -s -- --force
```

### 5. After update

- Verify the new version by reading `~/.config/opencode/opencode.version` or `.opencode/opencode.version`
- Inform the user of the updated version
- Note: the AGENTS.md file distributed with OpenCode is pre-compiled and does not need a separate compile step in the target project

## Important

- **NEVER use this for application code updates**
- **NEVER update business logic or project-specific files**
- Only update OpenCode configuration artifacts
- Never update without explicit user confirmation
- Always show the version comparison before asking to proceed
- If the update fails, the backup at `.opencode.bak/` can be restored manually