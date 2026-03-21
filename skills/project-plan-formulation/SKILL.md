# Project Plan Formulation

---
name: project-plan-formulation
description: Conducts iterative interviews to develop comprehensive project planning documents covering overview, tech stack, architecture, development process, conventions, and security. Use when the user asks to "create a project plan", "document a project", "conduct project planning interview", or mentions needing structured project documentation. Can accept supplemental context or instructions when invoked. Supports targeting a specific section with --section.
allowed-tools: "Read,Grep,Glob,Bash,AskUserQuestion,Write,TodoWrite"
version: "1.7.0"
author: "Claude Code"
---

## Introduction

This skill conducts an interactive interview process to formulate comprehensive project planning documents. It's designed for use at the start of new projects or when documenting existing ones to establish clear architectural and development guidelines.

The skill generates a structured `PROJECT_PLAN.md` document covering:
1. **Overview** - What the project is, its purpose and scope
2. **Tech Stack** - Languages, frameworks, tools, and dependencies
3. **Architecture Overview** - System components, data flow, and design decisions
4. **Development and Testing Process** - Setup, workflows, and testing approach
5. **Conventions and Rules** - Code organization, naming, and standards
6. **Security Considerations** - Auth, data protection, and vulnerabilities

### Process Flow

The skill follows a structured, iterative approach:
- Each section includes: **gather** → **clarify** → **summarize** → **confirm**
- You must approve each section before moving to the next (blocking gates)
- You can navigate back to revise sections, skip sections, or stop at any time
- Final document is reviewed, modified if needed, and saved to the project root

### Naming Conventions in This Skill

This skill uses two distinct naming schemes. Understanding the distinction helps agents reliably map between the interview workflow and the output document.

**Workflow headings (in this SKILL.md file):**
- `## Step N:` — Procedural steps that are not interview content sections (Step 0: setup/loading, Step 7: final assembly). These do not map to output document sections.
- `## Section N: Title` — The 6 interview content sections (Sections 1-6). Each maps 1:1 to an output document heading.
- `### Step N.M:` — Sub-steps within a Step or Section (e.g., Step 2.0, Step 1.1, Step 7.4). These are workflow instructions, not output headings.

**Output document headings (in the generated PROJECT_PLAN.md):**
- `## Title` — No numbering, no "Section" prefix. The output uses clean heading names only (e.g., `## Overview`, `## Tech Stack`, `## Architecture Overview`).

**Interview summary headings (shown to the user mid-interview for confirmation):**
- `## Section N: Title ✓` — These are transient, shown only during the interview to help the user track progress. They are **not** carried into the final output document.

**Mapping between interview sections and output headings:**

| Workflow heading | Output heading |
|---|---|
| Section 1: Project Overview | `## Overview` |
| Section 2: Tech Stack | `## Tech Stack` |
| Section 3: Architecture Overview | `## Architecture Overview` |
| Section 4: Development and Testing Process | `## Development and Testing Process` |
| Section 5: Conventions and Rules | `## Conventions and Rules` |
| Section 6: Security Considerations | `## Security Considerations` |

### Usage

Invoke with: `/project-plan-formulation [optional context]`

You can provide supplemental context at invocation:
- File paths to read (e.g., "read AGENTS.md and tests/")
- Specific instructions (e.g., "focus on security aspects")
- Existing documentation to incorporate

**Section targeting:** To work on a specific section only, use the `--section` flag:
- `/project-plan-formulation --section 2` (by number)
- `/project-plan-formulation --section "Tech Stack"` (by name)
- `/project-plan-formulation --section security` (by keyword match)

Section targeting requires an existing `PROJECT_PLAN.md` to load context from. The targeted section will go through the normal gather/clarify/confirm cycle, and the updated content will be merged back into the existing plan.

**Targeted updates:** When an existing `PROJECT_PLAN.md` is detected, you can choose "Targeted update" to describe what has changed (e.g., "we switched from Redis to Memcached"). The skill will identify which sections are affected and only re-interview those, carrying forward all unaffected sections unchanged.

The interview typically takes 10-20 minutes for a full run, 3-5 minutes when targeting a single section, or 5-10 minutes for a targeted update depending on how many sections are affected.

---

## State Tracking

Throughout the interview, maintain an internal state object to track progress. This ensures resilience to context loss and provides a clear snapshot of where the interview stands at any point.

