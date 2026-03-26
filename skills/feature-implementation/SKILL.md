---
name: feature-implementation
description: Implements a feature from a GitHub issue specification using TDD approach. Use when user asks to "implement a feature", "start implementation", or after completing feature-planning.
allowed-tools: "Read,Grep,Glob,Bash,Write,Edit,todowrite,skill"
version: "2.0.0"
---

## Introduction

This skill implements a feature from a previously created GitHub issue specification using a test-driven development (TDD) approach. Use `feature-planning` first to create the specification in a GitHub issue.

The skill reads feature specifications from GitHub issues labeled `feature-plan` and implements them following the structured workflow defined in the issue body.

### Prerequisites

- A GitHub issue with the `feature-plan` label must exist
- The issue body should contain the structured feature specification
- The `gh` CLI must be installed and authenticated

### Process Flow

1. **Step 0:** Select feature specification to implement
2. **Step 6:** Create feature branch (with user approval)
3. **Step 7:** Implementation planning
4. **Step 8:** TDD implementation loop
5. **Step 9:** Final verification
6. **Step 10:** Git operations and PR creation

### Usage

Invoke with: `/feature-implementation [optional feature name]`

If feature name is provided, that specification file will be used directly. Otherwise, you'll be prompted to select from available plans.

---

## State Tracking

Throughout the implementation, maintain an internal state object.

### State Object Schema

```yaml
implementation_state:
  github_issue_number: null | "<ISSUE_NUMBER>"
  feature_name: null | "<FEATURE_NAME>"
  feature_name_sanitized: null | "<FEATURE_NAME with spaces as '-' and invalid chars removed>"
  issue_body: null | "<Full issue body content>"
  branch_name: null | "feature/FEATURE_NAME"
  branch_created: false
  current_module: null
  modules: []
  all_tests_pass: false
  deliverables_verified: false
  current_step: "0"
  started_at: null
  last_updated: null
```

### State Management Rules

1. **Initialize** the state object at the very start
2. **Update `current_step`** each time you transition to a new step
3. **Set `github_issue_number`** and `issue_body` after Step 0
4. **Set `feature_name_sanitized`** after parsing the issue (lowercase, spaces to `-`, remove invalid chars)
5. **Set `branch_name`** after Step 6
6. **Set `deliverables_verified`** to `true` after Step 9.2

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
3. If "Yes", set `github_issue_number` and `issue_body` and proceed to Step 0.3

**If multiple issues found:**
1. Present list of available issues (showing issue numbers and titles)
2. Use `question` tool to prompt: "Which feature would you like to implement?"
3. Options: List of issue titles with numbers, "Cancel"
4. After selection, set `github_issue_number` and `issue_body` and proceed to Step 0.3

### Step 0.3: Parse Specification

After selecting an issue:
1. Store the full issue body in `issue_body`
2. Extract the feature name from the issue title
3. Derive `feature_name_sanitized` by converting to lowercase, replacing spaces with `-`, and removing characters not matching `[A-Za-z0-9-_]`
4. Parse the issue body to extract all sections (Description, Requirements, Constraints, Verification, Deliverables) by looking for `## Section X:` headers
5. Update state with all extracted information

### Step 0.4: Legacy File-Based Plans (Deprecated)

**Note:** File-based feature plans in `./feature-plans/` are no longer supported. Only GitHub issues with the `feature-plan` label are used for feature specifications.

---

## Step 6: Create Feature Branch

### Step 6.1: Propose Branch Creation

Use the `question` tool to ask:

"Ready to create a feature branch. The default name will be `feature/FEATURE_NAME`. Would you like to proceed, or would you like to specify a different branch name?"

Options:
- "Create branch with default name"
- "Specify custom branch name"
- "Skip branch creation"

**If "Specify custom branch name":**
1. Ask: "What branch name would you like to use?"
2. Validate the branch name (no spaces, valid characters)
3. Update `branch_name` in state

**If "Skip branch creation":**
1. Note: "Branch creation skipped. Proceeding with current branch."
2. Set `branch_created: false`
3. Proceed to Step 7

### Step 6.2: Create Branch

Use `Bash` to create the feature branch:

```bash
git checkout -b <branch_name>
```

Update state: `branch_created: true`

---

## Step 7: Implementation Planning

### Step 7.1: Analyze Requirements

Review the approved feature requirements and identify:
1. All modules that need to be created or modified
2. All functions within each module
3. Dependencies between modules
4. Test files needed

### Step 7.2: Present Implementation Plan (BLOCKING STEP)

Present a structured implementation plan:

```markdown
## Implementation Plan for FEATURE_NAME

### Module 1: [module_name]
- Function 1.1: [function_name] - [purpose]
- Function 1.2: [function_name] - [purpose]

### Module 2: [module_name]
- Function 2.1: [function_name] - [purpose]
- ...

### Implementation Order:
1. [Module/Function]
2. [Module/Function]
...
```

Use the `question` tool to ask:
- "Does this implementation plan look correct?"
- Options: "Looks good, proceed", "Modify plan"

