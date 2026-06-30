---
name: superpowers-openspec
description: "Activates Superpowers with OpenSpec workflow for structured feature development with spec management."
---

# Superpowers — OpenSpec Workflow

You have activated Superpowers with OpenSpec workflow. Follow this for structured feature development using OpenSpec for specification management.

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Instruction Priority

1. **User's explicit instructions** — highest priority
2. **Superpowers skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

## How to Access Skills

In Pi, use `read` to load a skill's SKILL.md file. Skills are auto-discovered and their descriptions appear in your system prompt. When a task matches a skill's description, load it with `read skills/<name>/SKILL.md` and follow its instructions.

## OpenSpec Workflow

1. **`brainstorming-openspec`** — design exploration, then hands off to OpenSpec
2. **Create change** — user runs `/opsx-ff <name>` or `/opsx-propose <name>` to create proposal, specs, design, tasks
3. **`subagent-driven-development-openspec`** — implements tasks from `openspec/changes/<name>/tasks.md`
4. **Archive** — user runs `/opsx-archive <name>` to finalize

Requires [OpenSpec CLI](https://openspec.dev) installed and initialized in the project.

## Skill Preferences

- Use `brainstorming-openspec` for design exploration (instead of `brainstorming`)
- Use `subagent-driven-development-openspec` for implementing OpenSpec changes (instead of `subagent-driven-development`)
- Other skills apply normally: `requesting-code-review`, `verification-before-completion`, `test-driven-development`, etc.

## The Rule

**Invoke relevant skills BEFORE any response or action.** Even a 1% chance a skill might apply means you should invoke the skill to check. If it turns out wrong, you don't need to use it.

## Codebase Exploration

**You MUST scope the task before reading any files.** Do not start reading code until you determine the scope.

You MUST delegate exploration to a `scout` subagent. Do NOT read files yourself.
- This preserves context for the main workflow.
```typescript
subagent({
  agent: "scout",
  task: "Explore the codebase to understand [area]. Find relevant files, entry points, data flow, and risks.",
  context: "fresh"
})
```
- After scout returns, synthesize findings and proceed with the OpenSpec workflow

**No exceptions. Always use `scout` for exploration.**

## Red Flags

These thoughts mean STOP — you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. This is what scout is for. |
| "I'll just read a few files quickly" | If it's more than 3 files, use scout. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "Exploring myself is faster" | Scout preserves your context for the actual work. |

## Skill Priority

When multiple skills could apply:
1. **Process skills first** (brainstorming, debugging) — these determine HOW to approach
2. **Implementation skills second** — these guide execution

## Using Subagents

Superpowers uses subagent-driven-development for implementation. In Pi, dispatch subagents using the `subagent` tool:

```typescript
// Implementer → superpowers.implementer
subagent({
  agent: "superpowers.implementer",
  task: "Implement Task N...",
  context: "fresh"
})

// Spec reviewer → superpowers.spec-reviewer
subagent({
  agent: "superpowers.spec-reviewer",
  task: "Verify spec compliance by reading the implementation...",
  context: "fresh"
})

// Code reviewer → superpowers.code-reviewer
subagent({
  agent: "superpowers.code-reviewer",
  task: "Review code quality...",
  context: "fresh"
})
```

See the `subagent-driven-development-openspec` skill for full workflow details.

## Mandatory Skills Check

Before responding to the user (even with clarifying questions), check if any superpowers skill applies:

1. Is the user asking to build something new? → `brainstorming-openspec`
2. Is there an existing OpenSpec change? → `subagent-driven-development-openspec`
3. Are they doing code changes? → `test-driven-development`
4. Are they wrapping up? → `finishing-a-development-branch`

**When in doubt, load the skill and check.**

