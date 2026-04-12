# MineOreDefense Vertical Slice Plan

This document is our working build plan for getting the project to a playable vertical slice.

The goal is to move in small, testable phases and leave the project in a playable state at the end of each phase. We should be able to stop after any phase, run the game, and meaningfully exercise what was built without needing debug-only intervention or half-finished systems.

## Vertical Slice Goal

Deliver one complete gameplay loop:

1. Start a new run from the main menu.
2. Spawn into the debug level during daytime.
3. Mine resources from veins.
4. Craft and place at least one meaningful defense.
5. Transition into night with clear visual and UI feedback.
6. Survive an enemy attack on the base.
7. Reach the next morning or lose if the `CorePod` is destroyed.

## Working Rules

- Every phase must end in a playable build.
- Every phase must have a clear manual test checklist.
- Prefer one complete feature path over multiple partial systems.
- New systems should have a single clear owner script when possible.
- If a feature is not needed for the slice, defer it.
- We optimize for reliability and readability before content volume.

## Current Starting Point

The project already has:

- Main menu and pause flow.
- `GameRoot`, `Level`, and `DebugLevel` runtime structure.
- Player spawning and movement.
- Mining/inventory/hotbar/build foundations.
- `CorePod` hookup and HUD support.
- A day/night cycle is currently being worked on.

That means the most important job now is to connect these systems into one complete loop.

## Phase Plan

### Phase 1: Day/Night Backbone

Purpose:
Create one authoritative cycle system that the rest of the slice can trust.

Deliverables:

- A cycle manager with explicit phases such as `DAY`, `PREP`, and `NIGHT`, or a simpler `DAY` / `NIGHT` split if that is enough.
- Configurable phase durations.
- Signals or public state for current phase, elapsed time, and time remaining.
- Lighting and sky updates driven from the same source of truth.
- HUD updates for current day number and current phase.
- The run always starts in daytime.

Out of scope:

- Fancy weather.
- Multiple day variants.
- Cinematic transitions that do not affect gameplay clarity.

Playable state at end of phase:

- The player can start a run and remain in the world as the cycle advances automatically.
- The scene visibly changes between day and night.
- The HUD reflects the current phase.

Manual test checklist:

1. Launch from the main menu into gameplay.
2. Confirm the run starts in daytime.
3. Wait for transition to night without using editor-only tools.
4. Confirm light/sky changes are visible.
5. Confirm the HUD updates the phase/day text correctly.
6. Confirm the game remains controllable through the full transition.

Suggested implementation notes:

- Prefer a dedicated manager under `system/` or `game/` rather than spreading timing logic across UI and level scripts.
- Treat visual transition and gameplay phase state as one system, not separate timers.

### Phase 2: Daytime Resource Loop

Purpose:
Make daytime gameplay productive and understandable.

Deliverables:

- Veins consistently provide resources when mined.
- Resource counts update immediately in the HUD.
- Depleted veins behave clearly and do not keep yielding.
- The player can gather enough resources for at least one craftable defense path.

Out of scope:

- Large biome variety.
- Multiple mining tools.
- Rare-resource balance work beyond slice needs.

Playable state at end of phase:

- The player can start a run, mine resources during day, and understand what they collected.

Manual test checklist:

1. Start a run.
2. Find at least one vein of each intended slice resource.
3. Mine a vein and verify resource count changes in the HUD.
4. Continue until at least one vein depletes and verify depletion behavior is clear.
5. Confirm the player can gather enough resources to support the next phase.

Suggested implementation notes:

- Prioritize feedback first: hit response, beam clarity, count updates, depletion readability.
- If balance is rough, err on the side of faster progression for the slice.

### Phase 3: Crafting and Building Loop

Purpose:
Let the player convert daytime mining into actual defensive preparation.

Deliverables:

- Fabricator menu opens reliably and displays the slice recipe set.
- At least one recipe crafts successfully from gathered resources.
- Crafted items enter the correct inventory/build flow.
- Hotbar and build inventory stay synchronized.
- The player can place at least one wall or other simple defense in the world.
- Repair behavior works for the chosen slice structure if repair is part of the intended loop.

Out of scope:

- Large crafting trees.
- Multiple stations.
- Advanced placement rules unless needed for preventing obvious exploits.

Playable state at end of phase:

- The player can mine, craft, equip, and place defenses in one uninterrupted run.

Manual test checklist:

1. Start a run and gather resources.
2. Open the fabricator.
3. Craft a defensive item.
4. Confirm costs are deducted correctly.
5. Confirm the crafted item appears in the correct inventory/hotbar path.
6. Place the defense in the world.
7. Restart the run and repeat to confirm the loop is stable.

Suggested implementation notes:

- Keep the slice recipe list intentionally tiny.
- If there is a conflict between inventory elegance and stability, choose stability.

### Phase 4: Player Combat Readiness

Purpose:
Give the player a complete, testable combat interaction before enemy work begins.

Deliverables:

- At least one combat weapon can be equipped from the hotbar.
- Primary fire works reliably.
- Aim-down-sights or other secondary handling works reliably if included in the slice weapon.
- The weapon can damage a valid target using the intended combat model.
- Combat feedback is readable, such as muzzle flash, tracer, hit effect, or impact decal.
- The debug level contains a stable combat target for testing even before enemies exist.

Out of scope:

- Large weapon arsenals.
- Ammo, reload, and weapon progression unless they are required for the feel of the first weapon.
- Multiple damage types.

Playable state at end of phase:

- The player can start a run, equip a combat weapon, aim, fire, and confirm hits on a target without breaking mining, building, or day/night flow.

Manual test checklist:

1. Start a run from the main menu.
2. Confirm the combat weapon can be selected from the hotbar.
3. Fire at a valid target and confirm hit registration is consistent.
4. Confirm combat feedback is visible and readable.
5. Confirm ADS or the weapon's secondary behavior works reliably.
6. Switch between combat weapon, mining tool, and build tool and confirm all still function.
7. Confirm the project remains playable through a full day/night transition with the weapon present.

Suggested implementation notes:

- Build this phase around one dependable weapon, not a whole arsenal.
- A debug dummy target is acceptable here and lowers risk before enemy work starts.
- The combat weapon should use the same runtime flow enemies will rely on later.

### Phase 5: Night Attack Loop

Purpose:
Make nighttime a real test of the player’s preparation.

Deliverables:

- Night start triggers enemy spawning.
- At least one enemy type can path toward and attack the `CorePod`.
- Enemy count and pacing are simple but functional.
- The player can interact with the wave using the existing movement/build/mining toolkit or by using prepared defenses.
- Dawn or wave completion stops enemy pressure cleanly.

Out of scope:

- Multiple enemy factions.
- Sophisticated AI behaviors.
- Endless survival scaling.

Playable state at end of phase:

- The player can prepare during day, survive a basic night attack, and keep playing through the transition back out of danger.

Manual test checklist:

1. Start a run and wait for night.
2. Confirm enemies spawn automatically at night.
3. Confirm enemies move toward the base objective.
4. Confirm enemies damage the `CorePod` when not stopped.
5. Confirm basic defenses materially affect the encounter if intended.
6. Confirm enemy pressure ends when the night phase ends.

Suggested implementation notes:

- One dependable enemy is better than several weakly implemented ones.
- Pathing and attack clarity matter more than animation complexity.

### Phase 6: Failure and Survival Resolution

Purpose:
Close the loop so the slice has a real success/failure outcome.

Deliverables:

- `CorePod` damage is readable in the HUD.
- `CorePod` destruction triggers a clean game-over flow.
- Surviving the night transitions back to daytime cleanly.
- The next day begins in a stable state, even if the slice currently stops after one successful night.
- Menu return, pause, and restart all still work after both win-like and lose states.

Out of scope:

- Full campaign progression.
- Meta progression.
- Save/load persistence.

Playable state at end of phase:

- The project contains one full end-to-end playable loop with clear fail and survive outcomes.

Manual test checklist:

1. Start a run and intentionally lose by allowing the `CorePod` to be destroyed.
2. Confirm game over triggers cleanly and the game returns to a stable menu state.
3. Start a fresh run after losing and verify the session is clean.
4. Start another run and survive until morning.
5. Confirm the transition back to daytime is stable and understandable.
6. Confirm pause/menu controls still behave correctly in both success and failure paths.

Suggested implementation notes:

- Even if we do not build a formal win screen yet, surviving a night must feel acknowledged.
- If needed, a simple “Dawn reached” or “Day 2” indicator is enough for the slice.

### Phase 7: Vertical Slice Polish Pass

Purpose:
Raise clarity and feel without destabilizing the loop.

Deliverables:

- Tune day/night durations for a short but satisfying session.
- Improve clarity of damage, placement validity, and important HUD states.
- Clean up obvious UX friction in fabricator, inventory, and phase transitions.
- Add missing audio or placeholder feedback hooks where absence hurts comprehension.
- Remove or gate debug behaviors that break the intended slice flow.

Out of scope:

- Large refactors unless they unblock reliability.
- Content expansion that introduces new systems late.

Playable state at end of phase:

- The slice is coherent, readable, and easy to demo from a fresh launch.

Manual test checklist:

1. Play from main menu through a full session with no editor intervention.
2. Confirm the intended gameplay loop is understandable to a new player.
3. Confirm no major blockers appear in mining, crafting, building, phase transitions, or combat.
4. Confirm performance and frame stability are acceptable for the slice target.

## Definition of Done

We can call the vertical slice complete when all of the following are true:

- A new run starts cleanly from the menu.
- Daytime, nighttime, and at least one transition between them work reliably.
- Mining is functional and clearly communicated.
- Crafting and building are functional and clearly communicated.
- The player can defend a `CorePod`.
- At least one enemy creates real nighttime pressure.
- Losing is functional and clean.
- Surviving until morning is functional and clean.
- The game remains playable at every step without needing unfinished debug scaffolding.

## Priorities When Tradeoffs Appear

If we need to cut scope, cut in this order:

1. Extra enemy types.
2. Extra buildables.
3. Extra recipes.
4. Fancy visuals beyond phase readability.
5. Non-essential persistence or meta systems.

Do not cut:

- The day/night backbone.
- The mine -> craft -> build -> defend loop.
- A clean lose condition.
- A playable build at the end of each phase.

## How We Should Use This Plan

Before starting work on a phase:

1. Confirm the exact deliverable for that phase.
2. Identify the smallest playable implementation.
3. Build only what is needed to pass the phase checklist.

After finishing a phase:

1. Run the manual checklist.
2. Fix any regressions that break playability.
3. Update this document if scope changes or a later phase needs to be simplified.

## Next Recommended Step

The next step is Phase 1: Day/Night Backbone.

Since that system is already in progress, we should finish it in a way that gives us:

- one authoritative owner for cycle state,
- one stable HUD hookup,
- one clean level startup path,
- and one reliable transition into the next gameplay phases.
