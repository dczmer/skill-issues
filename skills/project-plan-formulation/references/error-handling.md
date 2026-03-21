# Error Handling Scenarios

This reference covers error handling for the project-plan-formulation skill. Load this file only when one of these scenarios occurs.

---

## Partial Completion

If user stops mid-interview:
1. Confirm they want to stop
2. Offer to save partial document
3. Mark incomplete sections with: `_[Section incomplete - stopped during interview]_`
4. Provide resume instructions: re-run the skill and it will automatically detect and load the saved partial `PROJECT_PLAN.md`, allowing the user to continue where they left off

---

## Contradictory Information

If user provides info that contradicts earlier sections:
1. Point out the contradiction
2. Ask which is correct
3. Offer to update the earlier section
4. Show both sections for review

---

## Unable to Answer

If user repeatedly says "I don't know":
1. Offer to explore codebase with `Glob`, `Grep`, or `Read`
2. Suggest specific files to check based on section topic:
   - For Overview: README.md, docs/, project description files
   - For Tech Stack: package.json, pyproject.toml, go.mod, Cargo.toml, etc.
   - For Architecture: docs/, diagrams/, src/ structure
   - For Development: Makefile, docker-compose.yml, .github/workflows/
   - For Conventions: .eslintrc*, .prettierrc*, ruff.toml, .editorconfig
   - For Security: auth-related code, config files, environment templates
3. Mark section for future completion
4. Offer to skip and continue with other sections

---

## File Write Failure

If `Write` fails:
1. Show the error message
2. Ask for alternative save location
3. Offer to display full content for manual copy-paste
4. Suggest checking file permissions