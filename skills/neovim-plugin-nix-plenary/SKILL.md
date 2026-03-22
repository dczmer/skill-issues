---
name: neovim-plugin-nix-plenary
description: Bootstraps a new Neovim plugin project using Nix flakes and plenary.nvim for testing. Use when starting a new Neovim plugin with test-driven development.
allowed-tools: "Read,Glob,Grep,Bash,Write,Task,TodoWrite,question,skill"
version: "1.0.0"
---

## Introduction

This skill bootstraps a new Neovim plugin project using Nix flakes for development environments and plenary.nvim for testing.

**Use this skill when:**
- Starting a new Neovim plugin from scratch
- Setting up a project after project-plan-formulation skill
- Initializing a Neovim plugin codebase

**This skill requires:**
- `PROJECT_PLAN.md` (required - must exist before bootstrapping)
- Output will create: `lua/`, `tests/lua/`, `scripts/`, `flake.nix`, `AGENTS.md`

---

## Workflow

### Phase 1: Project Planning

1. **Run project-plan-formulation skill** to develop a comprehensive PROJECT_PLAN.md covering:
   - Overview and purpose
   - Tech stack (Lua, Nix, plenary.nvim)
   - Architecture (module structure)
   - Development and testing process
   - Conventions and rules
   - Security considerations

### Phase 2: Bootstrap from Documentation

2. **Run bootstrap-from-documentation skill** with the instructions from this skill to create:
   - Directory structure
   - flake.nix with wrapped Neovim
   - Test infrastructure

---

## Standard Project Structure

```
project/
├── flake.nix                    # Nix build with wrapped Neovim
├── lua/modulename/
│   ├── init.lua               # Public interface (entry point, M.setup)
│   └── core.lua               # Core utilities
├── tests/lua/modulename/
│   └── core_spec.lua          # Tests mirror lua/ structure
├── scripts/
│   └── minimal-init.lua       # Minimal Neovim config for testing
├── test_root/                  # Test data (real files, not mocks)
├── README.md
├── PROJECT_PLAN.md
└── AGENTS.md
```

---

## Module Pattern

Lua modules should follow this pattern:

```lua
local M = {}

---@type string|nil
M.property = nil

--- Setup the module
---@param opts table?
---@return table
function M.setup(opts)
    opts = opts or {}
    -- initialization logic
    return M
end

return M
```

**Key points:**
- `M.setup()` returns `M` (the module itself)
- Public properties are accessible directly on `M` after setup
- Third-party modules (telescope, cmp) should be loaded at setup time, not import time

---

## Testing Commands

Run tests with:

```sh
nix run .#nvim-test -- -u scripts/minimal-init.lua --headless -c 'PlenaryBustedFile tests/lua/path/to_spec.lua' -c 'qa!'
```

**Always use:**
- `-u scripts/minimal-init.lua` - minimal init for testing
- `PlenaryBustedFile` - run specific test file
- `PlenaryBustedDirectory` - run all tests in directory
- `-c 'qa!'` - exit after tests complete

---

## Test File Pattern

```lua
---
-- Tests for modulename.core
-- @module modulename.core_spec

local lua_module = require("modulename.core")

describe("modulename.core", function()
    before_each(function()
        lua_module.property = nil  -- reset state
    end)

    it("should do something", function()
        lua_module.setup({ option = "value" })
        assert.are.equal("expected", lua_module.property)
    end)
end)
```

**Key points:**
- Tests are in `tests/lua/` mirroring `lua/` structure
- File naming: `lua/modulename/core.lua` → `tests/lua/modulename/core_spec.lua`
- Reset module state in `before_each`
- Use `lua_module` as the require result variable name

---

## flake.nix Template

