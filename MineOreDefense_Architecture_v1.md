# Architecture Plan v1.2  
**MineOre Defense**  
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
- Code only instantiates existing scenes (`load("res://scenes/.../wall.tscn").instantiate()`).

**Static Instance Pattern (Managers)**  
- No Autoloads.  
- Every manager uses the static instance pattern so we can control exact instantiation order from a single `Bootstrap.gd` or `RunRoot.gd`.

**Colors**  
- Always `Color(1.0, 0.5, 0.0, 1.0)` — never shorthand or named colors.

**Communication**  
- No Large "buss managers" for signals.  
- Managers expose public methods + signals.
- Parent nodes should be glue and signal passes of child components
- Sibling nodes should go to their parent (or the objects root: ie PlayerController may have a compoents node with components in it - should reach out to player controller)

**Data-Driven**  
- All upgrades, enemy stats, resource definitions, wave data live in `.tres` Resource files.

## 2. Project Folder Structure (Scenes + Scripts Colocated) - this is example, need to extrapolate as we go
//Res
-Assets
--shaders
--textures
--models
--icons
--sfx
--music
-System #these are our systems and managers
--Globals #if any autoloads are required (and cant be instantiated at run time)
-Resources #any tres that we use, go here, in organized folders
-Menus
--menu.gd
--main_menu
---mainmenu.gd and tscn
--pause_menu
---pausemenu.gd and tscn
-Game
--levels
---level.gd
---debug_level
----debuglevel.gd
----debuglevel.tscn
-UI

## 3. Key Systems & How They Are Architected

**Managers (Static Instance)**  
Instantiated in strict order inside `run.gd` or `Bootstrap.gd`.

**Player**  
`scenes/run/player/player.tscn` with all child nodes pre-attached.

**Structures / Base Building**  
Every placeable inherits from `destructible_base.tscn`.  
`DestructibleStructure.gd` (attached to the root) handles health, damage, and destruction.

**Destruction & Debris (Locked Decision)**  
- When any structure’s health reaches zero:  
  1. Call `DestructibleStructure.take_damage()` → play hit VFX.  
  2. Spawn 4–8 instances of `debris_cluster.tscn` at the structure’s position (pre-built RigidBody3D with low-poly chunks + random angular velocity).  
  3. `queue_free()` the original structure.  
- Debris falls with physics, bounces once or twice, then fades out (simple lifetime script).  
- This gives the visual “base is crumbling” fantasy **without** any structural connectivity or physics on live buildings.

**Enemies**  
`swarmer.tscn` and `hulk.tscn` with pre-wired attack bubbles.

**UI**  
All panels are separate `.tscn` + colocated `.gd`.

## 4. Resolved Discussion Points

**Structural Integrity / Connectivity**  
**Decision: Option A + Debris**  
- No physics or connectivity checks on placed structures (they remain StaticBody3D forever).  
- Destruction spawns falling debris clusters for visual feedback.  
- This keeps building snappy, first-person friendly, and 100 % stable for the jam.

**All other points from v1.1 are unchanged and locked.**

## 5. Performance & Jam-Specific Guards
- Max 80–100 structures + 80 enemies + ~400 debris pieces across a night (Godot 4.6 handles this easily with Forward+ and low-poly).  
- Debris uses simple RigidBody3D with low collision complexity.

## 6. Save & Persistence (Vertical Slice)
- Skipped for the prototype.  
- data lives in `.tres` Resource files, where it makes sense
- persistant player data for the game will be implemented later. 
