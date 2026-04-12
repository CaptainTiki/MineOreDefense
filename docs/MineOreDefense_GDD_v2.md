# Game Design Document
**MineOre Defense**
**Version:** 2.0 (Prototype Direction Update)
**Genre:** First-person survival builder / frontier base defense / light extraction strategy
**Platform:** PC (Godot 4.6, low-poly 3D)
**Tone:** Darkly comedic corporate dystopia

---

## 1. High Concept
You are a disposable contractor for **MineOre Corp**, dropped onto a hostile mineral world to establish a foothold, extract valuable resources, and survive escalating nightly attacks from the native bug population.

The player does not begin with a completed base. They arrive in a landing pod or deployment rocket, retrieve their starting gear, deploy the **Core Pod**, and decide where to establish their first defensible foothold before nightfall.

From there, the game becomes a push-and-pull between:
- expanding safely,
- extracting enough resources to grow,
- defending the home base,
- and deciding when distant outposts are worth the risk.

The longer the player stays on the planet, and the more industry they build, the more aggressively the world responds.

**Fantasy:**
> Land on a hostile world. Build a foothold. Push outward for richer ore. Hold the line while the planet learns to hate you.

**Tagline:**
> “Mine. Build. Survive. File Incident Reports Later.”

---

## 2. Core Pillars

### 2.1 Establish a Foothold
The player starts vulnerable. The first minutes are about landing, gathering supplies, placing the Core Pod, and building just enough shelter and utility to survive the first night.

### 2.2 Expand with Purpose
Ore is not all clustered near spawn. The player must move outward, scout deposits, and decide where to commit defenses, power, and time.

### 2.3 Defend What You Build
Every wall, turret, power source, drill, and outpost is a statement: “this location matters.” Bugs attack the player’s infrastructure, not just abstract wave targets.

### 2.4 Risk Distance
Going farther from home means richer rewards, but also more vulnerability. If the main base is attacked while the player is at a mining outpost, they may not get back in time.

### 2.5 The Planet Reacts
Threat rises not only with time, but with industrial activity. Mining, drilling, power generation, fortification, and prolonged occupation make the player more visible and more hated.

---

## 3. Core Gameplay Loop
A run is built around repeating **day/night cycles**.

### Day Phase
- Land or continue from an existing foothold.
- Scout terrain and ore deposits.
- Hand-mine resources from nearby nodes.
- Fabricate blocks, utilities, and defenses.
- Expand the home base.
- Place drills on discovered deposits.
- Establish forward mining outposts using batteries, walls, relays, and turrets.
- Decide whether to stay close to home or push farther for better resource income.

### Night Phase
- Bug attacks begin.
- Pressure can fall on the home base, an outpost, or both depending on threat and activity.
- The player fights personally while turrets and built defenses try to hold.
- Damage to structures creates real breaches and repair emergencies.
- The player may need to choose which position to reinforce and which to abandon.

### Long-Run Tension
- The player’s footprint grows.
- Threat escalates.
- Richer extraction requires more exposure.
- Maintenance cost and defensive burden increase.
- The question becomes not just “can I survive tonight?” but “how much of my footprint can I afford to hold?”

---

## 4. Player Experience Goals
The first 10–15 minutes should feel like this:
1. I deploy onto a hostile planet.
2. I retrieve my gear and place my Core Pod.
3. I gather just enough nearby ore to get started.
4. I realize the rich deposits are farther out.
5. I race to build a minimal defense before night.
6. I survive one messy night and feel relief at dawn.
7. I start thinking about how to expand, not just how to endure.

The mid-game should feel like this:
1. My home base is stable enough to leave behind briefly.
2. I can bring a field kit to a distant deposit.
3. I build a mining outpost with limited power and defenses.
4. Night falls and I have to decide whether to defend home or hold the outpost.
5. I feel clever when infrastructure holds without me, and punished when I overextend.

---

## 5. World Structure
The world is a **hand-authored chunk-based map**, not procedural for now.

