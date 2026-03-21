---
name: task
description: Manage a project-specific todo list using dstask with tag-based filtering. Tags +PROJECT and +PROJECT:BRANCH are used for project/branch scope. Use when user mentions "TODO" in their request (e.g., "add task to TODO", "print my TODO list", "start task 1 from TODO").
allowed-tools: "Bash,Read,Glob,Grep"
version: "1.1.0"
---

## Introduction

This skill manages a per-project task list using `dstask`. Tasks are tagged with `+PROJECT` (project-wide) and `+PROJECT:BRANCH` (branch-specific) to enable scoped filtering without using the global `dstask context` command.

---

## Step 1: Detect Project and Branch

Use `Bash` to detect the project name and current branch:

```bash
git rev-parse --show-toplevel 2>/dev/null | xargs -I{} basename {}
git branch --show-current 2>/dev/null
```

Store these values:
- `PROJECT` = project name (e.g., `myproject`)
- `BRANCH` = branch name (e.g., `feature-branch`)

---

## Step 2: Parse User Intent and Execute Command

### View Tasks

**Trigger phrases:** "show", "view", "print", "list", "display", "my TODO", "todo list"

**If user asks for "project TODO"** (project-scoped):
```bash
dstask show-open -- +PROJECT
```
Example: `dstask show-open -- +myproject`

**If user asks for "all TODO" or "full TODO"** (unfiltered):
```bash
dstask show-open
```

**Default:** If unclear, prefer project-scoped view with `+PROJECT`.

---

### Add Task

**Trigger phrases:** "add", "create", "new task", "TODO:"

```bash
dstask add <task summary> +PROJECT +PROJECT:BRANCH
```
Example: `dstask add Fix login bug +myproject +myproject:feature-branch`

Extract the task description from the user's request. Additional tags can be added inline (e.g., `+bug`, `+feature`).

---

### Complete Task

**Trigger phrases:** "complete", "done", "finish", "resolve", "close"

```bash
dstask <id> done [optional closing note]
```
Example: `dstask 1 done`

Extract the task ID from the user's request (e.g., "complete task 1" → `dstask 1 done`).

---

### Modify Task

**Trigger phrases:** "modify", "change", "update", "set priority", "retag"

```bash
dstask <id> modify [+tag] [-tag] [P1/P2/P3]
```
Example: `dstask 1 modify +urgent P1`

Supports modifying:
- Tags: `+tag` to add, `-tag` to remove
- Priority: `P0` (critical), `P1` (high), `P2` (normal), `P3` (low)

---

### Start Task

**Trigger phrases:** "start", "begin", "work on", "activate"

```bash
dstask <id> start
```

---

### Stop Task

**Trigger phrases:** "stop", "pause", "hold", "deactivate"

```bash
dstask <id> stop
```

---

### Show Active Tasks

**Trigger phrases:** "active", "in progress", "started", "working on"

```bash
dstask show-active
```

---

### Show Paused Tasks

**Trigger phrases:** "paused", "stopped", "on hold"

```bash
dstask show-paused
```

---

## Step 3: Display Results

After executing the dstask command, display the output directly to the user.

---

## Error Handling

If `dstask` command fails:
1. Check if dstask is installed: `which dstask`
2. Check if in a git repository
3. Display the error message and suggest: `dstask help <command>`

---

## Tag Reference

| Tag | Scope | Description |
|-----|-------|-------------|
| `+PROJECT` | Project-wide | All tasks for this project across branches |
| `+PROJECT:BRANCH` | Branch-specific | Tasks for this specific project+branch |

Use `+PROJECT` when viewing tasks to see everything related to the project. Use `+PROJECT:BRANCH` when you want to filter to just the current branch.
