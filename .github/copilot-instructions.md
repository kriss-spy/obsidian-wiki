# Obsidian Wiki — Copilot Context

This project is a **skill-based framework** for building and maintaining an Obsidian knowledge base using AI coding agents. There are no scripts or dependencies — everything is markdown instructions that the agent executes directly.

## Project Overview

- **Purpose:** Build and maintain an Obsidian wiki using the LLM Wiki pattern (Andrej Karpathy).
- **Tech Stack:** Markdown only. No code, no dependencies. The AI agent IS the runtime.
- **Key Config:** `.env` contains `OBSIDIAN_VAULT_PATH` pointing to the vault location.
- **Skills:** `.agents/skills/` contains skill folders, each with a `SKILL.md` defining a workflow.

## Key Concepts

- The wiki is a **compiled artifact** — knowledge distilled from raw sources into interconnected pages.
- Every wiki page has YAML frontmatter: `title`, `category`, `tags`, `sources`, `created`, `updated`.
- Pages are connected with Obsidian `[[wikilinks]]`.
- A `.manifest.json` in the vault root tracks all ingested sources for delta-based updates.
- `index.md` and `log.md` must be updated after every operation.

## Skills Reference

| Skill | Folder | Purpose |
|---|---|---|
| Setup | `.agents/skills/wiki-setup/` | Initialize vault structure |
| Ingest | `.agents/skills/wiki-ingest/` | Distill documents into wiki pages |
| History Router | `.agents/skills/wiki-history-ingest/` | Route `/wiki-history-ingest <claude|codex>` to the right history skill |
| Claude History | `.agents/skills/claude-history-ingest/` | Mine `~/.claude` conversations |
| Codex History | `.agents/skills/codex-history-ingest/` | Mine `~/.codex` sessions and rollout logs |
| Data Ingest | `.agents/skills/data-ingest/` | Process any text data |
| Status | `.agents/skills/wiki-status/` | Audit ingestion state and delta |
| Query | `.agents/skills/wiki-query/` | Answer questions from wiki |
| Lint | `.agents/skills/wiki-lint/` | Find broken links, orphans |
| Rebuild | `.agents/skills/wiki-rebuild/` | Archive and rebuild |
| Cross-Linker | `.agents/skills/cross-linker/` | Auto-discover and insert missing wikilinks |
| Tag Taxonomy | `.agents/skills/tag-taxonomy/` | Enforce consistent tag vocabulary |
| LLM Wiki | `.agents/skills/llm-wiki/` | Core architecture pattern |
| Skill Creator | `.agents/skills/skill-creator/` | Create new skills |

## Coding Conventions

- When creating wiki pages, always use YAML frontmatter.
- Use `[[wikilinks]]` syntax for cross-references — NOT markdown links.
- Project-specific knowledge goes in `projects/<name>/`. Global knowledge goes in top-level categories.
- Never modify the `.obsidian/` directory.
