---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Save plans to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

If the spec is for a single feature but the implementation will be large (5+ tasks), flag this early. You'll do a formal PR scope check in the self-review step and mark task boundaries.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Format Choice (Ask User First)

Before writing the plan, ask the user which format they prefer:

> "Two plan formats available:
> - **Lite** (recommended): Tasks + file paths + high-level steps. No code copied. ~200-500 lines.
> - **Complete**: Full code in every step. Good for complex features. ~1000-2000+ lines.
> 
> Which do you prefer?"

**Lite format** (recommended):
````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test** - Write minimal test
- [ ] **Step 2: Run test to verify it fails** - Expected: FAIL
- [ ] **Step 3: Write implementation** - Write minimal code to pass test
- [ ] **Step 4: Run test to verify it passes** - Expected: PASS
- [ ] **Step 5: Commit**
````

**Complete format** (current):
- Same structure as Lite but with full code blocks in each step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Format:** [Lite | Complete]

---
```

## Task Structure

**For Lite format:**
````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test** - Write minimal test
- [ ] **Step 2: Run test to verify it fails** - Run: pytest tests/path/test.py | Expected: FAIL
- [ ] **Step 3: Write implementation** - Write minimal code to make test pass
- [ ] **Step 4: Run test to verify it passes** - Run: pytest tests/path/test.py | Expected: PASS
- [ ] **Step 5: Commit**
````

**For Complete format:**
````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## No Placeholders

Every step must contain the content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code for Complete format)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for Complete format)
- References to types, functions, or methods not defined in any task

## Remember
- Exact file paths always
- Complete code in every step (Complete format) OR concise steps with clear intent (Lite format)
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits

## PR Scope Check

After the self-review, estimate the plan scope:

**Count:**
- How many tasks?
- How many files modified (from File Structure section)?
- Rough estimate of lines to add/change per task

**If the plan is large (e.g., 5+ tasks or ~1000+ lines estimated), warn the user:**

> ⚠️ **Plan Scope Warning:** This plan has X tasks and modifies ~Y files with an estimated Z lines of changes.
> 
> **Consider splitting into multiple PRs for easier review — each PR should be ~300-500 lines max:**
> 1. First PR: Tasks 1 through N (smaller, faster to review)
> 2. Second PR: Tasks N+1 through end (after first PR merges from main)
> 
> I'll mark each task with its PR group so the scope is clear.

**If the user agrees to split (or if you recommend it and they don't object), annotate every task with its PR group.** Use a `**PR:**` line at the top of each task:

```markdown
### Task 1: [Component Name]
**PR:** 1/2 (Tasks 1-3)

**Files:**
- Create: `path/to/file.py`
...
```

```markdown
### Task 4: [Component Name]
**PR:** 2/2 (Tasks 4-6)

**Files:**
- Create: `path/to/file.py`
...
```

**This is advisory — don't enforce.** The user decides whether to split. Just make the recommendation clearly and annotate the tasks so they can see the boundaries.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/superpowers/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- Batch execution with checkpoints for review