### State Object Schema

```yaml
interview_state:
  mode: "full" | "section_target" | "targeted_update" | "update"
  target_section: null | 1-6          # only set in section_target mode
  affected_sections: []               # only set in targeted_update mode
  existing_plan_loaded: true | false
  sections:
    overview:
      status: "pending" | "in_progress" | "approved" | "skipped" | "carried_forward"
      iteration: 0                    # number of gather/clarify/confirm cycles completed
      content: null | "<approved markdown content>"
    tech_stack:
      status: "pending"
      iteration: 0
      content: null
    architecture:
      status: "pending"
      iteration: 0
      content: null
    development_and_testing:
      status: "pending"
      iteration: 0
      content: null
    conventions_and_rules:
      status: "pending"
      iteration: 0
      content: null
    security:
      status: "pending"
      iteration: 0
      content: null
  current_step: "0.1"                 # tracks which step is currently active
  started_at: null | "<ISO 8601 timestamp>"
  last_updated: null | "<ISO 8601 timestamp>"
```

### State Management Rules

1. **Initialize** the state object at the very start of the skill invocation, before Step 0.1.
2. **Update `current_step`** each time you transition to a new step or sub-step.
3. **Update section status** immediately when a section's status changes:
   - `"pending"` → `"in_progress"` when you begin gathering for that section
   - `"in_progress"` → `"approved"` when the user confirms the summary
   - `"pending"` or `"in_progress"` → `"skipped"` when the user skips
   - `"pending"` → `"carried_forward"` when content is preserved unchanged (targeted update or section-target modes)
4. **Increment `iteration`** each time you complete a full gather → clarify → confirm cycle for a section (including revision loops).
5. **Store `content`** with the approved markdown content for each section once approved.
6. **Set `mode`** during Step 0 based on the user's choices:
   - `"full"` — new plan, full interview
   - `"update"` — existing plan, full re-interview
   - `"section_target"` — `--section` flag used
   - `"targeted_update"` — user chose "Targeted update" in Step 0.1
7. **Present state on request:** If the user asks "where are we?" or "what's the status?", display a summary derived from the state object showing each section's status and the current step.

### Using TodoWrite for Progress Visibility

In addition to the internal state object, use the `TodoWrite` tool to give the user visible progress tracking in their UI. This is especially helpful during long interview sessions.

**At the start of the interview (after Step 0 resolves the mode):** Create a todo list with one item per section that will be interviewed. For example, in full mode:
- "Section 1: Project Overview" — pending
- "Section 2: Tech Stack" — pending
- "Section 3: Architecture Overview" — pending
- "Section 4: Development and Testing Process" — pending
- "Section 5: Conventions and Rules" — pending
- "Section 6: Security Considerations" — pending
- "Final assembly and save" — pending

**During the interview:**
- Mark the current section as `in_progress` when you begin gathering for it
- Mark the section as `completed` when the user approves it
- Mark skipped sections as `cancelled`
- In targeted update or section-target modes, only create todos for the sections being interviewed (not carried-forward sections)

**Keep the todo list in sync with the internal state object.** Update todos immediately on status changes — do not batch updates.

---

## Step 0: Load Existing Plan and Process Supplemental Context

### Step 0.1: Check for Existing PROJECT_PLAN.md

Before doing anything else, use `Glob` to check if a `PROJECT_PLAN.md` file already exists in the project root.

**If `PROJECT_PLAN.md` exists:**
1. Use `Read` to load the full contents of the existing plan
2. Parse the document to identify which sections are already populated vs. placeholder/incomplete
3. Present a summary to the user:
   - "I found an existing `PROJECT_PLAN.md`. Here's what it currently contains:"
   - List each section with a brief status (e.g., "populated", "placeholder/skipped", "missing")
4. Use `AskUserQuestion` to ask:
   - "How would you like to proceed with the existing plan?"
   - Options: "Update it — interview me to revise/fill sections", "Targeted update — tell me what changed and I'll update only affected sections", "Start fresh — discard and rebuild from scratch", "Cancel"
