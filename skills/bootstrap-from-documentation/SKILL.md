---
name: bootstrap-from-documentation
description: Bootstraps a new project from PROJECT_PLAN.md by creating directory structure, configuration files, flake.nix, and testing the development environment. Use when you want to set up a project based on existing documentation.
allowed-tools: "Read,Glob,Grep,Bash,Write,Task,TodoWrite,question,skill"
version: "1.0.0"
---

## Introduction

This skill bootstraps a project from its PROJECT_PLAN.md documentation, creating the initial directory structure, configuration files, and validating that development tooling works correctly. It operates step-by-step with pauses between each step to allow you to explore, debug, and refine.

**Use this skill when:**
- Starting a new project from a completed PROJECT_PLAN.md
- Setting up a project after the project-plan-formulation skill
- Initializing a codebase from documentation

**This skill requires:**
- `PROJECT_PLAN.md` (required - bootstrap source)
- `README.md` (required - or will prompt to generate)
- `AGENTS.md` (required - or will prompt to generate)

---

## Step 0: Prerequisites Check

Execute this step before starting the bootstrap process.

### Step 0.1: Check for PROJECT_PLAN.md

Use `Glob` to check if `PROJECT_PLAN.md` exists in the project root.

**If `PROJECT_PLAN.md` does not exist or is empty:**
1. Use `question` to ask:
   - "PROJECT_PLAN.md is missing or empty. Would you like to create it first?"
   - Options: "Run project-plan-formulation skill" / "Abort"
2. **If user chooses project-plan-formulation:**
   - Use the `skill` tool to invoke `project-plan-formulation`
   - After it completes, return to Step 0.1
3. **If user chooses Abort:**
   - End the skill invocation immediately

### Step 0.2: Check for README.md

Use `Read` to check if `README.md` exists and has content.

**If `README.md` does not exist or is empty:**
1. Use `question` to ask:
   - "README.md is missing or empty. What would you like to do?"
   - Options: "Auto-generate from PROJECT_PLAN.md" / "I'll create it manually (abort)" / "Skip this check"
2. **If user chooses Auto-generate:**
   - Extract Overview and Tech Stack sections from `PROJECT_PLAN.md`
   - Create a basic README.md with:
     - Project name and description (from Overview)
     - Installation instructions (from Tech Stack / Development Process)
     - Usage/Quick Start (if documented)
   - Continue to Step 0.3
3. **If user chooses Abort:**
   - End the skill invocation
4. **If user chooses Skip:**
   - Continue to Step 0.3 without README.md

### Step 0.3: Check for AGENTS.md

Use `Read` to check if `AGENTS.md` exists and has content.

**If `AGENTS.md` does not exist or is empty:**
1. Use `question` to ask:
   - "AGENTS.md is missing or empty. What would you like to do?"
   - Options: "Auto-generate from PROJECT_PLAN.md" / "I'll create it manually (abort)" / "Skip this check"
2. **If user chooses Auto-generate:**
   - Extract relevant sections from `PROJECT_PLAN.md`
   - Create AGENTS.md with:
     - Project Overview (from Overview section)
     - Build/Lint/Test Commands (from Development and Testing section)
     - Code Style Guidelines (from Conventions section)
     - Git Conventions (if documented)
     - Security Considerations (from Security section)
   - Continue to Step 1
3. **If user chooses Abort:**
   - End the skill invocation
4. **If user chooses Skip:**
   - Continue to Step 1 without AGENTS.md

---

## Step 1: Run Documentation Consistency Check

**BLOCKING STEP:** This step must complete before proceeding.

### Step 1.1: Invoke Consistency Skill

Use the `skill` tool to invoke the `documentation-consistency` skill:

```
skill name="documentation-consistency"
```

### Step 1.2: Review Results and Pause

After the consistency check completes:
1. Review any inconsistencies found
2. Use `question` to ask:
   - "Documentation consistency check complete. Found [N] issues. Would you like to fix them before continuing, or proceed anyway?"
   - Options: "Fix issues first" / "Proceed anyway" / "Show me the issues"