```nix
{
  description = "A Neovim plugin for ...";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        customRC = ''
          " Add plugin dependencies to rtp for plenary tests
          set rtp+=${pkgs.vimPlugins.nvim-cmp}
          set rtp+=${pkgs.vimPlugins.telescope-nvim}
          set rtp+=${pkgs.vimPlugins.plenary-nvim}
        '';
        runtimeInputs = with pkgs; [
          ripgrep
          fd
          fzf
        ];
        devPackages = with pkgs; [
          lua54Packages.luacheck
          lua-language-server
          stylua
        ];
        neovimWrapped = pkgs.wrapNeovim pkgs.neovim-unwrapped {
          configure = {
            inherit customRC;
            packages.myVimPackage = with pkgs.vimPlugins; {
              start = [
                plenary-nvim
                nvim-cmp
                cmp-buffer
                cmp-path
              ];
            };
          };
        };
        nvim-test-app = pkgs.writeShellApplication {
          name = "nvim-test";
          text = ''
            ${neovimWrapped}/bin/nvim "$@"
          '';
          inherit runtimeInputs;
        };
      in
      {
        packages = {
          luacheck = pkgs.lua54Packages.luacheck;
          stylua = pkgs.stylua;
        };
        apps = rec {
          default = nvim-test;
          nvim-test = {
            type = "app";
            program = "${nvim-test-app}/bin/nvim-test";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs =
            with pkgs;
            [
              git
            ]
            ++ runtimeInputs
            ++ devPackages;

          shellHook = ''
            echo "Neovim plugin development environment loaded"
            echo "Run 'nix run .#nvim-test -- -u scripts/minimal-init.lua --headless -c \"lua ...\"' to run tests"
          '';
        };
      }
    );
}
```

---

## minimal-init.lua Template

```lua
-- Minimal neovim configuration for testing plugin

-- Set runtimepath to include plugin and dependencies
vim.opt.runtimepath:append(vim.fn.fnamemodify(debug.getinfo(1).source:match("@(.*/)"), ":p") .. "..")
vim.opt.runtimepath:append(vim.fn.fnamemodify(debug.getinfo(1).source:match("@(.*/)"), ":p") .. "../../lua")

-- Set wiki_root to test_root for tests
vim.g.davewiki_test_root = vim.fn.fnamemodify(debug.getinfo(1).source:match("@(.*/)"), ":p") .. "../test_root"

-- Minimal plugin setup for testing
vim.opt.runtimepath:append(vim.g.davewiki_test_root)

-- Suppress startup messages
vim.opt.shortmess:append("I")

-- Minimal UI
vim.opt.number = false
vim.opt.relativenumber = false
```

---

## Code Quality Requirements

- **Type annotations:** All Lua code must include lua-language-server type annotations
- **Linting:** Run `luacheck` before committing (vim global warnings are expected)
- **Formatting:** Run `stylua` before committing
- **Tests:** All tests must pass before committing

**Linting command:**
```bash
nix develop -c luacheck lua/ tests/
```

**Formatting command:**
```bash
nix develop -c stylua lua/ tests/
```

---

## Antipatterns to Avoid

1. **Requiring third-party modules at import time**
   - Causes unnecessary startup errors
   - Load third-party Lua modules (telescope, cmp) at setup time, not import time

2. **Over-mocking in unit tests**
   - Produces passing tests for incorrect code
   - Use a directory of test files with real content (e.g., `test_root/`)

3. **Placing test files outside `tests/lua/` structure**
   - Tests must mirror the `lua/` directory structure
   - File naming: `lua/modulename/file.lua` → `tests/lua/modulename/file_spec.lua`

---

## AGENTS.md Requirements

Every Neovim plugin project should have an AGENTS.md with:

```markdown
# AGENTS.md

Instructions for AI coding assistants working on this project.

## Testing

Run tests with:
```sh
nix run .#nvim-test -- -u scripts/minimal-init.lua --headless -c 'PlenaryBustedFile tests/lua/path/to_spec.lua' -c 'qa!'
```

### Testing Rules

- **Never mock** vim internal functions or filesystem operations unless there is no alternative.
- Tests run against **real files** in `test_root/` — no mocking the filesystem.

### Test File Structure

- **Directory layout:** Tests mirror the `lua/` folder structure under `tests/lua/`
- **File naming:** Append `_spec.lua` to the corresponding module name
- **Examples:**
  - `lua/davewiki/init.lua` → `tests/lua/davewiki/init_spec.lua`
  - `lua/davewiki/core.lua` → `tests/lua/davewiki/core_spec.lua`
```

---

## Summary

When this skill completes, you will have:

1. A complete `PROJECT_PLAN.md` for the plugin
2. Standard directory structure (`lua/`, `tests/lua/`, `scripts/`)
3. A working `flake.nix` with wrapped Neovim for testing
4. A `minimal-init.lua` for test configuration
5. A `test_root/` directory for test data
6. An `AGENTS.md` with project-specific instructions
