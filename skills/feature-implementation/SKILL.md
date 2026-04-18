---
name: feature-implementation
description: Implements a feature from a GitHub issue specification using TDD approach with subagent delegation via @ mentions. Use when user asks to "implement a feature", "start implementation", or after completing feature-planning.
allowed-tools: "Read,Grep,Glob,Bash,Write,Edit,todowrite,skill,question"
---

## Introduction

This skill implements a feature from a previously created GitHub issue specification using a test-driven development (TDD) approach with specialized subagent delegation for parallel processing and modularity.

The skill reads feature specifications from GitHub issues labeled `feature-plan` and implements them following the structured workflow defined in the issue body, delegating specific tasks to specialized subagents defined in `/agents/`.

### Prerequisites

- A GitHub issue with the `feature-plan` label must exist
- The issue body should contain the structured feature specification
- The `gh` CLI must be installed and authenticated
- Git must be configured for checkpoint creation

### Process Flow

1. **Step 0:** Select feature specification to implement
2. **Step 6:** Create feature branch (with user approval)
3. **Step 7:** Implementation planning (via `requirements-analyzer` subagent)
4. **Step 8:** TDD implementation loop (via `test-writer`, `stub-creator`, `implement-function`, `code-fixer` subagents)
5. **Step 9:** Final verification (via parallel `deliverables-verifier` subagents)
6. **Step 10:** Git operations and PR creation
7. **Step 11:** PR review handling (via parallel `review-responder` subagents)

### Usage

Invoke with: `/feature-implementation [optional feature name]`

If feature name is provided, that specification file will be used directly. Otherwise, you'll be prompted to select from available plans.

---

## Step 0: Select GitHub Issue

### Step 0.1: Check for GitHub Issues

Use `Bash` to list open issues with the `feature-plan` label:

```bash
gh issue list --label feature-plan --state open --limit 20 --json number,title,body
```

Parse the JSON results to extract issue number, title, and body.

### Step 0.2: Handle Results

**If no open issues found:**
1. Inform user: "No open GitHub issues with the 'feature-plan' label found."
2. Suggest: "Run `/feature-planning` first to create a specification"
3. Exit the skill

**If one issue found:**
1. Display issue title and ask: "Implement this feature?"
2. Options: "Yes", "No, select different issue", "Cancel"
3. If "Yes", record the selected issue number and body, then proceed to Step 0.3

**If multiple issues found:**
1. Present list of available issues (showing issue numbers and titles)
2. Use `question` tool to prompt: "Which feature would you like to implement?"
3. Options: List of issue titles with numbers, "Cancel"
4. After selection, record the selected issue number and body, then proceed to Step 0.3

### Step 0.3: Parse Specification

After selecting an issue:
1. Keep track of the issue number and body for later use
2. Extract the feature name from the issue title
3. Derive a sanitized feature name: lowercase, replace spaces with `-`, remove special chars except `[A-Za-z0-9-_]`
4. Parse the issue body to extract all sections (Description, Requirements, Constraints, Verification, Deliverables)

### Step 0.4: Prepare Subagent Context

Create a context document to pass to subagents:

```json
{
  "feature": {
    "name": "Feature Name",
    "sanitized_name": "feature-name",
    "issue_number": 123,
    "issue_body": "full issue body content"
  },
  "repository": {
    "root_path": "/absolute/path/to/repo",
    "reference_files": ["AGENTS.md", "README.md", "pyproject.toml"]
  },
  "session": {
    "timestamp": "ISO8601 timestamp",
    "checkpoint_prefix": "checkpoint"
  }
}
```

Store this context for use throughout the skill.

---

## Step 6: Create Feature Branch

### Step 6.1: Propose Branch Creation

Use `question` tool:

"Ready to create a feature branch. Default name: `feature/FEATURE_NAME`. Proceed?"

Options: "Create with default name", "Specify custom name", "Skip branch creation"

**If custom name:**
1. Ask for branch name
2. Validate (no spaces, valid chars)

**If skip:** Note and proceed to Step 7

### Step 6.2: Create Branch

```bash
git checkout -b <branch_name>
```

---

## Step 7: Implementation Planning

### Step 7.1: Invoke Requirements Analyzer

Use `@` mention to invoke the requirements-analyzer subagent:

