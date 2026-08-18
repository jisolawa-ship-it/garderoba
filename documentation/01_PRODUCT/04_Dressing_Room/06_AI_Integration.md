# Dressing Room User Flows

> **Complete user journeys for experimenting with outfit ideas inside the Dressing Room.**

---

# Purpose

This document describes how users interact with the Dressing Room while exploring outfit ideas.

Unlike traditional editing workflows, the Dressing Room emphasizes creativity, experimentation and iterative refinement.

---

# Flow Index

| ID | Flow |
|----|------|
| DR-001 | Start New Session |
| DR-002 | Create Outfit |
| DR-003 | Replace Clothing |
| DR-004 | Compare Outfit Variants |
| DR-005 | Use AI Suggestions |
| DR-006 | Build Outfit from Inspiration |
| DR-007 | Optimize for Weather |
| DR-008 | Optimize for Occasion |
| DR-009 | Plan Family Outfits |
| DR-010 | Save Outfit |
| DR-011 | Schedule Outfit |
| DR-012 | Discard Session |
| DR-013 | Resume Session |

---

# Flow Template

Every Dressing Room flow follows the same structure:

- Goal
- Trigger
- Preconditions
- Main Steps
- Success Result
- Failure Handling
- Next Actions

---

# Example

## DR-005 — Use AI Suggestions

### Goal

Improve an outfit using AI assistance.

### Trigger

The user requests outfit recommendations.

### Preconditions

An outfit is currently being edited.

### Main Steps

1. AI analyzes the outfit.
2. AI generates recommendations.
3. The user reviews them.
4. The user applies or ignores the suggestions.
5. The outfit is updated.

### Success Result

The outfit reflects the user's chosen changes.

### Failure Handling

If no useful recommendation is available, the user continues manually.

### Next Actions

Continue experimenting or save the outfit.

---

# Shared Flow Rules

All Dressing Room flows should:

- preserve user creativity,
- avoid automatic saving,
- support undo and redo,
- preserve session history,
- encourage experimentation without risk.

---

# Related Documents

- Purpose.md
- Modes.md
- Functions.md
- Screens.md
- AI_Integration.md
- Navigation.md

---

# Closing Statement

Every Dressing Room flow should feel like a creative journey rather than a sequence of tasks.

Users should always feel free to explore, compare and refine outfit ideas before deciding whether to save them.