3. **If "Fix issues first":**
   - Help user resolve each inconsistency
   - Re-run the consistency check
   - Repeat until no issues or user chooses to proceed
4. **If "Show me the issues":**
   - Display the full consistency report
   - Return to options after user reviews

**After this step:** STOP and wait for user confirmation before continuing to Step 2.

---

## Step 2: Create Directory Structure

**BLOCKING STEP:** This step must complete before proceeding.

### Step 2.1: Parse Project Plan for Structure

1. Use `Read` to load `PROJECT_PLAN.md`
2. Extract directory structure from:
   - Architecture Overview section (look for "structure", "directories", "organization")
   - File Structure / Conventions section (if present)
3. Identify directories mentioned by name paths (e.g., `src/components/`, `tests/`, `docs/`)

### Step 2.2: Create Todo List

Use `TodoWrite` to create a todo list for tracking progress:

- "Run documentation-consistency skill" — completed
- "Create directory structure" — in_progress
- "Create flake.nix with devShell" — pending
- "Create stub files and modules" — pending
- "Test linting/type checking" — pending
- "Test unit test support" — pending
- "Test build process" — pending
- "Run final consistency check" — pending

### Step 2.3: Create Directories

Use `Bash` to create the identified directories:

```bash
mkdir -p <directory1> <directory2> ...
```

If no explicit structure is documented, create a sensible default based on the tech stack:
- **Python:** `src/`, `tests/`, `docs/`
- **Node.js/TypeScript:** `src/`, `tests/` or `__tests__/`, `dist/`
- **Go:** `cmd/`, `pkg/`, `internal/`
- **Rust:** `src/`, `tests/`
- **Nix:** derivations in appropriate locations

### Step 2.4: Pause for Review

Use `question` to ask:
- "Created directory structure: [list directories]. Does this look correct?"
- Options: "Continue" / "I need to make changes" / "Abort"

**If "I need to make changes":**
- Ask user what directories to add/remove/modify
- Apply changes
- Show updated structure and ask again

**After this step:** STOP. Update todo list (mark "Create directory structure" as completed, mark next step as in_progress). Wait for user to confirm they're ready to continue.

---

## Step 3: Create flake.nix

**BLOCKING STEP:** This step must complete before proceeding.

### Step 3.1: Parse Tech Stack for Dependencies

1. Use `Read` to load `PROJECT_PLAN.md`
2. Extract from Tech Stack section:
   - Programming language and version
   - Frameworks and libraries
   - Build tools
   - Development tools (linters, formatters)
   - Test frameworks
3. Note package names that need to be searched in nixpkgs

### Step 3.2: Search for Nix Packages

For each dependency identified, use `Bash` to search nixpkgs:

```bash
nix search nixpkgs PACKAGE_NAME
```

Common package mappings:
- Python: `python3XX`, `python3XXPackages.packageName`
- Node.js: `nodejs_XX`, `nodePackages.packageName`
- Go: `go`, `gotools`
- Rust: `rustc`, `cargo`, `rust-analyzer`
- Generic tools: search by exact name or common aliases

### Step 3.3: Create flake.nix

Use `Write` to create `flake.nix` in the project root with:

```nix
{
  description = "Project description from Overview section";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Language-specific packages
        langPackages = [
          # Language runtime, e.g., python312, nodejs_20
        ];
        
        devPackages = [
          # Development tools, e.g., git, just, direnv
        ];
        
        lintPackages = [
          # Linters and formatters
        ];
        
        testPackages = [
          # Test frameworks
        ];
        
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = langPackages ++ devPackages ++ lintPackages ++ testPackages;
          
          shellHook = ''
            # Environment setup
            echo "Development environment loaded"
          '';
        };
      }
    );
}
```

Customize based on detected tech stack.

### Step 3.4: Pause for Review

Use `question` to ask:
- "Created flake.nix with the following packages: [list]. Would you like to review or modify?"
- Options: "Continue" / "Edit flake.nix" / "Add more packages" / "Abort"

**If "Edit flake.nix" or "Add more packages":**
- Ask what changes are needed
- Apply changes
- Show updated flake.nix

