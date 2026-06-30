---
name: brainstorming-openspec
description: Use for design exploration. After design approval, transitions to OpenSpec workflow instead of writing-plans.
---

# Brainstorming → OpenSpec

Help turn ideas into fully formed designs through natural collaborative dialogue, then hand off to OpenSpec for spec/plan management.

Start by understanding the current project context, then ask questions one at a time to refine the idea (use the `question` tool for multiple-choice questions). Once you understand what you're building, present the design and get user approval.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>

**Prerequisite:** [OpenSpec CLI](https://openspec.dev) installed globally (`npm install -g @fission-ai/openspec@latest`).

**Setup check:** Si no existe `openspec/` en la raíz del proyecto, pregunta al usuario:

> "OpenSpec no está inicializado en este proyecto. ¿Quieres configurarlo?"
> - **Sí, para OpenCode** → ejecuta `openspec init --tools opencode`
> - **No ahora** → continua con brainstorming normal (sin OpenSpec)

Si el usuario acepta, ejecuta el comando y confirma que los slash commands (`/opsx-ff`, `/opsx-archive`, etc.) ya están disponibles.

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every project goes through this process. A todo list, a single-function utility, a config change — all of them. "Simple" projects are where unexamined assumptions cause the most wasted work. The design can be short (a few sentences for truly simple projects), but you MUST present it and get approval.

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Explore project context** — check files, docs, recent commits, existing openspec specs
2. **Offer visual companion** (if topic will involve visual questions) — its own message
3. **Ask clarifying questions** — one at a time (use the `question` tool with predefined options when possible)
4. **Research third-party dependencies** — if the design involves complex external libraries (payment SDKs, cloud APIs, auth providers, etc.), launch a sub-agent to investigate before proposing approaches. See section below.
5. **Propose 2-3 approaches** — with trade-offs and your recommendation
6. **Present design** — in sections scaled to their complexity
7. **Transition to OpenSpec** — instruct user to create OpenSpec change (`/opsx-ff <name>`)
8. **Choose implementation approach** — after artifacts generated, ask user how to implement (subagent-driven-development-openspec, manual, or other)

## Process Flow

```dot
digraph brainstorming_openspec {
    "Explore project context" [shape=box];
    "Ask clarifying questions" [shape=box];
    "Complex third-party deps?" [shape=diamond];
    "Research dependencies" [shape=box];
    "Propose 2-3 approaches" [shape=box];
    "Present design sections" [shape=box];
    "User approves design?" [shape=diamond];
    "User runs /opsx-ff\nor /opsx-propose" [shape=box];
    "Choose implementation\napproach" [shape=diamond];

    "Explore project context" -> "Ask clarifying questions";
    "Ask clarifying questions" -> "Complex third-party deps?";
    "Complex third-party deps?" -> "Research dependencies" [label="yes"];
    "Complex third-party deps?" -> "Propose 2-3 approaches" [label="no"];
    "Research dependencies" -> "Propose 2-3 approaches";
    "Propose 2-3 approaches" -> "Present design sections";
    "Present design sections" -> "User approves design?";
    "User approves design?" -> "Present design sections" [label="no, revise"];
    "User approves design?" -> "User runs /opsx-ff\nor /opsx-propose" [label="yes"];
    "User runs /opsx-ff\nor /opsx-propose" -> "Choose implementation\napproach";
}
```

**After `/opsx-ff` generates the artifacts, ask the user how they want to implement.** Offer options: `subagent-driven-development-openspec`, manual implementation, or another approach.

## The Process

**Understanding the idea:**

- Check out the current project state first (files, docs, recent commits, existing openspec specs)
- Before asking detailed questions, assess scope: if the request describes multiple independent subsystems, flag this immediately
- If the project is too large for a single spec, help decompose into sub-projects
- For appropriately-scoped projects, ask questions one at a time
- Use the `question` tool for multiple-choice questions (predefined options help the user answer quickly). The tool supports a custom "Other" option, so you never need to worry about missing an option.
- Focus on understanding: purpose, constraints, success criteria

**Research third-party dependencies:**

- If the design involves complex external libraries (payment SDKs like Stripe, cloud APIs, auth providers, etc.), research them before proposing approaches
- Launch a sub-agent to investigate using `context7`, official docs, or web search
- Focus on: setup requirements, API surface, auth patterns, error handling, webhooks/callbacks, rate limits, official SDK patterns
- Collect findings into a structured summary to reference when proposing approaches and in the design
- For simple/well-known libraries (formatting, utility helpers), skip this step

**Exploring approaches:**

- Propose 2-3 different approaches with trade-offs
- Lead with your recommended option and explain why

**Presenting the design:**

- Scale each section to its complexity
- Cover: architecture, components, data flow, error handling, testing
- Be ready to go back and clarify

## Transition to OpenSpec

After the user approves, tell them to create the OpenSpec change:

> "Design approved. Create the OpenSpec change to capture specs, design decisions, and tasks:
>
> - **`/opsx-ff <change-name>`** — Generate all artifacts at once (proposal, specs, design, tasks)
> - **`/opsx-propose <change-name>`** — Same as ff
> - **`/opsx-continue <change-name>`** — Step by step (one artifact at a time)
>
> When implementation is complete, run `/opsx-archive <change-name>` to archive."

After the user runs `/opsx-ff`, ask how they want to implement: `subagent-driven-development-openspec`, manually, or another approach.

## Key Principles

- **One question at a time** - Don't overwhelm
- **Use the `question` tool** - It supports predefined options (with a custom "Other" fallback), perfect for multiple-choice questions. Prefer this over asking open-ended questions in plain text.
- **YAGNI ruthlessly** - Remove unnecessary features
- **Research before proposing** - When complex third-party dependencies are involved, investigate before designing architecture
- **Explore alternatives** - Always propose 2-3 approaches
- **Incremental validation** - Present design, get approval before moving on

## Visual Companion

A browser-based companion for showing mockups, diagrams, and visual options during brainstorming.

**Offering the companion:** When you anticipate that upcoming questions will involve visual content, offer it once for consent.

**This offer MUST be its own message.** Wait for the user's response before continuing. If they decline, proceed with text-only brainstorming.

If they agree to the companion, read the detailed guide before proceeding:
`skills/brainstorming/visual-companion.md`
