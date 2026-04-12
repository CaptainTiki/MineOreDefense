# MineOre Defense — V2 Implementation Plan

This document updates the original vertical slice plan to match the current direction of the prototype.

The core mission for V2 is simple:

> Make the game feel intentional from the first minute, make exploration matter, and make expansion create real strategic pressure.

We are not trying to build the entire finished game in this pass. We are trying to turn the current promising prototype into a stronger, more playable slice of the real game.

---

## 1. V2 Outcome
A successful V2 build should support this loop:

1. Start a run.
2. Deploy onto the planet through a short mission-start sequence.
3. Retrieve the starting kit and place the Core Pod manually.
4. Gather limited nearby ore.
5. Build a minimal foothold before night.
6. Survive a first night attack.
7. Move outward for better deposits.
8. Place a drill on a real ore site.
9. Begin building a small mining outpost.
10. Feel the pressure of defending more than one important location.

---

## 2. Working Rules
- Every phase must end in a playable build.
- Every phase must have a practical manual test checklist.
- Prefer one complete feature path over several partial systems.
- Use authored content before procedural systems.
- Solve for feel and clarity before scale and variety.
- Avoid rewrites unless a system is actively blocking progress.

---

## 3. Current Strengths From V1
The prototype already has a lot of good bones:
- runtime structure through `Main`, `GameRoot`, `Level`, and `DebugLevel`
- mining, inventory, hotbar, and build foundations
- fabricator and basic resource loop
- day/night cycle and night attack cadence
- combat that feels readable and useful
- a working base-defense prototype loop

That means V2 should focus on **purpose, terrain, ore distribution, and territorial pressure**, not on reinventing everything.

---

## 4. Phase Plan

## Phase 1 — Mission Start and Base Establishment

### Purpose
Replace the aimless opening with a clear, purposeful start.

### Deliverables
- A short deployment intro (drop pod / rocket / lander arrival)
- A supply crate, lander locker, or similar start container
- Manual Core Pod placement by the player
- Simple opening objectives:
  - Retrieve supplies
  - Place Core Pod
  - Gather ore
  - Build first defense

### Notes
The goal is not a cinematic. The goal is a ritual.
The player should feel like they are starting the mission, not spawning into a test map.

### Playable State at End of Phase
- Start a run
- Watch or experience deployment
- Retrieve starting tools
- Place the Core Pod manually
- Continue normal gameplay from there

### Manual Test Checklist
1. Start a new run from the menu.
2. Confirm the deployment sequence plays reliably.
3. Confirm control is returned cleanly.
4. Confirm the player can retrieve the starting kit.
5. Confirm the Core Pod is not pre-placed in the world.
6. Confirm the player can place the Core Pod successfully.
7. Confirm the run continues normally after deployment.

---

## Phase 2 — Terrain Expansion and Edge Hiding

### Purpose
Make the world feel like a place instead of a small prototype box.

### Deliverables
- Chunk-based authored terrain layout
- Larger playable footprint
- Multiple sensible base locations
- Distant cliffs, crater walls, haze, or vista meshes to hide hard boundaries

### Notes
This is **not** procedural generation work.
It is authored chunk assembly and world dressing.
The goal is to stop the player from seeing the edge of reality five seconds after landing.

### Playable State at End of Phase
- The player can move around a larger environment
- The world no longer reads as a tiny isolated square
- The terrain supports travel routes and expansion direction

### Manual Test Checklist
1. Load the level and explore several directions.
2. Confirm the player does not immediately see obvious terrain edges.
3. Confirm the level contains more than one sensible build area.
4. Confirm traversal still feels readable and not overly frustrating.
5. Confirm current combat and build systems still function on the new terrain.

---

## Phase 3 — Ore Redistribution and Exploration Pressure

### Purpose
Make resource gathering create decisions instead of chores.

### Deliverables
- Minimal starter ore near the landing / starting zone
- More meaningful mid-range deposits
- Richer or rarer far deposits
- At least 3–5 recognizable ore points of interest

### Notes
The player should not be able to fully stockpile before the first night simply because all the ore is piled at their feet.
The map should teach the player that moving outward matters.

### Playable State at End of Phase
- The player can gather enough to get started nearby
- The player must travel outward for better returns
- The level now supports meaningful exploration during the day

### Manual Test Checklist
1. Start a run and gather nearby resources.
2. Confirm nearby resources are enough to start, but not enough to fully solve the run.
3. Explore outward and confirm richer or more useful deposits exist farther away.
4. Confirm the player has to make a travel decision before the first or second night.
5. Confirm ore sites are easy to visually identify and remember.

---

## Phase 4 — Core Pod Rules and Base Placement Value

### Purpose
Make the choice of base location matter.

### Deliverables
- Validity rules for Core Pod placement
- At least 2–3 sensible starting base locations
- Nearby terrain tradeoffs such as:
  - flatter terrain
  - better sight lines
  - shorter walk to starter ore
  - safer perimeter shape

### Notes
The Core Pod should feel like the anchor of the run, not just another placeable.
The player should make a meaningful commitment when they place it.

### Playable State at End of Phase
- Different players can plausibly choose different base locations
- The opening of the run feels strategic instead of predetermined

### Manual Test Checklist
1. Start a run and inspect the starting zone.
2. Confirm there are multiple viable Core Pod placement spots.
3. Confirm placement validation prevents nonsense or broken placements.
4. Confirm the chosen base location changes travel or defense considerations.
5. Confirm the game still proceeds cleanly after placement.

---

## Phase 5 — Drill Prototype on Real Deposits

### Purpose
Introduce automated extraction without requiring terrain deformation.

