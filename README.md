My personal agent skills library.

WARNING: I have no idea what I'm doing this is just practice.

Includes a `nix` development shell to provide an environment for tooling and testing utilities:
- [uv](https://github.com/astral-sh/uv) manages the python environment and packages
- [agentskills](https://github.com/agentskills/agentskills/tree/main) python library and CLI tools

## Available Skills

This library provides the following skills for use with agentic coding tools:

| Skill | Description |
|-------|-------------|
| `bootstrap-from-documentation` | Bootstraps a new project from PROJECT_PLAN.md |
| `documentation-consistency` | Check and fix consistency across README.md, PROJECT_PLAN.md, AGENTS.md, and flake.nix |
| `feature-implementation` | Implements a feature from a GitHub issue specification using TDD approach |
| `feature-planning` | Interactive analysis and requirements gathering for creating feature specifications |
| `neovim-plugin-bootstrap` | Bootstraps a new Neovim plugin project using Nix flakes and plenary.nvim |
| `neovim-plugin-dev` | Reference guide for developing Neovim plugins using Lua, Nix, and plenary.nvim |
| `project-plan-formulation` | Conducts iterative interviews to develop comprehensive project planning documents |
| `task` | Manage a project-specific todo list using dstask with tag-based filtering |

## Installation

Install skills and agents into OpenCode's configuration:

```bash
ln -s $(pwd) ~/.config/opencode/skills/skill-issues

ln -s $(pwd)/agents ~/.config/opencode/agents/skill-issues
```

## Verification

After installation, verify skills and agents are discoverable:

```bash
# Check skills are available in the /skills menu
# Type `/skills` in the OpenCode prompt to see available skills

# Verify agents appear in @ autocomplete
# Type @ in the OpenCode prompt to see available agents

# Test skill loading
/skill feature-planning

# Test agent invocation
@feature-planner help me plan a new feature
```

## Usage Examples

### Invoking Skills

Skills can be loaded via the `/skills` menu or by typing `/<skill-name>`:

```markdown
# List all available skills
/skills

# Load a specific skill directly
/feature-implementation

# The skill's instructions will guide the agent through the process
```

### Invoking Agents

Agents can be invoked via @ mention:

```markdown
@feature-planner create a feature specification for adding dark mode
```

Or via Task tool from other agents:

```markdown
When planning is needed, delegate to the feature planner:

Use the task tool with subagent_type "feature-planner" for requirements analysis.
```

