---
name: neovim-plugin-bootstrap
description: Bootstraps a new Neovim plugin project using Nix flakes and plenary.nvim for testing. Use when starting a new Neovim plugin from scratch.
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
                # additional vim plugins for dependencies
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
          # expose development tool packages for the agent to use
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
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"
vim.cmd([[
    filetype on
    filetype indent on
    filetype plugin on
    syntax on
]])
vim.cmd.colorscheme("elflord")

-- Add the current directory (structured as a vim plugin directory) to the `runtimepath`.
vim.opt.runtimepath:append(".")
```

---

## AGENTS.md Template

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
- Tests run against **real files** in a folder of test files — no mocking the filesystem without approval from the user.

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
