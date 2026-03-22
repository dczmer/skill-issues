---
name: new-feature
description: Interactive analysis and requirements gathering process for implementing new features with TDD approach. Use when user asks to "add a feature", "implement a feature", "create a new feature", or similar requests.
allowed-tools: "Read,Grep,Glob,Bash,AskUserQuestion,Write,Edit,todowrite,task,skill"
version: "1.0.0"
author: "Claude Code"
---

## Introduction

This skill conducts an interactive interview process to gather feature requirements and then implements the feature using a test-driven development (TDD) approach. It ensures thorough requirements capture, incremental development, and validation through testing.

The skill generates a structured `FEATURE_NAME.md` document covering:
1. **Feature Name and Description** - What the feature is and its purpose
2. **Feature Requirements** - Detailed functional requirements
3. **Constraints** - Technical, business, and operational constraints
4. **Feature Verification Testing** - How the feature will be tested and validated

### Process Flow

The skill follows a structured, iterative approach:
- **Phase 1:** Requirements gathering with interactive refinement (blocking gates between sections)
- **Phase 2:** Implementation with TDD workflow (stops for user input at key points)
- **Phase 3:** Verification, documentation check, and optional PR creation

### Usage

Invoke with: `/new-feature [optional feature context]`

You can provide supplemental context at invocation:
- Feature description or partial requirements
- File paths to existing code that relates to the feature
- Specific constraints or requirements to consider

---

## State Tracking

Throughout the process, maintain an internal state object to track progress.

### State Object Schema

```yaml
feature_state:
  mode: "new" | "continue"
  feature_name: null | "<FEATURE_NAME>"
  feature_name_sanitized: null | "<FEATURE_NAME with spaces as '-' and invalid chars removed>"
  sections:
    description:
      status: "pending" | "in_progress" | "approved" | "skipped"
      iteration: 0
      content: null
    requirements:
      status: "pending" | "in_progress" | "approved" | "skipped"
      iteration: 0
      content: null
    constraints:
      status: "pending" | "in_progress" | "approved" | "skipped"
      iteration: 0
      content: null
    verification:
      status: "pending" | "in_progress" | "approved" | "skipped"
      iteration: 0
      content: null
  implementation:
    current_module: null
    modules: []
    branch_created: false
    all_tests_pass: false
  current_step: "0.1"
  started_at: null
  last_updated: null
```

### State Management Rules

1. **Initialize** the state object at the very start
2. **Update `current_step`** each time you transition to a new step
3. **Update section status** immediately when a section's status changes
4. **Increment `iteration`** each time you complete a gather/clarify/confirm cycle
5. **Set `feature_name_sanitized`** after Section 1 is approved (replace spaces with `-`, remove invalid unix filename characters)

---

## Step 0: Check for Continuation

### Step 0.1: Check for Existing Feature Document

Use `Glob` to check if a `features/FEATURE_NAME.md` file already exists (where FEATURE_NAME is a sanitized feature name from a previous run).

**If feature document exists:**
1. Use `Read` to load the full contents
2. Present: "I found an existing feature document. Would you like to continue from where we left off or start fresh?"
3. Options: "Continue implementation", "Start fresh", "Cancel"

**If no existing document:**
- Check for invocation modifiers or supplemental context
- Proceed directly to Section 1

---

## Section 1: Feature Name and Description

### Step 1.1: Initial Information Gathering

Use `AskUserQuestion` to gather the following information:

**Questions:**
1. What is the name of the feature you want to add?
2. What problem does this feature solve or what value does it provide?
3. Who are the primary users or stakeholders who will use this feature?
4. What is the expected behavior of this feature?

Wait for the user's response.

### Step 1.2: Analyze and Clarify

After receiving the initial response:
1. Identify any ambiguities, gaps, or areas needing clarification
2. Formulate 2-4 specific follow-up questions

Example clarifications might cover:
- Edge cases or boundary conditions
- Integration points with existing functionality
- Success criteria or acceptance conditions
- Dependencies on other features or systems

