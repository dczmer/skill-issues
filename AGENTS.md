# AGENTS.md

Guidelines for agentic coding agents operating in this repository.

## Project Overview

This is a personal skills library containing markdown-based skill definition files (SKILL.md) for use with agentic coding tools. Each skill defines structured workflows and instructions that agents can follow.

## Build/Lint/Test Commands

### Environment Setup

```bash
# Enter Nix dev shell (provides uv)
nix develop

# Or manually: uv venv .venv && source .venv/bin/activate && uv sync
```

### Dependencies

```bash
# Install dependencies
uv sync

# Install Python if needed
uv python install
```

### Testing Skills

```bash
# Run agentskills CLI to validate/test skill definitions
agentskills --help

# Validate a specific skill
agentskills validate skills/project-plan-formulation/SKILL.md
```

### Running a Single Test

```bash
# If pytest tests exist (check tests/ directory)
uv run pytest tests/path/to/test_file.py::test_function_name -v

# Run specific pytest marker
uv run pytest -m "marker_name" -v
```

### Linting and Formatting

```bash
# Python linting (if ruff is configured)
uv run ruff check .

# Python formatting
uv run ruff format .

# Markdown linting (if mdl or similar is installed)
mdl skills/**/*.md
```

## File Structure

```
skill-issues/
├── skills/                      # Skill definitions directory
│   └── <skill-name>/           # Each skill in its own directory
│       ├── SKILL.md            # Main skill definition (required)
│       └── references/         # Supporting reference documents
│           ├── *.md            # Reference files loaded by skill
├── pyproject.toml              # Python project configuration
├── flake.nix                   # Nix development shell
├── uv.lock                     # Locked dependencies
└── .python-version             # Python version
```

## Code Style Guidelines

### Markdown Style

**SKILL.md Structure:**
```markdown
---
name: skill-name
description: Brief description of what the skill does
allowed-tools: "Tool1,Tool2,Tool3"
version: "X.Y.Z"
author: "Author Name"
---

## Introduction

Brief overview and purpose.

## Step X: [Step Name]

### Step X.Y: [Sub-step Name]

Instructions for this sub-step.

**BLOCKING STEP:** If this step requires user confirmation before proceeding.

**If condition:**
1. Action one
2. Action two

---
```

**Reference Files:**
- Organize supporting content in `references/` directory
- Load reference files only when needed (e.g., on error scenarios)
- Use descriptive filenames: `error-handling.md`, `best-practices.md`

### Formatting Rules

1. **Headings:** Use ATX style (`#`, `##`, `###`)
2. **Lists:** Use `-` for unordered, `1.` for ordered
3. **Code blocks:** Specify language for syntax highlighting
4. **Emphasis:** Use `**bold**` for important terms, `*italic*` for emphasis
5. **Line length:** Wrap at 80-120 characters for readability
6. **Blank lines:** Use one blank line between sections, two before headings

### Naming Conventions

- **Skill directories:** `kebab-case` (e.g., `project-plan-formulation`)
- **SKILL.md:** Always exactly `SKILL.md` (uppercase)
- **Reference files:** `kebab-case.md` (e.g., `invocation-modes.md`)

### YAML Front Matter

All SKILL.md files must include:
```yaml
---
name: skill-name                # Required: kebab-case identifier
description: Description text   # Required: one-line summary
allowed-tools: "Tool1,Tool2"    # Required: comma-separated tool list
version: "1.0.0"                # Required: semantic versioning
author: "Author Name"           # Optional
---
```

## Writing Conventions

### Step Instructions

1. **Clear actions:** Start with verbs (Use, Read, Write, Ask)
2. **Explicit blocking:** Mark steps that require user input with `**BLOCKING STEP:**`
3. **Conditional logic:** Use `**If X:**` / `**If Y:**` patterns
4. **Numbered lists:** For sequential actions that must happen in order
5. **Bulleted lists:** For options, alternatives, or unordered information

### User Interaction

- Use `AskUserQuestion` tool for user prompts
- Provide multiple-choice options when possible
- Include "Other" or custom input option when appropriate
- Always wait for response before proceeding with blocking steps

### Error Handling

- Define clear error scenarios
- Provide actionable recovery steps
- Reference error-handling.md files for complex scenarios

## Types

This project is primarily markdown-based. No TypeScript or strict typing is required.

## Imports and Dependencies

- Python 3.14 required
- `skills-ref` (>=0.1.1) - provides agentskills CLI
- Uses `uv` for package management (not pip/poetry)

## Development Workflow

1. Create skill directory under `skills/<skill-name>/`
2. Write `SKILL.md` with frontmatter and structured steps
3. Add reference files in `references/` subdirectory as needed
4. Validate skill definition with `agentskills validate`
5. Test skill invocation through appropriate agent

## Git Conventions

- Commit messages: Clear, descriptive summaries
- Branch naming: Not strictly enforced
- No CI/CD pipeline currently configured

## Security Considerations

- Skills should not expose or log secrets
- File writes should respect project boundaries
- User confirmation required for destructive operations

## Testing Skills

Skills are validated by:
1. YAML frontmatter parsing
2. Reference file existence checks
3. Workflow step validation
4. Agent invocation testing

## Common Tasks

### Adding a New Skill

```bash
mkdir -p skills/new-skill-name/references
touch skills/new-skill-name/SKILL.md
# Edit SKILL.md with appropriate structure
```

### Updating an Existing Skill

1. Edit `skills/<name>/SKILL.md`
2. Update version in frontmatter
3. Update any affected reference files

### Validating Skills

```bash
agentskills validate skills/<skill-name>/SKILL.md
```
