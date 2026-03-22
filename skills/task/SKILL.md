---
name: task
description: Manage a project-specific todo list using dstask with tag-based filtering. Tags +PROJECT and +PROJECT:BRANCH are used for project/branch scope. Use when user mentions "TODO" in their request (e.g., "add task to TODO", "print my TODO list", "start task 1 from TODO").
allowed-tools: "Bash,Read,Glob,Grep"
version: "1.2.0"
---

## Introduction

This skill manages a per-project task list using `dstask` with project and branch scoping. Tasks are filtered using the `project:PROJECT_NAME` parameter and optional `+PROJECT:BRANCH` tags to show relevant tasks based on the current branch context.

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
- `IS_FEATURE_BRANCH` = true if BRANCH is neither "main" nor "master", false otherwise

---

## Step 2: Determine Scope

Based on the branch and user request, determine the appropriate scope:

### Branch Types

| Branch | Behavior |
|--------|----------|
| `main` or `master` | Project scope: all tasks for this project |
| Feature branch | Branch scope: only tasks for this project AND branch |

### Keyword Overrides

| Keyword | Scope |
|---------|-------|
| "all" | Project scope (ignores branch filter) |
| "global" | Project scope (ignores branch filter) |

**On main/master branch:** Commands use `project:PROJECT` to show all project tasks.

**On feature branch:** Commands use `project:PROJECT` plus `+PROJECT:BRANCH` tag to filter to branch-specific tasks, unless user specifies "all" or "global".

---

## Step 3: Parse User Intent and Execute Command

### View Tasks

**Trigger phrases:** "show", "view", "print", "list", "display", "my TODO", "todo list"

**User asks for "all" or "global" (project-wide view):**
```bash
dstask show-open project:PROJECT
```
Example: `dstask show-open project:myproject`

**On main/master branch (project-wide view):**
```bash
dstask show-open project:PROJECT
```

**On feature branch (branch-scoped view):**
```bash
dstask show-open project:PROJECT +PROJECT:BRANCH
```
Example: `dstask show-open project:myproject +myproject:feature-login`

---

### Add Task

**Trigger phrases:** "add", "create", "new task", "TODO:"

**On main/master branch:**
```bash
dstask add project:PROJECT "<task summary>" [+TAG]
```
Example: `dstask add project:myproject "Fix deployment bug" +bug`

**On feature branch:**
```bash
dstask add project:PROJECT "<task summary>" +PROJECT:BRANCH [+TAG]
```
Example: `dstask add project:myproject "Implement login form" +myproject:feature-login`

**User specifies "global" task (visible across all branches):**
```bash
dstask add project:PROJECT "<task summary>"
```
This creates a project-level task without the branch-specific tag.

Additional tags can be added inline (e.g., `+bug`, `+feature`).

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

**On main/master branch:**
```bash
dstask show-active project:PROJECT
```

**On feature branch:**
```bash
dstask show-active project:PROJECT +PROJECT:BRANCH
```

---

### Show Paused Tasks

**Trigger phrases:** "paused", "stopped", "on hold"

**On main/master branch:**
```bash
dstask show-paused project:PROJECT
```

**On feature branch:**
```bash
dstask show-paused project:PROJECT +PROJECT:BRANCH
```

---

## Step 4: Display Results

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
| `+PROJECT:BRANCH` | Branch-specific | Tasks for this specific project+branch |

The `project:PROJECT` parameter filters to all tasks for the project. The `+PROJECT:BRANCH` tag further filters to tasks for the current branch.
