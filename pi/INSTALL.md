# Installing Superpowers for Pi

## Installation

```bash
pi install /path/to/superpowers/pi
```

Or from GitHub (once published):

```bash
pi install git:github.com/damian-git-99/superpowers/pi
```

This registers all Superpowers skills and subagents.

## Required Extensions

Superpowers for Pi uses these extensions for enhanced functionality. Install them alongside:

```bash
# Subagent dispatch (code-reviewer, implementer, spec-reviewer, etc.)
pi install npm:pi-subagents

# Structured brainstorming questions (tabs, previews, multi-select)
pi install npm:@juicesharp/rpiv-ask-user-question
```

**pi-subagents** is required for subagent-driven-development, dispatching-parallel-agents, and any skill that delegates to subagents. All Superpowers subagents (code-reviewer, implementer, spec-reviewer, etc.) are registered as pi-subagents.

**@juicesharp/rpiv-ask-user-question** is used by the `brainstorming` and `brainstorming-openspec` skills to present structured clarifying questions via the `ask_user_question` tool. If not installed, they fall back to manual questions.

## What gets installed

- **Skills** (18 total):
  - `superpowers` / `superpowers-openspec` — activate the full workflow at session start
  - `using-superpowers` — how to use skills (red flags, priority, skill flow)
  - `brainstorming`, `writing-plans`, `subagent-driven-development` — core workflow
  - `test-driven-development`, `systematic-debugging` — disciplined practices
  - `dispatching-parallel-agents`, `requesting-code-review`, `finishing-a-development-branch` — collaboration
  - And more — all 16 original skills plus 2 new activator skills

- **Subagents** (5 agents for pi-subagents):
  - `superpowers.code-reviewer` — code quality and architecture review
  - `superpowers.implementer` — implements tasks from plans
  - `superpowers.spec-reviewer` — verifies spec compliance
  - `superpowers.spec-document-reviewer` — reviews spec documents
  - `superpowers.plan-document-reviewer` — reviews implementation plans

## Usage

### Activate Superpowers workflow

At the start of a session, load the activator skill:

```text
/skill:superpowers "Let's make a react todo list"
```

Or for the OpenSpec variant:

```text
/skill:superpowers-openspec "Add a new API endpoint"
```

The skill instructs your agent to follow the full workflow: brainstorming → plans → subagent-driven-development → finish branch.

### Use subagents directly

```text
List available subagents.
```

Then dispatch them:

```text
Use superpowers.implementer to implement this task.
Use superpowers.code-reviewer to review this diff.
Use superpowers.spec-reviewer to check spec compliance.
```

Or programmatically:

```text
subagent({ agent: "superpowers.implementer", task: "Implement...", context: "fresh" })
```

### Use individual skills

Skills are auto-discovered. The agent checks them automatically when a task matches. You can also load them explicitly:

```text
/skill:brainstorming "Let's design the auth flow"
/skill:test-driven-development
/skill:systematic-debugging "This test is flaky"
```

## Verify

```text
Show me available skills.
```

You should see all 18 Superpowers skills.

```text
List available subagents.
```

You should see `superpowers.code-reviewer`, `superpowers.implementer`, etc.

## Troubleshooting

### Skills not found

```bash
pi list
```

### Agents not found

The extension copies agent files to `~/.pi/agent/agents/superpowers/` on first load:

```bash
ls ~/.pi/agent/agents/superpowers/
```

If empty, restart Pi or run `/reload`.
