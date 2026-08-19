# Calendar Screens

> **The structural specification of every screen within the Calendar module.**

---

# Purpose

This document defines every screen belonging to the Calendar module.

The Calendar is designed as the planning hub of the Szafnik ecosystem, connecting outfits, events, weather and preparation into a single planning experience.

Visual appearance and implementation details are documented separately.

---

# Screen Architecture

The Calendar module consists of:

- Planning Dashboard
- Calendar View
- Event Details
- Schedule Outfit
- Preparation Timeline
- Conflict Center
- Weather Overview
- Family Planning

Each screen focuses on a single planning responsibility.

---

# Screen Specifications

## Planning Dashboard

### Purpose

Provides an overview of the user's upcoming plans and preparation status.

### Sections

- Today's Plan
- Upcoming Events
- Preparation Tasks
- Weather Alerts
- AI Recommendations
- Planning Status

### Navigation

- Calendar View
- Event Details
- Conflict Center

### Variants

- Empty Calendar
- Active Planning
- Busy Schedule

---

## Calendar View

### Purpose

Displays scheduled events using multiple calendar layouts.

### Views

- Day
- Week
- Month
- Agenda

---

## Event Details

### Purpose

Displays complete information about a planned event.

### Sections

- Event Information
- Assigned Outfit
- Weather Summary
- Preparation Timeline
- Family Participation
- AI Recommendations
- Quick Actions

### Navigation

- Schedule Outfit
- Outfit Details
- Calendar View

---

## Schedule Outfit

### Purpose

Allows users to assign or replace outfits for an event.

---

## Preparation Timeline

### Purpose

Shows all preparation tasks required before the event.

---

## Conflict Center

### Purpose

Displays scheduling conflicts together with suggested resolutions.

---

## Weather Overview

### Purpose

Summarizes weather conditions affecting planned events.

---

## Family Planning

### Purpose

Coordinates planning across family members.

---

# Navigation Matrix

| From | To |
|------|----|
| Planning Dashboard | Calendar View |
| Planning Dashboard | Event Details |
| Calendar View | Event Details |
| Event Details | Schedule Outfit |
| Event Details | Outfit Details |
| Event Details | Preparation Timeline |
| Event Details | Conflict Center |
| Event Details | Weather Overview |
| Event Details | Family Planning |

---

# Dynamic Behaviour

The Calendar updates dynamically when:

- weather forecasts change,
- events are modified,
- outfit availability changes,
- conflicts appear,
- family plans are synchronized.

The planning interface should always reflect the current situation.

---

# Related Documents

- Purpose.md
- Functions.md
- Scheduling.md
- Weather_Integration.md
- User_Flows.md
- AI_Integration.md
- States.md

Design

- Design System
- Visual Assets

---

# Closing Statement

The Calendar should help users understand not only what is planned, but also how prepared they are for the days ahead.

Every screen should contribute to reducing uncertainty and making future planning simple, flexible and reliable.