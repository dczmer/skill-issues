# AGENTS.md

Guidelines for agentic coding agents operating in this repository.

## Project Overview

This is an **OpenCode plugin** providing a personal skills library with custom subagents and markdown-based skill definitions. It follows the OpenCode plugin architecture while maintaining compatibility with Claude and other agentic tools.

**Key Features:**
- **Skills**: Reusable instruction sets loaded on-demand via the native `skill` tool
- **Subagents**: Specialized agents for task delegation via the `task` tool or `@` mention
- **OpenCode Native**: Designed for `~/.config/opencode/` with `.agents/` compatibility

---

## File Structure

```
skill-issues/
├── skills/                      # Skill definitions directory
│   └── <skill-name>/           # Each skill in its own directory
│       ├── SKILL.md            # Main skill definition (required)
│       ├── references/         # Supporting reference documents
│       │   └── *.md            # Reference files loaded by skill
│       └── scripts/            # Reusable scripts for skill implementation
│           └── *.sh            # Bash or Python scripts
├── agents/                      # Custom subagent definitions
│   └── <agent-name>.md         # Agent configuration files
├── flake.nix                   # Nix development shell
├── pyproject.toml              # Python project configuration
├── uv.lock                     # Locked dependencies
└── .python-version             # Python version
```

---

## Build/Lint/Test Commands

### Environment Setup

```bash
# Enter Nix dev shell (provides uv, mdl, gh)
nix develop
```

### Testing Skills

```bash
# Run agentskills CLI to validate skill definitions
agentskills --help

# Validate a specific skill
agentskills validate skills/project-plan-formulation/SKILL.md

# Validate all skills
for skill in skills/*/SKILL.md; do
    agentskills validate "$skill"
done
```

### Linting and Formatting

```bash
# Markdown linting
mdl skills/**/*.md agents/**/*.md
```

---

## Skill Development

### SKILL.md Structure

All skills must be named `SKILL.md` (uppercase) and include YAML frontmatter:

```markdown
---
name: skill-name                # Required: kebab-case identifier
version: "1.0.0"                # Semantic versioning
description: Brief description  # Required: one-line summary (1-1024 chars)
allowed-tools: "Tool1,Tool2"    # Tools this skill uses
author: "Author Name"           # Optional
license: "MIT"                  # Optional
compatibility: "opencode"       # Optional: opencode, claude, all
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

### Naming Conventions

- **Skill names:** Must match `^[a-z0-9]+(-[a-z0-9]+)*$`
  - 1-64 characters
  - Lowercase alphanumeric with single hyphens
  - Must match the directory name
- **Skill directories:** `kebab-case` (e.g., `project-plan-formulation`)
- **Reference files:** `kebab-case.md` (e.g., `error-handling.md`)

### Reference Files

Organize supporting content in `references/` subdirectories:

**When to use reference files:**
- When a skill file exceeds 400 lines, look for content that can be extracted
- Focus on error handling instructions and corner-case scenarios
- Extract guidance that doesn't impact the skill's "happy path" workflow
- Keep the main SKILL.md focused on the primary workflow

**Example extraction:**
```markdown
## Step 5: Handle Errors

**If an error occurs:**

Load the error-handling reference for recovery steps:

Read({ filePath: "references/error-handling.md" })

**After reading**, follow the appropriate recovery procedure based on the error type.
```

### Reusable Scripts

When implementing deterministic steps in skills, prefer creating reusable bash or Python scripts:

1. **Create scripts** for operations that need to be performed consistently within a skill
2. **Place scripts** in a `scripts/` directory next to the SKILL.md file
3. **Document usage** in the skill's reference files or inline with code examples
4. **Example:** A script that validates YAML frontmatter could be placed at `skills/my-skill/scripts/validate-frontmatter.sh`

**Skill Structure with Scripts:**
```
skills/
  my-skill/
    SKILL.md              # Main skill definition
    references/           # Supporting docs
      error-handling.md
    scripts/              # Reusable scripts
      validate-frontmatter.sh
      extract-references.py
```

Benefits:
- Consistency across skill implementations
- Easier testing and maintenance
- Reduced duplication in skill definitions
- Scripts are co-located with the skill they support

---

## Agent Development

### Agent Configuration

Agents are defined as markdown files with YAML frontmatter:

```markdown
---
description: Reviews code for best practices   # Required
mode: subagent                                 # primary, subagent, or all
model: anthropic/claude-sonnet-4-20250514     # Optional: defaults to global
temperature: 0.1                               # Optional: 0.0-1.0
steps: 10                                      # Optional: max iterations
permission:                                    # Tool permissions
  edit: ask
  bash:
    "*": ask
    "git status": allow
  skill:
    "*": allow
    "experimental-*": ask
color: "#FF5733"                              # Optional: hex or theme color
hidden: false                                  # Hide from @ menu (subagent only)
---

You are a specialized agent. Your purpose is...

## Responsibilities

