---
name: neovim-plugin-dev
description: Reference guide for developing Neovim plugins using Lua, Nix, and plenary.nvim. Load this skill when working on an existing Neovim plugin project.
allowed-tools: "Read,Glob,Grep,Bash,Write,Task,TodoWrite,question,skill"
version: "1.0.0"
---

## Introduction

This skill provides guidance for ongoing development of Neovim plugins using Lua, Nix flakes, and plenary.nvim for testing.

**Use this skill when:**
- Working on an existing Neovim plugin codebase
- Adding features or fixing bugs in a plugin
- Writing or modifying tests
- Referencing Neovim APIs and documentation

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

## Exploring Neovim Documentation

When building a Neovim plugin, you often need to reference internal APIs, vim functions, and configuration options. Here are the best ways to access Neovim documentation:

### Method 1: Local Runtime Documentation

If you know the Neovim installation location, documentation files are stored under `runtime/doc/`:

```bash
# Find Neovim runtime path
nix run .#nvim-test -- --headless -c 'echo $VIMRUNTIME' -c 'qa!' 2>&1 | head -1

# Common locations in Nix store
ls $(nix build .#nvim-test --no-link --print-out-paths)/share/nvim/runtime/doc/
```

Documentation files use the `.txt` extension (e.g., `api.txt`, `lua.txt`, `options.txt`).

### Method 2: Online Documentation Browser

For quick reference without starting Neovim:

**Vim documentation (HTML):** https://vimdoc.sourceforge.net/htmldoc/

Browse categories like:
- `eval.html` - Vimscript functions and expressions
- `options.html` - Configuration options
- `autocmd.html` - Autocommands
- `map.html` - Key mappings

**Neovim-specific docs:** https://neovim.io/doc/user/

- `api.html` - Lua API functions
- `lua.html` - Lua scripting guide
- `lsp.html` - LSP client API
- `treesitter.html` - Treesitter integration

### Method 3: Headless Neovim Help Commands

Query documentation directly from the command line:

```bash
# View help for a specific topic and output to stdout
nix run .#nvim-test -- --headless -c "h quickfix" -c ":!cat %" -c "qa" 2>/dev/null

# Search for a pattern in help files
nix run .#nvim-test -- --headless -c "helpgrep lua_api" -c "cfirst" -c ":!cat %" -c "qa" 2>/dev/null

# List all functions matching a pattern
nix run .#nvim-test -- --headless -c "h vim.api.nvim_" -c ":!cat %" -c "qa" 2>/dev/null
```

**Common help topics for plugin development:**
- `:h api` - Lua API reference
- `:h lua-guide` - Lua scripting in Neovim
- `:h autocommand` - Event handling
- `:h map` - Key mapping functions
- `:h vim.opt` - Option manipulation
- `:h vim.fn` - Vimscript function access
- `:h lsp` - Language Server Protocol
- `:h treesitter` - Syntax tree parsing

### Method 4: Lua API Reference

For Lua-specific development:

```bash
# List all vim.api functions
nix run .#nvim-test -- --headless -c "lua print(vim.inspect(vim.api))" -c "qa!" 2>&1

# Check a specific API function signature
nix run .#nvim-test -- --headless -c "lua print(vim.inspect(vim.api.nvim_create_autocmd))" -c "qa!" 2>&1
```

### Method 5: Type Annotations with lua-language-server

The `lua-language-server` included in the dev shell provides inline documentation:

1. Hover over Neovim API calls in your editor to see signatures
2. Use `@class` and `@field` annotations for custom types
3. Reference `vim.*` types for autocomplete and documentation

```lua
---@param opts table See :h nvim_create_autocmd for options
function M.setup_autocmd(opts)
    -- lua-language-server will show nvim_create_autocmd signature
    vim.api.nvim_create_autocmd("BufWritePost", opts)
end
```

---

## Additional Development Tips

### Debugging Plugin Issues

1. **Use `vim.notify()` for logging:**
   ```lua
   vim.notify("Debug: " .. vim.inspect(value), vim.log.levels.DEBUG)
   ```

2. **Enable verbose mode for tracing:**
   ```bash
   nix run .#nvim-test -- -V15log.txt -u scripts/minimal-init.lua
   ```

3. **Test in isolation:**
   Always use the minimal init when debugging to rule out conflicts with other plugins.

### Testing Best Practices

1. **Test against real scenarios:**
   - Create representative test files in `test_root/`
   - Test edge cases (empty files, binary files, large files)
   - Verify behavior with different filetypes

2. **Mock only when necessary:**
   - Use real filesystem operations where possible
   - Mock time-sensitive operations or external API calls
   - Document why mocking is needed

3. **Organize tests logically:**
   - Group related tests in `describe()` blocks
   - Use clear, descriptive test names
   - One assertion per test when possible

### Common Pitfalls

1. **Global namespace pollution:**
   - Always use `local M = {}` pattern
   - Avoid creating global variables
   - Use `vim.g.` for intentional globals only

2. **Lazy loading issues:**
   - Don't assume plugins are loaded at require time
   - Use `pcall(require, "plugin")` for optional dependencies
   - Check for API availability before calling

3. **Autocmd cleanup:**
   - Store autocmd IDs for cleanup in `M.cleanup()`
   - Use `augroup` to prevent duplicate registrations
   - Clear autocmds in `before_each` for tests

---

## Quick Reference

### Common Commands

```bash
# Run all tests
nix run .#nvim-test -- -u scripts/minimal-init.lua --headless -c 'PlenaryBustedDirectory tests/lua' -c 'qa!'

# Run specific test file
nix run .#nvim-test -- -u scripts/minimal-init.lua --headless -c 'PlenaryBustedFile tests/lua/modulename/core_spec.lua' -c 'qa!'

# Lint code
nix develop -c luacheck lua/ tests/

# Format code
nix develop -c stylua lua/ tests/

# Check docs for API function
nix run .#nvim-test -- --headless -c "h nvim_create_autocmd" -c ":!cat %" -c "qa" 2>/dev/null
```
