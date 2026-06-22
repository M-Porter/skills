---
name: plan
description: Build a multi-phase implementation plan with atomic task checklists from research file
allowed-tools: Agent, Read, Write, AskUserQuestion
argument-hint: "[research.md file]"
---

# Plan Implementation from Research

Transform research findings into actionable, atomic task plans that follow TDD principles and the RPI Strategy methodology.

## Variables

RESEARCH_FILE = $ARGUMENTS // Path to research.md file

## Validation

- Ensure RESEARCH_FILE exists and is readable. If it is missing or unreadable, STOP and report the error — do not build or write a plan from a missing input.
- Extract directory path from RESEARCH_FILE for output location

## Commit Strategy (ask up front)

Before analyzing the research file or building the plan, ask the user whether the plan should include commit checkpoints. Call AskUserQuestion (header e.g. "Commits") with a question like "Should the plan include commit tasks at logical change boundaries?":
- First option: "Yes, add commit checkpoints"
- Second option: "No commits in plan"

Record the answer as COMMIT_CHECKPOINTS (true/false) and apply it when building the plan in Step 2. If true, the plan must interleave commit tasks at logical boundaries per the "Commit Checkpoints" guidance below. If false, do not add any commit tasks.

## Step 1: Analyze Research File

Use the **codebase-analyzer** agent to deeply analyze the research file. Run it in the FOREGROUND; do NOT set `run_in_background`. Wait for the analyzer's returned result before proceeding to Step 2 — do not begin building the plan in the same turn that you launch the agent.

**Agent**: codebase-analyzer
**Task**: Analyze the research file at RESEARCH_FILE and extract:
- Key decisions and conclusions
- Actionable recommendations
- Technical specifications and constraints
- Implementation requirements
- Dependencies and integration points
- Testing requirements
- Edge cases and gotchas

Focus on identifying concrete, implementable items that can be translated into atomic tasks.

IMPORTANT: Return your analysis as your final message ONLY. Do NOT create, write, or edit any files. Do NOT create a plan or any output file. You are an analysis sub-agent; the coordinator is the sole author of plan.md.

## Step 2: Build Implementation Plan

Build the plan from the analyzer's returned output. Reading the research file directly may supplement the analysis but must not replace it — the codebase-analyzer call is not decorative. Do not invent decisions or requirements the analysis and research did not contain; note gaps instead. Using insights from the analysis, create a comprehensive implementation plan with these requirements:

### Plan Structure

1. **Overview Section** (in every plan file)
   - Brief summary of what will be implemented
   - Link back to the research file
   - Key decisions from research
   - Overall approach and strategy

2. **Phase Organization**
   - Each phase should have ≤10 atomic tasks
   - If more than 10 tasks needed, break into additional phases
   - Phases should have clear, logical boundaries
   - Each phase should be independently accomplishable

3. **Task Format** (atomic tasks using `- [ ]` checklist format)
   - Each task must be atomic: a single CLI command, file creation, file edit, test run, etc.
   - Start with TDD workflow: write test first (red), implement (green), refactor
   - Format: `- [ ] Action: specific description`
   - Examples:
     - `- [ ] Create test file: tests/unit/rate_limiter_test.py`
     - `- [ ] Write failing test: test_rate_limit_exceeded_returns_429`
     - `- [ ] Run tests: pytest tests/unit/rate_limiter_test.py (expect failure)`
     - `- [ ] Create file: src/middleware/rate_limiter.py`
     - `- [ ] Edit: Add RateLimiter class with check_limit() method`
     - `- [ ] Run tests: pytest tests/unit/rate_limiter_test.py (expect pass)`
     - `- [ ] Refactor: Extract sliding window logic to separate function`
     - `- [ ] Run command: npm install express-rate-limit`

4. **Context Per Phase**
   - Include just enough context to accomplish the phase
   - Reference relevant code files or documentation
   - Note key constraints or requirements
   - Highlight integration points or dependencies
   - Include test strategy for the phase

5. **TDD Workflow Priority**
   - Each feature should follow red/green/refactor cycle
   - Write test first (red)
   - Implement minimal code to pass (green)
   - Refactor for quality (refactor)
   - Include test execution steps explicitly

6. **Code References**
   - List all files that will be created or modified
   - Use fenced code block with file paths

7. **Testing Plan**
   - Overall testing strategy for the implementation
   - Test coverage expectations
   - Integration test requirements

8. **Dependencies & Sequencing**
   - External dependencies or packages needed
   - Phase execution order and dependencies
   - Parallel execution opportunities (mark with `[P]`)

9. **Risk Mitigation**
   - Potential blockers or challenges
   - Mitigation strategies
   - Fallback approaches

10. **Rollback Strategy**
    - How to undo changes if implementation fails
    - Database migration rollback if applicable
    - Feature flag approach if relevant

