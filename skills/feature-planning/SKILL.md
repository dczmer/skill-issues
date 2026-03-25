---
name: feature-planning
description: Interactive analysis and requirements gathering process for creating feature specification documents. Use when user asks to "plan a feature", "create a feature plan", "feature spec", or similar requests.
allowed-tools: "Read,Grep,Glob,Bash,Write,todowrite,question"
version: "2.0.0"
---

## Introduction

This skill conducts an interactive interview process to gather feature requirements and create a structured specification document stored as a GitHub issue. After planning is complete, use the `feature-implementation` skill to implement the feature.

The skill creates or updates a GitHub issue with a structured feature specification covering:
1. **Feature Name and Description** - What the feature is and its purpose
2. **Feature Requirements** - Detailed functional requirements
3. **Constraints** - Technical, business, and operational constraints
4. **Feature Verification Testing** - How the feature will be tested and validated
5. **Deliverables and Artifacts** - Public functions, user-facing features, documentation, and other outputs

### Process Flow

The skill follows a structured, iterative approach with blocking gates between sections for user approval. It integrates with GitHub issues to track feature planning.

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
  mode: "new" | "continue" | "existing_issue"
  github_issue_number: null | "<ISSUE_NUMBER>"
  feature_name: null | "<FEATURE_NAME>"
  feature_name_sanitized: null | "<FEATURE_NAME with spaces as '-' and invalid chars removed>"
  issue_context: null | "<Issue description from GitHub>"
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
    deliverables:
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

## Step 0: Check for GitHub Issues and Continuation

### Step 0.1: Check for Open GitHub Issues

**BLOCKING STEP:** Ask user permission before checking GitHub issues.

Use the `question` tool to ask:
"Would you like me to check for open GitHub issues that might relate to this feature planning session?"
Options: "Yes, check for open issues", "No, start fresh"

**If user approves:**
1. Use `Bash` to list open issues:
   ```bash
   gh issue list --state open --limit 20 --json number,title,body,state
   ```
2. Parse the results and present to the user
3. Use `question` to ask: "Would you like to use one of these existing issues as the basis for this feature plan, or create a new one?"
   Options: [List issue titles as options], "Create new issue", "Start without issue"

**If existing issue selected:**
1. Store the `github_issue_number` in state
2. Store the issue body in `issue_context`
3. Parse the issue title as the feature name
4. Set `mode` to "existing_issue"
5. Present: "I'll use issue #N as the basis for this feature plan. I'll incorporate the existing issue description as context."

**If no issues found or user declines:**
- Set `mode` to "new"
- Proceed to Section 1

### Step 0.2: Check for Existing Feature Document (Deprecated)

**Note:** File-based feature plans in `./feature-plans/` are deprecated. This step exists only for backward compatibility.

Use `Glob` to check if a `feature-plans/FEATURE_NAME.md` file already exists (where FEATURE_NAME is a sanitized feature name from a previous run).

**If feature document exists:**
1. Use `Read` to load the full contents
2. Present: "I found an existing feature document. This file-based storage is deprecated. Would you like to migrate this to a GitHub issue and continue, or start fresh?"
3. Options: "Migrate to GitHub issue", "Start fresh", "Cancel"
4. If "Migrate to GitHub issue": Extract content and proceed to Step 6.3 to create/update the issue

**If no existing document:**
- Check for invocation modifiers or supplemental context
- Proceed directly to Section 1

---

## Section 1: Feature Name and Description

### Step 1.1: Initial Information Gathering

**If existing issue context is available:**
Review the issue description stored in `issue_context` and use it to pre-populate suggestions for the interview questions.

Use `question` tool to gather the following information:

**Questions:**
1. What is the name of the feature you want to add?
2. What problem does this feature solve or what value does it provide?
3. Who are the primary users or stakeholders who will use this feature?
4. What is the expected behavior of this feature?

**If issue context exists, include context-aware prompts:**
- "Based on the issue description, this feature seems to be about [X]. Does that sound right?"
- "The issue mentions [Y] — is this the primary focus, or are there other aspects to consider?"

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

### Step 1.3: Analyze and Suggest Improvements

Before presenting the summary for approval, review the gathered information and offer proactive guidance. Consider:

- Is the purpose statement clear and specific, or vague?
- Is the expected behavior concrete enough for an agent to implement without ambiguity?
- Are there obvious edge cases or failure modes not mentioned?
- Are primary users/stakeholders relevant to include, or is this a single-user tool where that's noise?
- Does the feature scope seem too broad or too narrow for a single implementation unit?

Present your analysis as a short bulleted list of **suggestions and potential improvements**, for example:
- "The expected behavior doesn't mention what happens when X — consider specifying this"
- "The purpose could be more concrete: instead of 'improves navigation', describe the specific action"
- "This feature seems large — consider splitting into X and Y"

Then present the section summary:

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

Use the `question` tool to present both the suggestions and summary, and ask:
- "Does this accurately capture the feature? Feel free to revise based on the suggestions above."
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

### Step 2.3: Analyze and Suggest Improvements

Before presenting the summary for approval, review the requirements and offer proactive guidance. Consider:

- Are any functional requirements ambiguous or untestable as written?
- Are there missing error handling cases (what happens when input is invalid, missing, or unexpected)?
- Are success conditions specific and verifiable, or subjective?
- Do the user interaction flows cover the full happy path and key failure paths?
- Are there implicit requirements that should be made explicit (e.g., atomicity, ordering, idempotency)?
- Do any requirements conflict with each other or with what was described in Section 1?

Present your analysis as a short bulleted list of **suggestions and potential improvements**.

Then present the section summary:

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

Use the `question` tool to present both the suggestions and summary, and ask for confirmation.

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

