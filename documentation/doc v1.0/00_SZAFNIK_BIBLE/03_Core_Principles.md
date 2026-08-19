# Core Principles

> **The non-negotiable principles that define Szafnik.**

---

# Purpose

The purpose of this document is to define the fundamental principles that guide every product, UX, AI and technical decision made throughout the Szafnik project.

These principles are **not recommendations**.

They are permanent rules that define the identity of the product.

Every new feature, workflow, AI capability, interface and architectural decision should be evaluated against these principles before implementation begins.

If a proposed solution violates one or more principles, it should either be redesigned or the principle should be intentionally updated through a documented product decision.

---

# Product Principles

## Reality First

### Definition

Szafnik always starts with the user's real wardrobe.

Artificial intelligence enhances reality rather than replacing it.

Every recommendation, visualization and suggestion should originate from real garments whenever possible.

---

### Reasoning

Users trust recommendations that are based on what they actually own.

The primary value of Szafnik comes from helping users make better use of their existing wardrobe.

---

### Implications

- Real wardrobe is always the primary source of data.
- AI should prioritize existing clothing.
- Generated content should complement reality rather than replace it.

---

### Examples

✔ Build Around uses an existing jacket.

✔ AI suggests combinations using clothes already stored.

✔ Packing assistant starts from owned garments.

---

### Anti-patterns

✘ Generating completely random outfits.

✘ Ignoring the user's wardrobe.

✘ Treating AI images as the primary experience.

---

## AI as an Assistant

### Definition

Artificial intelligence exists to support human decision making.

It does not replace the user.

---

### Reasoning

Users should feel empowered, not controlled.

The final decision always belongs to the user.

---

### Implications

- AI recommends.
- AI explains.
- AI asks when necessary.
- AI never forces decisions.

---

### Examples

✔ "Here are three suggestions."

✔ "Would you like me to schedule this outfit?"

---

### Anti-patterns

✘ Automatically modifying the wardrobe.

✘ Automatically deleting clothing.

✘ Making irreversible decisions without confirmation.

---

## Privacy by Design

### Definition

Privacy is the default state of the product.

User data belongs to the user.

---

### Reasoning

Szafnik stores highly personal information.

Trust is impossible without strong privacy.

---

### Implications

- Private by default.
- Explicit consent for sharing.
- Transparent AI access.

---

### Examples

✔ Adult wardrobes remain private.

✔ AI explains why it accessed information.

---

### Anti-patterns

✘ Family members browsing each other's wardrobes.

✘ Hidden data sharing.

---

## Family with Privacy

### Definition

Family members collaborate through AI while maintaining independent personal spaces.

---

### Reasoning

Families benefit from shared planning.

Adults also deserve privacy.

---

### Implications

- Adults own separate wardrobes.
- AI may analyze connected wardrobes (with permission).
- Children use dependent profiles managed by parents.

---

### Examples

✔ AI prepares family outfits.

✔ AI creates shared shopping lists.

✔ Parents manage a child's wardrobe together.

---

### Anti-patterns

✘ Adults directly browsing another adult's wardrobe.

✘ Shared family wardrobe for everyone.

---

## Human in Control

### Definition

Every important action remains under user control.

---

### Reasoning

AI should reduce effort without removing agency.

---

### Implications

Confirmation is required before:

- deleting,
- overwriting,
- scheduling,
- sharing,
- purchasing.

---

### Examples

✔ Save outfit?

✔ Schedule outfit?

---

### Anti-patterns

✘ Automatic purchases.

✘ Automatic calendar changes.

---

# Experience Principles

## Calm Experience

### Definition

Szafnik should reduce mental load instead of creating it.

---

### Reasoning

The application exists to simplify daily decisions.

---

### Implications

- Clean layouts.
- Clear navigation.
- Limited choices.
- One primary action per screen.

---

### Examples

✔ One highlighted CTA.

✔ Spacious layouts.

---

### Anti-patterns

✘ Visual clutter.

✘ Five equally important buttons.

---

## Premium Quality

### Definition

