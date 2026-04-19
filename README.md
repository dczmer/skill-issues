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

### As OpenCode Plugin

Install skills and agents into OpenCode's configuration:

```bash
# Global installation (recommended)
ln -s $(pwd) ~/.config/opencode/skills/skill-issues

# Or for agents only
ln -s $(pwd)/agents ~/.config/opencode/agents/skill-issues

# Claude compatibility (legacy)
ln -s $(pwd) ~/.agents/skills/skill-issues
```

### Project-Local Installation

For project-specific usage:

```bash
# Within your project
cd your-project/
ln -s /path/to/skill-issues .opencode/skills/skill-issues
```

## Verification

After installation, verify skills and agents are discoverable:

```bash
# Check skills are visible in the skill tool
# In OpenCode, the skill tool will list available skills in <available_skills>

# Verify agents appear in @ autocomplete
# Type @ in the OpenCode prompt to see available agents

# Test skill loading
skill({ name: "feature-planning" })

# Test agent invocation
@feature-planner help me plan a new feature
```

## Usage Examples

### Invoking Skills

Skills can be loaded via the native `skill` tool:

```markdown
# Load a skill to access its workflow
skill({ name: "feature-implementation" })

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

## Discovery Paths

OpenCode searches for skills and agents in these locations:

**Skills:**
- `~/.config/opencode/skills/<name>/SKILL.md` (OpenCode native)
- `~/.agents/skills/<name>/SKILL.md` (Agent-compatible)
- `.opencode/skills/<name>/SKILL.md` (Project-local)
- `.agents/skills/<name>/SKILL.md` (Project-local, agent-compatible)

**Agents:**
- `~/.config/opencode/agents/<name>.md` (OpenCode native)
- `.opencode/agents/<name>.md` (Project-local)

## Troubleshooting

### Skills Not Appearing

1. Verify `SKILL.md` is spelled in all caps
2. Check frontmatter includes `name` and `description`
3. Ensure skill name matches directory name
4. Check permissions—skills with `deny` are hidden
5. Verify installation path is in discovery locations

### Agents Not Discoverable

1. Verify `.md` file extension
2. Check frontmatter includes `description`
3. For subagents, ensure `mode: subagent` is set
4. Check `hidden: true` isn't hiding from @ menu
5. Verify file is in `agents/` directory or `~/.config/opencode/agents/`

### Permission Issues

1. Check global `opencode.json` permission settings
2. Verify agent-specific permission overrides
3. Review skill-specific permissions in `permission.skill`
4. Ensure task permissions allow subagent invocation
