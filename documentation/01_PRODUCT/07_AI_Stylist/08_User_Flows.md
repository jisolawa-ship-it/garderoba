# AI Stylist Screens

> **The structural specification of every dedicated screen belonging to the AI Stylist module.**

---

# Purpose

This document defines the dedicated user interfaces of the AI Stylist.

Although the AI is deeply integrated throughout the Szafnik ecosystem, only a small number of standalone screens belong exclusively to the AI Stylist.

Most AI interactions appear contextually inside other modules.

---

# Screen Architecture

The AI Stylist module consists of:

- Conversation
- Recommendation Center
- Recommendation Details
- Shopping Advisor
- Trend Insights
- Personalization
- AI Memory
- AI Settings

These screens complement the contextual AI experiences embedded throughout the application.

---

# Screen Specifications

## Conversation

### Purpose

Provides a natural conversational interface with the AI Stylist.

### Sections

- Chat
- Suggested Questions
- Current Context
- Attachments
- Conversation History

---

## Recommendation Center

### Purpose

Displays all active AI recommendations in one place.

### Sections

- Outfit Recommendations
- Wardrobe Recommendations
- Planning Recommendations
- Shopping Recommendations
- Trend Recommendations

---

## Recommendation Details

### Purpose

Explains a single recommendation in detail, including reasoning, alternatives and possible actions.

---

## Shopping Advisor

### Purpose

Presents wardrobe-related shopping guidance together with priorities and explanations.

---

## Trend Insights

### Purpose

Shows trend-inspired recommendations adapted to the user's wardrobe and personal style.

---

## Personalization

### Purpose

Allows users to review and manage AI personalization preferences.

---

## AI Memory

### Purpose

Displays the long-term preferences, patterns and learned behaviors used to personalize recommendations.

Users can review, edit or reset remembered information where appropriate.

---

## AI Settings

### Purpose

Allows users to configure AI behavior, notification preferences and privacy-related settings.

---

# Navigation Matrix

| From | To |
|------|----|
| Conversation | Recommendation Details |
| Recommendation Center | Recommendation Details |
| Recommendation Center | Shopping Advisor |
| Recommendation Center | Trend Insights |
| Personalization | AI Memory |
| AI Settings | Personalization |

---

# Embedded Experiences

Most AI interactions should appear contextually inside existing modules rather than requiring navigation to a dedicated AI screen.

Examples include:

- outfit suggestions in Dressing Room,
- wardrobe insights in Wardrobe,
- planning recommendations in Calendar,
- shopping suggestions in Shopping,
- trend inspiration in Outfit creation.

Dedicated AI screens should support deeper exploration rather than replace contextual assistance.

---

# Dynamic Behaviour

The AI interface updates dynamically when:

- new recommendations become available,
- user preferences evolve,
- wardrobe data changes,
- planning context changes,
- recommendations expire.

The interface should always reflect the most relevant information.

---

# Related Documents

- Purpose.md
- Functions.md
- Conversation.md
- Recommendations.md
- Shopping.md
- Trends.md
- Personalization.md
- States.md

Design

- Design System
- Visual Assets

---

# Closing Statement

The AI Stylist should feel present throughout the entire application without becoming the center of attention.

Dedicated AI screens exist to deepen understanding, while contextual assistance remains the primary way users experience intelligent support.