Quality is always more important than quantity.

---

### Reasoning

Every interaction should feel intentional and refined.

---

### Implications

- Polish over feature count.
- Elegant animations.
- Thoughtful details.

---

### Examples

✔ Smooth transitions.

✔ Premium illustrations.

---

### Anti-patterns

✘ Feature overload.

✘ Cheap visual shortcuts.

---

## Meaningful AI

### Definition

Artificial intelligence should provide measurable value.

---

### Reasoning

AI is not decoration.

Every recommendation should have a purpose.

---

### Implications

AI recommendations must be:

- relevant,
- contextual,
- explainable.

---

### Examples

✔ Recommendation based on weather.

✔ Recommendation based on wardrobe history.

---

### Anti-patterns

✘ Random AI suggestions.

✘ Generic chatbot responses.

---

# Design Principles

The following visual principles are mandatory throughout the product.

Their complete definitions are documented separately within the Design System documentation.

The product must consistently follow:

- Hero Spaces
- Luxury Editorial
- Door Transition Principle
- Reality Layer
- AI Layer
- Glassmorphism
- Open Space Composition
- 60/40 Reality–Interface Balance

No feature should contradict these principles.

---

# AI Principles

## Explainability

AI should explain its recommendations whenever appropriate.

---

## Transparency

Users should understand why AI is making a suggestion.

---

## Gradual Learning

AI learns progressively rather than assuming preferences immediately.

---

## Confidence Awareness

Whenever confidence is low, AI should ask rather than guess.

---

## Helpful Proactivity

AI may proactively suggest useful actions but should never interrupt the user unnecessarily.

---

# Architecture Principles

These are product architecture principles rather than implementation rules.

---

## Single Source of Truth

Each piece of information should exist only once.

---

## Dynamic Rendering

Generated previews should be rendered dynamically whenever possible instead of stored as duplicated images.

---

## Reuse Before Creation

Existing user data should always be reused before generating new content.

---

## Modular Thinking

Every module should have one clearly defined responsibility.

---

## Scalable Foundation

Product decisions should support future expansion without requiring redesign.

---

# Documentation Principles

The documentation follows several permanent rules.

---

## Single Responsibility Documentation

Every document has one clearly defined purpose.

---

## One Source of Truth

Information should only exist in one document.

Other documents may reference it but should not duplicate it.

---

## Product Before Technology

Documentation describes the product first.

Technology is documented separately.

---

## Technology Independence

The product documentation should remain valid even if implementation technologies change in the future.

---

# Decision Rule

Whenever a future feature, design or architectural proposal is evaluated, it should first be checked against these Core Principles.

If it violates one or more principles:

1. the proposal should be redesigned,

or

2. the principle should be intentionally updated through a documented product decision.

Core Principles are the highest-level design constraints of the entire Szafnik project.

Every successful implementation begins by respecting them.

## Immediate Decision Documentation

### Definition

Every significant product decision must be documented immediately after it is made.

Documentation is part of the decision-making process, not a separate task performed later.

---

### Reasoning

The reasoning behind a decision is most accurate at the moment it is made.

Delaying documentation increases the risk of losing important context, forgetting rejected alternatives or creating inconsistencies between the product and its documentation.

---

### Implications

- Every product decision is recorded using the standard Decision Log template.
- Documentation is updated before moving on to the next major topic.
- Significant decisions are never collected and documented in batches.
- The Decision Log remains a real-time history of the project's evolution.

---

### Examples

✔ After deciding that Family AI can analyze connected wardrobes while preserving adult privacy, the decision is immediately added to the Decision Log.

✔ After introducing the Door Transition Principle, the decision is documented before continuing product design.

✔ After agreeing on a new AI capability, such as Shopping Advisor or Weather Adaptation, the decision is recorded immediately.

---

### Anti-patterns

✘ Writing down multiple decisions days or weeks later.

✘ Relying on memory instead of documentation.

✘ Continuing product design while leaving important decisions undocumented.

✘ Treating documentation as a task to be completed after the design phase.