11. **Optional: Abbreviated FACTS Self-Check**
    - An optional, informal self-assessment to catch obvious gaps before formal validation. This is NOT formal scoring — do not compute a mean or a pass/fail verdict here.
    - Before self-checking, read the FACTS rubric in this plugin's validate-plan skill at `${CLAUDE_PLUGIN_ROOT}/skills/validate-plan/SKILL.md` (the "## FACTS Rubric" section) and sanity-check the plan against the dimensions, criteria, and scoring cues defined there. Do not rely on a remembered summary of the scale — read it from that file.
    - Note: Formal FACTS validation happens via the `/rpi:validate-plan` command (this plugin's validate-plan skill), which scores the plan against that same rubric.

12. **Commit Checkpoints** (include ONLY if COMMIT_CHECKPOINTS is true)
    - Interleave atomic commit tasks at logical change boundaries — after each coherent, self-contained unit of work (typically the green step of a red/green/refactor cycle, or the completion of a small related group of edits)
    - Keep commits SMALL and focused: one logical change per commit. Never bundle a whole phase into a single mega-commit, and never defer all commits to one commit at the end
    - Format: `- [ ] Commit: <concise message>`
    - Commit messages must be concise and describe the change. Commit only — do NOT push, and do NOT add attribution or co-author trailers
    - If COMMIT_CHECKPOINTS is false, do not add any commit tasks

### Output Location

Create single file `plan.md` in same directory as RESEARCH_FILE. You (the coordinator) are the sole author of `plan.md`; write it exactly once, after the analyzer result is in hand. The Write tool creates the directory if needed, so no separate `mkdir` step is required.

The plan should use H2 headings (##) to organize phases within the single file.

### Plan Content Guidelines

- **Be specific**: No vague tasks like "implement feature" - break it down
- **Be atomic**: Each task should be one clear action
- **Be testable**: Include verification/test steps
- **Be ordered**: Tasks should flow logically, TDD workflow
- **Include commands**: Show exact CLI commands where applicable
- **Reference files**: Include file paths for edits/creations
- **Note dependencies**: Make inter-task dependencies clear

## Example Plan Structure

```markdown
# Implementation Plan: [Feature Name]

**Research**: [Link to research.md]
**Created**: [Date]

## Overview

[Brief summary of implementation]

### Key Decisions
- [Decision 1 from research]
- [Decision 2 from research]

### Approach
[Overall implementation strategy]

---

## Phase 1: [Phase Name]

**Goal**: [What this phase accomplishes]

**Context**:
- [Relevant constraint or requirement]
- [Key file or integration point]

**Tasks**:
- [ ] Create test file: tests/feature_test.py
- [ ] Write failing test: test_basic_functionality
- [ ] Run tests: pytest tests/feature_test.py (expect failure)
- [ ] Create file: src/feature.py
- [ ] Edit: Implement basic Feature class
- [ ] Run tests: pytest tests/feature_test.py (expect pass)
- [ ] Refactor: Extract helper methods
- [ ] Commit: add Feature class with basic functionality (only if commit checkpoints enabled)
- [ ] [P] Update documentation (can run parallel with Phase 2 setup)

---

## Phase 2: [Phase Name]

[Continue pattern...]

---

## Code References

```
Files to be created:
- tests/feature_test.py
- src/feature.py

Files to be modified:
- src/index.js (add feature import)
- README.md (update documentation)
```

## Testing Plan

- Unit tests for all Feature class methods
- Integration tests for API endpoints
- Target: 90% code coverage

## Dependencies & Sequencing

- No external dependencies required
- Phase 1 must complete before Phase 2
- Documentation updates can run in parallel (marked with `[P]`)

## Risk Mitigation

- **Risk**: Existing API might conflict with new feature
- **Mitigation**: Use feature flag for gradual rollout

## Rollback Strategy

- Remove feature flag to disable
- Revert migrations: `npm run migrate:rollback`

## FACTS Self-Check (Optional)

Quick assessment before formal validation, against the FACTS rubric in `${CLAUDE_PLUGIN_ROOT}/skills/validate-plan/SKILL.md` (read it rather than relying on a remembered summary).

Note: Run `/rpi:validate-plan plan.md` for formal FACTS validation
```

## Important Guidelines

- **Atomic tasks only**: No compound tasks or vague descriptions
- **TDD first**: Prioritize test-driven development workflow
- **10 task limit**: Break phases if exceeding 10 tasks per phase
- **Clear boundaries**: Each phase should be self-contained where possible
- **Include verification**: Every implementation step should have corresponding test/verification
- **Mark parallel tasks**: Use `[P]` prefix for tasks that can run in parallel with others
- **Be practical**: Tasks should map to actual commands, edits, or file operations
- **Preserve context**: Link back to research, note key decisions
- **Enable execution**: Someone should be able to follow the plan step-by-step
- **Single file**: Always output to single `plan.md` with H2 phase sections
- **Validation**: Include optional FACTS self-check; formal validation via `/rpi:validate-plan`

## Output Summary

After creating plan.md, provide a summary:
- Number of phases created
- File path of created plan
- Total number of atomic tasks
- Brief overview of implementation approach
- Key insights from research analysis
- Reminder to run `/rpi:validate-plan plan.md` for formal FACTS validation