```
@requirements-analyzer Analyze this feature:

Feature: [feature_name]
Sanitized: [sanitized_name]
Issue Body:
[issue_body]

Repository Root: [root_path]

Return the structured JSON output as specified in your definition.
```

**Wait for completion and parse the JSON response.**

### Step 7.2: Present Implementation Plan (BLOCKING STEP)

Parse and present:

```markdown
## Implementation Plan for [FEATURE_NAME]

### Modules:
- [module_name]: [function signatures]

### Implementation Order:
1. [module.function]

### Patterns:
- Test Framework: [framework]
- Style: [notes]
```

Use `question`:
- "Does this plan look correct?"
- Options: "Looks good, proceed", "Modify plan", "Re-analyze", "Cancel"

**If modify:** Collect feedback, relaunch subagent, return to Step 7.1

**If approved:** Store plan, proceed to Step 8

---

## Step 8: TDD Implementation Loop

For each function in implementation order:

### Step 8.1: Create Checkpoint

```bash
git add -A
git commit -m "checkpoint: before [module].[function]" --allow-empty
git tag checkpoint/before-[module]-[function]-$(date +%s)
```

### Step 8.2: Invoke Test Writer

Use `@` mention to invoke the test-writer subagent:

```
@test-writer Create comprehensive tests for:

Function: [function_name]
Signature: [signature]
Purpose: [purpose]
Module: [module]
Requirements: [relevant_requirements]
Patterns: [patterns_observed]
Test Framework: [framework]
Reference Tests: [test_files]

Return the structured JSON output.
```

**Wait for completion and parse JSON.**

### Step 8.3: Write Tests

Write test code to the specified file path.

### Step 8.4: Invoke Stub Creator

Use `@` mention to invoke the stub-creator subagent:

```
@stub-creator Create minimal stubs for:

Function: [function_name]
Signature: [signature]
Module Path: [module_path]
Test Content: [test_content]
Existing Module: [current_content or null]

Return the structured JSON output.
```

**Wait for completion.**

### Step 8.5: Write Stubs and Verify Tests Fail

1. Write stub code
2. Run tests to confirm they fail:

```bash
uv run pytest [test_file] -v 2>&1
```

**Expected:** Tests fail with assertion errors or NotImplementedError

**If tests pass unexpectedly:** Inform user and ask how to proceed

### Step 8.6: Present Tests for Review (BLOCKING STEP)

Present test coverage, code, and confidence level.

Use `question`:
- "Review these tests. Proceed to implementation?"
- Options: "Looks good", "Modify tests", "Skip function"

**If modify:** Rollback, relaunch test-writer with feedback, return to Step 8.2

**If approved:** Proceed to Step 8.7

### Step 8.7: Invoke Implementation Subagent

Use `@` mention to invoke the implement-function subagent:

```
@implement-function Implement this function:

Function: [function_name]
Signature: [signature]
Purpose: [purpose]
Test Content: [test_content]
Stub Code: [stub_code]
References: [similar_functions]
Patterns: [patterns_observed]
Requirements: [requirements]

Return the structured JSON output.
```

**Wait for completion.**

### Step 8.8: Write Implementation and Validate

1. Write implementation code
2. Run tests:

```bash
uv run pytest [test_file] -v 2>&1
```

**If pass:** Proceed to Step 8.9

**If fail:**
- Simple fixes: Apply directly
- Complex: Rollback, relaunch with failure context, return to Step 8.7

### Step 8.9: Parallel Quality Checks

Invoke code-fixer subagent in parallel with main test suite:

**Subagent (via @ mention):**
```
@code-fixer Fix quality issues in:

Files: [modified_files]
Linter: [ruff/etc]
Type Checker: [mypy/etc]
Config Files: [pyproject.toml, .ruff.toml]

Return the structured JSON output.
```

**Main agent (parallel):**
```bash
uv run pytest -x -v 2>&1 | head -100
```

### Step 8.10: Handle Quality Issues (BLOCKING STEP)

Compile results from code-fixer and test suite.

**If all pass:** Proceed to Step 8.11

**If issues:** Use `question`:
- "Quality issues found. How to proceed?"
- Options: "Auto-fix", "Show issues", "Skip", "Rollback"

### Step 8.11: Documentation Check

Use `question`:
- "Check for documentation updates?"
- Options: "Yes", "No"

**If yes:** Search docs, present findings, ask which to update

