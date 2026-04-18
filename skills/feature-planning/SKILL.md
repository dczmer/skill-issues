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
1. Record the issue number for later reference
2. Keep the issue body as context for the interview
3. Parse the issue title as the feature name
4. Present: "I'll use issue #N as the basis for this feature plan. I'll incorporate the existing issue description as context."

**If no issues found or user declines:**
- Proceed to Section 1

---

## Section 1: Feature Name and Description

### Step 1.1: Initial Information Gathering

**If existing issue context is available:**
Review the issue description from the selected issue and use it to pre-populate suggestions for the interview questions.

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

**Purpose clarity:**
- Does the purpose follow the format: "This feature enables [user] to [action] in order to [outcome]?"
- Would a developer understand the value without domain expertise?

**Behavior concreteness:**
- Can a test case be written from this description without asking clarifying questions?
- Are inputs (triggers), processing (logic), and outputs (results) all defined?

**Edge cases and failures:**
- Has behavior been defined for: invalid/missing input, timeout conditions, and dependency failures?
- Are there limits documented (max items, size bounds, rate limits)?

**Stakeholder relevance:**
- If this is a single-developer internal tool → stakeholder section can be brief
- If this affects teammates, users, or external systems → each stakeholder group should be listed with their specific interest

**Scope sizing:**
- Can this feature be described in one sentence using "and"/"or" at most once?
- Does it have 3-7 distinct functional requirements (fewer suggests scope is too narrow, more suggests it should split)?

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

**Testability of requirements:**
- Can each requirement be verified with a single pass/fail test? If multiple tests are needed, the requirement should be split.
- Do all requirements avoid subjective terms ("fast", "user-friendly", "appropriate") without quantified definitions?

**Error handling coverage:**
- For each input, is behavior defined for: valid case, empty/null case, format error case, and permission denied case?
- Is there a requirement specifying behavior when external dependencies (APIs, databases, files) are unavailable?

**Success condition concreteness:**
- Does each success condition include: observable output (what changes), measurable threshold (if applicable), and verification method?
- Replace vague conditions like "system handles load" with specific metrics: "processes N requests/second with <100ms latency at P95"

**Interaction flow completeness:**
- Happy path checklist: starting state → trigger action → expected state change → confirmation/output
- Failure path checklist: at each step, document behavior when: user cancels, input is invalid, timeout occurs, or concurrent modification happens

**Implicit requirement documentation:**
- Specify if operations must be: atomic (all-or-nothing), ordered (sequence matters), idempotent (repeating has same effect), or exclusive (no concurrent execution)
- Document data persistence expectations: cached vs. stored, immediate vs. eventual consistency

**Cross-reference consistency:**
- Does any requirement describe functionality outside the "Scope (IN)" from Section 1?
- Flag conflicts: if Requirement A requires X and Requirement B requires not-X, this must be resolved

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

**Constraint-requirement alignment:**
- Map each constraint to affected requirements: does it prevent implementation, increase complexity, or extend timeline?
- Flag direct contradictions (e.g., "must work offline" vs. "real-time cloud sync") for resolution

**Security constraint coverage:**
- For each data input/output from Section 2, verify constraints exist for: encryption at rest, encryption in transit, access control, and audit logging
- If user data is processed: are PII handling, data retention limits, and deletion procedures specified?

**Constraint measurability:**
- Performance constraints should include: metric (latency/throughput/memory), threshold (specific number), and conditions (load level, data size)
- Compatibility constraints should specify: exact versions supported, deprecation timeline, and upgrade/migration path

**Category utility:**
- Remove any category containing only "None" or "No constraints identified"
- Merge sparse categories: if two categories have fewer than 2 items combined, consolidate them

**Project-context constraints:**
- Review AGENTS.md for implied constraints: language versions, framework requirements, environment restrictions
- Check configuration files (flake.nix, package.json, etc.) for dependency versions that should be listed as constraints

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

**Edge case coverage:**
- Cross-reference: for each error handling requirement in Section 2, verify a corresponding edge case test exists
- Check coverage matrix: valid input, invalid format, missing/empty input, boundary values, concurrency/race conditions

**Security-relevant test cases:**
- For file path inputs: test path traversal (../), absolute paths, symlink resolution, and null bytes
- For user-provided strings: test injection patterns (SQL, command, HTML), Unicode edge cases, and maximum length overflow
- For numeric inputs: test boundary values (0, -1, max int), type confusion (string "123" vs number 123), and precision edge cases

**Success criteria specificity:**
- Success criteria must be observable: verifiable via assertion, checkable in logs/output, or inspectable in UI state
- Replace subjective criteria ("works well", "looks correct") with objective ones ("returns expected output", "completes with exit code 0", "matches reference snapshot")

**Test type appropriateness:**
- Flag for manual testing: UI requiring visual verification, external hardware, or third-party services without test endpoints
- Flag for integration testing: database transactions, file system operations, network requests, or multi-process coordination

**Manual testing documentation:**
- Document manual tests with: exact setup steps, specific actions to perform, and observable pass/fail criteria
- If manual testing exceeds 10 minutes per cycle, flag for potential automation or simplified validation

**Convention compliance:**
- Verify test file location matches project convention (tests/ vs __tests__/ vs spec/)
- Check test file naming matches AGENTS.md pattern (e.g., *.test.ts, *_spec.lua, test_*.py)

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

**Function signature completeness:**
- Each function signature should include: function name, parameter list with types and descriptions, return type with description, and error/exception types thrown
- Example format: `function_name(param1: Type, param2: Type): ReturnType` followed by brief description

**Requirement-to-deliverable traceability:**
- For each requirement in Section 2, map it to a specific function: requirement text → function name → where it's defined
- Flag requirements describing data transformation, validation, or storage that don't have corresponding functions listed

**Category utility:**
- Remove any category with only "None", "N/A", or fewer than 2 items
- If a category has only one generic item like "Documentation updates", merge it into the most closely related populated category

**Documentation specificity:**
- For each documentation item, specify: format (README section, API doc file, inline comments), location (file path or URL), and audience (users, developers, operators)
- Remove boilerplate like "Update docs" unless specific changes are identified; add explicit file paths like "Add section to README.md explaining configuration options"

**New vs. modified artifacts:**
- Tag each deliverable as [NEW] or [MODIFY]: "src/utils.py [MODIFY]" vs "src/new_module.py [NEW]"
- For modifications, specify line ranges or function names when possible; for new files, specify directory location

**Success condition coverage:**
- Create a traceability matrix: list each success condition from Section 2 and map to the deliverable(s) that satisfy it
- Flag any success condition that doesn't have at least one deliverable explicitly responsible for it

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

**If an existing issue was selected:**
1. Use `Bash` to update the issue body and ensure it has the `feature-plan` label:
   ```bash
   gh issue edit <ISSUE_NUMBER> --body "$(cat <<'EOF'
   <Compiled markdown content here>
   EOF
   )" --add-label "feature-plan"
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
3. Record it for reference in subsequent steps

**Success message:**
```
Feature specification updated in GitHub issue #<NUMBER>: <Feature Name>

GitHub issue status: open
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