### Goals
- The playable space feels larger than the current prototype.
- The player should not easily see obvious hard edges.
- Terrain supports multiple meaningful base sites and resource routes.
- Distance should matter without becoming tedious.

### Map Composition
- **Starter Zone:** safe-ish landing area with minimal starter ore.
- **Mid Ring:** the first meaningful deposits and likely expansion routes.
- **Far Deposits / POIs:** richer resource sites intended for outposts and long travel runs.
- **Vista / Boundary Terrain:** distant cliffs, crater walls, and haze to hide the literal edge of the map.

---

## 6. Opening Flow
The run should begin with a strong ritual instead of an aimless spawn.

### Deployment Sequence
- The player arrives via rocket, drop pod, or similar deployment craft.
- Camera shake, dust, audio, and brief objective text sell the landing.
- A supply crate or lander locker contains the player’s initial kit.

### Starting Kit
- Basic weapon
- Mining tool
- Build tool
- Flashlight
- Folded / deployable Core Pod

### First Objectives
- Retrieve supplies
- Deploy Core Pod
- Gather starter ore
- Build first defenses or utilities
- Survive until dawn

This sequence gives the game immediate purpose and makes the player feel like they are establishing the base themselves.

---

## 7. Resources & Economy
The resource model should support both personal action and territorial expansion.

### Core Resources
Current prototype resources can remain the foundation, but their roles should become more distinct:
- **Structural Resource** → walls, floors, basic blocks, repairs
- **Power / Tech Resource** → generators, batteries, relays, advanced defenses
- **High-Value / Rare Resource** → stronger defenses, advanced logistics, major unlocks, or eventual extraction goals

Exact naming can remain flexible while the systems settle.

### Economy Principles
- Starter ore near spawn is intentionally limited.
- Better resource density exists farther from the Core Pod.
- Hand-mining is the early-game method.
- Drills become the mid-game method.
- Growth should come from claiming deposits, not from printing resources anywhere.

---

## 8. Mining & Drills
The game should support both **manual mining** and **automated extraction** without deforming the terrain.

### Manual Mining
- Fast and direct.
- Good for early game and emergency gathering.
- Encourages player exploration and route learning.

### Automated Drills
Drills do **not** need to visibly carve terrain.
They can simply produce ore over time as long as they are grounded in the world fiction and placement rules.

### Drill Rules
- Drills may only be placed on valid ore deposits or extraction hotspots.
- They produce the matching resource over time.
- They should be slower than concentrated player mining at first, but they free the player to build, defend, and expand.
- They may require power, storage, maintenance, or pickup support to stay meaningful.

### Why This Works
The important fantasy is not terrain deformation.
It is:
- finding a deposit,
- claiming it,
- industrializing it,
- and defending the investment.

---

## 9. Base Building
This is not a pure factory game. Building is about **defensible infrastructure**.

### Core Building Goals
- Simple, readable first-person construction.
- Fast enough to support combat pressure.
- Modular enough to let players improvise walls, firing lines, power corners, and utility clusters.

### Important Structures
- Core Pod
- Walls / foundations / ramps / basic structure pieces
- Batteries / generators / simple power infrastructure
- Turrets
- Lights / utility support
- Drills
- Drone relay or collection support later

### Damage Model
- Structures have individual health.
- Bugs can breach walls and expose interiors.
- The player repairs during downtime or in a panic if things go badly.

---

## 10. Home Base vs Outposts
This is the strategic heart of the game.

### Home Base
- The anchor of the run.
- Holds the Core Pod.
- Usually receives the most investment and the strongest fortification.
- Losing it should matter most.

### Outposts
- Built near valuable distant deposits.
- Initially small and risky.
- Can be powered and defended well enough to survive short periods alone.
- Become more autonomous as the player improves logistics and infrastructure.

### Nighttime Decision Pressure
A key recurring choice is:
- Do I return home before night?
- Do I trust the home base defenses and stay at the outpost?
- Do I abandon the outpost and preserve the core?
- Do I split resources now so future nights are easier?

The game should regularly create situations where the player cannot personally defend everything at once.