1. Focus area one
2. Focus area two

## Guidelines

- Guideline one
- Guideline two
```

### Agent Modes

- **primary**: Main agents users interact with directly (switch via Tab)
- **subagent**: Specialized agents invoked via @ mention or Task tool
- **all**: Can function as both

### Agent Permissions

Control tool access via frontmatter:

```yaml
# In agent.md frontmatter
permission:
  edit: deny          # ask, allow, or deny
  bash:
    "*": ask
    "git status*": allow
  skill:
    "*": allow
    "internal-*": deny
  task:               # Subagent invocation
    "*": deny
    "orchestrator-*": allow
```

### File Naming

- **Agent files:** `<agent-name>.md` (becomes the agent identifier)
- **Location:** `agents/` directory or `~/.config/opencode/agents/`

---

## Writing Conventions

### Step Instructions

1. **Clear actions:** Start with verbs (Use, Read, Write, Ask)
2. **Explicit blocking:** Mark steps requiring user input with `**BLOCKING STEP:**`
3. **Conditional logic:** Use `**If X:**` / **If Y:**` patterns
4. **Numbered lists:** For sequential actions
5. **Bulleted lists:** For options or alternatives

### Markdown Formatting

1. **Headings:** Use ATX style (`#`, `##`, `###`)
2. **Lists:** Use `-` for unordered, `1.` for ordered
3. **Code blocks:** Specify language for syntax highlighting
4. **Emphasis:** Use `**bold**` for important terms
5. **Line length:** Wrap at 80-120 characters
6. **Blank lines:** One between sections, two before headings

### User Interaction

- Use `question` tool for user prompts
- Provide multiple-choice options when possible
- Include "Other" or custom input option when appropriate
- Always wait for response before proceeding with blocking steps

---

## Development Workflow

### Adding a New Skill

1. Create directory: `mkdir -p skills/<skill-name>/references`
2. Create SKILL.md: `touch skills/<skill-name>/SKILL.md`
3. Add frontmatter with `name`, `version`, `description`, `allowed-tools`
4. Write structured steps using the conventions above
5. Validate: `agentskills validate skills/<skill-name>/SKILL.md`
6. Test invocation through appropriate agent

### Adding a New Agent

1. Create file: `touch agents/<agent-name>.md`
2. Add frontmatter with `description` and `mode`
3. Write system prompt defining agent behavior
4. Configure permissions as needed
5. Install to `~/.config/opencode/agents/` for testing

### Updating Existing Components

1. Edit `skills/<name>/SKILL.md` or `agents/<name>.md`
2. Update version in skill frontmatter if applicable
3. Update affected reference files
4. Validate changes
5. Reload OpenCode to pick up changes

---

## Testing

### Skills

Validated by:
1. YAML frontmatter parsing (name, description required)
2. Name format validation (`^[a-z0-9]+(-[a-z0-9]+)*$`)
3. Reference file existence checks
4. Workflow step validation
5. Agent invocation testing via `skill({ name: "..." })`

### Agents

Test by:
1. Verifying discovery in @ autocomplete (if not hidden)
2. Testing Task tool invocation from parent agents
3. Testing @ mention invocation directly
4. Validating permission restrictions
5. Checking tool access behavior

---

## Integration Patterns

### Skill + Subagent Pattern

For complex workflows, create both:

1. **Skill**: Defines the workflow steps (reusable instructions)
2. **Subagent**: Executes the workflow with specific permissions

Example:
```
skills/
  feature-planning/
    SKILL.md           # How to plan a feature
agents/
  feature-planner.md   # Agent that uses the skill
```

### Cross-Skill References

Skills can reference other skills:

```markdown
## Step 1: Analyze Requirements

Load the project planning skill for initial analysis:

skill({ name: "project-plan-formulation" })

**After loading**, follow the interview process defined there.
```

### Agent Delegation

Primary agents can invoke subagents in two ways:

1. **Via Task tool** (programmatic invocation):
```markdown
When detailed analysis is needed, delegate to the explore agent:

Use the task tool with subagent_type "explore" for codebase analysis.
```

2. **Via @ mention** (user or agent invocation):
```markdown
@explore find all occurrences of the User class in this codebase
```

**Note:** Users can invoke any subagent via @ mention, even if Task permissions would deny it.

---

## Security Considerations

- **Skills** should not expose or log secrets
- **Agents** should have minimal required permissions (principle of least privilege)
- **File writes** must respect project boundaries
- **User confirmation** required for destructive operations (use `ask` permission)
- **Task permissions** control which subagents can invoke others

---

## References

- [OpenCode Plugins](https://opencode.ai/docs/plugins/)
- [OpenCode Agents](https://opencode.ai/docs/agents/)
- [OpenCode Skills](https://opencode.ai/docs/skills/)
- [OpenCode SDK](https://opencode.ai/docs/sdk/)
- [agentskills CLI](https://github.com/agentskills/agentskills)
