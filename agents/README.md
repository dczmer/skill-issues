# Skill Subagents

This directory contains markdown-based subagent definitions used by various skills. Each subagent handles a specific aspect of skill workflows.

## Subagent Overview

### Feature Implementation Subagents

| Subagent | Purpose | When Used | Parallel |
|----------|---------|-----------|----------|
| [requirements-analyzer](requirements-analyzer.md) | Codebase analysis and implementation planning | Step 7 | No |
| [test-writer](test-writer.md) | Create TDD unit tests | Step 8.2 | No |
| [stub-creator](stub-creator.md) | Create minimal failing stubs | Step 8.4 | No |
| [implement-function](implement-function.md) | Implement function logic | Step 8.7 | No |
| [code-fixer](code-fixer.md) | Fix linter/type checker issues | Step 8.9 | Yes |
| [deliverables-verifier](deliverables-verifier.md) | Verify deliverable categories | Step 9.2 | Yes (5 instances) |
| [review-responder](review-responder.md) | Address PR review comments | Step 11.5 | Yes |

### Bootstrap Subagents

| Subagent | Purpose | When Used | Parallel |
|----------|---------|-----------|----------|
| [bootstrap-stub-creator](bootstrap-stub-creator.md) | Generate multi-language stub files for bootstrapping | Step 4 | Yes (max 5) |

## Usage

Subagents are launched using the `general` agent type with specific prompts based on these definitions. The main skill orchestrates subagent execution, collects results, and presents them to the user at blocking steps.

### Example Invocation

```python
# Launch subagent with context
subagent_prompt = f"""
You are a test-writer. Create comprehensive unit tests following TDD principles.

Context:
- Function Name: {function_name}
- Signature: {signature}
- Purpose: {purpose}

Tasks:
1. Create comprehensive unit tests
2. Include happy paths, edge cases, error conditions
3. Follow project patterns

Return JSON with test_code, coverage_analysis, and confidence.
"""

# Launch and wait for completion
task_result = task(
    subagent_type="general",
    prompt=subagent_prompt
)
```

## Input/Output Format

All subagents accept structured JSON context and return structured JSON results. See individual subagent definitions for specific schemas.

### Common Input Fields

```json
{
  "feature": {
    "name": "Feature Name",
    "sanitized_name": "feature-name"
  },
  "repository": {
    "root_path": "/path/to/repo"
  }
}
```

### Common Output Fields

```json
{
  "confidence": "high|medium|low",
  "notes": "Additional context or recommendations"
}
```

## Checkpoint and Rollback

All subagents operate within a checkpoint system:

1. Checkpoint created before subagent invocation
2. Subagent performs work
3. User reviews at blocking step
4. If rejected: rollback to checkpoint, retry
5. If approved: commit and continue

See [main skill documentation](/skills/feature-implementation/SKILL.md) for checkpoint details.

## Error Handling

If a subagent fails:
1. Log failure context
2. Present options to user
3. Allow retry with main agent, skip, or cancel

## Extending Subagents

To add a new subagent:

1. Create new markdown file in this directory
2. Define purpose, inputs, tasks, and outputs
3. Update this README
4. Add invocation in main SKILL.md
5. Follow existing patterns for consistency
