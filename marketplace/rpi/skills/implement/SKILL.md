---
name: implement
description: Implement tasks from a plan file, one at a time or all at once
allowed-tools: "Agent, Read, Grep, Glob, Bash, AskUserQuestion"
argument-hint: "[plan.md file] [optional: all]"
---

## Variables

PLAN_FILE = $0 // The plan.md file containing tasks to implement
IMPLEMENT_ALL = $1 // Optional flag "all" to implement all tasks without returning

## Branch Safety Check (run first, do not skip)

Before gathering context, parsing the plan, or making any change, guard against accidentally implementing on a protected branch.

1. Confirm this is a git repo: run `git rev-parse --is-inside-work-tree`. If it fails (not a git repo), skip this entire check and proceed.
2. Get the current branch: `git rev-parse --abbrev-ref HEAD`.
3. Determine the repo's default branch: `git symbolic-ref --quiet refs/remotes/origin/HEAD` and strip the `refs/remotes/origin/` prefix. If that fails, use `main` and `master` as the protected set.
4. The branch is PROTECTED if it equals the default branch or is named `main` or `master` (case-insensitive).
5. If the branch is protected, you MUST pause and call AskUserQuestion before doing anything else. Ask whether implementing on this branch is intentional (header e.g. "Branch", question e.g. "You're on protected branch `<branch>`. Is implementing here intentional?"). The FIRST option MUST be "Not intended, exit." and a second option confirms it is intentional (e.g. "Yes, intended — continue on <branch>").
   - If the user picks "Not intended, exit." (or otherwise declines), STOP immediately: do NOT gather context, implement any task, run quality gates, or modify the plan file. Report that you stopped because changes were about to be made on protected branch <branch>.
   - Only if the user explicitly confirms may you continue to Gather Context and implementation.
6. If the branch is not protected, proceed normally.

## Gather Context
- Read the plan file at PLAN_FILE using the Read tool

# Implement Plan Tasks

You are implementing tasks from a plan file. The plan file contains a list of tasks with checkboxes indicating completion status.

## Source of Truth & Scope Discipline (read before doing anything)

- The plan file is the single source of truth. Implement ONLY tasks that are written in it. Do not invent, expand, reorder, or skip work beyond the listed tasks.
- Every code change you make MUST correspond to a checklist item. If you are about to do something that is not represented by a task, that is the signal to STOP and use the Deviation Protocol — never proceed off-checklist or go ad-hoc.
- The plan file is a live ledger. After each task, mark it `[x]` before moving on. Never do work without recording it in the plan.
- Original task lines are immutable. Never edit, reword, delete, or reorder a task that came from the original plan. The ONLY change allowed to an original task is toggling its checkbox `[ ]` → `[x]`. New tasks are added only via the Deviation Protocol, clearly marked as amendments.

## Your Responsibilities

### 1. Parse the Plan File
- Identify all tasks in the plan file (look for checkbox patterns like `- [ ]` or `- [x]`)
- Determine which tasks are complete (`[x]`) and which are incomplete (`[ ]`)
- Extract any context, dependencies, or requirements mentioned in the plan

### 2. Fetch Required Context
- Scan the plan file for references to other files, directories, or components
- Use Grep and Glob tools to locate relevant code files
- Read any files that provide necessary context for implementation
- Understand the codebase structure and existing patterns

### 3. Determine Execution Mode

**Single Task Mode (default):**
- If IMPLEMENT_ALL is not "all", implement only the NEXT unchecked task
- After completing the task, return to user for validation
- Do NOT proceed to subsequent tasks

**All Tasks Mode (when IMPLEMENT_ALL = "all"):**
- Implement EVERY unchecked task in the plan file
- Continue through all tasks without returning to user
- Provide comprehensive summary at the end

### 4. Task Execution Process

For each task to implement:

**a) Implement the Task:**
- Make the necessary code changes
- Follow existing code patterns and conventions
- Ensure the implementation matches the task requirements
- Handle edge cases and error conditions
- Respect phase boundaries (complete all tasks in a phase before proceeding)
- Identify parallel tasks marked with `[P]` prefix

**b) Run Quality Gates:**
After implementation, run in sequence:
1. **Build** - Project must compile/build successfully
2. **Lint** - Code must pass linting checks
3. **Test** - All tests must pass

Note: Skip quality gates during TDD "Red" phase (when test is expected to fail)

**c) Update Plan File (non-skippable — do this before starting the next task):**
- Mark the completed task as done by changing `- [ ]` to `- [x]`
- If you took the AMEND path of the Deviation Protocol, the new `[AMENDMENT NNNNNN]` sub-tasks and their matching Amendment Log entries must already be reflected here
- Preserve all plan metadata (FACTS scores, sections, etc.) and all original task text
- Do not modify other content in the plan file

### 5. Quality Gates & Failure Classification

Run appropriate project commands: build → lint → test

**Failure Classification:**
- **Minor**: Single test failure, fixable in current session - attempt a fix at most twice; if it still fails after two attempts, escalate to Major (stop and report). Do not rabbit-hole into open-ended ad-hoc fixes
- **Major**: Multiple test failures, build breaks, lint errors requiring rework - stop and report to user
- **Critical**: 3+ consecutive major failures, fundamental design flaw, security issue - stop and output postmortem to user

