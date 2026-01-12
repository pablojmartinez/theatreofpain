# Theatre of Pain | Garry's Mod Gamemode

[![Watch the Demo](https://img.youtube.com/vi/AAxCqAm0SDo/0.jpg)](https://www.youtube.com/watch?v=AAxCqAm0SDo)

This repository contains the core logic for a survival/roleplay gamemode commissioned in late 2016. The project involved 150+ hours of development, built by heavily modifying and extending the **Nutscript framework**.

### 🛠 Technical Highlights & Engineering Solutions

* **Synchronized Group-Based Access Control:** Engineered a "Character Groups" system integrated with a persistent **Lock System**. This allowed dynamically created player factions to share ownership and permissions over world entities (doors and containers).
* **Source Engine Hooking & Workarounds:** Bypassed engine-level constraints regarding environmental destruction. Since `EntityTakeDamage` had limitations with certain entity types, I implemented a custom hook system (`OnEntityExplode`) to intercept explosive logic and manually calculate destruction states.
* **Algorithmic Entity Spawning:** Developed a position-based spawning system for loot and NPCs (Nextbots). It features configurable probability tables, item-type density settings, and global instance limits to maintain server performance and network stability.
* **State Persistence & Mechanics:** 
    * Implemented individual weapon ammo persistence (non-shared pools).
    * Developed status-dependent player systems (Hunger/Infection) with custom UI overlays.
    * Integrated AI door-breaching logic for NPC interactions with the environment.

### 📝 Project Context
* **Language:** Lua
* **Base Framework:** Nutscript (Heavily modified to fix core bugs and extend functionality).
* **Focus:** Logic architecture, state management, and overcoming engine limitations.

---
**Note on Seniority & Current Work:**
This is a **legacy project from 2016**. While it showcases my foundation in logic and systems design, my current professional focus is on **C# and .NET 8 Architecture**, high-performance simulation engines, and Blazor web ecosystems. 

*Private repositories containing current proprietary C# work and simulation architecture are available for technical walkthroughs during the interview process.*
