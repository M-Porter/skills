---
name: validate-research
description: Validate research document against FAR (Factual, Actionable, Relevant) rubric
allowed-tools: Read
argument-hint: "[research.md file]"
---

# Validate Research Against FAR Scale

Evaluate the provided research document against the FAR Scale rubric to determine if it meets the quality criteria required to proceed from the Research phase to the Plan phase.

## Variables

RESEARCH_FILE = $ARGUMENTS

## Gather Context

- Read the research document to validate at RESEARCH_FILE using the Read tool. If it is missing, unreadable, or empty, STOP and report the error — do not fabricate scores.
- Use the FAR Rubric embedded at the bottom of this file as the scoring reference.

## Task

You are a Research Agent evaluating research findings against the FAR Scale validation criteria. Your role is to:

1. **Analyze the Research Document**: Review the provided research.md file for:
   - Evidence quality (code references, traces, tests, reproduction steps)
   - Implementation readiness (concrete next steps, clear ownership, actionable plans)
   - Problem alignment (relevance to ticket/story, impact on acceptance criteria)

2. **Score Each FAR Dimension**: Using the rubric scoring scale (0-5), evaluate:

   **Factual (F)**: "Is this evidenced in the code/system?"
   - Look for: deterministic repro, code references, failing tests, traces, commit history
   - Strong evidence: >= 4 (corroborated or strongly verified)
   - Threshold: Must be >= 4 to pass

   **Actionable (A)**: "Can I move this forward now?"
   - Look for: concrete next steps, clear ownership, low-friction plan, specific files/functions
   - Implementation ready: >= 3 (concrete next step exists)
   - Threshold: Must be >= 3 to pass

   **Relevant (R)**: "Does it matter to this ticket/story now?"
   - Look for: blocks acceptance criteria, affects current sprint, customer impact
   - On-theme: >= 3 (within component/surface, affects acceptance criteria)
   - Threshold: Must be >= 3 to pass

3. **Calculate Mean Score**:
   - Mean = (F + A + R) / 3
   - Calculate to 2 decimal places (no additional rounding)
   - Threshold: Must be >= 4.00 to pass

4. **Determine Pass/Fail Status**:
   - **PASS** if ALL criteria met:
     - F >= 4
     - A >= 3
     - R >= 3
     - Mean >= 4.00
   - **FAIL** if ANY criterion not met

5. **Provide Recommendations** (if FAIL):
   - Identify which dimension(s) fell short
   - Cite specific gaps in the research document
   - Recommend concrete improvements to reach pass criteria
   - Reference rubric examples and scoring cues
   - Note: FAR is for research validation; FACTS Scale is used for plan validation (different rubrics)

## Output Format

Return your evaluation to the user in this format:

```
=== FAR SCALE VALIDATION ===

SCORES:
F: [score]  A: [score]  R: [score]  Mean: [X.XX]  --> [PASS/FAIL]

STATUS: [PASS/FAIL]

ANALYSIS:

Factual (F = [score]):
[Justify score with specific evidence from research document]

Actionable (A = [score]):
[Justify score with specific evidence from research document]

Relevant (R = [score]):
[Justify score with specific evidence from research document]

[If PASS:]
VERDICT: Research meets all FAR criteria. Ready to proceed to Plan phase.

NEXT STEP: Use this validated research.md as input to /plan command.

[If FAIL:]
VERDICT: Research does not meet FAR criteria.

FAILURE CLASSIFICATION:
- Minor (3.5-3.9): Additional targeted research needed
- Major (2.0-3.4): Restart Research phase for comprehensive investigation
- Critical (<2.0): Problem may be ill-defined or out of scope

RECOMMENDATIONS TO IMPROVE:
- [Specific recommendation 1 with rubric reference]
- [Specific recommendation 2 with rubric reference]
- [etc.]

NEXT STEP: Address recommendations and restart Research phase if needed.
```

## Important Guidelines

- **Be objective**: Base scores strictly on evidence present in the research document
- **Cite specifics**: Reference exact sections, code references, or gaps in the research
- **Apply rubric rigorously**: Use the scoring cues and examples from the FAR Scale
- **Don't create documents**: Only return evaluation to the user (do not write files)
- **Calculate precisely**: Mean score to exactly 2 decimal places
- **Be constructive**: If failing, provide actionable path to improvement
- **Note on rubrics**: FAR Scale validates research quality; FACTS Scale validates plan quality (used in /validate-plan)

