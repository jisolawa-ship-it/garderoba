# Clothing Screens

> **The structural specification of every screen within the Clothing module.**

---

# Purpose

This document defines every screen belonging to the Clothing module.

Each screen has a clearly defined responsibility related to a single clothing item.

Visual appearance and implementation details are documented separately.

---

# Screen Architecture

The Clothing module consists of the following screens:

- Clothing Details
- Edit Clothing
- Recognition Review
- Photo Manager
- Metadata Editor
- Lifecycle History

Each screen focuses on one aspect of managing an individual garment.

---

# Screen Specifications

## Clothing Details

### Purpose

Serves as the primary overview of a clothing item.

### Sections

- Hero Photo
- Metadata Summary
- AI Insights
- Usage Statistics
- Related Outfits
- Lifecycle Summary
- Quick Actions

### Data Sources

- Clothing

### Navigation

- Edit Clothing
- Metadata Editor
- Photo Manager
- Lifecycle History

### Variants

- Complete
- Incomplete Metadata
- Archived
- Offline

---

## Edit Clothing

### Purpose

Allows users to update clothing information.

### Navigation

Returns to Clothing Details.

---

## Recognition Review

### Purpose

Allows users to review and approve AI-generated metadata before saving.

### Data Sources

- AI Recognition

### Navigation

- Clothing Details
- Metadata Editor

---

## Photo Manager

### Purpose

Manages clothing photos.

### Functions

- Add
- Remove
- Replace
- Reorder
- Select Primary

---

## Metadata Editor

### Purpose

Provides full editing of clothing metadata.

### Sections

- Identity
- Appearance
- Physical Properties
- Usage
- Notes

---

## Lifecycle History

### Purpose

Displays the complete lifecycle of the clothing item.

### Sections

- Creation
- Updates
- Wear History
- Archive Events

---

# Navigation Matrix

| From | To |
|------|----|
| Clothing Details | Edit Clothing |
| Clothing Details | Metadata Editor |
| Clothing Details | Photo Manager |
| Clothing Details | Lifecycle History |
| Recognition Review | Clothing Details |
| Edit Clothing | Clothing Details |

---

# Dynamic Behaviour

The following screens adapt dynamically:

- Clothing Details
- Recognition Review
- Lifecycle History

Content changes based on available metadata and AI analysis.

The screen structure remains stable.

---

# Related Documents

Product

- Functions.md
- Metadata.md
- Recognition.md
- Lifecycle.md

Design

- Design System
- Visual Assets

---

# Closing Statement

The Clothing module provides focused tools for managing a single garment.

Each screen contributes to maintaining an accurate, complete and trustworthy digital representation of one real clothing item.