### Deliverables
- A starter drill structure
- Drill placement limited to valid deposits or extraction hotspots
- Drill output over time
- Clear visual or UI feedback showing the drill is working
- Optional simple storage behavior if needed

### Notes
The drill is not a free ore printer.
It must be tied to discovered resource sites so exploration and map control stay meaningful.

Early balance target:
- player hand-mining is faster in short bursts
- drill mining is slower but persistent
- the value is freeing the player to do other things

### Playable State at End of Phase
- The player can find a deposit, place a drill, and begin automated extraction
- The player has a reason to defend something beyond the Core Pod

### Manual Test Checklist
1. Gather the resources needed to build a drill.
2. Travel to a valid deposit.
3. Confirm the drill cannot be placed just anywhere.
4. Place the drill successfully on a valid site.
5. Confirm it generates the expected resource over time.
6. Confirm the output is understandable to the player.

---

## Phase 6 — Forward Outpost Kit

### Purpose
Turn distant extraction into a small territorial play instead of a temporary walk.

### Deliverables
- Enough placeables and rules to support a tiny mining outpost:
  - battery or small generator
  - a few wall pieces
  - one turret
  - one drill
- A lightweight concept of “field kit” play
- At least one deposit site that is clearly worth fortifying

### Notes
This phase is about proving the fantasy of taking materials into the field and establishing a remote foothold.
The outpost does not need deep logistics yet. It just needs to be real enough to defend.

### Playable State at End of Phase
- The player can travel to a richer deposit
- Build a minimal defended extraction site
- Feel the difference between home-base safety and frontier risk

### Manual Test Checklist
1. Establish a home base.
2. Travel to a farther deposit with building materials.
3. Build a small outpost around the deposit.
4. Power and arm the outpost.
5. Confirm the site feels worth caring about.
6. Confirm the player can leave it and return without breaking the run.

---

## Phase 7 — Threat Model Pass

### Purpose
Make the world feel reactive instead of timer-only.

### Deliverables
- A simple **global threat** value
- A simple **local threat** value for active bases or outposts
- Enemy pressure influenced by both time and player activity
- Clear debug readouts during development, even if hidden later

### Notes
This does not need to be a giant simulation.
Even a modest version will help a lot.

Suggested first-pass inputs:
- days survived
- structures placed
- drills active
- generators active
- nearby powered defenses

Suggested first-pass outputs:
- attack size
- attack frequency
- target preference between base and outpost

### Playable State at End of Phase
- Staying longer on the planet feels more dangerous
- Loud, active industrial sites feel more likely to attract attention
- Expanding your footprint creates pressure instead of just free value

### Manual Test Checklist
1. Start a run and remain relatively quiet.
2. Confirm threat still rises over time.
3. Build more infrastructure and activate drills.
4. Confirm attacks intensify or target important sites more often.
5. Compare runs with low and high activity and confirm the difference is noticeable.

---

## Phase 8 — Night Pressure at Multiple Sites

### Purpose
Create the strategic choice between defending home and defending expansion.

### Deliverables
- The ability for attacks to target more than one meaningful location
- Outposts that can sometimes survive without direct player presence
- Situations where the player must decide what to reinforce and what to risk

### Notes
This is where the game starts becoming itself.
The goal is not to punish the player with chaos soup. The goal is to create pressure that reveals whether their infrastructure actually works.

### Playable State at End of Phase
- A night can threaten the home base, the outpost, or both
- The player cannot comfortably be everywhere at once
- The player can lose part of their footprint without automatically losing the whole run

### Manual Test Checklist
1. Establish a home base.
2. Build one defended outpost.
3. Survive a night where attacks focus home.
4. Survive a night where attacks focus the outpost.
5. Survive or fail a night where the player must choose where to stand.
6. Confirm the resulting damage feels fair and informative.

---

## Phase 9 — First-Day and First-Night Tuning

### Purpose
Make the opening loop land emotionally.

### Deliverables
- Better day-one pacing
- Better dusk readability
- Enough time to get started, but not enough to feel solved
- The first night should feel survivable but unfinished

### Notes
The desired feeling is:
> “I got a foothold down, but I’m absolutely not ready.”

That is perfect for this game.

### Playable State at End of Phase
- New runs consistently create urgency without feeling unfair
- The player understands what they should care about before nightfall

### Manual Test Checklist
1. Start several fresh runs.
2. Confirm the opening objective flow feels clear each time.
3. Confirm first-day ore and build time feels tight but fair.
4. Confirm dusk communicates danger clearly.
5. Confirm first-night survival feels earned, not trivial.

---

## 5. Systems to Avoid Expanding During V2
To keep scope sane, avoid deep work in these areas unless something is actively blocking progress:

- procedural map generation
- terrain deformation
- conveyor systems or full factory logistics
- large enemy rosters
- elaborate meta progression
- multiple planets or biomes
- major combat overhauls

Combat already sounds like it is doing its job. Leave it mostly alone unless readability breaks.

---

## 6. Recommended Build Order
If progress needs to be ruthlessly prioritized, do the work in this order:

1. Deployment intro
2. Manual Core Pod placement
3. Larger chunk-based terrain
4. Ore redistribution
5. Base placement value
6. Starter drill on real deposits
7. Small mining outpost support
8. Global/local threat pass
9. Multi-site night pressure
10. First-day tuning

---

## 7. “Done” Definition for V2
V2 is successful if the game reliably creates this story:

- I land on the planet.
- I retrieve my equipment.
- I choose where to place my base.
- I realize nearby ore is limited.
- I leave safety to secure better deposits.
- I build a defended extraction site.
- Night falls before I feel fully ready.
- I cannot safely protect everything at once.
- I start making real decisions about what to hold and what to sacrifice.

That is the leap from “good prototype” to “this is the actual game.”
