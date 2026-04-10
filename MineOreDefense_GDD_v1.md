# Game Design Document  
**MineOre Defender**  
**Version:** 1.0 (Vertical Slice – 30-Day Solo Jam)  
**Genre:** First-person survival builder / horde defense / light roguelite  
**Target Length:** One complete run = 45–60 minutes  
**Platform:** PC (Godot 4.6, low-poly 3D)  
**Tone:** Darkly comedic corporate dystopia  

## 1. High Concept (The Fantasy)
You are a disposable contractor for **MineOre Corp**, a ruthless megacorp that mines volatile crystal worlds. They dropped you on **Omnicron 4** with a cheap pod, a pickaxe, and an expense form. Your job: hand-mine glowing minerals by day, slap together a temporary fortified outpost, and survive the nightly swarms of crystal-maddened wildlife.  

The goal is **not** to survive forever. It’s to extract **1,200 Energy Crystals** and call in the evacuation shuttle. The same crystals you need to win are also the best fuel for turrets, shields, and power generators. Every crystal you spend on defense is one less toward extraction.  

When you think you have enough, you plant the beacon and pray you survive one final night. If the base falls or you die… the company shrugs. Your death is cheaper than a recovery shuttle.  

Between runs you wake up in the grimy **MineOre Reclamation Hub** — a vending-machine-filled orbital hellhole — and spend your meager **Hazard Pay Credits** at the **MineOre Brand Store™** on permanent upgrades. The corp doesn’t care if you live. But they *do* love upselling you slightly-less-shitty equipment.

**Tagline:** “Mine. Build. Survive. Expense Report Your Corpse.”

## 2. Core Gameplay Loop
A single run is built around short, tense **day/night cycles** (5–7 total for the slice).  

**Day Phase** (exploration & preparation)  
- First-person free-roaming across a small, contained alien valley.  
- Hand-mine colored crystal veins for three resources.  
- Return to your outpost to refine raw materials at the fabricator.  
- Place or upgrade static automation drills directly on veins (set-and-forget).  
- Build and expand a modular base using grid-snapped prefabs: floors, walls, corners, turrets, generators, shield emitters, and the central **Core Pod** (the extraction point that must stay alive).  
- Every structure is independent — walls can be blasted open, turrets can be destroyed, creating real holes and panic-repair moments.

**Night Phase** (horde defense)  
- Waves of crystal-maddened creatures swarm from the map edges.  
- You fight personally (basic FPS weapons + melee) while automated defenses engage.  
- Enemies converge on the Core Pod. If it reaches zero health, the run ends in failure.  
- Structures take individual damage; enemies can literally chew holes through your base.  
- Survive until dawn.

**End of Run**  
- Reach 1,200 Energy Crystals + plant the beacon + survive the final night = **Successful Extraction**.  
- Core Pod destroyed or player death = **KIA**.  
- Earn Hazard Pay Credits based on crystals extracted (full amount on success, reduced on failure).  
- Return to the Reclamation Hub for upgrades and “one more run.”

The central tension is the **judgement call**: spend rare Energy Crystals on a shield generator tonight, or save them for the win quota? Build heavy defenses early and risk falling short, or stay lean and pray your walls hold?

## 3. Resources & Economy
Three resources only — deliberately limited and meaningful:

- **Plasteel** (common gray veins) → bulk building material for walls and floors.  
- **Power Shards** (medium blue veins) → fuel for generators and advanced turrets.  
- **Energy Crystals** (rare glowing purple veins + enemy drops) → high-tier defense, research-equivalent upgrades, **and the win-condition quota**.  

Resources are both your currency *and* your win ticket. Automation drills slowly feed a shared stockpile so you’re not hand-carrying everything forever, but the player still makes the big strategic choices.

## 4. Base Building & Defense
- Modular, first-person-friendly grid building.  
- Every placeable (wall segment, turret, floor tile, generator, shield projector, Core Pod) has its own independent health.  
- Destruction creates genuine tactical holes — enemies pour through gaps, forcing mid-night repairs or desperate repositioning.  
- Late-game tools include area shields that protect everything inside their bubble (until the emitter is destroyed).  
- No complex wiring or conveyors — keep the fantasy clean and focused on the “build fast, defend harder” loop.

## 5. Enemies & Horde Behavior
- Pure horde fantasy: crystal-maddened wildlife that feels chaotic and relentless.  
- Two enemy types in the slice: fast melee swarmers and slower, tankier hulks that smash structures.  
- Enemies seek the Core Pod. They attack any “MineOre property” (player-owned structures or the player) that enters their attack bubble.  
- When stuck, they burrow underground and re-emerge closer to the base — visually selling the “they’re tunneling through the crystal veins” fantasy.  
- No smart pathfinding — just raw numbers, momentum, and swarm pressure.

## 6. Progression & Meta Layer
**In-run progression**  
- Start with only a pickaxe and basic pistol.  
- Unlock better tools, turrets, and structures by surviving nights and banking crystals.  
- Automation and defenses scale up across the 5–7 cycles.

**Between-run meta-progression (roguelite lite)**  
- In the **MineOre Reclamation Hub** you visit the **MineOre Brand Store™**.  
- Spend Hazard Pay Credits on permanent unlocks: faster mining, extra starting turrets, higher crystal drop rates, auto-repair kits, better starting health, shield improvements, etc.  
- Upgrades are flavorfully corporate (“Now with 40 % less spontaneous combustion!”).  
- The game remains fully beatable with zero upgrades, but each successful run makes future runs noticeably smoother and more strategic.  
- Death is never punishing — it’s expected. The corp even sends a snarky “thank you for your sacrifice” email.

## 7. Tone, Theme & World Flavor
- **Corporate dystopia**: Everything screams cheap, sleazy megacorp. Loading-screen tips, death screens, store voice lines, and emails lean hard into dark humor.  
- **Visual style**: Low-poly 3D, vibrant glowing crystals against barren alien rock. Bright hazard orange and corporate teal accents on all player structures and tools.  
- **Audio**: Tense day/night music shift, rumbling burrow sounds, corporate hold-music in the hub, satisfying mining clunks and turret fire.  
- **Narrative**: Delivered through emails, loading tips, and store flavor text. No cutscenes or voiced story — the world is told through the systems and the absurdity of your situation.

## 8. Scope & Vertical Slice Definition
**What “done” looks like in 30 days (solo):**  
- One small fixed map (contained valley).  
- Complete first-person mining, refining, building, and defense loop.  
- 5–7 day/night cycles with scaling difficulty.  
- Full resource economy and judgement-call tension.  
- Independent health on every structure.  
- Two enemy types with burrow behavior.  
- Win condition (1,200 crystals + final night survival).  
- Death/KIA and successful extraction endings.  
- Tiny Reclamation Hub with functional MineOre Brand Store™ and permanent upgrades.  
- Polished enough to feel complete and replayable, even if unrefined around the edges.

**Explicitly out of scope for the slice:**  
- Procedural maps  
- Conveyor logistics or complex automation  
- Multiple biomes  
- Flying enemies  
- Multiplayer  
- Deep story or voiced dialogue  

---

**This is the complete fantasy**: desperate mining under corporate pressure, frantic base-building, and the constant knife-edge decision of “do I have enough to extract… or do I need one more night?”  

The game is short, tense, funny, and replayable. Every run feels different because your own resource choices and upgrade path create new “when do I bail?” moments.  

We are building a game that nails the fantasy in one focused, shippable vertical slice — nothing more, nothing less.
