# Outfits

> **The permanent library of saved outfit compositions.**

---

# Purpose

The Outfits module stores outfit compositions that users have decided to keep.

Unlike the Dressing Room, which focuses on experimentation, the Outfits module manages outfits that have lasting value.

These saved outfits become reusable assets that can be planned, organized and reused across the Szafnik ecosystem.

---

# Module Responsibility

The Outfits module is responsible for:

- storing saved outfits,
- organizing outfit collections,
- editing saved outfits,
- managing outfit history,
- supporting outfit reuse,
- providing outfits to other modules.

The Outfits module is **not** responsible for:

- wardrobe management,
- clothing recognition,
- creative experimentation,
- clothing metadata.

These responsibilities belong to other modules.

---

# Folder Structure

This folder contains the complete documentation for the Outfits module.

## 01_Purpose.md

Defines why the module exists.

---

## 02_Domain_Model.md

Defines the conceptual structure of outfits.

---

## 03_Functions.md

Documents all available functions.

---

## 04_Screens.md

Defines every screen.

---

## 05_User_Flows.md

Documents user journeys.

---

## 06_AI_Integration.md

Describes AI support.

---

## 07_States.md

Defines module states.

---

## 08_Navigation.md

Documents navigation.

---

## 09_Future_Ideas.md

Captures future opportunities.

---

# Relationships

The Outfits module collaborates with:

- Wardrobe
- Clothing
- Dressing Room
- Calendar
- AI Stylist
- Shopping
- Family

Outfits reference Clothing items but never duplicate them.

New outfits are typically created in the Dressing Room and then saved here.

---

# Scope

The Outfits module manages persistent outfit collections.

Creative experimentation belongs to the Dressing Room.

Clothing ownership belongs to the Wardrobe.

Scheduling belongs to the Calendar.

---

# Closing Statement

The Outfits module transforms successful outfit ideas into reusable assets.

By preserving favorite combinations, it helps users spend less time deciding what to wear while making better use of the clothing they already own.