**After this step:** STOP. Update todo list. Wait for user confirmation before continuing.

---

## Step 4: Create Stub Files and Modules

**BLOCKING STEP:** This step must complete before proceeding.

### Step 4.1: Identify Files and Modules from Project Plan

1. Use `Read` to load `PROJECT_PLAN.md`
2. Extract from multiple sections:
   - **Architecture Overview:** Components, modules, services mentioned by name
   - **File Structure:** Explicit file organization
   - **Conventions:** Naming conventions, module patterns
3. Create a list of files and their expected contents:
   - File paths
   - Module/function/class names mentioned
   - Import/dependency relationships

### Step 4.2: Create Stub Files

For each identified file:

1. Determine the appropriate language from tech stack
2. Create the file with:
   - File header/docstring
   - Module-level identifiers (classes, functions, interfaces) mentioned by name
   - Placeholder implementations (`pass`, `TODO`, `raise NotImplementedError`)

**Stub Template Examples:**

**Python:**
```python
"""
Module: [module_name]
Purpose: [from project plan]
"""

class ClassName:
    """Docstring from project plan."""
    pass

def function_name():
    """Docstring from project plan."""
    pass
```

**TypeScript/JavaScript:**
```typescript
/**
 * Module: [module_name]
 * Purpose: [from project plan]
 */

export class ClassName {
  // TODO: implement
}

export function functionName(): ReturnType {
  // TODO: implement
}
```

**Go:**
```go
// Package [name] - [purpose from project plan]
package packagename

// FunctionName - [description]
func FunctionName() {
    // TODO: implement
}
```

### Step 4.3: Pause for Review

Use `question` to ask:
- "Created [N] stub files with [M] module identifiers. Review the structure?"
- Options: "Continue" / "Show me the files" / "I need changes" / "Abort"

**If "Show me the files":**
- List all created files with their stubs
- Return to options

**If "I need changes":**
- Ask what to add/remove/modify
- Apply changes
- Show updated structure

**After this step:** STOP. Update todo list. Wait for user confirmation before continuing.

---

## Step 5: Test Linting and Type Checking

**BLOCKING STEP:** This step must complete before proceeding.

### Step 5.1: Create Temporary Test File

Create a temporary file in the appropriate language to test linting:

**Python (temp_lint_test.py):**
```python
def test_function() -> str:
    """Test function for linting."""
    return "test"
```

**TypeScript (temp_lint_test.ts):**
```typescript
export function testFunction(): string {
  return "test";
}
```

### Step 5.2: Run Linter

Based on detected tech stack, run the appropriate linter:

```bash
# Python
uv run ruff check . || python -m pylint . || python -m flake8 .

# TypeScript/JavaScript
npx eslint . || npm run lint

# Go
gofmt -d . || go vet ./...

# Rust
cargo clippy
```

If flake.nix was created, use:
```bash
nix develop -c <lint_command>
```

### Step 5.3: Run Type Checker

Based on detected tech stack:

```bash
# Python
uv run mypy . || python -m mypy .

# TypeScript
npx tsc --noEmit

# Go
# Built into compiler

# Rust
cargo check
```

### Step 5.4: Clean Up and Report

1. Remove temporary test file
2. Use `question` to ask:
   - "Linting and type checking completed. Results: [summary]. Continue?"
   - Options: "Continue" / "Fix issues first" / "Abort"

**If "Fix issues first":**
- Help resolve linting/type errors
- Re-run checks
- Repeat until clean or user chooses to proceed

**After this step:** STOP. Update todo list. Wait for user confirmation before continuing.

---

## Step 6: Test Unit Test Support

**BLOCKING STEP:** This step must complete before proceeding.

### Step 6.1: Create Temporary Test File

Create a temporary test file to verify test framework works:

**Python (tests/temp_test.py):**
```python
def test_placeholder():
    assert True
```

**TypeScript (temp.test.ts):**
```typescript
import { describe, it } from 'vitest'; // or jest/mocha

describe('placeholder', () => {
  it('should pass', () => {
    expect(true).toBe(true);
  });
});
```