### Step 8.12: Documentation Consistency

Invoke skill:
```
/skill documentation-consistency
```

### Step 8.13: Completion Checkpoint

```bash
git add -A
git commit -m "feat([module]): implement [function] with tests"
git tag checkpoint/after-[module]-[function]-$(date +%s)
```

### Step 8.14-8.15: Continue or Complete Module

- If more functions: Return to Step 8.1
- If module complete: Ask about manual testing, then continue to next module or proceed to Step 9

---

## Step 9: Final Verification

### Step 9.1: Parse Deliverables

Extract deliverables from issue body Section 5.

### Step 9.2: Invoke Parallel Deliverables Verifiers

Invoke 5 subagents in parallel (one per category):

**Public Functions/APIs:**
```
@deliverables-verifier Verify Public Functions/APIs:

Category: Public Functions/APIs
Deliverables: [list]
Implementation: [current_state]

Return the structured JSON output.
```

**User-Facing Features:**
```
@deliverables-verifier Verify User-Facing Features:

Category: User-Facing Features
Deliverables: [list]
Implementation: [current_state]

Return the structured JSON output.
```

**Documentation:**
```
@deliverables-verifier Verify Documentation:

Category: Documentation
Deliverables: [list]
Implementation: [current_state]

Return the structured JSON output.
```

**Configuration/Infrastructure:**
```
@deliverables-verifier Verify Configuration/Infrastructure:

Category: Configuration/Infrastructure
Deliverables: [list]
Implementation: [current_state]

Return the structured JSON output.
```

**Deployment Artifacts:**
```
@deliverables-verifier Verify Deployment Artifacts:

Category: Deployment Artifacts
Deliverables: [list]
Implementation: [current_state]

Return the structured JSON output.
```

**Wait for all to complete.**

### Step 9.3: Aggregate Results

Compile into unified checklist.

### Step 9.4: Present Verification (BLOCKING STEP)

Use `question`:
- "Verification complete. Proceed?"
- Options: "All verified", "Fix missing items", "Re-verify category", "Cancel"

**If missing:** Address items, re-run verification

**If approved:** Proceed to Step 9.5

### Step 9.5: Final Test Suite

```bash
uv run pytest -v --tb=short 2>&1 | tail -50
uv run ruff check . 2>&1
uv run mypy . 2>&1 || echo "Type check completed"
```

**If issues:** Present and ask how to proceed

**If all pass:** Proceed to Step 9.6

### Step 9.6: Present Completion Summary

Show summary with:
- Modules implemented
- Tests added
- Documentation updated
- Deliverables verified
- Subagents used
- Quality metrics

---

## Step 10: Git Operations

### Step 10.1: Final Commit

```bash
git add -A
git commit -m "feat: implement [FEATURE] [closes #[ISSUE]]"
```

### Step 10.2: Push Branch

```bash
git push -u origin [branch_name]
```

### Step 10.3: Create Pull Request (BLOCKING STEP)

Use `question`:
- "Create pull request?"
- Options: "Yes", "No"

**If yes:**

Ask a subagent to generate PR content:

```
@general Create PR content for this feature:

Feature: [feature_name]
Issue: [issue_number]
Modules: [list]
Tests: [list]
Deliverables: [list]

Return JSON with pr_title and pr_body.
```

Create PR:
```bash
gh pr create --title "[title]" --body "[body]" --base main
```

Capture PR URL.

### Step 10.4: Update GitHub Issue

**If PR created:**
```bash
gh issue comment [ISSUE] --body "Complete. PR: [URL]"
gh issue close [ISSUE]
```

**If no PR:**
```bash
gh issue comment [ISSUE] --body "Complete. Branch: [branch_name]"
```

**If cancelled:** Do not close issue

---

## Step 11: PR Review Handling

### Step 11.1: Completion Options (BLOCKING STEP)

Use `question`:
- "PR created. What next?"
- Options: "Mark complete", "Check PR comments", "Complete later"

**If check comments:** Proceed to Step 11.2

### Step 11.2: Retrieve PR Comments

```bash
gh pr list --head [branch] --json number --jq '.[0].number'
gh pr view [pr] --json comments --jq '.comments'
gh api graphql -f query='...'  # for inline comments
```

### Step 11.3: Analyze Comments

Ask subagent to organize comments:

