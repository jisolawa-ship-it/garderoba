# Home Decision References

> **Product decisions governing the Home module.**

---

# Purpose

This document identifies every product decision that directly influences the Home module.

It does not duplicate decision content.

Its purpose is to help designers, developers and AI systems quickly identify which architectural and product decisions must be respected when working on Home.

For the full reasoning behind each decision, refer to the central `Decision_Log.md`.

---

# Decision Categories

The Home module is primarily influenced by decisions in the following areas:

- Product
- UX
- AI
- Design
- Navigation
- Family
- Documentation

---

# Decision Map

| Decision | Topic | Impact on Home |
|----------|-------|----------------|
| DEC-001 | Single Responsibility Documentation | Defines documentation boundaries. |
| DEC-002 | Hero Spaces | Home begins with a symbolic Hero Space. |
| DEC-003 | Door Transition Principle | Entry animation into Home. |
| DEC-004 | Reality First | Home prioritizes real user data over decoration. |
| DEC-005 | AI as Assistant | AI supports rather than dominates the experience. |
| DEC-006 | Dynamic Home | Content adapts while layout remains stable. |
| DEC-007 | Immediate Decision Documentation | Documentation changes are recorded immediately. |

---

# Mandatory Decisions

The following decisions are considered fundamental for the Home module and must never be violated:

- Hero Spaces
- Reality First
- AI as Assistant
- Human in Control
- Privacy by Design
- Single Source of Truth

---

# Decision Impact Matrix

| Area | Governing Decisions |
|------|----------------------|
| Screen Structure | Hero Spaces, Reality First |
| AI Recommendations | AI as Assistant |
| Navigation | Human in Control |
| Family Summary | Privacy by Design |
| Documentation | Single Responsibility Documentation |
| Dynamic Content | Dynamic Home |

---

# Future Dependencies

The Home module is expected to integrate with future product decisions related to:

- Voice interactions
- Smart notifications
- Wearables
- Cross-device continuity
- Additional AI capabilities

These integrations should be added once officially accepted in the Decision Log.

---

# Maintenance Rules

Whenever a new accepted decision affects the Home module:

1. Add it to the Decision Log.
2. Update this document.
3. Verify whether any Home documentation requires revision.

This document should always reflect the current decision landscape.

---

# Related Documents

- Decision_Log.md
- Purpose.md
- Functions.md
- Screens.md
- UX_Rules.md

---

# Closing Statement

The Home module is shaped by a collection of product decisions rather than isolated implementation choices.

This document ensures that every contributor understands which decisions define the Home experience and where to find their complete rationale.