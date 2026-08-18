# Wardrobe States

> **Behavior of the Wardrobe module under different user and system conditions.**

---

# Purpose

This document defines every significant state that the Wardrobe module may enter.

A state represents a combination of available data, user context and system conditions that influence how the module behaves.

The goal is to ensure predictable and consistent behavior in every scenario.

---

# Initial State

### Description

The user has completed onboarding but has not yet added any clothing.

### Behavior

- Display the Empty Wardrobe experience.
- Introduce the value of a digital wardrobe.
- Encourage adding the first clothing item.

---

# Data States

## Empty Wardrobe

No clothing items exist.

Primary Action:

**Add First Clothing Item**

---

## Small Wardrobe

The user has only a limited number of clothing items.

Behavior:

Encourage continued wardrobe building while highlighting AI-assisted import.

---

## Established Wardrobe

The wardrobe contains a meaningful collection of clothing.

Behavior:

Display full browsing, search and organizational capabilities.

---

## Large Wardrobe

The wardrobe contains hundreds or thousands of items.

Behavior:

Prioritize search, filters, collections and performance optimizations.

---

# Import States

## Import Started

The user has selected an import method.

---

## Image Processing

AI is analyzing uploaded images.

---

## Recognition Review

The user is reviewing AI-generated metadata.

---

## Import Completed

Clothing has been successfully added.

---

## Import Failed

Recognition failed or import was interrupted.

Allow retry or manual completion.

---

# AI States

## AI Learning

Insufficient user corrections available.

Recognition confidence may improve over time.

---

## AI Suggestion Available

Display suggested metadata awaiting user confirmation.

---

## Low Confidence Recognition

Clearly communicate uncertainty.

Encourage manual verification.

---

## Duplicate Warning

Potential duplicate detected.

Allow the user to continue or cancel.

---

# Search States

## Active Search

Display filtered wardrobe results.

---

## No Results

Explain why no items match.

Offer filter reset and suggestions.

---

# Offline State

Behavior:

- Cached wardrobe remains available.
- Editing is allowed where possible.
- Cloud synchronization resumes automatically once connectivity returns.

---

# Synchronization States

## Synchronizing

Background synchronization is in progress.

---

## Sync Conflict

Changes require conflict resolution.

The user should always remain in control.

---

## Sync Completed

The wardrobe is fully synchronized.

---

# Error States

Examples include:

- image upload failure,
- corrupted image,
- unsupported format,
- storage unavailable,
- synchronization error.

Errors should always explain the problem and provide a recovery path.

---

# Maintenance States

## Missing Photos

Highlight clothing items without images.

---

## Missing Metadata

Suggest completing important information.

---

## Duplicate Candidates

Display potential duplicate clothing items for review.

---

## Archived Items

Separate archived clothing from the active wardrobe while keeping it searchable.

---

# State Transitions

Transitions between states should:

- preserve user context,
- avoid unnecessary reloads,
- provide clear feedback,
- complete smoothly.

Whenever possible, operations should continue in the background.

---

# Visual References

The visual appearance of each state is documented separately.

Design

→ Design System

Assets

→ Visual Assets / Empty States

---

# Related Documents

- Functions.md
- User_Flows.md
- Search_and_Filter.md
- AI_Capabilities.md
- Navigation.md

---

# Closing Statement

Regardless of the amount of clothing or system conditions, the Wardrobe module should always remain reliable, understandable and easy to use.

Every state should help users continue managing their wardrobe with confidence.