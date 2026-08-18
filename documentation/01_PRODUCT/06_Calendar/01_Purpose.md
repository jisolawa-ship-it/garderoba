# Calendar

> **The intelligent planning hub connecting outfits, wardrobe and real-life events.**

---

# Purpose

The Calendar module connects the user's wardrobe with their daily life.

Its purpose is to help users plan what they will wear, when they will wear it and how their wardrobe supports upcoming events.

Rather than storing clothing or creating outfits, the Calendar organizes when saved outfits are used.

It transforms outfit planning into an intelligent daily schedule.

---

# Module Responsibility

The Calendar module is responsible for:

- planning outfits,
- managing wardrobe schedules,
- organizing events,
- coordinating clothing availability,
- reminding users about upcoming outfits,
- synchronizing planning across the ecosystem.

The Calendar module is **not** responsible for:

- creating outfits,
- storing clothing,
- recognizing garments,
- editing wardrobe metadata.

These responsibilities belong to their respective modules.

---

# Folder Structure

This folder contains the complete documentation for the Calendar module.

## 01_Purpose.md

Explains why the Calendar exists.

---

## 02_Event_Model.md

Defines calendar events.

---

## 03_Functions.md

Documents available functionality.

---

## 04_Screens.md

Defines every screen.

---

## 05_User_Flows.md

Documents user journeys.

---

## 06_AI_Integration.md

Describes AI planning assistance.

---

## 07_Weather_Integration.md

Documents weather-aware planning.

---

## 08_States.md

Defines module states.

---

## 09_Future_Ideas.md

Captures future opportunities.

---

# Relationships

The Calendar collaborates with:

- Wardrobe
- Clothing
- Outfits
- Dressing Room
- AI Stylist
- Weather
- Family
- Travel

The Calendar references outfits rather than storing clothing directly.

It serves as the planning layer of the entire Szafnik ecosystem.

---

# Scope

The Calendar module manages planning and scheduling.

Outfit creation belongs to the Dressing Room.

Outfit storage belongs to the Outfits module.

Wardrobe management belongs to the Wardrobe module.

---

# Closing Statement

The Calendar transforms saved outfits into actionable daily plans.

By connecting wardrobe data with real-life events, weather and personal routines, it helps users prepare confidently while making better use of the clothing they already own.