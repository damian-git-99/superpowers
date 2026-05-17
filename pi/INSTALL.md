# Installing Superpowers for Pi

## Installation

```bash
pi install /path/to/superpowers/pi
```

Or from GitHub (once published):

```bash
pi install git:github.com/damian-git-99/superpowers/pi
```

## Required Dependencies

```bash
# Subagent dispatch (worker, reviewer, scout, planner, oracle)
pi install npm:pi-subagents

# Structured brainstorming questions (tabs, previews, multi-select)
pi install npm:@juicesharp/rpiv-ask-user-question
```

## What gets installed

- **Skills** (18 total):
  - `superpowers` / `superpowers-openspec` — activate the full workflow at session start
  - `using-superpowers` — how to use skills (red flags, priority, skill flow)
  - `brainstorming`, `writing-plans`, `subagent-driven-development` — core workflow
  - `test-driven-development`, `systematic-debugging` — disciplined practices
  - `dispatching-parallel-agents`, `requesting-code-review`, `finishing-a-development-branch` — collaboration
  - And more — all 16 original skills plus 2 new activator skills

- **Subagents**: Uses pi-subagents builtin agents:
  - `worker` — implements tasks (equivalent to implementer)
  - `reviewer` — code quality and spec review
  - `scout` — codebase exploration
  - `planner` — creates implementation plans
  - `oracle` — second opinion and advisory

## Usage

### Activate Superpowers workflow

```text
/skill:superpowers "Let's make a react todo list"
/skill:superpowers-openspec "Add a new API endpoint"
```

### Use subagents directly

```text
Use worker to implement this task.
Use reviewer to review this diff.
Use scout to explore the codebase.
```

Or programmatically:

```text
subagent({ agent: "worker", task: "Implement...", context: "fresh" })
subagent({ agent: "reviewer", task: "Review this diff", context: "fresh" })
subagent({ agent: "scout", task: "Explore the auth flow", context: "fresh" })
```

### Model overrides per agent

In `~/.pi/agent/settings.json`:

```json
{
  "subagents": {
    "agentOverrides": {
      "worker": {
        "model": "opencode-go/deepseek-v4-flash",
        "thinking": "high"
      },
      "reviewer": {
        "model": "opencode-go/qwen3.6-plus"
      },
      "scout": {
        "model": "opencode-go/deepseek-v4-flash"
      }
    }
  }
}
```

## Troubleshooting

### Skills not found

```bash
pi list
```

### Subagents not working

```bash
/subagents-doctor
```
