# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**MineOreDefense** is a Godot 4.6 first-person survival builder / horde defense game. Players mine crystals, build defenses, and survive nightly creature swarms on an alien world. Corporate dystopia tone with darkly comedic writing.

- **Engine:** Godot 4.6 (GDScript), Forward Plus renderer, D3D12 (Windows)
- **Physics:** Jolt Physics (3D)
- **Entry Point:** `system/main/main.tscn`
- **Addon:** `godot_state_charts` — used for enemy, player, and level phase state machines

## Development Commands

Open and run the project through the Godot 4.6 editor. There is no CLI build system — all running, testing, and exporting is done via the Godot editor UI.

- **Run game:** F5 in the Godot editor (runs `system/main/main.tscn`)
- **Run current scene:** F6 in the Godot editor
- **Export:** Project → Export in Godot editor

## Architecture

### Core Principles (Non-Negotiable)

1. **No Autoloads** — All managers use a `static var instance` pattern. Instantiation order is controlled explicitly in `main.tscn`. Access managers via `GameData.instance`, `MenuManager.instance`, etc.

2. **Strongly Typed Everywhere** — Every variable, parameter, and return type must be explicitly typed. Never use `:=` inference — always `var x: Type = value`. Use `const`, `enum`, and `class_name` aggressively.

3. **Scene-First** — Never build nodes through code. All placeables (structures, enemies, turrets, UI panels) are pre-built `.tscn` files. Code only calls `.instantiate()` on existing scenes.

4. **Composition Over Inheritance** — Use Godot's node hierarchy as the component system. Prefer small, reusable child nodes over deep inheritance trees.

5. **Signal Routing** — No global signal buses. Managers expose public methods + signals. Siblings communicate through their parent. Parents are glue and signal routers.

6. **Data-Driven** — All resource definitions (enemy stats, upgrades, wave data, building specs) live in `.tres` Resource files, not hardcoded in scripts.

### Directory Layout

```
system/     # Core managers: Main, GameData, MenuManager, SaveManager, Prefabs
game/       # All gameplay: game_root, actors, components, levels, systems, weapons
ui/         # UI only: menus (main_menu, pause_menu) and game_hud (not yet built)
addons/     # godot_state_charts (third-party)
```

### Core Flow

```
main.tscn (root)
  ├── GameRoot        — 3D world container (static instance, currently empty)
  ├── CanvasLayer
  │   └── MenuManager — instantiates & manages all menus
  ├── SaveManager     — save/load stub
  └── GameData        — game state (static instance)
```

Startup: `Main._ready()` → `MenuManager.show_menu(Menu.Type.MAIN)` → user clicks Play → `GameData.reset_for_new_game()` → `Main.start_game()` → gameplay.

### Key Files

| File | Role |
|------|------|
| `system/main/main.gd` | Orchestrator — game start, pause, menu transitions |
| `system/menu_manager/menu_manager.gd` | Menu lifecycle and visibility |
| `system/game_data/game_data.gd` | Central game state (to be populated as systems are built) |
| `system/prefabs/block_prefabs.gd` | Scene path constants for all placeable blocks |
| `system/prefabs/menu_prefabs.gd` | Scene path constants for all menus |
| `ui/menus/menu.gd` | Abstract base class for all menus (`Menu.Type` enum lives here) |
| `game/levels/level.gd` | Base class for all game levels |
| `game/game_root.gd` | Root 3D node for gameplay (static instance) |
| `MineOreDefense_Architecture_v1.md` | Locked design decisions — read before making structural changes |
| `MineOreDefense_GDD_v1.md` | Full gameplay design spec — reference for what to build |

### Prefab Pattern

New scene types get added to a prefab loader in `system/prefabs/`. These are plain GDScript classes with `const` paths to `.tscn` files. Instantiate via:
```gdscript
var scene: PackedScene = load(BlockPrefabs.TURRET_BASIC)
var node: TurretBasic = scene.instantiate()
```

### Menu Pattern

All menus extend `Menu` (ui/menus/menu.gd). Add a new menu type to `Menu.Type` enum, add its scene to `MenuPrefabs`, and register it in `MenuManager._ready()`. The manager handles show/hide lifecycle.

### State Machines

Use `godot_state_charts` addon for any complex state logic (enemy behavior, player states, wave phases). Do not roll custom state machines.

### What's Built vs. Planned

**Built:** Menu system (main + pause), GameData skeleton, SaveManager stub, Prefab loaders, Level base class, GameRoot placeholder.

**Not yet built:** Player controller, camera, mining, resource economy, grid building, enemy AI, turrets, wave/spawning, day-night cycle, damage/health, HUD.

Placeholder directories awaiting implementation: `game/actors/`, `game/components/` (blocks, devices, enemy, player, weapons), `game/systems/`.
