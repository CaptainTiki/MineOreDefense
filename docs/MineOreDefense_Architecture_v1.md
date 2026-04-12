# Architecture Plan v1.3  
**MineOre Defender**  
**Godot 4.6 • GDScript 4.6 • Low-Poly 3D • Vertical Slice**  
**Date:** 2026-04-10

## 1. Core Programming Principles (Non-Negotiable)

**Strongly Typed Everywhere**  
- Every variable, function parameter, return type, and signal must be explicitly typed.  
- **No `:=` operator anywhere** — always `var my_var: int = 5` or `var my_var: Node3D`.  
- Use `const`, `enum`, and custom `class_name` aggressively for clarity.

**Composition Over Inheritance**  
- Godot’s node system *is* our component system.  
- Prefer many small, reusable nodes/scripts attached to a parent scene over deep inheritance trees.

**Scene-First Philosophy**  
- **Never build nodes through code** when a `.tscn` can do the job.  
- All placeables, enemies, UI panels, VFX, debris, etc. are pre-built reusable `.tscn` files with nodes already attached and configured in the editor.  
- Code only instantiates existing scenes (`load("res://.../wall.tscn").instantiate()`).

**Static Instance Pattern (Managers)**  
- No Autoloads.  
- Every manager uses the static instance pattern so we can control exact instantiation order from a single `Bootstrap.gd` or `Main.gd`.

**Colors**  
- Always `Color(1.0, 0.5, 0.0, 1.0)` — never shorthand or named colors.

**Communication**  
- Signals for 95 % of cross-system events.  
- Managers expose public methods + signals.  
- Parent nodes should be glue and signal passes of child components.  
- Sibling nodes should reach out to their parent (or the object’s root).

**Data-Driven**  
- All upgrades, enemy stats, resource definitions, wave data live in `.tres` Resource files.

## 2. Project Folder Structure (Current – Matches v1)
MineOreDefense/
├── addons/
│   └── godot_state_charts/          # State machine addon (kept)
├── game/
│   ├── actors/
│   │   └── blocks/
│   │       └── veins/               # ore_vein.tscn, limestone_vein.tscn, etc.
│   └── levels/
│       ├── level.gd
│       └── debug_level.tscn         # current test level
├── resources/
│   ├── blocks/                      # VeinData.tres + vein_data.gd
│   ├── player/                      # PlayerStatsResource.tres
│   └── run/                         # RunData.gd
├── system/
│   ├── game_data/
│   ├── main/                        # main.gd + main.tscn (entry point)
│   ├── menu_manager/
│   ├── prefabs/                     # BlockPrefabs.gd, LevelPrefabs.gd, etc.
│   └── save_manager/
├── ui/
│   ├── game_hud/                    # GameHud, ResourceCounterPanel, etc.
│   └── menus/
│       ├── fabricator_menu/
│       ├── main_menu/
│       └── pause_menu/
├── MineOreDefense_Architecture_v1.3.md
├── MineOreDefense_GDD_v1.md
├── project.godot
└── (other root files)


## 3. Key Systems & How They Are Architected

**Managers (Static Instance)**  
Instantiated in strict order inside `system/main/main.gd`.

**Player**  
`game/actors/player/player.tscn` with all child nodes pre-attached.

**Structures / Base Building**  
Every placeable inherits from `destructible_base.tscn` (planned).  
`DestructibleStructure.gd` (attached to the root) handles health, damage, and destruction.

**Destruction & Debris (Locked Decision)**  
- When any structure’s health reaches zero:  
  1. Call `DestructibleStructure.take_damage()` → play hit VFX.  
  2. Spawn 4–8 instances of `debris_cluster.tscn` at the structure’s position (pre-built RigidBody3D with low-poly chunks + random angular velocity).  
  3. `queue_free()` the original structure.  
- Debris falls with physics, bounces once or twice, then fades out (simple lifetime script).  
- This gives the visual “base is crumbling” fantasy **without** any structural connectivity or physics on live buildings.

**Enemies**  
`swarmer.tscn` and `hulk.tscn` with pre-wired attack bubbles (planned).

**UI**  
All panels are separate `.tscn` + colocated `.gd` under `ui/`.

## 4. Resolved Discussion Points

**Structural Integrity / Connectivity**  
**Decision: Option A + Debris**  
- No physics or connectivity checks on placed structures (they remain StaticBody3D forever).  
- Destruction spawns falling debris clusters for visual feedback.  
- This keeps building snappy, first-person friendly, and 100 % stable for the jam.

**All other points from v1.2 are unchanged and locked.**

## 5. Performance & Jam-Specific Guards
- Max 80–100 structures + 80 enemies + ~400 debris pieces across a night (Godot 4.6 handles this easily with Forward+ and low-poly).  
- Debris uses simple RigidBody3D with low collision complexity.

## 6. Save & Persistence (Vertical Slice)
- Skipped for the prototype.  
- Data lives in `.tres` Resource files where it makes sense.  
- Persistent player data will be implemented later.

## 7. Next Steps After Approval
1. Continue building on the existing skeleton (menus, GameData, RunData, debug level).  
2. Polish the mining loop (next logical step).  
3. Expand the building system once mining feels good.

---
