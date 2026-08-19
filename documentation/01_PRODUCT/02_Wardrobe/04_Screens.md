# Wardrobe Screens

> **The structural specification of every screen within the Wardrobe module.**

---

# Purpose

This document defines every screen that belongs to the Wardrobe module.

It specifies each screen's purpose, responsibilities and relationships while intentionally leaving visual design and implementation details to dedicated documentation.

---

# Screen Architecture

The Wardrobe module consists of the following screens:

- Wardrobe Home
- Clothing Details
- Add Clothing
- Edit Clothing
- AI Recognition Review
- Search
- Filters
- Collections
- Archive
- Import Wizard

Each screen has a clearly defined responsibility.

---

# Screen Specifications

## Wardrobe Home

### Purpose

Displays the user's wardrobe and serves as the primary browsing experience.

### Sections

- Hero Space
- Search
- Filters
- Clothing Grid
- Quick Actions

### Data Sources

- Wardrobe

### Navigation

- Clothing Details
- Add Clothing
- Search
- Filters

### Variants

- Empty Wardrobe
- Populated Wardrobe
- Offline

---

## Clothing Details

### Purpose

Displays complete information about a single clothing item.

### Sections

- Photos
- Metadata
- AI Insights
- Related Outfits
- Actions

### Data Sources

- Wardrobe

### Navigation

- Edit Clothing
- Dressing Room
- Outfits

---

## Add Clothing

### Purpose

Creates a new clothing item.

### Entry Methods

- Camera
- Gallery
- Manual

### Navigation

- AI Recognition Review
- Wardrobe Home

---

## Edit Clothing

### Purpose

Updates information for an existing clothing item.

### Navigation

- Clothing Details

---

## AI Recognition Review

### Purpose

Allows the user to verify AI-generated clothing metadata before saving.

### Data Sources

- AI Recognition

### Navigation

- Save Clothing
- Edit Recognition

---

## Search

### Purpose

Provides advanced wardrobe search.

---

## Filters

### Purpose

Allows users to narrow wardrobe results.

---

## Collections

### Purpose

Displays curated clothing groups.

---

## Archive

### Purpose

Displays archived clothing items.

---

## Import Wizard

### Purpose

Guides users through importing multiple clothing items.

---

# Navigation Matrix

| From | To |
|------|----|
| Wardrobe Home | Clothing Details |
| Wardrobe Home | Add Clothing |
| Add Clothing | AI Recognition Review |
| AI Recognition Review | Clothing Details |
| Clothing Details | Edit Clothing |
| Search | Clothing Details |
| Archive | Clothing Details |

---

# Dynamic Behaviour

The following screens adapt dynamically:

- Wardrobe Home
- Search
- Filters
- AI Recognition Review

The navigation structure itself should remain stable.

---

# Related Documents

- Functions.md
- User_Flows.md
- Search_and_Filter.md
- AI_Integration.md
- States.md
- Navigation.md

Design

- Design System
- Visual Assets

---

# Closing Statement

Every screen within the Wardrobe module has a single responsibility.

Together, these screens provide a complete environment for building and maintaining a faithful digital representation of the user's real wardrobe.