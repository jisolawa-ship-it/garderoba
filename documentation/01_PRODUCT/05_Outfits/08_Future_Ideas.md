# Outfit States

> **Behavior of saved outfits throughout their lifecycle inside the Outfits library.**

---

# Purpose

This document defines the states that a saved outfit may enter after it has been created.

Unlike the Dressing Room, which manages creative sessions, the Outfits module manages persistent outfit objects that evolve together with the user's wardrobe.

---

# Availability States

## Active

The outfit is complete and ready to use.

---

## Needs Update

One or more garments have changed or become unavailable.

AI may recommend refreshing the outfit.

---

## Incomplete

The outfit is missing one or more required garments.

The outfit remains in the library but should not be presented as ready to wear.

---

## Archived

The outfit is preserved for historical purposes.

Archived outfits are hidden from everyday recommendations.

---

# Usage States

## Never Used

The outfit has never been worn.

---

## Recently Used

The outfit has been worn recently.

---

## Frequently Used

The outfit is one of the user's favorite combinations.

---

## Long Time Unused

The outfit has not been worn for an extended period.

AI may recommend rediscovering it.

---

# Planning States

## Not Planned

The outfit is not linked to any future event.

---

## Planned

The outfit is scheduled in the Calendar.

---

## In Progress

The outfit is currently associated with an ongoing event.

---

## Completed

The planned event has finished.

The outfit becomes part of the user's styling history.

---

# AI States

## Healthy

All garments are available and metadata is complete.

---

## Recommendations Available

AI has suggestions for improving or updating the outfit.

---

## Duplicate Suspected

The outfit is very similar to another saved outfit.

---

## Replacement Suggested

AI recommends replacing one or more garments.

---

# Collection States

An outfit may be:

- not assigned to any collection,
- assigned to one collection,
- assigned to multiple collections.

Collections never change the outfit itself.

---

# Family States

Where appropriate, an outfit may be:

- private,
- shared with family,
- assigned to a child,
- part of a coordinated family plan.

Family sharing follows the Privacy by Design principle.

---

# Error States

Possible error scenarios include:

- missing garment,
- broken clothing reference,
- missing preview image,
- unavailable wardrobe data.

Errors should always preserve the saved outfit whenever possible.

---

# State Transitions

State transitions should:

- preserve outfit history,
- update automatically after wardrobe changes,
- clearly communicate status changes,
- never remove outfits without explicit user action.

---

# Related Documents

- Purpose.md
- Functions.md
- Collections.md
- AI_Integration.md
- User_Flows.md
- Calendar Integration

---

# Closing Statement

Saved outfits evolve together with the wardrobe.

The Outfits module should continuously reflect the current reality while preserving the user's styling history and maintaining confidence in every saved outfit.