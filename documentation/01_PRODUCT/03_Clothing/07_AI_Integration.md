# Clothing User Flows

> **Complete user journeys for managing an individual clothing item.**

---

# Purpose

This document describes how users interact with a single Clothing item throughout its lifecycle.

Each flow represents a complete business process from the user's perspective.

The focus is on user behavior rather than technical implementation.

---

# Flow Index

| ID | Flow |
|----|------|
| CF-001 | Create Clothing |
| CF-002 | Review AI Recognition |
| CF-003 | Edit Metadata |
| CF-004 | Manage Photos |
| CF-005 | View Clothing Details |
| CF-006 | Update Lifecycle |
| CF-007 | Archive Clothing |
| CF-008 | Restore Clothing |
| CF-009 | Mark as Sold |
| CF-010 | Mark as Donated |
| CF-011 | Mark as Discarded |
| CF-012 | Review AI Suggestions |

---

# Flow Template

Every Clothing flow follows the same structure.

## Goal

What the user wants to accomplish.

---

## Trigger

What starts the flow.

---

## Preconditions

Conditions required before the flow begins.

---

## Main Steps

High-level sequence of user actions.

---

## Success Result

Expected outcome after completion.

---

## Failure Handling

Possible failure scenarios and recovery options.

---

## Next Actions

Recommended continuation after completing the flow.

---

# Example

## CF-003 — Edit Metadata

### Goal

Update information describing a clothing item.

### Trigger

User selects **Edit** from Clothing Details.

### Preconditions

The clothing item already exists.

### Main Steps

1. Open metadata editor.
2. Modify one or more attributes.
3. Validate changes.
4. Save updated metadata.

### Success Result

The clothing item immediately reflects the updated information.

### Failure Handling

Display validation errors or allow retry if saving fails.

### Next Actions

Return to Clothing Details.

---

# Shared Flow Rules

All Clothing flows should:

- focus on a single clothing item,
- preserve user changes whenever possible,
- allow cancellation before saving,
- provide immediate feedback after successful actions,
- never modify data without user confirmation.

---

# Related Documents

- Functions.md
- Screens.md
- Metadata.md
- Recognition.md
- Lifecycle.md
- AI_Capabilities.md

---

# Closing Statement

Every Clothing flow should feel simple, predictable and focused.

Managing an individual garment should require minimal effort while ensuring that its digital representation remains accurate throughout its lifecycle.