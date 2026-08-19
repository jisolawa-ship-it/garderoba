# Outfits User Flows

> **Complete user journeys for managing and reusing saved outfits.**

---

# Purpose

This document describes how users interact with saved outfits after they have been created.

Unlike the Dressing Room, the Outfits module focuses on organization, reuse and long-term management of outfit compositions.

---

# Flow Index

| ID | Flow |
|----|------|
| OF-001 | Save Outfit from Dressing Room |
| OF-002 | Browse Outfit Library |
| OF-003 | View Outfit Details |
| OF-004 | Edit Saved Outfit |
| OF-005 | Organize Collections |
| OF-006 | Search Outfits |
| OF-007 | Schedule Outfit |
| OF-008 | Duplicate Outfit |
| OF-009 | Archive Outfit |
| OF-010 | Restore Outfit |
| OF-011 | Delete Outfit |
| OF-012 | Update Outfit After Wardrobe Changes |
| OF-013 | Share Outfit with Family |

---

# Flow Template

Every Outfit flow follows the same structure:

- Goal
- Trigger
- Preconditions
- Main Steps
- Success Result
- Failure Handling
- Next Actions

---

# Example

## OF-007 — Schedule Outfit

### Goal

Schedule a saved outfit for a future date.

### Trigger

The user selects **Schedule**.

### Preconditions

The outfit exists and all required garments are available.

### Main Steps

1. Open the calendar.
2. Select a date.
3. Verify garment availability.
4. Confirm scheduling.

### Success Result

The outfit is linked to the selected calendar event.

### Failure Handling

If one or more garments are unavailable, inform the user and offer alternative garments or outfits.

### Next Actions

Continue planning or return to the Outfit Library.

---

# Shared Flow Rules

All Outfit flows should:

- preserve outfit history,
- keep Clothing references up to date,
- avoid unnecessary data duplication,
- support AI recommendations where appropriate,
- allow safe cancellation whenever possible.

---

# Related Documents

- Purpose.md
- Functions.md
- Collections.md
- Screens.md
- AI_Integration.md
- States.md

---

# Closing Statement

Every Outfit flow should make it easy to preserve, organize and reuse successful styling decisions.

The module should help users build a reliable personal outfit library that remains useful as their wardrobe evolves.