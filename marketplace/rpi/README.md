# The RPI claude plugin

Taken from https://github.com/patrob/rpi-strategy with some changes to make it better fit my needs.

Available skills:
- `/rpi:research` - Research a problem using codebase and web search agents, compile findings into comprehensive research document.
- `/rpi:plan` - Build a multi-phase implementation plan with atomic task checklists from research file.
- `/rpi:implement` - Implement tasks from a plan file.
- `/rpi:validate-plan` - Validate a plan against the FACTS rubric and return score, pass/fail status, and recommendations.
- `/rpi:validate-research` - Validate research document against FAR rubric and return score, pass/fail status, and recommendations.