5. **If "Update it":** Pre-populate each section's content from the existing plan. During the interview, present the existing content for each section first and ask whether to keep, revise, or replace it. Skip the initial gathering questions for sections the user confirms are still accurate.
6. **If "Targeted update":** Proceed to Step 0.4 (Diff-Based Targeted Update).
7. **If "Start fresh":** Discard the loaded content and proceed as if no plan exists.
8. **If "Cancel":** End the skill invocation.

**If `PROJECT_PLAN.md` does not exist:**
- Proceed to Step 0.2

### Step 0.2: Process Supplemental Context

Check if the user provided any supplemental context or instructions at invocation.

**If supplemental context is provided:**
1. Parse the invocation for file paths, directories, or specific instructions
2. Use `Read`, `Grep`, or `Glob` to gather the referenced materials
3. Summarize what you've found and how it will inform the interview
4. Ask if there's anything else to review before starting

**If no supplemental context:**
- Proceed directly to Section 1 (or the targeted section, if `--section` was used)
- Note that you'll rely on the user's knowledge during the interview
- Mention that you can read files during the interview if references come up

### Step 0.3: Resolve Section Targeting

Check if the user provided a `--section` flag in the invocation.

**If `--section` is present:**
1. Parse the section identifier. Match against sections using any of:
   - **Number:** `1` through `6` maps directly to Sections 1-6
   - **Exact name:** e.g., `"Tech Stack"`, `"Architecture Overview"`
   - **Keyword:** Case-insensitive partial match (e.g., `security` matches "Security Considerations", `dev` matches "Development and Testing Process", `conventions` matches "Conventions and Rules")
2. If the match is ambiguous (e.g., keyword matches multiple sections), use `AskUserQuestion` to ask the user to clarify which section they meant, listing the matching candidates.
3. If no match is found, inform the user that the section identifier was not recognized, list valid section names and numbers, and ask them to try again.
4. **Require an existing plan:** If `PROJECT_PLAN.md` does not exist, inform the user that section targeting requires an existing plan to provide context, and ask whether to proceed with a full interview instead.
5. Once the target section is resolved:
   - Load the existing `PROJECT_PLAN.md` content (if not already loaded in Step 0.1)
   - Skip directly to the targeted section's Step X.1
   - Pre-populate the section with existing content from the plan (same as the "Update it" flow)
   - After the targeted section is approved, skip to Step 7 (Final Assembly) — merge the updated section back into the existing plan, preserving all other sections unchanged
   - Present the updated plan and proceed through Steps 7.2-7.4 as normal

**If `--section` is not present:**
- Proceed with the normal sequential flow starting at Section 1

### Step 0.4: Diff-Based Targeted Update

This step is entered when the user selects "Targeted update" in Step 0.1. It allows the user to describe what has changed, and only the affected sections are re-interviewed.

**Step 0.4.1: Gather Change Description**

Use `AskUserQuestion` to ask:
- "Describe what has changed since the plan was last updated. Be as specific as you like — for example: 'We switched from Redis to Memcached for caching', 'Added E2E tests with Playwright', 'New authentication provider', etc."

Wait for the user's response.

**Step 0.4.2: Identify Affected Sections**

Analyze the user's change description and map it to the plan's sections:

| Change topic | Likely affected sections |
|---|---|
| Scope, users, purpose, constraints | Section 1: Overview |
| Languages, frameworks, libraries, databases, tools | Section 2: Tech Stack |
| Components, services, data flow, deployment | Section 3: Architecture |
| Build, setup, testing, CI/CD, dev workflow | Section 4: Development and Testing |
| Naming, file structure, code style, review process | Section 5: Conventions and Rules |
| Auth, access control, secrets, encryption, compliance | Section 6: Security |

A single change may affect multiple sections (e.g., "switched to a microservices architecture" affects Sections 3, 4, and possibly 2).

Present the affected sections to the user using `AskUserQuestion`:
- "Based on your description, I believe these sections need updating:"
- List the affected sections with a brief explanation of why each is affected
- "Are these the right sections, or should I include/exclude any?"

Wait for the user's confirmation or corrections.

**Step 0.4.3: Interview Affected Sections Only**

For each confirmed affected section, in order:
1. Show the current content from the existing plan
2. Highlight which parts are likely affected by the described change
3. Run the normal interview cycle for that section (Steps X.1 → X.2 → X.3), pre-populated with existing content
4. After the section is approved, move to the next affected section

For all unaffected sections, carry forward existing content unchanged.

