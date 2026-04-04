# Changelog

Todas as mudanças significativas deste projeto serão documentadas neste arquivo.

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
