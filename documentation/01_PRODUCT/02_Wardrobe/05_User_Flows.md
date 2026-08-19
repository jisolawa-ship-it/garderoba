# Wardrobe User Flows

> **Complete user journeys within the Wardrobe module.**

---

# Purpose

This document describes how users accomplish tasks within the Wardrobe module.

Each flow represents a complete user journey from initiation to completion.

These flows define business behavior rather than technical implementation.

---

# Flow Index

| ID | Flow |
|----|------|
| WF-001 | Add Clothing |
| WF-002 | Import Clothing from Gallery |
| WF-003 | Capture Clothing with Camera |
| WF-004 | AI Recognition Review |
| WF-005 | Edit Clothing |
| WF-006 | Delete Clothing |
| WF-007 | Archive Clothing |
| WF-008 | Restore Clothing |
| WF-009 | Search Clothing |
| WF-010 | Filter Wardrobe |
| WF-011 | View Clothing Details |
| WF-012 | Add Clothing to Outfit |
| WF-013 | Open in Dressing Room |
| WF-014 | Duplicate Detection |
| WF-015 | Batch Import |
| WF-016 | Batch Metadata Editing |

---

# Flow Template

Every flow follows the same structure.

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

Expected outcome.

---

## Failure Handling

Possible failure scenarios.

---

## Next Actions

Recommended continuation after completion.

---

# Example

## WF-001 — Add Clothing

### Goal

Add a new clothing item to the wardrobe.

### Trigger

User selects "Add Clothing".

### Preconditions

User has an active wardrobe.

### Main Steps

1. Choose import method.
2. Capture or select image.
3. AI analyzes clothing.
4. User reviews metadata.
5. Clothing is saved.

### Success Result

New clothing item becomes available in the wardrobe.

### Failure Handling

User may retry recognition or complete metadata manually.

### Next Actions

Open Clothing Details.

---

# Shared Flow Rules

All wardrobe flows should:

- support cancellation,
- preserve entered information whenever possible,
- avoid unnecessary confirmations,
- provide clear progress indicators,
- return users to a meaningful destination after completion.

---

# Related Documents

- Functions.md
- Screens.md
- AI_Integration.md
- Navigation.md
- States.md

---

# Closing Statement

Wardrobe user flows should minimize effort while maintaining user control.

AI assists throughout the process, but the final decision always belongs to the user.