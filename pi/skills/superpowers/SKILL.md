---
name: superpowers
description: "Activates the Superpowers development methodology. Load at session start for structured development: brainstorming, plans, subagent-driven-development, TDD, and code review."
---

# Superpowers — Standard Workflow

You have activated Superpowers. Follow this workflow for structured, high-quality development.

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

## Standard Workflow

1. **`brainstorming`** — design exploration, questions, design approval
2. **`writing-plans`** — create implementation plan (Lite or Complete)
3. **`subagent-driven-development`** — implement tasks via subagents with reviews
4. **`finishing-a-development-branch`** — merge/PR decision after completion

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
- After scout returns, synthesize findings and proceed with the workflow

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

## Skill Types

**Rigid** (TDD, debugging): Follow exactly. Don't adapt away discipline.
**Flexible** (patterns): Adapt principles to context.
The skill itself tells you which.

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

See the `subagent-driven-development` skill for full workflow details.

## Mandatory Skills Check

Before responding to the user (even with clarifying questions), check if any superpowers skill applies:

1. Is the user asking to build something new? → `brainstorming`
2. Is there a bug to fix? → `systematic-debugging`
3. Do they want to implement from a plan? → `subagent-driven-development`
4. Are they doing code changes? → `test-driven-development`
5. Are they wrapping up? → `finishing-a-development-branch`

**When in doubt, load the skill and check.**