```
@general Organize these PR review comments into groups:

General Comments:
[comments]

Inline Comments:
[inline_comments]

Return JSON with groups array including complexity assessment.
```

### Step 11.4: Present Feedback (BLOCKING STEP)

Show organized groups with complexity and approach.

Use `question`:
- "How to proceed with review feedback?"
- Options: "Address all", "Address specific", "Mark complete", "Check later"

### Step 11.5: Invoke Parallel Review Responders

For each selected group, invoke via `@` mention:

**Example invocation:**
```
@review-responder Address this review feedback group:

Group ID: [group_id]
Type: [style/documentation/logic]
Files: [file_paths]
Comments:
- [comment 1 details]
- [comment 2 details]

Current Code:
[code_context]

Test Files: [paths]
Patterns: [observed_patterns]

Return the structured JSON output.
```

**All groups run in parallel.**

### Step 11.6: Apply Changes

For each completed subagent response:
1. Write modified files from response
2. Run verification commands
3. Check results

**If pass:** Stage changes

**If fail:** Fix or re-invoke subagent with failure context

### Step 11.7: Commit Changes

```bash
git add -A
git commit -m "refactor: address PR review feedback"
git push origin [branch_name]
```

### Step 11.8: Mark Comments Resolved

```bash
gh api graphql -f query='mutation...' -f threadId="[id]"
```

### Step 11.9: Repeat or Complete

Return to Step 11.2 to check for new comments.

Loop until user marks complete or exits.

---

## Navigation and Special Commands

**Moving Forward:**
- "next"/"continue" → Proceed
- "looks good"/"approved" → Approve

**Stopping:**
- "stop"/"cancel"/"abort" → End implementation
- Ask: "Close the feature issue?"
- Options: "Yes, close it", "No, keep open"

**If close:**
```bash
gh issue close [ISSUE] --comment "Cancelled."
git tag -l "checkpoint/*[feature]*" | xargs git tag -d
```

**If keep open:**
```bash
gh issue comment [ISSUE] --body "Partial implementation."
```

---

## Subagent Reference

All subagents are defined in `/agents/`:

| Subagent | File | Purpose |
|----------|------|---------|
| requirements-analyzer | [/agents/requirements-analyzer.md](/agents/requirements-analyzer.md) | Codebase analysis and planning |
| test-writer | [/agents/test-writer.md](/agents/test-writer.md) | Create TDD tests |
| stub-creator | [/agents/stub-creator.md](/agents/stub-creator.md) | Create failing stubs |
| implement-function | [/agents/implement-function.md](/agents/implement-function.md) | Implement logic |
| code-fixer | [/agents/code-fixer.md](/agents/code-fixer.md) | Fix linter/type issues |
| deliverables-verifier | [/agents/deliverables-verifier.md](/agents/deliverables-verifier.md) | Verify deliverables |
| review-responder | [/agents/review-responder.md](/agents/review-responder.md) | Address PR comments |

### Invoking Subagents

All subagents are invoked using `@` mentions with the agent name:

```
@[agent-name] [Context and instructions]

[Structured input data]

Return the structured JSON output.
```

**Notes:**
- Subagents defined in `/agents/` are automatically available via `@` mentions
- The agent's `description` field determines when it's invoked automatically
- Parallel invocation: Multiple `@` mentions can be sent in parallel
- Response format: All agents return structured JSON as defined in their SKILL.md

---

## Checkpoint and Rollback Strategy

### Creating Checkpoints

```bash
git add -A
git commit -m "checkpoint: before [action]" --allow-empty 2>/dev/null || true
git tag checkpoint/before-[action]-$(date +%s)
```

### Rollback

```bash
git reset --soft [checkpoint_tag]
git checkout -- .
git clean -fd
```

---

## Performance Considerations

### Parallel Points

1. **Step 8.9:** Code-fixer runs parallel to test suite
2. **Step 9.2:** 5 deliverables verifiers run in parallel
3. **Step 11.5:** Review responders run in parallel per group

### Sequential Requirements

- Tests → Stubs → Implementation (must be sequential)
- User approval required before proceeding from blocking steps

---

## Tips

- Review issue spec thoroughly before starting
- Follow patterns identified by requirements-analyzer
- Use checkpoints liberally
- Monitor subagent confidence scores
- Don't skip manual testing if uncertain