### Step 3.3: Analyze and Suggest Improvements

Before presenting the summary for approval, review the constraints and offer proactive guidance. Consider:

- Do any constraints conflict with or make the requirements in Section 2 impossible or harder than necessary?
- Are there security constraints implied by the requirements that haven't been stated explicitly?
- Are any constraints too vague to be actionable (e.g., "must be fast" vs. a specific benchmark)?
- Are empty constraint categories worth keeping, or should they be omitted to reduce noise?
- Are there constraints that are obvious from the project context (e.g., from AGENTS.md) that could be auto-populated rather than asked about?

Present your analysis as a short bulleted list of **suggestions and potential improvements**.

Then present the section summary:

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

Use the `question` tool to present both the suggestions and summary, and ask for confirmation.

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

### Step 4.3: Analyze and Suggest Improvements

Before presenting the summary for approval, review the verification plan and offer proactive guidance. Consider:

- Do the edge cases listed actually cover the failure modes described in Section 2's requirements?
- Are there security-relevant edge cases (e.g., path traversal, injection, boundary inputs) that are missing?
- Is the success criteria description specific enough for an agent to self-evaluate, or is it vague?
- Are any behaviors marked for unit testing that are actually untestable without mocking or manual interaction? Flag these explicitly.
- Are there behaviors that can only be verified manually? Make sure they are listed under manual testing.
- Does the test plan reference the correct test patterns from the project's AGENTS.md or established conventions?

Present your analysis as a short bulleted list of **suggestions and potential improvements**.

Then present the section summary:

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

Use the `question` tool to present both the suggestions and summary, and ask for confirmation.

**BLOCKING GATE:** Must wait for approval, handle corrections, then proceed.

---

## Section 5: Deliverables and Artifacts

### Step 5.1: Initial Information Gathering

Use the `question` tool to gather the following information:

**Questions:**
1. What public functions, APIs, or interfaces will this feature expose?
2. What user-facing features or UI components will be created?
3. What documentation needs to be created or updated? (README, API docs, user guides, etc.)
4. What configuration files, migrations, or infrastructure changes are needed?
5. Are there any artifacts for deployment, packaging, or distribution?

Wait for the user's response.

### Step 5.2: Analyze and Clarify

After receiving the initial response:
1. Identify any missing deliverables or unclear artifact definitions
2. Formulate 2-4 specific follow-up questions

Example clarifications might cover:
- Specific function signatures or API endpoints
- File locations and naming conventions
- Documentation format and location
- Migration scripts or seed data
- Version compatibility notes

Use the `question` tool to ask these clarifying questions and wait for response.

### Step 5.3: Analyze and Suggest Improvements

Before presenting the summary for approval, review the deliverables and offer proactive guidance. Consider:

- Do the public function signatures have enough detail for an agent to implement them (parameter names, types, return values)?
- Are there functions implied by the requirements in Section 2 that are missing from the deliverables list?
- Are any categories empty (e.g., "Deployment Artifacts: None") — if so, suggest omitting them for clarity?
- Is the documentation list realistic and necessary, or boilerplate that won't actually be written?
- Are there new files to create vs. existing files to modify? Both should be explicit.
- Do the deliverables fully account for all the success conditions in Section 2?

Present your analysis as a short bulleted list of **suggestions and potential improvements**.

Then present the section summary:

```markdown
## Section 5: Deliverables and Artifacts ✓

**Public Functions/APIs:**
- `[function_name()]` - [Brief description of what it does]
- `[endpoint]` - [API endpoint description]

**User-Facing Features:**
- [Feature/component 1]
- [Feature/component 2]

**Documentation:**
- [README updates]
- [API documentation]
- [User guides]

**Configuration/Infrastructure:**
- [Config files]
- [Migration scripts]
- [Environment variables]

**Deployment Artifacts:**
- [Package files]
- [Docker images]
- [Release notes]
```

Use the `question` tool to present both the suggestions and summary, and ask for confirmation.

**BLOCKING GATE:** Must wait for approval, handle corrections, then proceed.

---

## Step 6: Final Assembly and GitHub Issue Update

### Step 6.1: Compile Full Feature Document

Once all sections are complete:
1. Assemble all approved section content
2. Add metadata (date, version)
3. Generate table of contents
4. Format consistently with proper markdown

**Note:** Frontmatter is no longer included. The feature name is derived from the GitHub issue title by:
- Converting to lowercase
- Replacing spaces with `-`
- Removing any characters that do not match `[A-Za-z0-9-_]`

### Step 6.2: Create or Update GitHub Issue

**If `github_issue_number` is set (existing issue):**
1. Use `Bash` to update the issue body:
   ```bash
   gh issue edit <ISSUE_NUMBER> --body "$(cat <<'EOF'
   <Compiled markdown content here>
   EOF
   )"
   ```

**If no issue exists:**
1. Use `Bash` to create a new issue:
   ```bash
   gh issue create --title "<Feature Name>" --body "$(cat <<'EOF'
   <Compiled markdown content here>
   EOF
   )" --label "feature-plan"
   ```
2. Capture the issue number from the output
3. Store it in `github_issue_number`

**Success message:**
```
Feature specification updated in GitHub issue #<NUMBER>: <Feature Name>

GitHub issue status: open
To implement this feature, invoke: /feature-implementation
```

### Step 6.3: Deprecated File-Based Storage

**Note:** File-based feature plans in `./feature-plans/` are deprecated. This section is retained for backward compatibility only. New feature plans should use GitHub issues exclusively.

If migrating from an existing file-based plan:
- The content is transferred to the GitHub issue
- The original file is left in place but is no longer the source of truth
- Future edits should be made through the GitHub issue



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
