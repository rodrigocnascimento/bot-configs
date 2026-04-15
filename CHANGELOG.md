# Changelog

Todas as mudanças significativas deste projeto serão documentadas neste arquivo.

---

## [1.3.1] - 2026-04-15

### Changed
- Rewrote README.md to reflect installer-based workflow with 3 installation methods
- Added "Atualizar" section documenting `--update`, `--check`, `--force` flags and backup mechanism
- Added "Versionamento" section explaining `opencode.version` and semver comparison
- Updated repository structure diagram with `dist/`, `opencode.version`, `installer.config`, `INSTALLER.md`
- Added `INSTALLER.md` reference in documentation table

---

## [1.3.0] - 2026-04-14

### Added
- Version tracking via `opencode.version` file for self-update capability
- `--update` flag on installer: updates only if newer version available, with backup
- `--check` flag on installer: compares local vs latest version without downloading
- `--force` flag on installer: forces reinstall without prompting
- `semver_compare()` and `get_latest_version()` in installer for version detection
- `backup_existing()` mechanism (`.opencode/` → `.opencode.bak/`)
- OpenCode `/update` command (`.opencode/commands/update.md`)
- TDD for self-update feature (`specs/tdd-opencode-self-update.md`)

### Changed
- `installer.config`: added `VERSION_FILE` and `RELEASES_API_URL` config vars
- `generate-installer.sh`: embedded version from `opencode.version`, generates installer with update/check/force support
- `dist/install-opencode.sh`: regenerated with all new functionality
- `INSTALLER.md`: documented update, check, backup, and version workflows

---

## [1.2.0] - 2026-04-14

### Added
- Hard gate for Issue ID and work branch creation in TDP command (`commands/tdp.md`)
- Backend anti-patterns detection rule (`rules/backend-anti-patterns.md`)
- Backend security review rule based on OWASP (`rules/backend-security-review.md`)
- Staff Engineer review rule with 6 dimensions (`rules/staff-engineer-review.md`)
- Backend code review skill with 5-step workflow (`skills/backend-code-review/SKILL.md`)
- Review rules reference for code review (`skills/backend-code-review/references/review-rules.md`)
- Comment templates for structured feedback (`skills/backend-code-review/references/comment-templates.md`)
- Updated code review command to invoke the backend-code-review skill

---

## [1.1.0] - 2026-04-13

### Added
- OpenCode curl-to-bash installer system for easy distribution
- GitHub Actions workflow (generate-installer.yml) for manual installer generation
- installer.config for centralized folder configuration
- generate-installer.sh script for local installer generation
- INSTALLER.md documentation for the installer system
- Technical Design Document (specs/tdd-opencode-installer.md)

### Features
- Hybrid approach: centralized config (Option B) + environment variable override (Option C)
- Users can install via: `curl -fsSL ... | bash`
- Users can customize folders: `PASTAS="commands docs" curl ... | bash`
- Maintainer can generate installer via GitHub Actions without local execution

---

## [1.0.2] - 2026-04-03

### Added
- (nenhuma mudança de funcionalidade)

### Changed
- Atualização na documentação de arquitetura (docs/regras/arquitetura.md)
- Bump de versão para 1.0.2

### Fixed
- (nenhuma correção de bug específica)

### Removed
- (nenhuma remoção)

---

## [1.0.1] - 2026-04-03

### Added
- (nenhuma mudança de funcionalidade)

### Changed
- Atualização na documentação de arquitetura (docs/regras/arquitetura.md)

### Fixed
- (nenhuma correção de bug específica)

### Removed
- (nenhuma remoção)

---

## [1.0.0] - 2026-04-03

### Added
- Feature-007 module implementation with clean architecture
  - DTOs, entities, repositories, use cases, and controllers
  - Comprehensive unit tests for the feature-007 use case
- Technical Design Document for feature-007 (specs/tdd-feature-007-feature-implementation.md)
- Fixed Mermaid diagram syntax error in docs/fluxos/feature-branch-flow.md
- Initial package.json with version 1.0.0

---

## 2026-03-27

### Adicionado
- **AGENTS.md**: Guia técnico para agentes de IA cobrendo comandos de build/test, code style, git workflow, TDP, processo de release, regras de segurança e padrões de arquitetura
- **README.md**: Documentação em pt-BR explicando o repositório, OpenCode, Cursor, skills e integrações com Jira/GitLab
- **docs/**: Estrutura de documentação completa com 12 arquivos Markdown organizados para Confluence:
  - Visão geral do OpenCode, regras operacionais, comandos e fluxos de trabalho
  - Visão geral do Cursor, skills e regras de review
  - Regras gerais de Git governance, code style, segurança e arquitetura
  - Fluxos de feature branches, release process e Technical Design Phase (TDP)

### Correções
- **README.md**: Atualizada seção "Para Novo Projeto" com instruções corretas:
  - OpenCode: usar comando `/init`
  - Cursor: solicitar ao agente (futuro: skill dedicada)
