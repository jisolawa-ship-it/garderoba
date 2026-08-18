# Wardrobe Domain Model

> **The conceptual business model of the Wardrobe module.**

---

# Purpose

This document defines the business entities that make up the Wardrobe module.

It describes concepts and relationships rather than database implementation.

The Domain Model serves as the foundation for future technical architecture.

---

# Core Entity

## Wardrobe

Represents the user's complete clothing collection.

A wardrobe owns every Clothing Item.

There is exactly one wardrobe per user profile.

---

## Clothing Item

Represents one real physical garment or accessory.

Every Clothing Item belongs to exactly one Wardrobe.

A Clothing Item may appear in multiple outfits without being duplicated.

---

## Category

Groups clothing items into logical categories.

Examples:

- Tops
- Bottoms
- Shoes
- Outerwear
- Accessories

Each Clothing Item belongs to one category.

---

## Color

Represents one or more dominant colors of a clothing item.

Multiple colors may exist.

---

## Material

Represents the primary material composition.

Examples:

- Cotton
- Wool
- Linen
- Leather

---

## Brand

Represents the manufacturer.

Optional.

---

## Season

Defines the seasons in which an item is appropriate.

Multiple seasons may apply.

---

## Occasion

Defines suitable usage.

Examples:

- Casual
- Business
- Formal
- Sport

---

## Tag

User-defined labels.

Examples:

- Favorite
- Travel
- Capsule
- Vintage

---

# Relationships

| Entity | Relationship |
|----------|--------------|
| Wardrobe | owns Clothing Items |
| Clothing Item | belongs to Wardrobe |
| Clothing Item | belongs to Category |
| Clothing Item | has Colors |
| Clothing Item | has Seasons |
| Clothing Item | has Occasions |
| Clothing Item | has Tags |
| Clothing Item | may belong to many Outfits |

---

# Ownership Rules

The Wardrobe module is the single owner of Clothing Items.

Other modules reference Clothing Items but never duplicate them.

Examples:

- Outfits reference Clothing Items.
- Calendar references Outfits.
- AI analyzes Clothing Items.
- Shopping compares against Clothing Items.

The Wardrobe remains the single source of truth.

---

# Future Domain Extensions

Potential future entities include:

- Wear History
- Laundry Status
- Repair Status
- Sustainability Metrics
- Warranty
- Purchase History
- Resale Information

These entities are outside the current product scope.

---

# Related Documents

- Purpose.md
- Functions.md
- AI Integration.md
- Decision Log