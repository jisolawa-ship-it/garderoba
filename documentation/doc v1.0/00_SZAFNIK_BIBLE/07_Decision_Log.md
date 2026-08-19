# Decision Log

> **The permanent history of product decisions.**

---

# Purpose

The Decision Log records every significant decision made during the development of Szafnik.

Its purpose is not only to preserve the final decision, but also the reasoning behind it.

Future team members should be able to understand not only **what** was decided, but also **why**.

The Decision Log is part of the product itself.

It is not an afterthought.

---

# How to Use

Only significant product decisions should be recorded here.

Examples include:

- product direction,
- AI capabilities,
- UX workflows,
- design principles,
- architecture principles,
- privacy decisions,
- family model,
- long-term strategy.

Do **not** record:

- bug fixes,
- typo corrections,
- implementation details,
- minor UI adjustments,
- temporary experiments.

---

## Immediate Decision Documentation

Every significant product decision must be documented immediately after it is made.

Documentation is part of the design process—not a task performed later.

Large batches of undocumented decisions should never exist.

The Decision Log should always represent the current state of product thinking.

---

# Decision Template

Every decision must follow the same structure.

---

## Decision ID

Example:

DEC-001

---

## Date

Decision date.

---

## Category

One of:

- PRODUCT
- AI
- UX
- DESIGN
- ARCHITECTURE
- FAMILY
- BUSINESS
- DOCUMENTATION

---

## Status

Possible values:

- Proposed
- Accepted
- Deprecated
- Superseded

---

## Title

A short descriptive title.

---

## Decision

A concise description of what has been decided.

---

## Context

Why was this decision necessary?

What problem were we trying to solve?

---

## Alternatives Considered

What other approaches were evaluated?

Why were they rejected?

---

## Reasoning

Explain why this option was selected.

---

## Consequences

How will this decision influence the product?

Positive and negative consequences should both be documented.

---

## Related Principles

List the Core Principles affected by this decision.

Example:

- Reality First
- Human in Control

---

## Related Documents

Reference all documentation that depends on this decision.

Example:

- Vision.md
- Product_Philosophy.md
- AI/Shopping.md

---

## Related Decisions

Reference previous or future decisions connected with this one.

Example:

DEC-003

DEC-014

---

# Decision Categories

The following categories should be used consistently.

| Category | Description |
|----------|-------------|
| PRODUCT | Product direction and features |
| AI | Artificial intelligence capabilities |
| UX | User experience |
| DESIGN | Visual and interaction design |
| ARCHITECTURE | Product architecture |
| FAMILY | Multi-user and family features |
| BUSINESS | Monetization and strategy |
| DOCUMENTATION | Documentation structure and standards |

---

# Impact Levels

Every decision should receive an impact level.

★★★★★ Fundamental

Core product direction.

---

★★★★☆ Major

Significant product change.

---

★★★☆☆ Medium

Module-level decision.

---

★★☆☆☆ Minor

Limited product impact.

---

★☆☆☆☆ Cosmetic

Very small influence.

---

# Decision History

All accepted decisions should be recorded below in chronological order.

Newest decisions may also be added to the top if preferred, provided the ordering remains consistent.

---

# Example

---

## DEC-001

**Date**

2026-08-03

---

**Category**

DOCUMENTATION

---

**Status**

Accepted

---

**Title**

Documentation follows the Single Responsibility Principle.

---

**Decision**

Each documentation file should have one clearly defined purpose and should never duplicate information maintained elsewhere.

---

**Context**

As the documentation expanded, overlapping content became increasingly difficult to maintain.

---

**Alternatives Considered**

Writing larger documents covering multiple topics.

Rejected because duplicated information would inevitably appear.

---

**Reasoning**

Single-purpose documents are easier to maintain, reference and evolve independently.

---

**Consequences**

Improved maintainability.

Reduced duplication.

Clear ownership of knowledge.

---

**Related Principles**

- Single Responsibility Documentation
- One Source of Truth

---

**Related Documents**

- Core_Principles.md
- README.md

---

**Related Decisions**

None