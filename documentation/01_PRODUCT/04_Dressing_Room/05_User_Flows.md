# Dressing Room Screens

> **The structural specification of every screen within the Dressing Room module.**

---

# Purpose

This document defines every screen belonging to the Dressing Room module.

The Dressing Room is designed as an interactive creative workspace where users experiment with clothing combinations before making permanent decisions.

Visual appearance and implementation details are documented separately.

---

# Screen Architecture

The Dressing Room module consists of the following screens:

- Dressing Room Workspace
- Inspiration Browser
- AI Stylist Panel
- Outfit Comparison
- Outfit Details
- Save Outfit

Each screen has a distinct responsibility while contributing to the overall styling experience.

---

# Workspace Philosophy

The Dressing Room Workspace is the heart of the module.

Rather than functioning as a traditional form, it acts as an interactive creative environment where users freely combine garments, explore ideas and compare alternatives.

The workspace should encourage experimentation without overwhelming the user.

---

# Screen Specifications

## Dressing Room Workspace

### Purpose

Provides the primary environment for creating and experimenting with outfit ideas.

### Workspace Areas

- Outfit Canvas
- Clothing Library
- Active Outfit
- AI Suggestions
- Quick Actions

### Navigation

- AI Stylist Panel
- Outfit Comparison
- Save Outfit

### Variants

- Empty Workspace
- Active Session
- AI Assisted
- Family Mode

---

## Inspiration Browser

### Purpose

Allows users to browse inspiration images and recreate looks using their own wardrobe.

---

## AI Stylist Panel

### Purpose

Displays AI-generated outfit suggestions, alternatives and explanations.

---

## Outfit Comparison

### Purpose

Allows side-by-side comparison of multiple outfit variations.

---

## Outfit Details

### Purpose

Displays detailed information about the currently selected outfit, including weather suitability, occasion fit and wardrobe usage.

---

## Save Outfit

### Purpose

Allows users to save the completed outfit into the Outfits module or schedule it in the Calendar.

---

# Navigation Matrix

| From | To |
|------|----|
| Workspace | AI Stylist Panel |
| Workspace | Inspiration Browser |
| Workspace | Outfit Comparison |
| Workspace | Save Outfit |
| AI Stylist Panel | Workspace |
| Inspiration Browser | Workspace |
| Outfit Comparison | Workspace |
| Save Outfit | Outfits |

---

# Dynamic Behaviour

The Dressing Room adapts based on the selected mode.

Different modes may prioritize:

- AI suggestions,
- inspiration,
- family planning,
- travel preparation,
- outfit comparison.

The overall navigation remains consistent.

---

# Related Documents

- Purpose.md
- Modes.md
- Functions.md
- User_Flows.md
- AI_Integration.md

Design

- Design System
- Visual Assets

---

# Closing Statement

The Dressing Room should feel like a creative studio rather than a traditional editor.

Its screens exist to help users confidently explore, refine and save outfit ideas while making full use of the clothing they already own.