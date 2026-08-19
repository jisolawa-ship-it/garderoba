# Calendar States

> **Behavior of plans, events and preparation throughout the planning lifecycle.**

---

# Purpose

This document defines the operational states of the Calendar module.

Rather than focusing on stored data, Calendar manages the readiness of future plans.

Its states help users understand whether planned events remain prepared, conflict-free and ready for execution.

---

# Event States

## Draft

The event is being created but has not yet been finalized.

---

## Planned

The event has been scheduled.

Preparation may still be required.

---

## Needs Attention

The plan requires user attention.

Examples include:

- weather changes,
- clothing availability,
- scheduling conflicts,
- missing preparation tasks.

---

## Ready

All preparation has been completed.

The planned outfit is available.

No known conflicts exist.

---

## Completed

The event has finished.

Planning history remains available.

---

## Cancelled

The event has been cancelled.

Historical information may be preserved.

---

# Preparation States

Preparation may be:

- Not Started
- In Progress
- Ready
- Delayed

Preparation status reflects readiness rather than event completion.

---

# Weather States

Weather monitoring may report:

- Stable Forecast
- Weather Change Detected
- Recommendation Available
- Severe Weather

Weather states never modify plans automatically.

---

# Conflict States

Possible planning conflicts include:

- No Conflict
- Clothing Conflict
- Schedule Conflict
- Family Conflict
- Availability Conflict

Every conflict should include a clear explanation.

---

# AI States

The Calendar AI may be:

- Monitoring
- Analyzing
- Recommendation Ready
- Waiting for User

Recommendations never bypass user approval.

---

# Family States

Family planning may include:

- Private Event
- Shared Family Event
- Child Planning
- Coordinated Family Plan

Family synchronization respects Privacy by Design.

---

# Planning Confidence

Each planned event may include a planning confidence indicator:

- High
- Medium
- Low

Confidence reflects the overall reliability of the current plan, taking into account weather stability, clothing availability and preparation progress.

---

# State Transitions

State transitions should:

- preserve planning history,
- update automatically when circumstances change,
- clearly communicate readiness,
- never modify user decisions without confirmation.

---

# Related Documents

- Purpose.md
- Functions.md
- Scheduling.md
- Weather_Integration.md
- AI_Integration.md
- User_Flows.md

---

# Closing Statement

The Calendar should continuously communicate how prepared users are for the future.

Its states exist not to describe data, but to help users confidently understand when plans are ready, when attention is required and when action should be taken.