**If user wants modifications:**
1. Present revised plan
2. Wait for approval**If approved:**
- Update state with the final implementation plan
- Proceed to Step 8

---

## Step 8: TDD Implementation Loop

For each module and function in the implementation plan:

### Step 8.1: Create Unit Tests

Create the test file and write unit tests for the function. Tests should:
- Cover the expected behavior from requirements
- Include edge cases
- Include error conditions
- Follow existing test patterns in the project

### Step 8.2: Create Stubs

Create the function/module stubs required for the tests to execute:
- Implement minimal stubs that will fail the tests
- This validates that tests are properly written

Run the tests to confirm they fail as expected.

### Step 8.3: Present Tests for Review (BLOCKING STEP)

**BLOCKING STEP:** Tests MUST be approved before proceeding to implementation. Do NOT proceed with Step 8.4 until the user explicitly approves the tests.

Use the `question` tool:
- "Here are the tests for [function_name]. Please review and let me know if they look correct or if any modifications are needed."
- Show the test code
- Options: "Looks good, proceed", "Modify tests"

**BLOCKING GATE:** Wait for user confirmation before proceeding.

**If user requests modifications:**
1. Update the tests
2. Show revised tests
3. Wait for approval
4. **Repeat until tests are approved**

**If approved:**
- Proceed to Step 8.4

### Step 8.4: Implement Function

Implement the function to make the tests pass:
1. Write the actual implementation
2. Run the tests for this function
3. If tests fail, debug and modify until tests pass

### Step 8.5: Run Full Test Suite and Linters (BLOCKING STEP on failures)

Run all linters, type checker, and unit tests:

1. **If type checker or linters fail:**
   - Fix the issues
   - Re-run until clean

2. **If other unit tests fail (not the one just implemented):**
   - **STOP and inform the user**
   - Present the failing tests
   - Ask: "These tests are failing. How would you like to proceed?"
   - Options: "Fix them", "Skip for now", "Cancel feature implementation"

3. **If all checks pass:**
   - Proceed to Step 8.6

### Step 8.6: Documentation Check Prompt

Use the `question` tool:
- "Implementation of [function_name] is complete. Should we look for documentation that needs updating?"
- Options: "Yes", "No"

**If Yes:**
1. Search for relevant documentation files
2. Present findings
3. Ask which documents to update

### Step 8.7: Run Documentation Consistency Check

Invoke the `documentation-consistency` skill to verify documentation remains consistent.

### Step 8.8: Manual Acceptance Testing Prompt

Use the `question` tool:
- "Module [module_name] implementation is complete. Would you like to do manual acceptance testing before continuing?"
- Options: "Yes", "No"

**If Yes:**
- Provide instructions for manual testing
- Wait for user confirmation

### Step 8.9: Repeat

Repeat Steps 8.1-8.8 for each remaining function/module.

---

## Step 9: Final Verification

After all modules are implemented:

### Step 9.1: Run Full Test Suite

Run all tests, linters, and type checker one final time.

### Step 9.2: Verify Deliverables and Artifacts

**Parse Section 5 (Deliverables and Artifacts) from the issue body** and verify each item was produced:

**Checklist:**

**Public Functions/APIs:**
- [ ] Verify each function/API listed in Section 5 exists and is accessible
- [ ] Confirm function signatures match specification

**User-Facing Features:**
- [ ] Verify each UI component/feature is implemented
- [ ] Test user interactions work as specified

**Documentation:**
- [ ] Check README updates are present
- [ ] Verify API documentation is complete
- [ ] Confirm user guides are written

**Configuration/Infrastructure:**
- [ ] Verify config files are in place
- [ ] Check migration scripts run successfully
- [ ] Confirm environment variables are documented

**Deployment Artifacts:**
- [ ] Verify package files are created
- [ ] Check Docker images build correctly
- [ ] Confirm release notes are prepared

Use the `question` tool to present this checklist:
- "Based on the deliverables in the feature plan, here's what was implemented. Please verify each item:"
- Show the checklist with status of each item
- Options: "All deliverables verified", "Missing items - explain below"

**If missing items:**
1. Ask which items need to be addressed
2. Go back to implement the missing deliverables
3. Re-run verification

**If all verified:**
- Proceed to Step 9.3

### Step 9.3: Present Completion Summary

```markdown
## Implementation Complete: FEATURE_NAME

### Modules Implemented:
- [Module 1]
- [Module 2]

### Tests Added:
- [Test file 1]
- [Test file 2]

### Documentation Updated:
- [Doc file 1]
- [Doc file 2]

### Deliverables Verified:
- [Deliverable 1] ✓
- [Deliverable 2] ✓
- [Deliverable 3] ✓

### Status:
All tests passing
All linters clean
Type checker passing
All deliverables verified
```

---

## Step 10: Git Operations

### Step 10.1: Stage and Commit

Use `Bash` to stage and commit changes:

```bash
git add -A
git commit -m "feat: implement FEATURE_NAME"
```

### Step 10.2: Pull Request (BLOCKING STEP)

Check if `gh` command is available:

```bash
which gh
```

