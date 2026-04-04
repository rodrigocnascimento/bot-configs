# Rule: Mandatory Test Coverage for All Features

## Context

To ensure code quality, prevent regressions, and maintain maintainability, **no feature, fix, or refactor shall be delivered without corresponding test coverage**. This rule ensures that every code change is validated and can be safely modified in the future.

## The Protocol

Whenever implementing a task, you **MUST** create tests that cover:

### Required Test Scenarios

1. **Happy Path**: The main functionality works as expected
2. **Edge Cases**: Boundary conditions, empty inputs, null/undefined values
3. **Error Handling**: How the code behaves when things go wrong
4. **Type Conversions**: Any type transformations or validations

### Test Location

- Place tests in the `tests/` directory
- Follow the naming convention: `<module>.test.ts`
- Use Vitest with `describe`/`it` pattern

### Test Coverage Requirements

- **New features**: At minimum, test the main exported functions
- **Bug fixes**: Add regression tests that would have caught the bug
- **CLI commands**: Test the main execution paths
- **Utility functions**: Test all exported functions with representative inputs

## Hard Execution Gates

**STOP** and do not deliver if:

- Tests do not exist for new functionality
- Tests fail to run (`npm run test` fails)
- Tests do not cover the main use cases

## Exceptions

This rule does NOT apply to:

- Documentation-only changes
- Configuration file updates
- Dependency updates (unless they affect behavior)

## Running Tests

```bash
npm run test        # Run all tests
npm run test:watch  # Run tests in watch mode
```

## Enforcement

Before finishing any task, verify:

1. Run `npm run test` - all tests must pass
2. New tests exist in `tests/` directory
3. Tests cover the main functionality
