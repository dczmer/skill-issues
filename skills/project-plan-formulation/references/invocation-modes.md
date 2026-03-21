# Invocation Modes

This reference covers three optional invocation modes that modify how the project-plan-formulation skill operates. Load this file only when one of these modes is triggered.

---

## Supplemental Context (Step 0.2)

The user may provide supplemental context or instructions at invocation (e.g., "read AGENTS.md and tests/", "focus on security aspects").

**If supplemental context is provided:**
1. Parse the invocation for file paths, directories, or specific instructions
2. Use `Read`, `Grep`, or `Glob` to gather the referenced materials
3. Summarize what you've found and how it will inform the interview
4. Ask if there's anything else to review before starting

**If no supplemental context:**
- Proceed directly to Section 1 (or the targeted section, if `--section` was used)
- Note that you'll rely on the user's knowledge during the interview
- Mention that you can read files during the interview if references come up

---

## Section Targeting (Step 0.3)

Check if the user provided a `--section` flag in the invocation.

**If `--section` is present:**
1. Parse the section identifier. Match against sections using any of:
   - **Number:** `1` through `6` maps directly to Sections 1-6
   - **Exact name:** e.g., `"Tech Stack"`, `"Architecture Overview"`
   - **Keyword:** Case-insensitive partial match (e.g., `security` matches "Security Considerations", `dev` matches "Development and Testing Process", `conventions` matches "Conventions and Rules")
2. If the match is ambiguous (e.g., keyword matches multiple sections), use `AskUserQuestion` to ask the user to clarify which section they meant, listing the matching candidates.
3. If no match is found, inform the user that the section identifier was not recognized, list valid section names and numbers, and ask them to try again.
4. **Require an existing plan:** If `PROJECT_PLAN.md` does not exist, inform the user that section targeting requires an existing plan to provide context, and ask whether to proceed with a full interview instead.
5. Once the target section is resolved:
   - Load the existing `PROJECT_PLAN.md` content (if not already loaded in Step 0.1)
   - Skip directly to the targeted section's Step X.1
   - Pre-populate the section with existing content from the plan (same as the "Update it" flow)
   - After the targeted section is approved, skip to Step 7 (Final Assembly) — merge the updated section back into the existing plan, preserving all other sections unchanged
   - Present the updated plan and proceed through Steps 7.2-7.4 as normal

**If `--section` is not present:**
- Proceed with the normal sequential flow starting at Section 1

---

## Targeted Update (Step 0.4)

This mode is entered when the user selects "Targeted update" in Step 0.1. It allows the user to describe what has changed, and only the affected sections are re-interviewed.

### Step 0.4.1: Gather Change Description

Use `AskUserQuestion` to ask:
- "Describe what has changed since the plan was last updated. Be as specific as you like — for example: 'We switched from Redis to Memcached for caching', 'Added E2E tests with Playwright', 'New authentication provider', etc."

Wait for the user's response.

### Step 0.4.2: Identify Affected Sections

Analyze the user's change description and map it to the plan's sections:

| Change topic | Likely affected sections |
|---|---|
| Scope, users, purpose, constraints | Section 1: Overview |
| Languages, frameworks, libraries, databases, tools | Section 2: Tech Stack |
| Components, services, data flow, deployment | Section 3: Architecture |
| Build, setup, testing, CI/CD, dev workflow | Section 4: Development and Testing |
| Naming, file structure, code style, review process | Section 5: Conventions and Rules |
| Auth, access control, secrets, encryption, compliance | Section 6: Security |

A single change may affect multiple sections (e.g., "switched to a microservices architecture" affects Sections 3, 4, and possibly 2).

Present the affected sections to the user using `AskUserQuestion`:
- "Based on your description, I believe these sections need updating:"
- List the affected sections with a brief explanation of why each is affected
- "Are these the right sections, or should I include/exclude any?"

Wait for the user's confirmation or corrections.

### Step 0.4.3: Interview Affected Sections Only

For each confirmed affected section, in order:
1. Show the current content from the existing plan
2. Highlight which parts are likely affected by the described change
3. Run the normal interview cycle for that section (Steps X.1 → X.2 → X.3), pre-populated with existing content
4. After the section is approved, move to the next affected section

For all unaffected sections, carry forward existing content unchanged.

### Step 0.4.4: Proceed to Final Assembly

Once all affected sections are approved, skip to Step 7 (Final Assembly):
- Merge updated sections back into the full plan
- Preserve all unaffected sections exactly as they were
- Proceed through Steps 7.1-7.4 as normal