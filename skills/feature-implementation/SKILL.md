---
name: feature-implementation
description: Implements a feature from a saved specification document using TDD approach. Use when user asks to "implement a feature", "start implementation", or after completing feature-planning.
allowed-tools: "Read,Grep,Glob,Bash,Write,Edit,todowrite,skill"
version: "1.0.0"
---

## Introduction

This skill implements a feature from a previously created specification document (`./feature-plans/FEATURE_NAME.md`) using a test-driven development (TDD) approach. Use `feature-planning` first to create the specification document.

### Prerequisites

- A feature specification document must exist in `./feature-plans/`
- The specification should have all required sections approved

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
  plan_file: null | "./feature-plans/FEATURE_NAME.md"
  feature_name: null | "<FEATURE_NAME>"
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
3. **Set `plan_file`** after Step 0
4. **Set `branch_name`** after Step 6
5. **Set `deliverables_verified`** to `true` after Step 9.2

---

## Step 0: Select Feature Specification

### Step 0.1: Check for Feature Plans

Use `Glob` to find all feature planning documents:

```
./feature-plans/*.md
```

Exclude `README.md` from results.

For each plan found, use `Read` to load the file and parse the YAML frontmatter. Only include plans where the `status` field is `"open"`. Plans with `status: "closed"` or `status: "done"` should be filtered out.

### Step 0.2: Handle Results

**If no open plans found:**
1. Inform user: "No feature specification documents with status 'open' found in ./feature-plans/"
2. Suggest: "Run `/feature-planning` first to create a specification"
3. Exit the skill

**If one plan found:**
1. Use `Read` to load the plan
2. Display feature name and ask: "Implement this feature?"
3. Options: "Yes", "No, select different plan", "Cancel"
4. If "Yes", set `plan_file` and proceed to Step 6

**If multiple plans found:**
1. Present list of available plans (showing feature names)
2. Use `question` tool to prompt: "Which feature would you like to implement?"
3. Options: List of feature names, "Cancel"
4. After selection, set `plan_file` and proceed to Step 6

### Step 0.3: Parse Specification

After selecting a plan:
1. Read the full specification document
2. Extract all sections for reference during implementation
3. Update state with `feature_name` from the document

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

Use the `question` tool:
- "Here are the tests for [function_name]. Please review and let me know if they look correct or if any modifications are needed."
- Show the test code
- Options: "Looks good, proceed", "Modify tests"

**If user requests modifications:**
1. Update the tests
2. Show revised tests
3. Wait for approval

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

**Read the feature plan's Section 5 (Deliverables and Artifacts)** and verify each item was produced:

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

### Step 10.3: Update Feature Plan Status

After successful completion, update the feature plan document's status to `"done"`:

1. Use `Read` to load the feature plan file
2. Use `Edit` to change the YAML frontmatter from `status: "open"` to `status: "done"`
3. Use `Write` to save the updated file

The feature plan document should now have:

```yaml
---
name: "<FEATURE_NAME>"
status: "done"
---
```

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
1. Update the feature plan's YAML frontmatter from `status: "open"` to `status: "closed"`
2. Use `Write` to save the updated file
3. Exit the skill

**If user wants to keep it open:**
- Exit the skill without changing status
- The feature plan remains available for future implementation attempts

---

## Tips for Best Results

- Review the specification document thoroughly before starting
- Follow existing code patterns in the project
- Run tests frequently during implementation
- Don't skip manual testing if uncertain