**Go (temp_test.go):**
```go
package packagename

import "testing"

func TestPlaceholder(t *testing.T) {
    // passes
}
```

### Step 6.2: Run Tests

Based on detected test framework:

```bash
# Python
uv run pytest tests/ -v

# TypeScript - check package.json for test command
npm test || npm run test

# Go
go test ./...

# Rust
cargo test
```

### Step 6.3: Clean Up and Report

1. Remove temporary test file
2. Use `question` to ask:
   - "Test framework executed successfully. [N] tests passed. Continue?"
   - Options: "Continue" / "Fix issues first" / "Abort"

**After this step:** STOP. Update todo list. Wait for user confirmation before continuing.

---

## Step 7: Test Build Process

**BLOCKING STEP:** This step must complete before proceeding.

### Step 7.1: Parse Build Commands from Project Plan

1. Use `Read` to load `PROJECT_PLAN.md`
2. Extract build commands from Development and Testing Process section
3. Identify required build artifacts

### Step 7.2: Handle Missing Build Dependencies

If build requires source files that don't exist yet:
- Create minimal placeholder files to satisfy build
- For interpretted languages (Python), this step may be a no-op
- For compiled languages (Go, Rust, TypeScript), create minimal entry points

### Step 7.3: Execute Build

```bash
# Python (usually no build, but check for pyproject.toml)
uv build || python -m build

# TypeScript
npm run build

# Go
go build ./...

# Rust
cargo build

# If flake.nix exists
nix build
```

### Step 7.4: Clean Up and Report

1. Remove any temporary placeholder files created for build
2. Use `question` to ask:
   - "Build process completed successfully. Continue?"
   - Options: "Continue" / "Fix issues first" / "Abort"

**After this step:** STOP. Update todo list. Wait for user confirmation before continuing.

---

## Step 8: Final Documentation Consistency Check

**BLOCKING STEP:** This step must complete before proceeding.

### Step 8.1: Run Consistency Skill Again

Use the `skill` tool to invoke `documentation-consistency` skill again:

```
skill name="documentation-consistency"
```

### Step 8.2: Report Final Status

After the consistency check:
1. Summarize all changes made during bootstrap
2. List any remaining inconsistencies
3. Use `question` to ask:
   - "Bootstrap complete! Final consistency check done. What would you like to do next?"
   - Options: "Done - end skill" / "Review and fix remaining issues" / "Run specific step again"

### Step 8.3: Mark All Todos Complete

Use `TodoWrite` to mark all items as completed.

---

## Error Handling

Throughout the skill, if any step fails or encounters an unexpected issue:

1. **Stop immediately** - do not proceed to the next step
2. **Preserve context** - keep track of what was completed successfully
3. **Ask user** - use `question` to present options:
   - "An error occurred during [step name]: [error message]. What would you like to do?"
   - Options: "Retry this step" / "Skip this step" / "Abort skill"

**If user chooses "Retry this step":**
- Attempt the step again
- If it fails again, offer the same options

**If user chooses "Skip this step":**
- Mark the step as skipped in the todo list
- Proceed to the next step
- Warn user that skipping may cause issues in subsequent steps

**If user chooses "Abort skill":**
- Print a summary of what was completed
- End the skill invocation

---

## Resume Support

If the skill is interrupted or aborted, users can resume from the last completed step:

1. The skill should check for partially completed work (e.g., files created, directories made)
2. When re-invoked, present the current state to the user:
   - "I found existing bootstrap work. Last completed step was [X]. Would you like to resume?"
   - Options: "Resume from last step" / "Start fresh"

---

## Summary

When the skill completes successfully:

```
Bootstrap complete! Created:

Directory structure:
- [list of created directories]

Configuration:
- flake.nix with devShell
- [any other config files]

Stub files:
- [count] files with module stubs

Verified:
- Linting works
- Type checking works
- Tests run
- Build succeeds

Next steps:
- Implement the stubbed modules
- Add tests for your functionality
- Run 'nix develop' to enter your dev environment
```