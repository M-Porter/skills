---
name: research
description: Research a problem using codebase and web search agents, compile findings into comprehensive research document
allowed-tools: Agent, Read, Write
argument-hint: "[Problem statement]"
---

# Research Problem Statement

Launch parallel research agents to investigate the problem statement from both codebase and web perspectives, then compile findings into a comprehensive research document following RPI Strategy Research phase standards.

## Variables

PROBLEM_STATEMENT = $ARGUMENTS
SHORT_NAME = kebab-case version of problem statement (e.g., "Fix login authentication bug" → "fix-login-authentication-bug") prefixed by the current date in YYYY-MM-DD (e.g. 2026-06-22) form.
OUTPUT_DIR = ./thoughts/SHORT_NAME/
OUTPUT_FILE = ./thoughts/SHORT_NAME/research.md

## Task Overview

This command executes the Research phase of the RPI Strategy by:

1. **Parallel Codebase Research**: Launch three specialized codebase agents simultaneously
   - @agent-codebase-locator: Find WHERE relevant code exists
   - @agent-codebase-analyzer: Understand HOW the code works
   - @agent-codebase-pattern-finder: Discover similar implementations and patterns

2. **Parallel Web Research**: Launch web search agent simultaneously
   - @agent-web-search-researcher: Find Factual, Actionable, and Relevant external information

3. **Synthesis**: Compile all findings into a structured research document
   - Follow RPI Strategy Research phase output format
   - Include FAR Scale validation
   - Output to ./thoughts/[short-name]/research.md

## Step 1: Launch All Research Agents in Parallel

Launch all four agents in a SINGLE message using multiple Agent tool calls. Run them in the FOREGROUND. Do NOT set `run_in_background` on any call. Each Agent call returns the sub-agent's final results as its tool result; you MUST wait for all four tool results to come back before doing anything else. Do not begin synthesis or write any file in the same turn that you launch the agents.

### Codebase Locator Agent
**Agent**: codebase-locator
**Task**: "Locate all files, directories, and components relevant to: {PROBLEM_STATEMENT}. Focus on:
- Implementation files (core logic)
- Test files (unit, integration, e2e)
- Configuration files
- Type definitions/interfaces
- Related documentation
- Similar features or patterns

Return structured results grouped by purpose with full file paths.

IMPORTANT: Return your findings as your final message ONLY. Do NOT create, write, or edit any files. Do NOT create a research document or any output file. You are a research sub-agent; the coordinator is the sole author of the output document."

### Codebase Analyzer Agent
**Agent**: codebase-analyzer
**Task**: "Analyze the implementation details for: {PROBLEM_STATEMENT}. Focus on:
- Entry points and public interfaces
- Core implementation logic
- Data flow and transformations
- State management
- Error handling
- Configuration usage
- Key architectural patterns

Provide detailed analysis with file:line references for all claims.

IMPORTANT: Return your findings as your final message ONLY. Do NOT create, write, or edit any files. Do NOT create a research document or any output file. You are a research sub-agent; the coordinator is the sole author of the output document."

### Codebase Pattern Finder Agent
**Agent**: codebase-pattern-finder
**Task**: "Find existing code patterns and examples related to: {PROBLEM_STATEMENT}. Focus on:
- Similar implementations in the codebase
- Reusable patterns and conventions
- Test patterns for similar features
- Integration patterns
- Best practices already in use

Provide concrete code examples with file:line references.

IMPORTANT: Return your findings as your final message ONLY. Do NOT create, write, or edit any files. Do NOT create a research document or any output file. You are a research sub-agent; the coordinator is the sole author of the output document."

### Web Search Researcher Agent
**Agent**: web-search-researcher
**Task**: "Research external information about: {PROBLEM_STATEMENT}. Your findings will be assessed against the FAR Scale (Factual, Actionable, Relevant). Before researching, read the FAR rubric in this plugin's validate-research skill at `${CLAUDE_PLUGIN_ROOT}/skills/validate-research/SKILL.md` (the '## FAR Rubric' section) and use its dimensions, 0–5 criteria, and pass thresholds to steer what you gather and how you evaluate sources. Do not rely on a remembered summary of the scale — read it from that file.

Structure findings with:
- Source URLs and publication dates
- Relevance assessment for each finding
- Key quotes and technical details
- FAR score for overall research quality

IMPORTANT: Return your findings as your final message ONLY. Do NOT create, write, or edit any files. Do NOT create a research document or any output file. You are a research sub-agent; the coordinator is the sole author of the output document."

## Step 2: Confirmation Gate (do not skip)