**Step 0.4.4: Proceed to Final Assembly**

Once all affected sections are approved, skip to Step 7 (Final Assembly):
- Merge updated sections back into the full plan
- Preserve all unaffected sections exactly as they were
- Proceed through Steps 7.1-7.4 as normal

---

## Section 1: Project Overview

### Step 1.1: Initial Information Gathering

Use `AskUserQuestion` to gather the following information:

**Questions:**
1. What is this project? What problem does it solve or what value does it provide?
2. Who are the primary users or stakeholders?
3. What is explicitly IN scope for this project?
4. What is explicitly OUT of scope (what won't this project do)?
5. Are there any important constraints, timelines, or context I should know about?

Wait for the user's response.

### Step 1.2: Analyze and Clarify

After receiving the initial response:
1. Identify any ambiguities, gaps, or areas needing clarification
2. Formulate 2-4 specific follow-up questions based on their answers
3. Use `AskUserQuestion` to ask these clarifying questions

Example clarifications might cover:
- Scale or performance requirements
- Integration points with other systems
- Success criteria or metrics
- Existing systems being replaced or enhanced
- Regulatory or compliance requirements

Wait for the user's response.

### Step 1.3: Present Summary and Confirm (BLOCKING STEP)

Format the section summary clearly:

```markdown
## Section 1: Project Overview ✓

**What it is:**
[Summary of the project]

**Primary users/stakeholders:**
[List]

**Scope (IN):**
- [Item 1]
- [Item 2]

**Scope (OUT):**
- [Item 1]
- [Item 2]

**Key context/constraints:**
[Important context]
```

Use `AskUserQuestion` to present this summary and ask:
- "Does this accurately capture the project overview?"
- Options: "Looks good", provide corrections, or "Skip this section"

**BLOCKING GATE:** Must wait for user confirmation before proceeding.

**If corrections provided:**
1. Update the summary based on feedback
2. Show the revised summary
3. Ask for confirmation again
4. Repeat until approved

**If user says "Skip this section":**
- Note that Section 1 was skipped
- Move to Section 2

**If approved:**
- Store the approved summary
- Acknowledge and transition: "Great! Moving to Section 2: Tech Stack"

---

## Section 2: Tech Stack

### Step 2.0: Auto-Detect Tech Stack From Codebase

Before asking the user questions, proactively scan the codebase for configuration files that reveal the tech stack. Use `Glob` and `Read` to check for the following (skip any that don't exist):

**Package/dependency files:**
- `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` (Node.js/JavaScript/TypeScript)
- `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements.txt`, `Pipfile`, `poetry.lock` (Python)
- `go.mod`, `go.sum` (Go)
- `Cargo.toml`, `Cargo.lock` (Rust)
- `Gemfile`, `Gemfile.lock` (Ruby)
- `pom.xml`, `build.gradle`, `build.gradle.kts` (Java/Kotlin)
- `*.csproj`, `*.sln`, `Directory.Build.props` (C#/.NET)
- `composer.json` (PHP)
- `mix.exs` (Elixir)
- `flake.nix`, `default.nix`, `shell.nix` (Nix — check `inputs` and `buildInputs` for dependencies, language runtimes, and tooling)

**Infrastructure/tooling files:**
- `Dockerfile`, `docker-compose.yml`, `docker-compose.yaml`
- `.github/workflows/*.yml`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/config.yml`
- `Makefile`, `Taskfile.yml`, `justfile`
- `tsconfig.json`, `.babelrc`, `babel.config.*`, `vite.config.*`, `webpack.config.*`, `next.config.*`
- `.eslintrc*`, `.prettierrc*`, `ruff.toml`, `pyproject.toml [tool.ruff]`, `.rubocop.yml`
- `.editorconfig`, `.nvmrc`, `.python-version`, `.tool-versions`, `.mise.toml`
- `flake.lock`, `*.nix` files in `nix/` directories — Nix flake inputs, overlays, and dev shell definitions

**From each discovered file, extract:**
- Languages and versions (from engine fields, version files, tsconfig targets, etc.)
- Frameworks and major libraries (from dependency lists)
- Build tools and task runners (from scripts, config files)
- Linting/formatting tools (from devDependencies or config files)
- Infrastructure hints (from Docker, CI configs)

**Present the auto-detected findings:**
Format the discovered tech stack as a preliminary summary and present it to the user using `AskUserQuestion`:
- "I scanned your codebase and detected the following tech stack. Please review and let me know what's correct, what's missing, and what needs correction:"
- List each category with discovered items
- Highlight any items you're uncertain about (e.g., "Found `redis` in dependencies — is this used for caching, sessions, or task queues?")

**If the codebase contains no recognizable config files:**
- Inform the user: "I wasn't able to auto-detect the tech stack from the codebase. Let me ask you directly."
- Fall through to Step 2.1 as normal

**After user responds to the auto-detected summary:**
- Merge corrections and additions into the working summary
- Proceed to Step 2.2 (Analyze and Clarify) with the merged information — skip Step 2.1 since the auto-detection replaces the initial gathering
- If the user confirmed everything and has nothing to add, proceed directly to Step 2.3 (Present Summary and Confirm)

### Step 2.1: Initial Information Gathering

If auto-detection was skipped or produced no results, use `AskUserQuestion` to gather the following information:

**Questions:**
1. What programming language(s) and versions will be used?
2. What frameworks or major libraries are you using?
3. What build tools, package managers, or task runners?
4. What databases, data stores, or caching layers?
5. Are there external services, APIs, or third-party integrations?
6. What development tools are critical (IDEs, linters, formatters, etc.)?

Wait for the user's response.

### Step 2.2: Analyze and Clarify

After receiving the initial response:
1. Identify missing details or potential compatibility concerns
2. Formulate 2-4 specific follow-up questions

Example clarifications might cover:
- Specific version requirements or ranges
- Rationale for framework choices
- Development vs. production dependencies
- Infrastructure dependencies (Docker, cloud services)
- Monitoring or observability tools

Use `AskUserQuestion` to ask these clarifying questions and wait for response.

### Step 2.3: Present Summary and Confirm (BLOCKING STEP)

Format the section summary:

```markdown
## Section 2: Tech Stack ✓

**Languages:**
- [Language] (version X.Y)

**Frameworks & Libraries:**
- [Framework/Library] (version X.Y) - [purpose]

**Build Tools:**
- [Tool] (version X.Y)

**Databases & Storage:**
- [Database] (version X.Y)

**External Services:**
- [Service] - [purpose]

**Development Tools:**
- [Tool] - [purpose]
```

Use `AskUserQuestion` to present and ask for confirmation.

**BLOCKING GATE:** Must wait for approval, handle corrections as in Section 1, then proceed.

---

## Section 3: Architecture Overview

### Step 3.1: Initial Information Gathering

Use `AskUserQuestion` to gather the following information:

**Questions:**
1. What are the main components or services in the system?
2. How do these components communicate? (APIs, message queues, events, etc.)
3. What does the deployment architecture look like? (monolith, microservices, serverless, etc.)
4. What are the key design decisions or trade-offs that shaped the architecture?
5. Are there existing architectural patterns or systems this should follow?

Wait for the user's response.

### Step 3.2: Analyze and Clarify

After receiving the initial response:
1. Identify areas where architectural details are unclear
2. Formulate 2-4 specific follow-up questions

Example clarifications might cover:
- Data flow through the system
- State management approach
- Scalability considerations
- Failure handling and resilience patterns
- Relationship to existing systems or services

Use `AskUserQuestion` to ask these clarifying questions and wait for response.

### Step 3.3: Present Summary and Confirm (BLOCKING STEP)

Format the section summary:

```markdown
## Section 3: Architecture Overview ✓

**System Components:**
- [Component 1] - [description]
- [Component 2] - [description]

**Communication Patterns:**
[Description of how components interact]

**Data Flow:**
[High-level data flow description]

**Deployment Architecture:**
[Description of deployment model]

**Key Design Decisions:**
1. [Decision] - [rationale]
2. [Decision] - [rationale]

**Existing Patterns to Follow:**
[Reference to existing systems or patterns]
```

Use `AskUserQuestion` to present and ask for confirmation.

**BLOCKING GATE:** Must wait for approval, handle corrections, then proceed.

---

## Section 4: Development and Testing Process

### Step 4.0: Auto-Detect Development and Testing Setup From Codebase

Before asking the user questions, proactively scan the codebase for files that reveal the development and testing setup. Use `Glob` and `Read` to check for the following (skip any that don't exist):

**Setup and build files:**
- `Makefile`, `Taskfile.yml`, `justfile` — look for targets like `setup`, `install`, `dev`, `build`, `test`, `lint`
- `package.json` `scripts` section — look for `dev`, `start`, `build`, `test`, `lint` scripts
- `docker-compose.yml` / `docker-compose.yaml` — identify services, ports, volumes
- `Dockerfile` — identify build stages and runtime setup
- `.env.example`, `.env.sample` — identify required environment variables
- `flake.nix`, `shell.nix`, `default.nix` — identify Nix-based dev shells, build derivations, and `nix develop`/`nix build` workflows; check `devShells`, `packages`, and `buildInputs` for available tooling and commands

**Test configuration:**
- `jest.config.*`, `vitest.config.*`, `pytest.ini`, `pyproject.toml [tool.pytest]`, `setup.cfg [tool:pytest]`
- `.mocharc.*`, `karma.conf.*`, `cypress.config.*`, `playwright.config.*`
- `tests/`, `test/`, `spec/`, `__tests__/` directories — identify test structure and types
- `conftest.py`, `fixtures/` — identify test infrastructure

**CI/CD pipelines:**
- `.github/workflows/*.yml`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/config.yml`
- Extract build steps, test commands, and deployment stages

**Development environment:**
- `README.md`, `CONTRIBUTING.md`, `docs/setup.md` — look for setup instructions
- `.devcontainer/`, `.vscode/launch.json`, `.idea/` — identify IDE and container configs
- `.pre-commit-config.yaml` — identify pre-commit hooks
- `flake.nix` `devShells` output — identify Nix-managed development environments (tools, shell hooks, environment variables available via `nix develop`)

**From each discovered file, extract:**
- Setup steps and prerequisites
- Build commands and processes
- How to run the application locally (commands, ports, URLs)
- Test types available and how to run them
- CI/CD pipeline structure
- Pre-commit hooks or automated checks

**Present the auto-detected findings:**
Format the discovered dev/testing setup as a preliminary summary and present it to the user using `AskUserQuestion`:
- "I scanned your codebase and detected the following development and testing setup. Please review and let me know what's correct, what's missing, and what needs correction:"
- List each category with discovered items
- Highlight any items you're uncertain about (e.g., "Found Playwright config but no test files — is E2E testing set up yet?")

**If the codebase contains no recognizable dev/test config files:**
- Inform the user: "I wasn't able to auto-detect the development setup from the codebase. Let me ask you directly."
- Fall through to Step 4.1 as normal

**After user responds to the auto-detected summary:**
- Merge corrections and additions into the working summary
- Proceed to Step 4.2 (Analyze and Clarify) with the merged information — skip Step 4.1 since the auto-detection replaces the initial gathering
- If the user confirmed everything and has nothing to add, proceed directly to Step 4.3 (Present Summary and Confirm)

### Step 4.1: Initial Information Gathering

If auto-detection was skipped or produced no results, use `AskUserQuestion` to gather the following information:

**Questions:**
1. How do you set up the development environment? (dependencies, configs, etc.)
2. What is the build/compile process?
3. How do you run the application locally?
4. What types of tests are required? (unit, integration, e2e, etc.)
5. What is the testing workflow? (how to run tests, where they live, etc.)
6. What are common debugging techniques or tools for this project?
7. What are the typical development workflows? (feature branches, hot reload, etc.)

Wait for the user's response.

### Step 4.2: Analyze and Clarify

After receiving the initial response:
1. Identify gaps in the development workflow description
2. Formulate 2-4 specific follow-up questions

Example clarifications might cover:
- Test coverage expectations
- CI/CD pipeline integration
- Local vs. containerized development
- Common gotchas or troubleshooting steps
- Code review process

Use `AskUserQuestion` to ask these clarifying questions and wait for response.

### Step 4.3: Present Summary and Confirm (BLOCKING STEP)

Format the section summary:

```markdown
## Section 4: Development and Testing Process ✓

**Environment Setup:**
1. [Step 1]
2. [Step 2]

**Build Process:**
[Description or command]

**Running Locally:**
[Description or command]

**Testing:**
- **Unit tests:** [description/command]
- **Integration tests:** [description/command]
- **E2E tests:** [description/command]

**Testing Workflow:**
[Description of how/when to run tests]

**Debugging:**
[Common debugging techniques and tools]

**Common Workflows:**
[Typical development workflows]
```

Use `AskUserQuestion` to present and ask for confirmation.

**BLOCKING GATE:** Must wait for approval, handle corrections, then proceed.

---

## Section 5: Conventions and Rules

### Step 5.1: Initial Information Gathering

Use `AskUserQuestion` to gather the following information:

**Questions:**
1. How should code be organized? (file structure, module patterns, etc.)
2. What naming conventions should be followed? (files, classes, functions, variables, etc.)
3. What documentation standards are expected? (docstrings, comments, README, etc.)
4. What are the code review practices or requirements?
5. Are there antipatterns or practices to avoid in this project?
6. How should files and folders be organized?

Wait for the user's response.

### Step 5.2: Analyze and Clarify

After receiving the initial response:
1. Identify areas where conventions are unclear or might conflict
2. Formulate 2-4 specific follow-up questions

Example clarifications might cover:
- Style guide references (PEP 8, Airbnb, Google, etc.)
- Linting and formatting tools/configs
- Import ordering conventions
- Error handling patterns
- Logging conventions

Use `AskUserQuestion` to ask these clarifying questions and wait for response.

### Step 5.3: Present Summary and Confirm (BLOCKING STEP)

Format the section summary:

```markdown
## Section 5: Conventions and Rules ✓

**Code Organization:**
[Description of file structure and module patterns]

**Naming Conventions:**
- **Files:** [convention]
- **Classes:** [convention]
- **Functions:** [convention]
- **Variables:** [convention]

**Documentation Standards:**
[Description of documentation expectations]

**Code Review Practices:**
[Description of review process and requirements]

**Antipatterns to Avoid:**
- [Antipattern 1] - [why to avoid]
- [Antipattern 2] - [why to avoid]

**File/Folder Organization:**
[Description or example structure]
```

Use `AskUserQuestion` to present and ask for confirmation.

**BLOCKING GATE:** Must wait for approval, handle corrections, then proceed.

---

## Section 6: Security Considerations

### Step 6.1: Initial Information Gathering

Use `AskUserQuestion` to gather the following information:

**Questions:**
1. How does authentication work in this system?
2. How is authorization/access control handled?
3. What data protection measures are in place? (encryption, PII handling, etc.)
4. Are there known vulnerabilities or security concerns to be aware of?
5. What security review or approval processes are required?
6. How are secrets and credentials managed?
7. What are the access control patterns or policies?

Wait for the user's response.

### Step 6.2: Analyze and Clarify

After receiving the initial response:
1. Identify security areas that need more detail
2. Formulate 2-4 specific follow-up questions

Example clarifications might cover:
- Input validation and sanitization
- OWASP top 10 considerations
- Compliance requirements (GDPR, HIPAA, etc.)
- Security testing requirements
- Incident response procedures
- Third-party security audits

Use `AskUserQuestion` to ask these clarifying questions and wait for response.

### Step 6.3: Present Summary and Confirm (BLOCKING STEP)

Format the section summary:

```markdown
## Section 6: Security Considerations ✓

**Authentication:**
[Description of authentication mechanism]

**Authorization:**
[Description of access control]

**Data Protection:**
[Description of encryption, PII handling, etc.]

**Known Vulnerabilities/Mitigations:**
- [Vulnerability] - [mitigation]

**Security Review Requirements:**
[Description of required reviews or approvals]

**Secrets Management:**
[Description of how secrets/credentials are handled]

**Access Control Patterns:**
[Description of access policies]
```

Use `AskUserQuestion` to present and ask for confirmation.

**BLOCKING GATE:** Must wait for approval, handle corrections, then proceed.

---

## Step 7: Final Assembly and Output

### Step 7.1: Compile Full Plan

Once all sections are complete (approved or skipped):
1. Assemble all approved section content
2. Add project metadata (date, version). If updating an existing plan, increment the version number and preserve the original **Generated** date while updating **Last Updated**.
3. Generate table of contents
4. Format consistently with proper markdown

For skipped sections, include placeholder:
```markdown
## [Section Name]

_[Information not provided during planning interview]_
```

### Step 7.2: Present Complete Plan

Display the complete document with this structure:

```markdown
# Project Plan: [Project Name]

**Generated**: [Current Date]
**Version**: 1.0
**Last Updated**: [Current Date]

## Table of Contents
1. [Overview](#overview)
2. [Tech Stack](#tech-stack)
3. [Architecture Overview](#architecture-overview)
4. [Development and Testing Process](#development-and-testing-process)
5. [Conventions and Rules](#conventions-and-rules)
6. [Security Considerations](#security-considerations)

[Full content for each section]
```

### Step 7.3: Request Final Modifications

Use `AskUserQuestion` to present the complete document and ask:

"Here's your complete project plan. What would you like to do?"

**Options:**
- "Save it" → Proceed to Step 7.4
- "Save as [filename]" → Proceed to Step 7.4 with custom filename
- Provide modifications → Update document, show again, ask again
- "Cancel" → Discard without saving

Wait for user's response and handle accordingly.

### Step 7.4: Write to File

**Default filename**: `PROJECT_PLAN.md` in project root

**If custom filename provided**: Use the user's specified name

Use `Write` tool to save the document:
1. Write to the specified file path in the project root
2. Confirm successful save with the full path
3. Explain document uses:
   - Onboarding new team members
   - Providing context to AI assistants
   - Recording architectural decisions
   - Guiding implementation choices

**Success message:**
```
✓ Project plan saved to: /path/to/PROJECT_PLAN.md

This document can be used for:
- Onboarding new team members
- Providing context to AI coding assistants
- Recording key architectural decisions
- Guiding consistent implementation

You can edit this file directly or re-run this skill to update it.
```

---

## Navigation and Special Commands

Throughout the interview, users can navigate flexibly:

**Moving Forward:**
- "next" or "continue" → Proceed to next section (after approval)
- "looks good" or "approved" → Approve current section summary

**Moving Backward:**
- "go back to [section name]" → Return to that section, allow revisions
- When returning to a section, show the current content, ask what to change

**Skipping:**
- "skip this" or "skip this section" → Mark section as skipped, move to next
- Skipped sections will have placeholder text in final document

**Stopping:**
- "stop" or "I'm done" → End interview immediately
- Offer to save partial content with incomplete sections noted
- Provide instructions for resuming: re-run the skill and it will automatically detect and load the saved partial `PROJECT_PLAN.md`, allowing you to continue where you left off

**Adding Context Mid-Interview:**
- If user references files: "Let me read [file]"
- Use `Read` to fetch the file
- Ask if this changes any previous sections
- Incorporate into current and future sections

**"I Don't Know" Responses:**
- Offer to explore codebase with `Glob`, `Grep`, or `Read`
- Suggest specific files to check based on section topic
- Mark section as incomplete if exploration doesn't help
- Offer to skip and revisit later

---

## Error Handling Scenarios

### Partial Completion

If user stops mid-interview:
1. Confirm they want to stop
2. Offer to save partial document
3. Mark incomplete sections with: `_[Section incomplete - stopped during interview]_`
4. Provide resume instructions

### Contradictory Information

If user provides info that contradicts earlier sections:
1. Point out the contradiction
2. Ask which is correct
3. Offer to update the earlier section
4. Show both sections for review

### Unable to Answer

If user repeatedly says "I don't know":
1. Offer codebase exploration
2. Suggest they consult with team members
3. Mark section for future completion
4. Offer to skip and continue with other sections

### File Write Failure

If `Write` fails:
1. Show the error message
2. Ask for alternative save location
3. Offer to display full content for manual copy-paste
4. Suggest checking file permissions

---

## Tips for Best Results

**For Users:**
- Have existing documentation handy (README, ADRs, etc.)
- Think through architectural decisions beforehand
- Be specific about constraints and requirements
- Don't worry about perfect wording - you can refine later

**For AI:**
- Build on information from previous sections
- Reference earlier answers when relevant in later questions
- Be specific in questions, not generic
- Acknowledge and validate user responses
- Keep summaries concise but complete
- Use proper markdown formatting consistently

---

## Related Documentation

- Example output structure: `references/output-template.md`
- For post-creation updates, just edit `PROJECT_PLAN.md` directly
- Consider checking this document into git for team visibility
- Link to this from `AGENTS.md` or `CLAUDE.md` for AI context
