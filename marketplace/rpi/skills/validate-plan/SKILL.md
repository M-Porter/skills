---
name: validate-plan
description: Validate a plan against the FACTS rubric and return score, pass/fail status, and recommendations
allowed-tools: Read
argument-hint: "[plan.md file]"
---

## Variables

PLAN_FILE = $ARGUMENTS

## Gather Context
- Read the plan file at PLAN_FILE using the Read tool. If it is missing, unreadable, or empty, STOP and report the error — do not fabricate scores.
- Use the FACTS Rubric embedded at the bottom of this file as the scoring reference.

# Validate Plan Against FACTS Rubric

You are tasked with evaluating a technical implementation plan against the FACTS Scale rubric to determine if it meets quality standards for proceeding to the Implement phase.

## Your Task

1. **Read and Understand the Plan**: Review all tasks in the provided plan file to understand the implementation approach, task breakdown, and execution strategy.

2. **Read and Understand the FACTS Rubric**: Study the FACTS Scale scoring criteria from the FACTS Rubric at the bottom of this file, including:
   - **F**easibility: Can this be implemented with available resources? (0-5)
   - **A**tomicity: Is this task focused on a single responsibility? (0-5)
   - **C**larity: Is the execution order and dependencies clear? (0-5)
   - **T**estability: Can completion be verified? (0-5)
   - **S**ize: Is the task appropriately scoped? (0-5)

3. **Evaluate Each Task**: For each task in the plan, assign a score (0-5) for each FACTS dimension based on the rubric criteria.

4. **Calculate Mean Score**:
   - Calculate the arithmetic mean of all five dimensions (F, A, C, T, S)
   - Round to exactly 2 decimal places
   - Pass threshold: Mean >= 3.00

5. **Determine Pass/Fail Status**:
   - **PASS**: Mean score >= 3.00 AND all individual scores are reasonable
   - **FAIL**: Mean score < 3.00 OR any critical dimension fails (e.g., F < 3 indicates infeasible tasks)

6. **Provide Structured Output**:

### For PASS Status:
```
FACTS VALIDATION RESULT
=======================

Overall Assessment: PASS ✓

FACTS Scores:
F: [score]  A: [score]  C: [score]  T: [score]  S: [score]  Mean: [X.XX]  --> PASS

Summary:
[Brief explanation of why the plan passes, highlighting strengths]

The plan meets quality standards and is ready to proceed to the Implement phase.
```

### For FAIL Status:
```
FACTS VALIDATION RESULT
=======================

Overall Assessment: FAIL ✗

FACTS Scores:
F: [score]  A: [score]  C: [score]  T: [score]  S: [score]  Mean: [X.XX]  --> FAIL

Failure Classification:
[MINOR / MAJOR / CRITICAL based on mean score]
- Minor (2.8-2.9): Single iteration task refinement needed
- Major (2.0-2.7): Return to Research phase for problem decomposition
- Critical (<2.0): Leadership escalation required

Failure Reason:
[Explain why the plan failed - mean below 3.00 or specific dimension issues]

Recommendations to Improve:

1. **[Dimension Name]** (Current: [score], Target: >= 3)
   - Issue: [Specific problem identified]
   - Recommendation: [Concrete action to improve]

2. **[Dimension Name]** (Current: [score], Target: >= 3)
   - Issue: [Specific problem identified]
   - Recommendation: [Concrete action to improve]

[Continue for all failing dimensions]

Next Steps:
- **Minor Failure**: Refine task descriptions, adjust estimates, re-validate with /validate-plan
- **Major Failure**: Return to Research phase for missing context or problem decomposition
- **Critical Failure**: Escalate to technical lead, consider problem unfeasible with current approach
```

## Important Guidelines

- **Be Objective**: Score based strictly on the rubric criteria, not personal preferences
- **Be Specific**: Cite specific tasks or sections from the plan when identifying issues
- **Be Constructive**: Frame recommendations as actionable improvements
- **Be Precise**: Calculate mean to exactly 2 decimal places
- **Do NOT Create Files**: Return all output directly to the user - do not create any documents
- **Focus on Task Quality**: Evaluate whether tasks are well-defined, appropriately scoped, and executable

## Failure Severity Guidelines

