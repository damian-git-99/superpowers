# Superpowers

Superpowers is a complete software development methodology for your coding agents, built on top of a set of composable skills and some initial instructions that make sure your agent uses them.

## How it works

It starts from the moment you fire up your coding agent. As soon as it sees that you're building something, it *doesn't* just jump into trying to write code. Instead, it steps back and asks you what you're really trying to do.

Once it's teased a spec out of the conversation, it shows it to you in chunks short enough to actually read and digest.

After you've signed off on the design, your agent puts together an implementation plan. You can choose between **Lite** (high-level tasks, ~200-500 lines) or **Complete** (full code in every step, ~1000-2000+ lines).

Next up, once you say "go", it launches a *subagent-driven-development* process, dispatching specialized subagents per task (implementer, spec-reviewer, code-reviewer), each with their own context and model. It's not uncommon for agents to work autonomously for extended periods without deviating from the plan.

## Installation (OpenCode)

Add to your `opencode.json` (global or project-level):

```json
{
  "plugin": ["superpowers@git+https://github.com/damian-git-99/superpowers.git"]
}
```

Restart OpenCode. That's it — the plugin auto-installs and registers all skills and agents.

To update (force refresh):
```bash
rm -rf ~/.cache/opencode/packages/superpowers@git+https:/github.com/damian-git-99/superpowers.git
```
Then restart OpenCode.

## Agents

This fork adds 5 dedicated subagents, each configurable with its own model:

| Agent | Role | Default model |
|-------|------|---------------|
| `code-reviewer` | Reviews code quality, architecture, plan alignment | Inherits from parent |
| `implementer` | Implements coding tasks from plans | Inherits from parent |
| `spec-reviewer` | Verifies implementation matches specification | Inherits from parent |
| `spec-document-reviewer` | Reviews spec documents for clarity and completeness | Inherits from parent |
| `plan-document-reviewer` | Reviews implementation plans for buildability | Inherits from parent |

Models inherit from the parent agent by default. To assign specific models per agent, set them in your `opencode.json`:

```json
{
  "agent": {
    "code-reviewer": {
      "model": "anthropic/claude-sonnet-4-20250514"
    },
    "implementer": {
      "model": "anthropic/claude-haiku-4-20250514"
    }
  }
}
```

## The Basic Workflow

1. **brainstorming** - Activates before writing code. Refines rough ideas through questions, explores alternatives, presents design in sections for validation. Saves design document.

2. **using-git-worktrees** - Activates after design approval. Creates isolated workspace on new branch, runs project setup, verifies clean test baseline.

3. **writing-plans** - Activates with approved design. Breaks work into bite-sized tasks. Ask you to choose Lite or Complete format.

4. **subagent-driven-development** or **executing-plans** - Activates with plan. Dispatches fresh subagent per task with two-stage review (spec compliance, then code quality), or executes in batches with human checkpoints.

5. **test-driven-development** - Activates during implementation. Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit. Deletes code written before tests.

6. **requesting-code-review** - Activates between tasks. Reviews against plan, reports issues by severity. Critical issues block progress.

7. **finishing-a-development-branch** - Activates when tasks complete. Verifies tests, presents options (merge/PR/keep/discard), cleans up worktree.

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.

## OpenSpec Integration

This fork supports an alternative workflow using [OpenSpec](https://openspec.dev) for spec/plan management. Requires [OpenSpec CLI](https://openspec.dev) installed and initialized (`openspec init`) in your project.

**Flow:**

```
1. brainstorming-openspec     → design approved
2. /opsx-ff <change-name>     → creates proposal, specs, design, tasks
3. subagent-driven-dev-openspec → implements tasks via subagents
4. /opsx-archive <change-name> → archives completed change
```

OpenSpec CLI generates the `/opsx-*` commands automatically. After install, run `openspec init` in your project to activate them.

| Skill | Replaces | Purpose |
|-------|----------|---------|
| `brainstorming-openspec` | — | Design exploration, then hands off to OpenSpec |
| `subagent-driven-development-openspec` | `/opsx-apply` | Implements tasks from `openspec/changes/<name>/tasks.md` |

## What's Inside

### Skills Library

**Testing**
- **test-driven-development** - RED-GREEN-REFACTOR cycle

**Debugging**
- **systematic-debugging** - 4-phase root cause process
- **verification-before-completion** - Ensure it's actually fixed

**Collaboration**
- **brainstorming** - Socratic design refinement
- **writing-plans** - Detailed implementation plans (Lite or Complete)
- **executing-plans** - Batch execution with checkpoints
- **dispatching-parallel-agents** - Concurrent subagent workflows
- **requesting-code-review** - Pre-review checklist
- **receiving-code-review** - Responding to feedback
- **using-git-worktrees** - Parallel development branches
- **finishing-a-development-branch** - Merge/PR decision workflow
- **subagent-driven-development** - Fast iteration with two-stage review
- **brainstorming-openspec** - Design exploration with OpenSpec handoff
- **subagent-driven-development-openspec** - Implement OpenSpec changes

**Meta**
- **writing-skills** - Create new skills following best practices
- **using-superpowers** - Introduction to the skills system

### Agents Library

| File | Role |
|------|------|
| `agents/code-reviewer.md` | Senior code reviewer (read-only + git diff) |
| `agents/implementer.md` | Implements tasks from plans (full tools) |
| `agents/spec-reviewer.md` | Spec compliance checker (read-only + git diff) |
| `agents/spec-document-reviewer.md` | Spec document reviewer (read-only) |
| `agents/plan-document-reviewer.md` | Plan document reviewer (read-only) |
| `agents/superpowers.md` | Primary agent: standard workflow |
| `agents/superpowers-openspec.md` | Primary agent: OpenSpec workflow |

**Primary agents** (`superpowers`, `superpowers-openspec`) are designed to use with **Tab** to switch. They include the `using-superpowers` behavioral rules (1% skill check, red flags, priority). To activate them, copy to `~/.config/opencode/agents/`. The plugin auto-registers subagents only.

## Philosophy

- **Test-Driven Development** - Write tests first, always
- **Systematic over ad-hoc** - Process over guessing
- **Complexity reduction** - Simplicity as primary goal
- **Evidence over claims** - Verify before declaring success

## Contributing

1. Fork the repository
2. Create a branch for your work
3. Follow the `writing-skills` skill for creating and testing new and modified skills
4. Submit a PR

## License

MIT License - see LICENSE file for details