Use `AskUserQuestion` to ask these clarifying questions and wait for response.

### Step 1.3: Present Summary and Confirm (BLOCKING STEP)

Format the section summary clearly:

```markdown
## Section 1: Feature Name and Description ✓

**Feature Name:**
[Name]

**Purpose:**
[What problem it solves or value it provides]

**Primary Users/Stakeholders:**
[List]

**Expected Behavior:**
[Description of expected behavior]
```

Use `AskUserQuestion` to present this summary and ask:
- "Does this accurately capture the feature?"
- Options: "Looks good", provide corrections, or "Skip this section"

**BLOCKING GATE:** Must wait for user confirmation before proceeding.

**If approved:**
- Store the approved summary
- Derive `FEATURE_NAME` by taking the feature name, replacing spaces with `-`, and removing any characters invalid for unix filenames
- Transition: "Great! Moving to Section 2: Feature Requirements"

---

## Section 2: Feature Requirements

### Step 2.1: Initial Information Gathering

Use `AskUserQuestion` to gather the following information:

**Questions:**
1. What are the functional requirements? (What should the feature do?)
2. What are the user interactions and flows?
3. What data does this feature need to process or produce?
4. Are there any specific formats, protocols, or interfaces required?
5. What are the success conditions for each requirement?

Wait for the user's response.

### Step 2.2: Analyze and Clarify

After receiving the initial response:
1. Identify missing requirements or unclear descriptions
2. Formulate 2-4 specific follow-up questions

Example clarifications might cover:
- Input validation requirements
- Error handling behavior
- Performance expectations
- Edge cases to handle
- Output format specifications

Use `AskUserQuestion` to ask these clarifying questions and wait for response.

### Step 2.3: Present Summary and Confirm (BLOCKING STEP)

Format the section summary:

```markdown
## Section 2: Feature Requirements ✓

**Functional Requirements:**
1. [Requirement 1]
2. [Requirement 2]
...

**User Interactions/Flows:**
- [Flow 1]
- [Flow 2]

**Data Requirements:**
- [Input data]
- [Output data]

**Success Conditions:**
- [Condition 1]
- [Condition 2]
```

Use `AskUserQuestion` to present and ask for confirmation.

**BLOCKING GATE:** Must wait for approval, handle corrections, then proceed.

---

## Section 3: Constraints

### Step 3.1: Initial Information Gathering

Use `AskUserQuestion` to gather the following information:

**Questions:**
1. Are there any technical constraints? (technology stack, libraries, frameworks)
2. Are there any business constraints? (budget, timeline, regulatory requirements)
3. Are there any operational constraints? (deployment environment, scalability requirements)
4. Are there compatibility requirements with existing systems?
5. Are there security or privacy constraints?

Wait for the user's response.

### Step 3.2: Analyze and Clarify

After receiving the initial response:
1. Identify constraints that might conflict with requirements
2. Formulate 2-4 specific follow-up questions

Example clarifications might cover:
- Performance benchmarks
- Version compatibility
- Third-party service limitations
- Legacy system integration

Use `AskUserQuestion` to ask these clarifying questions and wait for response.

### Step 3.3: Present Summary and Confirm (BLOCKING STEP)

Format the section summary:

```markdown
## Section 3: Constraints ✓

**Technical Constraints:**
- [Constraint 1]
- [Constraint 2]

**Business Constraints:**
- [Constraint 1]
- [Constraint 2]

**Operational Constraints:**
- [Constraint 1]
- [Constraint 2]

**Compatibility Requirements:**
- [Requirement]

**Security/Privacy Constraints:**
- [Constraint]
```

Use `AskUserQuestion` to present and ask for confirmation.

**BLOCKING GATE:** Must wait for approval, handle corrections, then proceed.

---

## Section 4: Feature Verification Testing

### Step 4.1: Initial Information Gathering

Use `AskUserQuestion` to gather the following information:

**Questions:**
1. What types of tests are required? (unit, integration, e2e)
2. What test files and frameworks are used in this project?
3. Are there existing test patterns to follow?
4. What are the test coverage expectations?
5. How should edge cases and error conditions be tested?
6. Please provide a written description of how you (the agent) will know this feature is correctly implemented. What specific outcomes, behaviors, or outputs will indicate success?

Wait for the user's response.

### Step 4.2: Analyze and Clarify

After receiving the initial response:
1. Identify testing gaps or unclear test requirements
2. Formulate 2-4 specific follow-up questions

Example clarifications might cover:
- Mocking strategies
- Test data requirements
- CI/CD integration for tests
- Manual vs automated testing

Use `AskUserQuestion` to ask these clarifying questions and wait for response.

### Step 4.3: Present Summary and Confirm (BLOCKING STEP)

Format the section summary:

```markdown
## Section 4: Feature Verification Testing ✓

**Test Types:**
- [Unit tests]
- [Integration tests]
- [E2E tests]

**Test Frameworks:**
- [Framework 1]
- [Framework 2]

**Test Patterns to Follow:**
- [Pattern 1]
- [Pattern 2]

**Coverage Expectations:**
[Description]

**Edge Cases to Test:**
- [Case 1]
- [Case 2]

**Success Criteria Description:**
[Written description of how the agent will know the feature is correctly implemented]
```

Use `AskUserQuestion` to present and ask for confirmation.

**BLOCKING GATE:** Must wait for approval, handle corrections, then proceed.

---

## Step 5: Final Assembly and Save

### Step 5.1: Compile Full Feature Document

Once all sections are complete:
1. Assemble all approved section content
2. Add metadata (date, version)
3. Generate table of contents
4. Format consistently with proper markdown

### Step 5.2: Write to File

Use the sanitized `FEATURE_NAME` as the filename with `.md` extension.

Ensure the `./features/` directory exists, then use `Write` tool to save the document to `./features/FEATURE_NAME.md`.

**Success message:**
```
✓ Feature specification saved to: ./features/FEATURE_NAME.md
```

---

## Phase 2: Implementation

After the feature specification is saved, proceed to implementation.

---

## Step 6: Create Feature Branch

### Step 6.1: Create Branch

Use `Bash` to create a feature branch named after `FEATURE_NAME` (the sanitized name):

```bash
git checkout -b feature/FEATURE_NAME
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
...

### Implementation Order:
1. [Module/Function]
2. [Module/Function]
...
```

Use `AskUserQuestion` to ask:
- "Does this implementation plan look correct?"
- Options: "Looks good, proceed", "Modify plan"

**If user wants modifications:**
1. Present revised plan
2. Wait for approval

**If approved:**
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

Use `AskUserQuestion`:
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

Use `AskUserQuestion`:
- "Implementation of [function_name] is complete. Should we look for documentation that needs updating?"
- Options: "Yes", "No"

**If Yes:**
1. Search for relevant documentation files
2. Present findings
3. Ask which documents to update

### Step 8.7: Run Documentation Consistency Check

Invoke the `documentation-consistency` skill to verify documentation remains consistent.

### Step 8.8: Manual Acceptance Testing Prompt

Use `AskUserQuestion`:
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

### Step 9.2: Present Completion Summary

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

### Status:
✓ All tests passing
✓ All linters clean
✓ Type checker passing
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
Use `AskUserQuestion`:
- "Would you like to create a pull request?"
- Options: "Yes", "No"

**If Yes:**
1. Use `gh pr create` with appropriate title and body
2. Present the PR URL

**If No:**
- Present commit summary and branch name for manual PR creation

---

## Navigation and Special Commands

**Moving Forward:**
- "next" or "continue" → Proceed to next step
- "looks good" or "approved" → Approve current section/step

**Moving Backward:**
- "go back to [section name]" → Return to that section

**Stopping:**
- "stop" or "cancel" → End implementation
- Offer to save any partial changes

---

## Tips for Best Results

- Be specific when describing requirements
- Think about edge cases early
- Review tests carefully before approving
- Don't skip manual testing if uncertain