---

## 11. Threat & Enemy Pressure
Threat should come from both **time** and **industry**.

### Global Threat
Represents the planet’s overall hostility.
Rises from:
- days survived,
- total extraction,
- structures placed,
- total footprint,
- major expansion milestones.

Global threat influences:
- raid size,
- enemy variety,
- attack frequency,
- number of simultaneous attack vectors.

### Local Threat
Represents how “loud” or visible a specific location is.
Rises from:
- nearby drills,
- generators,
- lights,
- turret fire,
- concentrated player activity,
- active extraction and logistics.

Local threat influences:
- which base or outpost gets targeted,
- how often remote sites are attacked,
- whether a quiet relay survives unnoticed while a loud mining site gets swarmed.

### Design Goal
The player should feel that the world is reacting to what they built, not just to a timer.

---

## 12. Enemies
The bug faction should feel like a living planetary immune response.

### Early Slice Enemies
- **Swarmers:** fast melee pressure, dangerous in groups
- **Bruisers / Smashers:** slower enemies that damage walls and structures heavily

### Behavioral Goals
- Clear silhouettes in darkness
- Pressure on structures, not just the player
- Believable assault behavior on bases and outposts
- Escalation that feels territorial, not random

Future enemies can expand the ecosystem, but the prototype should focus on one or two dependable attackers first.

---

## 13. Combat
Combat already serves the game well as a readable personal defense tool.

### Combat Role
- The player is the emergency responder, especially early.
- Guns should feel effective enough that the player can save a bad situation.
- Combat is there to support base defense and field survival, not to replace building.

### Desired Feel
- Dark nights
- Flashlight scanning
- Easy-to-read enemy silhouettes
- Fast kills on weaker bugs
- “I can survive this if I stay alert” energy

The player should not feel helpless, but they also should not feel free to ignore infrastructure.

---

## 14. Progression Curve
### Early Game
- Deploy
- Place Core Pod
- Hand-mine
- Build minimal walls and power
- Personally defend the base

### Mid Game
- Stabilize home base
- Build better turrets and storage
- Scout farther deposits
- Establish a crude mining outpost
- Start trusting infrastructure a little more

### Late Prototype Direction
- Multiple active extraction sites
- More autonomous defense and logistics
- Escalating planetary hostility
- Difficult choices about what to reinforce, repair, or sacrifice

---

## 15. Tone & Presentation
The corporate dystopia tone still fits beautifully.

### Tone Goals
- Cheap corporate gear on a hostile world
- Dry, dark humor through UI, tooltips, and transmissions
- “You are replaceable” energy without heavy narrative overhead

### Presentation Goals
- Strong deployment intro
- Distinct day/night mood shift
- Clear build silhouettes and readable nighttime combat
- Modular, practical structures that feel like disposable industrial hardware

---

## 16. Vertical Slice Scope (Updated)
The next strong slice should prove this specific fantasy:

### Slice Success Definition
- The player deploys onto the planet through a short intro sequence.
- The player retrieves starting gear and places the Core Pod manually.
- The player gathers limited starter ore near spawn.
- The player must move farther out for better extraction.
- The player can build a basic defensible home base.
- Night attacks pressure that base.
- The player can place at least one drill on a real deposit.
- The player can begin establishing a small forward outpost.
- Threat escalation is visible and understandable.

### Explicitly Out of Scope for This Stage
- Procedural terrain generation
- Terrain deformation for mining or drilling
- Deep factory logistics / conveyor systems
- Large enemy rosters
- Full campaign narrative
- Multiplayer

---

## 17. Summary
MineOre Defense is evolving away from a simple “wave defense on a tiny map” prototype and toward a stronger identity:

**A hostile-world survival builder where the player establishes a foothold, expands into distant resource zones, and survives escalating bug aggression by deciding where to invest defenses and what to sacrifice.**

The game’s best moments should come from commitment, overextension, and relief:
- committing to a base site,
- overextending for richer deposits,
- and barely holding the line until dawn.

That is the good stuff.
