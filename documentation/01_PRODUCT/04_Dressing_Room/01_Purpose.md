# Dressing Room

> **The digital space where users experiment with their wardrobe before making real-world decisions.**

---

# Purpose

The Dressing Room module provides a safe and creative environment where users can experiment with clothing combinations using garments they already own.

Rather than planning events or managing wardrobes, the Dressing Room focuses on exploration.

It allows users to mix, compare and evaluate clothing without affecting the physical wardrobe.

The Dressing Room transforms the wardrobe from a static collection into an interactive creative workspace.

---

# Module Responsibility

The Dressing Room module is responsible for:

- creating outfits,
- editing outfits,
- experimenting with clothing combinations,
- comparing outfit variations,
- previewing clothing combinations,
- supporting AI-assisted styling.

The Dressing Room is **not** responsible for:

- storing clothing,
- managing wardrobe organization,
- planning calendar events,
- shopping decisions,
- managing clothing metadata.

These responsibilities belong to their respective modules.

---

# Folder Structure

This folder contains the complete product documentation for the Dressing Room module.

## 01_Purpose.md

Explains why the Dressing Room exists.

---

## 02_Functions.md

Describes every available capability.

---

## 03_Screens.md

Defines every screen belonging to the module.

---

## 04_User_Flows.md

Documents user journeys.

---

## 05_Outfit_Model.md

Defines the conceptual structure of outfits.

---

## 06_AI_Integration.md

Describes AI support within the Dressing Room.

---

## 07_States.md

Defines all module states.

---

## 08_Navigation.md

Documents navigation.

---

## 09_Future_Ideas.md

Captures future evolution ideas.

---

# Relationships

The Dressing Room collaborates with:

- Wardrobe
- Clothing
- Outfits
- Calendar
- AI Stylist
- Shopping
- Family

The Dressing Room never owns clothing.

It references Clothing items managed by the Wardrobe module.

Completed outfits may later be saved into the Outfits module.

---

# Scope

The Dressing Room documents everything related to experimenting with clothing combinations.

Persistent outfit storage belongs to the Outfits module.

Wardrobe management belongs to the Wardrobe module.

Calendar planning belongs to the Calendar module.

---

# Closing Statement

The Dressing Room is the creative workspace of Szafnik.

It bridges the gap between owning clothes and confidently deciding what to wear by allowing users to experiment freely before committing to an outfit.