**Minor Failure (Mean 2.8-2.9):**
- Plan is close to passing
- Single iteration refinement likely sufficient
- Focus on task description clarity and scoping adjustments

**Major Failure (Mean 2.0-2.7):**
- Significant gaps in plan quality
- May need additional research or problem decomposition
- Return to Research phase for enhanced context

**Critical Failure (Mean <2.0):**
- Fundamental issues with feasibility or approach
- Escalate to technical leadership
- Consider problem unfeasible with current approach or resources

The FACTS Scale ensures that plans are executable, maintainable, and set up for successful implementation.

## FACTS Rubric

The FACTS Scale validates Plan phase outputs across five dimensions. Each task in the plan is scored 0-5 per dimension; the plan's mean across F, A, C, T, S must be >= 3.00 to pass.

### Feasibility — "Can this be implemented with available resources, access, and skills?"

**0 — Impossible**: Requires unavailable resources, blocked dependencies, or contradicts stated constraints
**1 — Highly doubtful**: Major unknowns, missing access, or speculative dependencies
**2 — Risky**: Feasible only with significant unproven prerequisites
**3 — Plausible**: Achievable with known tools; only minor unknowns remain
**4 — Solid**: Clear path with available resources; risks identified and mitigated
**5 — Certain**: Trivially achievable with current tools, access, and skills

**Scoring cues:**
- Unresolved external dependency or missing access caps Feasibility at <= 2
- Known tools + clear path is >= 3

### Atomicity — "Is each task focused on a single responsibility?"

**0 — Tangled**: Many unrelated responsibilities bundled into one task
**1 — Broad**: Multiple concerns per task; hard to isolate
**2 — Mixed**: Mostly one concern but with side responsibilities
**3 — Mostly atomic**: Single responsibility with minor coupling
**4 — Atomic**: One clear action/responsibility per task
**5 — Perfectly atomic**: Indivisible single action with no overlap

**Scoring cues:**
- "And"/"then" joining unrelated actions in one task lowers the score
- One verb, one target is >= 4

### Clarity — "Is execution order, dependencies, and intent clear?"

**0 — Opaque**: No order, no dependencies, ambiguous intent
**1 — Vague**: Intent unclear; ordering implicit and confusing
**2 — Partial**: Some steps clear, dependencies under-specified
**3 — Clear enough**: Order and dependencies mostly explicit
**4 — Clear**: Explicit ordering, dependencies, and intent per task
**5 — Unambiguous**: Fully sequenced with dependencies and acceptance criteria noted

**Scoring cues:**
- Implicit ordering or unstated dependencies caps Clarity at <= 2
- Explicit sequence + named dependencies is >= 4

### Testability — "Can completion be objectively verified?"

**0 — Unverifiable**: No way to confirm completion
**1 — Subjective**: Only opinion-based confirmation
**2 — Weak**: Indirect signals; no concrete check
**3 — Verifiable**: A concrete check or test exists per task
**4 — Well-tested**: Explicit test/verification step tied to each task
**5 — Fully verifiable**: Automated test or observable outcome defines done

**Scoring cues:**
- No verification step on an implementation task caps Testability at <= 2
- Explicit test command or observable outcome is >= 4

### Size — "Is each task appropriately scoped (small, completable)?"

**0 — Mega**: Massive multi-day scope crammed into one task
**1 — Oversized**: Spans many files/concerns; not completable in one sitting
**2 — Large**: Bigger than ideal; should be split
**3 — Reasonable**: Completable in a single focused session
**4 — Small**: Tight, single-sitting scope
**5 — Minimal**: One-edit or one-command sized

**Scoring cues:**
- A task touching many files or spanning phases lowers Size
- Single-file, single-sitting scope is >= 4

## FACTS Scoring Format

```
F: [score]  A: [score]  C: [score]  T: [score]  S: [score]  Mean: [X.XX]  --> [PASS/FAIL]
```

**Pass Example:**
```
F: 4  A: 4  C: 3  T: 4  S: 4  Mean: 3.80  --> PASS
```

**Fail Example:**
```
F: 3  A: 2  C: 3  T: 2  S: 3  Mean: 2.60  --> FAIL (Mean < 3.00)
```
