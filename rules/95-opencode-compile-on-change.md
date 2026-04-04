# Rule: OpenCode Configuration Synchronization (OCCS)

## Context

To ensure that the agent's operational instructions are always up-to-date, any modification within the `.opencode/` directory must be immediately reflected in the compiled `AGENTS.md` file. This compiled file is the single source of truth for the agent's rules and configurations during runtime.

## The Protocol

### Trigger Conditions

This rule is triggered by any of the following operations within the `.opencode/` directory or its subdirectories:

- Creating a new file (rule, agent, command, skill, etc.)
- Modifying an existing file
- Deleting a file

### Mandatory Action

Immediately after any of the trigger conditions are met, you **MUST** execute the following command:

```bash
npm run opencode:compile
```

### Verification

After execution, you must confirm that the command ran successfully and that the `AGENTS.md` file has been updated. No task involving a change to the `.opencode/` directory is complete until this command has been successfully executed.

## Hard Execution Gate

**STOP** and do not proceed with any other actions if:

- A change was made in `.opencode/`.
- `npm run opencode:compile` has not been executed yet.

This ensures the agent never operates with outdated instructions.
