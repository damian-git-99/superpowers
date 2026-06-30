---
name: openspec-reference
description: Use when working with OpenSpec and unsure whether to use bash commands, slash commands, or skills
---

# OpenSpec Reference

## Prerequisite Check

When this skill is loaded, verify OpenSpec is set up:

1. Check if `openspec/` directory exists in project root
2. Check if `.opencode/commands/opsx-ff.md` exists (slash commands registered)

**If either is missing, warn the user:**

> "OpenSpec is not set up in this project. Run: `openspec init --tools opencode`"

**If both exist, continue with the reference below.**

## Setup (bash)

```bash
openspec init --tools opencode
```

Run once per project. Registers slash commands in `.opencode/commands/`.

## Slash Commands

User-invocable. Generate artifacts with conversation context.

| Command | Purpose |
|---------|---------|
| `/opsx-ff <name>` | Create change + generate ALL artifacts |
| `/opsx-archive <name>` | Archive completed change |
| `/opsx-continue <name>` | Step-by-step artifact creation |
| `/opsx-propose <name>` | Alternative to `/opsx-ff` |
| `/opsx-sync` | Sync delta specs to canonical specs |
| `/opsx-verify <name>` | Verify delta specs |

## Superpowers Skills

Load via `skill` tool.

| Skill | When |
|-------|------|
| `brainstorming-openspec` | Design exploration before creating a change |
| `subagent-driven-development-openspec` | Implementing tasks from `openspec/changes/<name>/tasks.md` |

## Workflow

```
brainstorming-openspec → /opsx-ff → implementation choice → subagent-driven-development-openspec → /opsx-archive
```

## What NOT to do

- Do NOT run `openspec status`, `openspec instructions`, or `openspec new` via bash for artifact generation — use slash commands
- Do NOT skip `brainstorming-openspec` before `/opsx-ff`
