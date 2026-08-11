---
name: adr
description: Architecture Decision Records (ADR) documentation practice. Use when documenting architectural decisions, recording technical trade-offs, creating decision logs, or establishing architectural patterns. Trigger keywords - "ADR", "architecture decision", "decision record", "trade-offs", "architectural decision", "decision log".
version: 0.2.0
tags: [dev, adr, architecture, decisions, documentation, trade-offs]
keywords: [adr, architecture, decision, record, trade-offs, documentation, rationale, alternatives]
plugin: dev
updated: 2026-01-28
---

# ADR Documentation

## What & Why

ADRs (Architecture Decision Records) are short, immutable documents that
capture *what* was decided, *why*, and *what alternatives were rejected*.
They preserve context for future contributors and prevent re-litigating
settled debates.

## When to Write One

**Write an ADR for:** technology/framework choices, architectural patterns,
breaking changes, security decisions, performance-critical trade-offs —
anything significant and hard to reverse.

**Skip it for:** minor implementation details, temporary workarounds,
style preferences, easily reversible choices.

## Template

```markdown
# ADR-XXXX: [Short, Specific Title]

## Status
Proposed | Accepted | Deprecated | Superseded by ADR-YYYY

## Date
YYYY-MM-DD

## Context
The problem, constraints, and requirements that led to this decision.

## Decision
What was decided, including scope (and what's explicitly out of scope).

## Consequences
### Positive
- ...
### Negative
- ...
### Neutral
- ...

## Alternatives Considered
### Alternative: [Name]
**Pros:** ... **Cons:** ... **Why Rejected:** ...
(repeat for 2-4 alternatives)

## Related ADRs
## References
```

Keep each ADR to 1-2 pages. Write context and alternatives honestly and
specifically — vague context ("we needed a database") isn't useful to
future readers.

## Naming & Location

- File: `ADR-XXXX-short-title.md` (zero-padded number, lowercase, hyphens)
- Location: `docs/adr/` (or `ai-docs/decisions/` for Claude Code projects)
- Numbers are sequential and never reused, even when superseded

## Lifecycle

1. **Proposed** → draft, gather feedback
2. **Accepted** → status/date updated, becomes immutable (don't rewrite
   history — add notes instead)
3. **Deprecated** → no longer recommended; add a short deprecation note
   explaining why
4. **Superseded** → a new ADR replaces it; old ADR's status points to the
   new one, new ADR references the old one in its Context

## Using ADRs with Claude Code

Reference key ADRs in `CLAUDE.md` so Claude follows established patterns:

```markdown
## Architectural Decisions
- ADR-0001: Use PostgreSQL for all structured data
- ADR-0012: Implement repository pattern for data access

Claude should follow these patterns in all code generation.
```

## Quick Example

```markdown
# ADR-0001: Use PostgreSQL for Primary Database

## Status
Accepted

## Date
2026-01-28

## Context
Need ACID transactions for billing, complex reporting queries, and
500k-user scale in year one. Team has 5+ years PostgreSQL experience.

## Decision
Use PostgreSQL 15+ via AWS RDS for all structured data (users,
subscriptions, billing). Redis handles caching separately.

## Consequences
### Positive
- ACID guarantees protect billing integrity; team already expert
### Negative
- Horizontal scaling needs a sharding strategy later
### Neutral
- Need to define backup/restore and migration procedures

## Alternatives Considered
### MongoDB
**Pros:** flexible schema, built-in sharding
**Cons:** no multi-document ACID transactions, no team experience
**Why Rejected:** billing workflow requires atomic multi-table updates

## Related ADRs
None (first ADR)
```