**On Failure:**
- Stop execution immediately
- Report complete error output
- Do NOT mark task as complete
- Do NOT proceed to next task

**Postmortem Output (Critical Failures):**
When catastrophic failure occurs, output to user:
- Failed task and phase context
- Complete error details and system state
- Root cause analysis
- Recommended solutions and recovery paths

### 6. Deviation Protocol (when reality diverges from the plan)

Use this whenever a task is harder than planned, blocked, requires steps not in the plan, the plan appears wrong or incomplete, or you feel tempted to do ad-hoc work. This is distinct from a quality-gate failure: it covers any divergence from the written checklist.

1. **STOP.** Do not improvise changes that aren't on the checklist.
2. **Classify the deviation:**
   - **Small and clearly in-scope** (the intent is unchanged; you just need extra atomic steps): take the AMEND path below, then implement.
   - **Changes scope or approach, introduces a new design decision, or is ambiguous:** STOP and return to the user with the deviation and a proposed plan change. Do NOT proceed until resolved. This applies even in All Tasks mode.
3. **AMEND path** (keep the original plan effectively immutable — amendments must be painfully obvious and traceable):
   - Do NOT modify any original task text. Add new tasks only.
   - Assign each amendment a unique ID of the form `AMENDMENT NNNNNN`, zero-padded to 6 digits and sequential within this plan file. The next ID is one greater than the highest ID already present in the `## Amendment Log` (start at `000001` if there are none).
   - Insert each new task directly beneath the original task that prompted it, indented one level, prefixed with `[AMENDMENT NNNNNN]`. Example:
     ```
     - [x] Edit: Implement basic Feature class
       - [ ] [AMENDMENT 000001] Add null-guard for empty config
     ```
   - Append a matching entry to an `## Amendment Log` section at the end of the plan file (create the section if it doesn't exist), reusing the SAME ID so the inline task and the log entry are linked. The timestamp is local time in 12-hour am/pm format (`YYYY-MM-DD HH:MM AM/PM`). Format:
     ```
     ## Amendment Log
     - [AMENDMENT 000001] Date: 2026-06-22 02:05 PM, Triggering task: "Edit: Implement basic Feature class", Reason: constructor NPEs on missing config, Added: null-guard for empty config
     ```
   - Each amendment gets its own incrementing ID, so even when several occur in the same day or session, every inline `[AMENDMENT NNNNNN]` maps to exactly one log entry.
   - Then implement the new tasks one at a time, marking each `[x]` like any other task.
4. **Never continue working off-checklist.** If the work isn't represented by a task, either add it via the AMEND path or stop via the ask path. There is no third option.

### 7. Reporting

**After Single Task (default mode):**
Provide:
- Summary of what was implemented
- Which task was completed
- Results of all quality checks (tests, build, lint)
- Any issues or considerations
- Updated plan file status

**After All Tasks (all mode):**
Provide:
- Comprehensive summary of all tasks completed
- Any tasks that could not be completed and why
- Overall quality check results
- Final plan file status
- Recommendations for next steps

## Special Considerations

- **Parallel Tasks:** Tasks marked with `[P]` can run concurrently if they affect different files with no shared dependencies
- **Phase Boundaries:** Complete all tasks in a phase before starting next phase
- **Task Dependencies:** If a task depends on another unchecked task, implement dependencies first or report the blocker
- **Ambiguous Tasks:** If a task is unclear in a way that affects the approach or outcome, STOP and ask the user via AskUserQuestion rather than assuming (this is the ask path of the Deviation Protocol). Only proceed on an assumption for trivial, low-risk ambiguities, and record the assumption in the report
- **Failed Checks:** Never mark a task complete if quality gates fail
- **File Not Found:** If the plan file doesn't exist, report error clearly
- **No Tasks:** If all tasks are complete, report this and take no action

## Implementation Strategy

### For Single Task Mode:
1. Read and parse plan file
2. Identify the first unchecked task in current phase
3. Gather relevant context
4. Implement the task — staying strictly on-checklist. If the work diverges from the plan, apply the Deviation Protocol (amend or stop-and-ask) before continuing
5. Run quality gates (build → lint → test)
6. Update plan file (mark `[x]`; reflect any amendments) — non-skippable
7. Report to user and STOP

### For All Tasks Mode:
1. Read and parse plan file
2. Get list of all unchecked tasks
3. For each unchecked task:
   a. Gather context
   b. Implement task — staying strictly on-checklist
   c. If the work diverges from the plan: apply the Deviation Protocol. Small in-scope gaps → amend the plan and continue; scope/approach/ambiguous changes → STOP and return to the user even in this mode
   d. Run quality gates
   e. If gates fail: classify failure, apply appropriate handling
   f. Update plan file (mark `[x]`; reflect any amendments) — non-skippable
   g. Continue to next task (respecting phase boundaries)
4. Provide comprehensive final report

Whenever you STOP (deviation or failure), the report must state the current plan state, which task is in progress, and any amendments made.

Begin implementation now based on the provided arguments.
