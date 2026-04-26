---
description: Check for updates and update OpenCode configuration files
mode: subagent
tools:
  bash: true
---

# OpenCode Self-Update

Check the current installed OpenCode configuration version against the latest available version, and update if a newer version is available.

## Workflow

### 1. Check current version

Read the installed version from `.opencode/opencode.version` in the current project directory.

If the file does not exist, report that OpenCode is not installed in this project.

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

- Verify the new version by reading `.opencode/opencode.version`
- Inform the user of the updated version
- Note: the AGENTS.md file distributed with OpenCode is pre-compiled and does not need a separate compile step in the target project

## Important

- Never update without explicit user confirmation
- Always show the version comparison before asking to proceed
- If the update fails, the backup at `.opencode.bak/` can be restored manually