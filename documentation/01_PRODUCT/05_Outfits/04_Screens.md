# Outfits Screens

> **The structural specification of every screen within the Outfits module.**

---

# Purpose

This document defines every screen belonging to the Outfits module.

The Outfits module is designed as a permanent library of saved outfit compositions.

Visual appearance and implementation details are documented separately.

---

# Screen Architecture

The Outfits module consists of the following screens:

- Outfit Library
- Outfit Details
- Edit Outfit
- Collections
- Outfit History
- Outfit Insights

Each screen has a clearly defined responsibility.

---

# Screen Specifications

## Outfit Library

### Purpose

Provides access to the user's saved outfit library.

### Sections

- Featured Outfits
- Collections
- Favorites
- Recently Used
- Search
- Filters

### Navigation

- Outfit Details
- Collections

### Variants

- Empty Library
- Populated Library
- Search Results
- Filtered Results

---

## Outfit Details

### Purpose

Displays complete information about a saved outfit.

### Sections

- Hero Preview
- Clothing List
- Outfit Metadata
- Usage Statistics
- Calendar History
- AI Suggestions
- Quick Actions

### Navigation

- Edit Outfit
- Dressing Room
- Calendar

---

## Edit Outfit

### Purpose

Allows users to modify a saved outfit.

---

## Collections

### Purpose

Organizes saved outfits into reusable collections.

---

## Outfit History

### Purpose

Displays the complete usage history of the outfit.

---

## Outfit Insights

### Purpose

Shows statistics and AI-generated insights related to the outfit.

---

# Navigation Matrix

| From | To |
|------|----|
| Outfit Library | Outfit Details |
| Outfit Library | Collections |
| Outfit Details | Edit Outfit |
| Outfit Details | Dressing Room |
| Outfit Details | Calendar |
| Edit Outfit | Outfit Details |

---

# Dynamic Behaviour

The Outfits module updates dynamically when:

- clothing becomes unavailable,
- AI proposes replacements,
- outfit statistics change,
- collections are updated,
- calendar usage changes.

The library should always reflect the current state of the wardrobe.

---

# Related Documents

- Purpose.md
- Functions.md
- Collections.md
- User_Flows.md
- AI_Integration.md
- States.md

Design

- Design System
- Visual Assets

---

# Closing Statement

The Outfits module should provide effortless access to every saved outfit.

Its screens should help users quickly find, understand and reuse their best outfit combinations while keeping the library organized and up to date.