**If gh is available:**
Use the `question` tool:
- "Would you like to create a pull request?"
- Options: "Yes", "No"

**If Yes:**
1. Use `gh pr create` with appropriate title and body
2. Present the PR URL

**If No:**
- Present commit summary and branch name for manual PR creation

### Step 10.3: Update GitHub Issue Status

After successful completion, update the GitHub issue to reflect implementation status:

1. Use `Bash` to close the issue:
   ```bash
   gh issue close <github_issue_number>
   ```

2. Optionally add a comment noting completion:
   ```bash
   gh issue comment <github_issue_number> --body "Feature implementation complete. All deliverables verified and tests passing."
   ```

3. Update state to reflect completion

**If the implementation was aborted or cancelled:**
- Do not close the issue
- Optionally add a comment: `gh issue comment <github_issue_number> --body "Implementation started but not completed. Issue remains open for future work."`
- Remove any `in-progress` label if present

---

## Navigation and Special Commands

**Moving Forward:**
- "next" or "continue" → Proceed to next step
- "looks good" or "approved" → Approve current step

**Stopping (Abort):**
- "stop" or "cancel" or "abort" → End implementation
- Ask user: "Would you like to mark this feature as closed?"
- Options: "Yes, close it", "No, keep it open"

**If user confirms closing:**
1. Use `Bash` to close the GitHub issue:
   ```bash
   gh issue close <github_issue_number>
   ```
2. Optionally add a comment explaining why it was closed:
   ```bash
   gh issue comment <github_issue_number> --body "Implementation cancelled/abandoned."
   ```
3. Exit the skill

**If user wants to keep it open:**
- Optionally add a comment noting the partial implementation:
  ```bash
  gh issue comment <github_issue_number> --body "Partial implementation completed. Work stopped at [describe current state]."
  ```
- Exit the skill without closing the issue
- The GitHub issue remains available for future implementation attempts

---

## Step 11: PR Review and Completion (BLOCKING STEP)

After creating the pull request, pause for user review and handle any feedback.

### Step 11.1: Present Completion Options (BLOCKING STEP)

**STOP** and use the `question` tool:

"The feature implementation is complete and a pull request has been created. What would you like to do next?"

Options:
- "Mark feature as complete (no PR review needed)"
- "Check PR for comments and review feedback"
- "Complete the process later (exit skill)"

**If "Mark feature as complete":**
1. Update the feature plan status to "done" (see Step 10.3)
2. Exit the skill

**If "Complete the process later":**
1. Exit the skill without changing status
2. The feature plan remains open for future continuation

**If "Check PR for comments":**
1. Proceed to Step 11.2

### Step 11.2: Retrieve PR Comments

Use `Bash` to view PR comments:

```bash
gh pr view <pr_number> --comments
```

If the PR number is not known, first retrieve it:

```bash
gh pr list --head <branch_name> --json number --jq '.[0].number'
```

### Step 11.3: Retrieve Inline Review Comments

Use `gh api graphql` to query for review threads with inline comments:

```bash
gh api graphql -f query='
query {
  repository(owner: "<owner>", name: "<repo>") {
    pullRequest(number: <pr_number>) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          comments(first: 100) {
            nodes {
              author { login }
              body
              path
              line
              originalLine
            }
          }
        }
      }
    }
  }
}'
```

Extract owner and repo from the remote URL:

```bash
git remote get-url origin | sed 's/.*github.com[:/]\([^/]*\)/\([^/]*\).*/\1 \2/'
```

### Step 11.4: Present Review Feedback (BLOCKING STEP)

Compile and present all comments:

```markdown
## PR Review Feedback

### General Comments:
[List general PR comments]

### Inline Review Comments:
[For each review thread]
- **File:** `path/to/file`
- **Line:** X
- **Author:** @username
- **Comment:** [comment body]
- **Status:** [Resolved / Unresolved]
```

Use the `question` tool:

"Here is the review feedback for this PR. How would you like to proceed?"

Options:
- "Address all comments"
- "Address specific comments (select below)"
- "Mark feature as complete (ignore remaining comments)"
- "Check again later (exit skill)"

**If "Address all comments" or "Address specific comments":**
1. For each comment to address:
   - Navigate to the file and line mentioned
   - Read the relevant code context
   - Make the requested changes
   - Test the changes
   - Commit with message referencing the review
2. After addressing comments, push changes:
   ```bash
   git push origin <branch_name>
   ```
3. Return to Step 11.2 to check for new comments or updates

**If "Mark feature as complete":**
1. Update the feature plan status to "done"
2. Exit the skill

**If "Check again later":**
1. Exit the skill
2. The feature plan remains open

### Step 11.5: Repeat Until Complete

Repeat Steps 11.2-11.4 until:
- The user chooses to mark the feature as complete, OR
- The user chooses to exit and continue later

Do NOT proceed without explicit user confirmation at each blocking step.

---

## Tips for Best Results

- Review the GitHub issue specification thoroughly before starting
- Follow existing code patterns in the project
- Run tests frequently during implementation
- Don't skip manual testing if uncertain