Before writing anything, confirm you have received the returned result text from ALL FOUR agents. If any agent's result is missing, has not returned, or errored, STOP — do not create the output directory and do not write any file. Either re-launch the missing agent or report the failure. You may proceed to synthesis and write the research document ONLY after all four results are in hand.

## Step 3: Synthesize Findings into Research Document

Once all agents complete, compile their findings into a comprehensive research document following the RPI Strategy Research phase format.

Every section must be grounded in the specific agent result(s) it summarizes. Build the document from the text the agents actually returned — do not fabricate findings, file paths, or sources that no agent reported, and do not substitute your own prior knowledge for agent output. If a needed detail was not returned by any agent, note it as a gap rather than inventing it.

### Research Document Structure

Create `./thoughts/SHORT_NAME/research.md` with the following mandatory sections:

```markdown
# [Problem Statement] Research

## Problem Context
- Restated, clarified problem statement
- Business/functional intent
- Current vs desired behavior
- Constraints (time, performance, compliance, environment)

[Synthesize from all agent findings to provide comprehensive context]

## Affected Files
```
[List files from codebase-locator findings]
[One reference per line using code reference syntax]
[path/to/file.ext:LINE or path/to/file.ext:START-END]
```

[Provide explanatory prose as bullet points beneath the code block]

## Code Examples
[Include minimal, relevant snippets from codebase-analyzer and codebase-pattern-finder]
[Show analogous patterns already in the codebase]
[Use triple backtick code fences, label language]

## External Research Findings
[Synthesize web-search-researcher findings]
[Include key insights, documentation references, best practices]
[Cite sources with URLs]

## FAR Scale Output

[Score the synthesized research against the FAR rubric defined in this plugin's validate-research skill at `${CLAUDE_PLUGIN_ROOT}/skills/validate-research/SKILL.md` (the "## FAR Rubric" section) — use those 0–5 criteria and pass thresholds rather than relying on memory or any other installed plugin. Do not reproduce the full rubric here. Formal validation happens via the `/rpi:validate-research` command, which scores against that same rubric.]

### Factual Score: [1-5]
[Evidence-based assessment with verifiable code/web references]

### Actionable Score: [1-5]
[Clear next steps identified from research]

### Relevant Score: [1-5]
[Solution addresses core problem and constraints]

### Mean: [calculated]
### Result: [PASS if mean ≥4.0, FAIL otherwise]

[If FAIL: Document what additional research is needed]

## Testing Strategy
Early hypotheses about:
- Unit test touchpoints [from codebase analysis]
- Integration/contract surfaces
- Observability (logs, metrics, traces)
- Repro steps if defect
- Risk areas needing characterization tests

## Potential Design Pattern Recommendations
[From codebase-pattern-finder and web research]
[Candidate patterns with rationale and internal exemplars]

## Assumptions
[Enumerated, falsifiable statements]
[Each should be testable or confirmable later]

## Out of Scope
[Explicit exclusions to prevent scope creep]
[Subsystems, refactors, deferred concerns]
```

## Step 4: Write Research Document

You (the coordinator) are the SOLE author of the output file. Write it exactly once, at the very end, only after the Step 2 gate has passed.

1. Write the synthesized research document to `./thoughts/SHORT_NAME/research.md`. The Write tool creates parent directories automatically, so no separate `mkdir` step is needed.
2. Report completion with the file path.

## Quality Gates

Before completing, verify:
- All four agent results were received and read before writing (Step 2 gate passed)
- Exactly one output file exists; no sub-agent created a competing document
- All four agents completed successfully
- Every code reference resolves (exists + line within bounds)
- No snippet exceeds ~40 lines unless justified
- All assumptions have validation steps or deferral notes
- FAR table present with numeric values + computed mean
- Output file created at correct path
- Research document follows mandatory section structure

## Expected Outcome

A comprehensive research document at `./thoughts/SHORT_NAME/research.md` that:
- Combines codebase analysis with external research
- Provides validated, FAR-qualified findings
- Follows RPI Strategy Research phase standards
- Enables confident progression to Plan phase

## Notes

- The short-name should be derived from the problem statement using kebab-case
- Keep it concise but descriptive (e.g., "user-authentication-timeout" not "fix-the-bug-where-users")
- All agent tasks run in parallel for efficiency
- Synthesis should integrate findings, not just concatenate them
- Apply critical thinking when assessing FAR scores; the full FAR scoring scale lives in `${CLAUDE_PLUGIN_ROOT}/skills/validate-research/SKILL.md`
