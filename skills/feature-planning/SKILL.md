---
name: feature-planning
description: Interactive analysis and requirements gathering process for creating feature specification documents. Use when user asks to "plan a feature", "create a feature plan", "feature spec", or similar requests.
allowed-tools: "Read,Grep,Glob,Bash,Write,todowrite"
version: "1.0.0"
author: "Claude Code"
---

## Introduction

This skill conducts an interactive interview process to gather feature requirements and create a structured specification document. After planning is complete, use the `feature-implementation` skill to implement the feature.

The skill generates a structured `FEATURE_NAME.md` document in `./feature-plans/` covering:
1. **Feature Name and Description** - What the feature is and its purpose
2. **Feature Requirements** - Detailed functional requirements
3. **Constraints** - Technical, business, and operational constraints
4. **Feature Verification Testing** - How the feature will be tested and validated

### Process Flow

The skill follows a structured, iterative approach with blocking gates between sections for user approval.

### Usage

Invoke with: `/feature-planning [optional feature context]`

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

Use `Glob` to check if a `feature-plans/FEATURE_NAME.md` file already exists (where FEATURE_NAME is a sanitized feature name from a previous run).

**If feature document exists:**
1. Use `Read` to load the full contents
2. Present: "I found an existing feature document. Would you like to continue from where we left off or start fresh?"
3. Options: "Continue editing", "Start fresh", "Cancel"

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

Use the `question` tool to present this summary and ask:
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

Use the `question` tool to gather the following information:

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

Use the `question` tool to ask these clarifying questions and wait for response.

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

Use the `question` tool to present and ask for confirmation.

**BLOCKING GATE:** Must wait for approval, handle corrections, then proceed.

---

## Section 3: Constraints

### Step 3.1: Initial Information Gathering

Use the `question` tool to gather the following information:

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

Use the `question` tool to ask these clarifying questions and wait for response.

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

Use the `question` tool to present and ask for confirmation.

**BLOCKING GATE:** Must wait for approval, handle corrections, then proceed.

---

## Section 4: Feature Verification Testing

### Step 4.1: Initial Information Gathering

Use the `question` tool to gather the following information:

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

Use the `question` tool to ask these clarifying questions and wait for response.

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

Use the `question` tool to present and ask for confirmation.

**BLOCKING GATE:** Must wait for approval, handle corrections, then proceed.

---

## Step 5: Final Assembly and Save

### Step 5.1: Compile Full Feature Document

Once all sections are complete:
1. Assemble all approved section content
2. Add YAML frontmatter with `name` and `status` fields
3. Add metadata (date, version)
4. Generate table of contents
5. Format consistently with proper markdown

### Step 5.1.1: YAML Frontmatter Format

The document must start with YAML frontmatter:

```yaml
---
name: "<FEATURE_NAME>"
status: "open"
---
```

- `name`: The sanitized feature name (same as filename without `.md`)
- `status`: Always initialized as `"open"` when created by this skill

Valid status values:
- `"open"` - Feature plan is active and ready for implementation
- `"closed"` - Feature plan is cancelled or deprecated
- `"done"` - Feature has been implemented

### Step 5.2: Ensure Directory Exists

Use `Bash` to create the feature-plans directory if it doesn't exist:

```bash
mkdir -p ./feature-plans
```

### Step 5.3: Write to File

Use the sanitized `FEATURE_NAME` as the filename with `.md` extension.

The document structure must be:```markdown
---
name: "<FEATURE_NAME>"
status: "open"
---

[Table of Contents]

[Section 1: Feature Name and Description]

[Section 2: Feature Requirements]

[Section 3: Constraints]

[Section 4: Feature Verification Testing]
```

Use `Write` tool to save the document to `./feature-plans/FEATURE_NAME.md`.

**Success message:**
```
Feature specification saved to: ./feature-plans/FEATURE_NAME.md

To implement this feature, invoke: /feature-implementation
```

---

## Navigation and Special Commands

**Moving Forward:**
- "next" or "continue" → Proceed to next step
- "looks good" or "approved" → Approve current section/step

**Moving Backward:**
- "go back to [section name]" → Return to that section

**Stopping:**
- "stop" or "cancel" → End planning session
- Offer to save any partial progress

---

## Tips for Best Results

- Be specific when describing requirements
- Think about edge cases early
- Provide context about existing codebase when relevant
- Review summaries carefully before approving
