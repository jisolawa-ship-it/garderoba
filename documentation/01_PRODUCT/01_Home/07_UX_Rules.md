# Home Integrations

> **How the Home module collaborates with the rest of Szafnik.**

---

# Purpose

The Home module does not own business data.

Its responsibility is to present the most relevant information collected from other modules and guide users toward the appropriate destination.

This document defines those relationships.

---

# Integration Principles

The Home module follows several integration principles.

- Home never becomes the source of truth.
- Every piece of information belongs to exactly one module.
- Home presents summaries rather than complete data.
- Users are redirected to dedicated modules for detailed interactions.
- Missing integrations should degrade gracefully without affecting the entire Home experience.

---

# Module Integrations

---

## Wardrobe

### Purpose

Provides wardrobe statistics and clothing information.

### Home Uses

- wardrobe summary
- clothing count
- empty wardrobe detection

---

## Dressing Room

### Purpose

Provides entry points for outfit creation and editing.

### Home Uses

- Quick Actions
- Today's Outfit

---

## Outfits

### Purpose

Provides planned outfits.

### Home Uses

- Today's Outfit
- outfit reminders

---

## Calendar

### Purpose

Provides upcoming events.

### Home Uses

- Calendar Preview
- Today's Focus

---

## AI Stylist

### Purpose

Generates personalized recommendations.

### Home Uses

- AI Recommendations
- Today's Focus
- Smart Suggestions

---

## Shopping

### Purpose

Provides shopping-related insights.

### Home Uses

- Purchase recommendations
- Shopping reminders
- Smart Compare suggestions

---

## Family

### Purpose

Provides shared planning information.

### Home Uses

- Family Summary
- Shared Events
- Children's planned outfits

Private wardrobe data belonging to other adults must never be displayed.

---

## Weather

### Purpose

Provides weather forecasts.

### Home Uses

- Weather summary
- Weather Adaptation suggestions

---

## Notifications

### Purpose

Provides user notifications.

### Home Uses

Displays only high-priority notifications.

---

# Data Ownership

| Data | Source Module |
|--------|---------------|
| User Profile | Profile |
| Wardrobe | Wardrobe |
| Clothing | Wardrobe |
| Outfits | Outfits |
| Calendar Events | Calendar |
| AI Recommendations | AI Stylist |
| Shopping Insights | Shopping |
| Family Information | Family |
| Weather | Weather Integration |
| Notifications | Notification Service |

The Home module owns none of these datasets.

---

# Refresh Behaviour

The Home module should refresh information intelligently.

Recommended behavior:

- Refresh visible summaries when the application becomes active.
- Update AI recommendations only when necessary.
- Refresh weather according to its own update schedule.
- Avoid unnecessary network requests.

---

# Failure Behaviour

If one integration becomes unavailable:

- hide only the affected section,
- preserve the rest of the Home experience,
- inform users only when meaningful,
- never block navigation.

Home should fail gracefully.

---

# Related Documents

Product

- Functions.md
- Screens.md
- States.md

AI

- AI Capabilities

Architecture

- Domain Model

---

# Closing Statement

The Home module is an orchestration layer rather than a business module.

Its purpose is to combine information from across the application into a single, coherent and meaningful starting experience while leaving ownership of every dataset to its respective module.