## Failure Severity Guidelines

**Minor Failure (Mean 3.5-3.9):**
- Research is close to passing
- Additional targeted research in specific areas
- Quick iteration likely sufficient

**Major Failure (Mean 2.0-3.4):**
- Significant gaps in research depth or evidence
- Restart Research phase with clearer focus
- May need different research approach

**Critical Failure (Mean <2.0):**
- Fundamental issues with problem definition or relevance
- Consult with stakeholders on problem scope
- Problem may be out of scope or ill-defined

Begin your validation now.

## FAR Rubric

The FAR Scale validates Research phase outputs by measuring three critical dimensions of code-focused investigation. Research findings must achieve specific pass criteria across all dimensions to proceed to the Plan phase.

### Pass Criteria
- **Factual (F)**: >= 4 (minimum threshold for evidence quality)
- **Actionable (A)**: >= 3 (minimum threshold for implementation readiness)
- **Relevant (R)**: >= 3 (minimum threshold for problem alignment)
- **Mean Score**: >= 4.00 (overall quality threshold)
- **Precision**: All scores calculated to 2 decimal places (no additional rounding)
- **Mean Calculation**: Arithmetic average of F, A, R dimensions

### Factual — "Is this evidenced in the code/system?"

**0 — Fabricated**
- Contradicts code/architecture; no artifacts; synthetic/edited logs

**1 — Rumor**
- Hearsay in chat/issue; no repro, logs, or code references

**2 — Single-source, weak provenance**
- One screenshot/log snippet or lone comment; indirect evidence; no deterministic repro

**3 — Provisionally credible**
- Partial/occasional repro; stack trace/module matches; one failing test locally or clear call path hypothesis

**4 — Corroborated**
- Deterministic repro; multiple environments/users; call graph/commit history aligns; added failing test or trace confirms

**5 — Strongly verified**
- Minimal repro + automated failing test; root-cause lines identified; bisected to commit/flag/config; owner review concurs

**Scoring cues:**
- Prefer source/tests/CI and traces over docs or anecdotes
- Deterministic repro + code reference is >= 4
- Bisect + failing test typically = 5

### Actionable — "Can I move this forward now?"

**0 — No action possible**
- No repro, no hypothesis, no access

**1 — Vague/long-term only**
- Needs large refactor/org changes; unclear ownership or env access

**2 — Directional, heavy lift**
- Hypothesis exists; requires env bootstrap, data seeding, or harness work before testing

**3 — Concrete next step exists**
- Specific file/function to probe; add logs/guards; author a failing test or reproduce locally this week

**4 — Clear, low-friction plan**
- Stepwise fix plan; owner known; small PR/config change; risk noted; validation path defined

**5 — Immediate, high-leverage, within control**
- One-liner or flag flip; failing test guides fix; can open PR < 60 min; success measurable via test/metric/CI

**Scoring cues:**
- If you can start today with known steps/tools, it's >= 3
- Small diff + clear validation pushes to 4-5

### Relevant — "Does it matter to this ticket/story now?"

**0 — Off-topic**
- Unrelated subsystem or external product; no impact on acceptance criteria

**1 — Tangential**
- Neighboring area; theoretical risk, low priority

**2 — Adjacent/general interest**
- Related subsystem behavior but not blocking success criteria

**3 — On-theme**
- Within the component/surface; affects acceptance criteria or tests, but not blocking today

**4 — Core + timely**
- Blocks ticket or degrades SLA/CI reliability; within team ownership; aligned to current sprint

**5 — Bullseye for now**
- Directly unblocks critical path or prod incident; customer impact measurable; you have unique context/assets

**Scoring cues:**
- If it blocks the story/bug now, score >= 4
- Customer/SLA impact and clear ownership push to 5

### Quick Examples

**Factual 5**: git bisect isolates commit; failing unit test reproduces; stack trace matches call path

**Actionable 5**: Add null check + test; PR in < 30 min; CI turns green

**Relevant 5**: Fix required to meet current story's acceptance criteria

### FAR Scoring Format

```
F: [score]  A: [score]  R: [score]  Mean: [X.XX]  --> [PASS/FAIL]
```

**Pass Example:**
```
F: 4  A: 4  R: 4  Mean: 4.00  --> PASS
```

**Fail Example:**
```
F: 4  A: 3  R: 4  Mean: 3.67  --> FAIL (Mean < 4.00)  (Restart)
```
