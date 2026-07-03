# The Last Farmer — Game Design Document

> Status: **Initial draft**
> Last updated: 2026-07-02
> Author: Solo dev (design, programming, narrative, and art)

---

## Table of contents

1. [Overview](#1-overview)
2. [Narrative and world](#2-narrative-and-world)
3. [Gameplay mechanics (core loop)](#3-gameplay-mechanics-core-loop)
4. [Progression and economy](#4-progression-and-economy)
5. [Art and visual style](#5-art-and-visual-style)
6. [Interface and controls](#6-interface-and-controls)
7. [Technical scope (Godot)](#7-technical-scope-godot)
8. [Roadmap and milestones](#8-roadmap-and-milestones)

---

## 1. Overview

### 1.1 Elevator pitch
> _TBD: a one-line summary of the game._

### 1.2 Design pillars
> _TBD: 3-4 principles that guide every design decision._

1. …
2. …
3. …

### 1.3 Genre and references
- Genre: top-down farm RPG
- Mechanics references: Stardew Valley
- Narrative tone references: _TBD_

### 1.4 Platforms and MVP scope
- Engine: Godot
- Target platforms: _TBD_
- MVP scope: full loop till → plant → water → grow → harvest → sell →
  sleep → next day; energy/stamina; reliable save (including inventory and
  farmland state); basic economy (selling crops); one NPC with dialogue and
  an initial narrative hook; start and pause menus.
  Milestone breakdown and implementation in [`docs/ROADMAP_MVP.md`](ROADMAP_MVP.md).

---

## 2. Narrative and world

### 2.1 Premise
> _TBD: the dark mystery of the pursued family lineage._

### 2.2 Tone and atmosphere
> _TBD_

### 2.3 Narrative structure
- How the story is paced out (dialogue, notes, events, cutscenes, etc.)
> _TBD_

### 2.4 Main characters
| Character | Role | Description |
|---|---|---|
| | | |

### 2.5 Narrative introduction (opening hook)
> _TBD — MVP priority_

---

## 3. Gameplay mechanics (core loop)

### 3.1 Day-to-day game loop
> _TBD_

### 3.2 Farming system
- Tilling
- Planting
- Harvesting
- Growth curves / seasons (if applicable)
> _TBD_

### 3.3 Tool system
- Progression
- Wear
- Upgrades
> _TBD_

### 3.4 Save system
> _TBD_

### 3.5 Other MVP mechanics
- Inventory
- Energy / stamina
- Basic economy
> _TBD_

---

## 4. Progression and economy

### 4.1 Content unlocks
> _TBD_

### 4.2 Internal economy
- Selling crops
- Buying seeds / tools
> _TBD_

---

## 5. Art and visual style

### 5.1 Art direction
- Color palette: _TBD_
- Visual references: _TBD_
- Sprite / tile size: _TBD_

### 5.2 Required assets list (MVP)
- [ ] Farmland terrain tileset
- [ ] Playable character sprite (idle, walk, tools)
- [ ] Tools (icons + use animations)
- [ ] Base UI
- [ ] _TBD: narrative assets_

---

## 6. Interface and controls

### 6.1 HUD
> _TBD_

### 6.2 Menus
> _TBD_

### 6.3 Controls
| Action | Keyboard/Mouse | Gamepad |
|---|---|---|
| | | |

---

## 7. Technical scope (Godot)

### 7.1 General architecture
- Main scenes: _TBD_
- Autoloads / singletons: _TBD_
- Key systems (save, inventory, dialogue, etc.): _TBD_

### 7.2 Non-functional requirements
- Target performance: _TBD_
- Supported resolutions: _TBD_

---

## 8. Roadmap and milestones

| Stage | Goal | What to show |
|---|---|---|
| MVP | Core mechanics + narrative intro | Vertical slice gameplay |
| Itch.io | First public release | Playable build |
| Early Access Steam | Expanded content | Trailer + demo |
| Kickstarter | Funding | Pitch + polished prototype |

The engineering milestone breakdown to reach the MVP (M0-M8, with files, `EventBus`
signals to reuse, and "done" criteria per milestone) lives in
[`docs/ROADMAP_MVP.md`](ROADMAP_MVP.md).

---

## Changelog

| Date | Change |
|---|---|
| 2026-07-02 | Created the initial GDD skeleton |
