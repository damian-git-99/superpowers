# Pi Tool Mapping

Skills use Claude Code tool names. When you encounter these in a skill, use your Pi equivalent:

| Skill references | Pi equivalent |
|-----------------|---------------|
| `Read` (file reading) | `read` |
| `Write` (file creation) | `write` |
| `Edit` (file editing) | `edit` |
| `Bash` (run commands) | `bash` |
| `Grep` (search file content) | `grep` |
| `Glob` (search files by name) | `glob` / `find` / `ls` |
| `Skill` tool (invoke a skill) | `read` on the skill's `SKILL.md` file |
| `Task` tool (dispatch subagent) | `subagent({ agent: "...", task: "...", context: "fresh" })` |
| Multiple `Task` calls (parallel) | `subagent({ tasks: [{ agent: ..., task: ... }, ...], concurrency: N })` |
| Task returns result | The subagent's response is returned directly |
| `TodoWrite` (task tracking) | Use `subagent` with `progress: true`, or track manually |
| `EnterPlanMode` / `ExitPlanMode` | No equivalent — work directly in the session |
| `WebFetch` | `fetch` via bash or use `brave-search` skill |
| `WebSearch` | Use `brave-search` skill or similar |

## Subagent dispatch in Pi

When a skill says to dispatch a named agent, use the `subagent` tool with pi-subagents builtin agents:

```typescript
// Single agent
subagent({
  agent: "superpowers.code-reviewer",
  task: "Review the implementation for...",
  context: "fresh"
})

// With inline model override
subagent({
  agent: "superpowers.implementer",
  task: "Implement Task N...",
  model: "anthropic/claude-sonnet-4",
  context: "fork"
})

// Parallel agents
subagent({
  tasks: [
    { agent: "superpowers.spec-reviewer", task: "Check spec compliance...", context: "fresh" },
    { agent: "superpowers.code-reviewer", task: "Review code quality...", context: "fresh" }
  ],
  concurrency: 2
})

// Sequential chain
subagent({
  chain: [
    { agent: "superpowers.implementer", task: "Implement...", context: "fresh" },
    { agent: "superpowers.spec-reviewer", task: "Review spec compliance {previous}", context: "fresh" },
    { agent: "superpowers.code-reviewer", task: "Review code quality {previous}", context: "fresh" }
  ]
})
```

## Agent mapping

| Skill references | Pi subagent | Cost |
|-----------------|-------------|------|
| `implementer` | `superpowers.implementer` | standard |
| `code-reviewer` (quality) | `superpowers.code-reviewer` | 💪 powerful |
| `spec-reviewer` (compliance) | `superpowers.spec-reviewer` | ⚡ cheap |
| `spec-document-reviewer` | `superpowers.spec-document-reviewer` | ⚡ cheap |
| `plan-document-reviewer` | `superpowers.plan-document-reviewer` | 💪 powerful |
| `Explore` / `scout` | `scout` (builtin) | ⚡ cheap |
| `planner` | `planner` (builtin) | 💪 powerful |
| `oracle` | `oracle` (builtin) | 💪 powerful |

## Prompt templates

Skills like `subagent-driven-development` include local prompt templates (e.g., `implementer-prompt.md`, `spec-reviewer-prompt.md`). When a skill tells you to use a template, read the template file and include its content as the subagent's task.

```typescript
// Read the template first
const prompt = await read("skills/subagent-driven-development/implementer-prompt.md")

// Use it as the task with a builtin agent
subagent({
  agent: "superpowers.implementer",
  task: prompt + "\n\n[fill in template placeholders]",
  context: "fresh"
})
```
