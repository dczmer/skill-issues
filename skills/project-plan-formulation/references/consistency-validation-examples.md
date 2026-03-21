# Cross-Section Consistency Validation Examples

This reference provides detailed examples of inconsistencies that may be detected during cross-section validation. Load this file when Step 6.5 detects potential inconsistencies and you need to present specific examples to the user.

---

## Technology References

A database, framework, language, or tool mentioned in one section but contradicted or absent in Section 2 (Tech Stack).

**Example 1:**
- Section 3 (Architecture) describes "Redis-based caching layer"
- Section 2 (Tech Stack) lists no Redis dependency
- Suggested resolution: "Add Redis to Section 2 Tech Stack, or clarify what caching solution is actually used"

**Example 2:**
- Section 4 (Development) mentions running `pytest` for tests
- Section 2 (Tech Stack) lists only TypeScript/Node.js
- Suggested resolution: "Add Python to Section 2, or clarify if tests are in a different language"

---

## Architecture vs. Process Alignment

Development/testing workflows (Section 4) that don't match the architecture described in Section 3.

**Example 1:**
- Section 3 describes a microservices architecture with multiple services
- Section 4 has no mention of Docker, Kubernetes, or service orchestration for local development
- Suggested resolution: "Add container-based development workflow to Section 4"

**Example 2:**
- Section 3 lists RabbitMQ as a message queue component
- Section 4 has no instructions for running or testing with RabbitMQ locally
- Suggested resolution: "Add RabbitMQ setup to Section 4 development environment"

---

## Security vs. Architecture Alignment

Security mechanisms (Section 6) that reference components not described in Section 3 (Architecture).

**Example:**
- Section 6 (Security) describes "Redis-based token blacklist for revoking JWTs"
- Section 3 (Architecture) doesn't include Redis as a system component
- Suggested resolution: "Add Redis to Section 3 Architecture, or use an alternative token revocation approach"

---

## Conventions vs. Tech Stack Alignment

Naming conventions (Section 5) that don't match the languages/frameworks in Section 2 (Tech Stack).

**Example:**
- Section 5 specifies "Follow PEP 8 style guide for Python code"
- Section 2 lists only TypeScript and React
- Suggested resolution: "Update conventions for TypeScript/React (e.g., ESLint + Prettier), or add Python if it's actually used"

---

## Scope Alignment

Features described in Sections 2-6 that fall outside the scope defined in Section 1 (Overview).

**Example:**
- Section 1 states "Mobile apps are out of scope for MVP"
- Section 3 describes "Mobile API endpoints for iOS and Android clients"
- Suggested resolution: "Either remove mobile API from Section 3, or update Section 1 scope to include mobile"