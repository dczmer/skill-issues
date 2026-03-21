# Documentation Consistency

This skill checks that README.md, PROJECT_PLAN.md, AGENTS.md, and flake.nix are consistent with each other and with the actual state of the project.

## Invocation

Use this skill when:
- You ask to "sync documentation", "check doc consistency", or "update docs"
- Making changes that affect project structure, conventions, or features
- Re-running after significant project changes

## Process

Use a subagent to perform the following checks:

### 1. Project README vs PROJECT_PLAN

Check that README.md contains:
- Accurate description matching PROJECT_PLAN's Overview section
- Correct installation instructions matching PROJECT_PLAN's dependencies
- Configuration options matching PROJECT_PLAN's Architecture
- Correct GitHub repository URL

### 2. AGENTS.md vs PROJECT_PLAN

Check that AGENTS.md doesn't contradict PROJECT_PLAN:
- Testing commands match PROJECT_PLAN's Development and Testing Process
- Security rules match PROJECT_PLAN's Security Considerations
- Antipatterns match PROJECT_PLAN's Antipatterns to Avoid
- Directory structure matches PROJECT_PLAN's Architecture

### 3. Actual Code vs Documentation

Check that documented items still exist:
- Directory structure in docs matches actual project structure
- Listed dependencies match flake.nix inputs and are still in use
- Configuration options match implemented setup()

### 4. Cross-Reference Accuracy

Check that:
- All documents reference same project name
- Version numbers are consistent (if applicable)
- Key features are consistently described

### 5. Flake.nix vs Documentation

Check that flake.nix is consistent with documentation:
- Dependencies in flake inputs match PROJECT_PLAN's Tech Stack
- Package names (`nvim-test`, `davewiki`, etc.) match documented build/run commands
- Dev shell tools match PROJECT_PLAN's Development Tools
- Version constraints align with documented versions

## Output

Report findings as a structured list:
- **Inconsistencies found:** Items that don't match across documents
- **Outdated information:** Items in docs that don't match actual code
- **Missing documentation:** Items in code not reflected in docs
- **Recommendations:** Specific updates needed

Ask user which updates to apply before making changes.