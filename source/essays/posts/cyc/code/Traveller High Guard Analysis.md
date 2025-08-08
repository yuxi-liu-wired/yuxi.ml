# Report on the 1981 Eurisko Fleet

by the Permanent Members of the Galactic Security Council (Claude, Gemini, O1, R1, Yuxi)

Signature: Claude 3.7 Sonnet, Gemini 2.5 Pro Experimental 03-25, OpenAI o1, DeepSeek-R1, YuxiLiu-2025-03-30.

## How to read the data sheets according to *Traveller: High Guard*

### Basic Identification (First Line)

*   **`Type-Name`**: `XX-ShipName`
    *   `XX`: Two-letter Ship Type Code (e.g., BC=Battle Cruiser, BA=Battle Armored, TB=Tanker/Tender Battle, IL=Intruder Light, FF=Fighter Fast). See *High Guard* p. 26 for codes.
    *   `ShipName`: The vessel's given name.
*   **`USP String`**: The 21-character Universal Ship Profile (detailed below).
*   **`MCrCost`**: Total cost in Millions of Credits.
*   **`Tonnage`**: Ship's displacement mass in tons.

### Universal Ship Profile (USP) String

Format: `TT-T C JMP C# - A S M N F R L E P G K - F` (Spaces added for clarity only)

| Pos   | Code | Description              | Details & Key Values (*High Guard*. pp. 23-26, 52) |
| :---- | :--- | :----------------------- | :------------------------------------------------------- |
| 1-2   | TT   | **Ship Type**            | See Section I.                                           |
| 3     | T    | **Tonnage**         | Size: 0 (<100), 1(100), ..., 9(900), A(1k), ..., K(10k), ..., R(100k), ..., Y(1M), Z(reserved). |
| 4     | C    | **Configuration**   | Shape/Streamlining: 1(Needle/Full), ..., 9(Buffered Planetoid/None). |
| 5     | J    | **Jump Drive**           | Max Jump distance (0-6+). 0 = None.                    |
| 6     | M    | **Maneuver Drive**       | Sublight thrust rating (0-Z...). Higher = faster potential. |
| 7     | P    | **Power Plant**          | Power output rating (0-Z...). Must be ≥ J or M. Determines EP. |
| 8     | C#   | **Computer**        | Model rating (0-9, A=1fib, ..., J=9fib, R=1bis, S=2bis). Controls Jump (Model# ≥ Jump#). |
| 9     | Crew | **Crew Size**       | 0(None), 1(1-9), 2(10-99), 3(100-999), 4(1k+)...        |
| ---   | ---  | **DEFENSES**             | ---                                                      |
| 10    | A    | **Hull Armor Factor**    | 0-9... Higher=tougher. Planetoids start at 3 (Std) or 6 (Buffered). |
| 11    | S    | **Sandcaster Factor**    | 0-9. Defense vs Lasers/Energy.                           |
| 12    | M    | **Meson Screen Factor**  | 0-9. Defense vs Meson Guns.                              |
| 13    | N    | **Nuclear Damper Factor**| 0-9. Defense vs Nuclear Missiles.                        |
| 14    | F    | **Force Field Factor**   | 0-9. (Black Globe). Absorbs energy.                      |
| 15    | R    | **Repulsor Factor**      | 0-9. Defense vs conventional Missiles.                   |
| ---   | ---  | **WEAPONS**              | ---                                                      |
| 16    | L    | **Laser**         | 0-9. Beam/Pulse Lasers per battery.                      |
| 17    | E    | **Energy Weapon** | 0-9. Plasma/Fusion Guns per battery.                     |
| 18    | P    | **Particle Accelerator (PA)**| A-T: PA strength per battery / Spinal Mount Code.      |
| 19    | G    | **Meson Gun**     | A-T: Meson Gun strength per battery / Spinal Mount Code. |
| 20    | K    | **Missile**       | 0-9. Missile strength per battery.                       |
| ---   | ---  | **OTHER**                | ---                                                      |
| 21    | F    | **Fighter Squadrons**    | 0-9. Number of typical fighter *squadrons* carried.      |

### Additional Data (Below USP)

*   **`Batteries Bearing / Batteries`**: Number/Code of batteries of *each weapon type* that can fire forward / Total number/code of batteries of *each weapon type* installed. Letters used for counts > 9. Aligns with USP factors from left (Armor) to right (Missiles).
*   **`Crew=`**: Specific number of crew members.
*   **`TL=`**: Tech Level of construction (often A=10, B=11, C=12...).
*   **`Passengers=`**: Number of dedicated passenger berths/staterooms.
*   **`Low=`**: Number of Low Berths (cryogenic suspension). Can be passengers or Frozen Watch (reserve crew).
*   **`Cargo=`**: Cargo capacity in tons.
*   **`Fuel=`**: Total fuel tankage in tons. (Used for Jump & Power Plant).
*   **`EP=`**: Energy Points available = `0.01 * Tonnage * Power Plant Rating`. Used for weapons, screens, agility, computer.
*   **`Agility=`**: Combat maneuverability rating (0 to Maneuver Drive rating). Higher = harder to hit, better dodging. Derived from remaining EP after systems are powered.
*   **`Marines=/Troops=`**: Number of ship's troops or marines carried.
*   **`Note:`**: Special information (e.g., L-Hyd drop tanks, design quirks).
    *   **L-Hyd Tanks**: Usually lists added fuel/mass, the modified USP performance (`XX-T'J'M'P'C#`), new Agility, and cost. Remember the ship is heavier and potentially slower *with* tanks attached.
*   **`Carried Craft Listings`**: Separate USP lines for fighters, pinnaces, boats etc. carried aboard. Their cost/tonnage is usually included in the parent ship's total.

## Analysis of EURISKO's fleet

1.  **Main Combatant Type (75 ships)**: -> **Eurisko Class** (BA-K952563-J41100-34003-0)
    *   **Fits**: Correct number (75), Agility 2 ("slightly above minimum"), no spinal mounts. Carries drop tanks. The description of "one solitary laser among their 50 or so weapon batteries... just to absorb damage" strongly points to the Eurisko's numerous turreted weapons (`1 11 V` - likely turreted missiles and lasers), fitting the *High Guard* damage allocation rules.
    *   **Conflicts/Confusion**: Lenat's mention of "an enormous number of small missile weapons" as the primary armament seems less accurate if 'V' (lasers) were numerous for damage absorption, unless '11' (missiles) were also present in large numbers per ship, or he was focusing on the *fleet-wide* missile volleys.
    *   **Conclusion**: The **Eurisko** class is definitively the main combatant line described.
2.  **Small, Agile, Defensive "Stalemate Guarantor"**: -> **Wasp Class** (IL-A90ZZF2-J00000-00009-0)
    *   **Fits**: "Small" (1000 tons), "super agile" (Agility 6), fitting the "unhittable lifeboat" or "stalemate guarantor" concept derived from high agility defense.
    *   **Conflicts/Confusion**: Lenat mentioned "one ship" functionally, but the fleet had 7 Wasps. The Wasp isn't *purely* defensive (likely has standard fighter weapons in its turret `1`).
    *   **Conclusion**: The **Wasp** is the only ship matching the critical "small and super agile" characteristic central to this described role.
3.  **Original Stalemate Guarantor "Lifeboat"**: -> **Bee Class** (FF-0906661-A30000-00001-0)
    *   **Fits**: The Bee's tiny 99-ton size (`Tonnage` 0), minimal crew/weapons, and heavy armor (Factor A=10) match the physical "lifeboat" description, potentially surviving hits that would destroy other small craft. It is carried aboard the Queller class.
    *   **Conflicts/Confusion**: Its Agility 0 directly contradicts the crucial "could not be hit" aspect of Lenat's description. High Agility, like the Wasp's (A6), is the primary driver of evasiveness in *High Guard*.
    *   **Conclusion**: The Bee might have been the original stalemate guarantor discovered accidentally, as a "lifeboat". Subsequently, learned to both include this *precise ship* in all its future fleets, and *also* began a search for ships that implement the same idea, except better, resulting in the Wasp class.
4.  **Anti-Agile Counter Type 1: "Monstrous Hulks"**: -> **Cisor Class** (BD-K9525F3-E41100-340C5-0)
    *   **Fits**: Fits the "monstrous hulks" description well (nearly 20k tons). Agility 0 fits "no chance of defense" (via evasion) and implies slow engines. Part of the "couple" of counter types. Its armament (Laser 3, Energy 4, Meson C, Missile 5) could be configured with high fire control (implied by the Model 6fib computer) to provide the "weapons just barely accurate enough to hit" agile targets like the Wasp. Heavy armor (E=14) fits the "hulk" concept, designed to soak damage it cannot evade.
    *   **Conflicts/Confusion**: Lenat's description of the *other* counter having "no armor" might bleed over confusingly; the Cisor is heavily armored.
    *   **Conclusion**: The **Cisor** best fits the general description of a large, slow, heavily armed and armored platform designed as a primary counter to agile ships through accurate fire rather than maneuver.
5.  **Anti-Agile Counter Type 2: Specialized PA "New Ship"**: -> **Queller Class** (BH-K1526F3-B41106-34Q02-1)
    *   **Fits**: This assignment is driven *specifically* by Lenat's description of a ship with "one single, enormous accelerator weapon," which *only* the Queller possesses (Spinal Mount PA `Z`). It also has the "largest possible guidance computer" (Model 6fib, shared with others) and relatively "slow engines" (Maneuver 2, resulting in Agility 0). Part of the "couple" of counter types. This seems to be the specialized ship developed *specifically* to destroy the "stalemate guarantor."
    *   **Conflicts/Confusion**: This assignment creates *major* conflicts with Lenat's physical description of *this specific ship type*:
        *   Lenat's interpretation of the PA's effectiveness ("glances harmlessly off large armor-plated ships," "very easy to aim") might be specific to his rules interpretation or a simplification.
        *   The rule book described computers that could go as high as 9fib, which is larger than the 6fib equipped by Queller.
    *   **Conclusion**: Despite the drastic contradictions in size and armor description, the presence of the unique Particle Accelerator spinal mount (`Z`) strongly suggests the **Queller** is the basis for Lenat's "new ship" counter description. He seems to have accurately remembered its unique weapon and tactical purpose (anti-agile specialist) while completely misremembering or conflating its physical characteristics (size, armor).
6.  **Warship as Rotating Fuel Tender**: -> **Garter Class** (TB-K1567F3-B41106-34009-1)
    *   **Fits**: Matches Lenat's separate description of using capable *warships* held in reserve as tenders. The Garter is a capable warship (12k tons, Weapons `C 1 EE 7`, Agility 4). It's explicitly designed for large drop tanks. Its Agility 4 makes it suitable for rotating *into* combat. The small number (4 ships) fits a reserve/tender role.
    *   **Conclusion**: The **Garter class** fits the rotating tender role perfectly.

| Lenat's Description                      | Likely JTAS Class          | Key Fits                                                                 | Key Conflicts/Confusions                                                     |
| :--------------------------------------- | :------------------------- | :----------------------------------------------------------------------- | :--------------------------------------------------------------------------- |
| Main Combatant (75)                  | **Eurisko Class**          | 75 ships, Agility 2, No spinal, Damage soak lasers                       | Weapon loadout description (missiles vs lasers) somewhat unclear.           |
| Stalemate Guarantor           | **Wasp Class**             | Super agile (A6), Small-ish, "Unhittable" concept                        | Not *purely* defensive, 7 ships vs 1 functional mention.                      |
| Stalemate Guarantor "Lifeboat"             | **Bee Class**              | Tiny, Agility 0, carried by Queller                                      | Role unclear from narrative, and seems to offer no advantage over Wasp Class as the stalemate guarantor.                        |
| Anti-Agile 1: "Monstrous Hulk"     | **Cisor Class**            | Large size, Low agility (A0), Slow, Accurate weapons vs agile, Hulk concept | Contradicts "no armor" if applied broadly.         |
| Anti-Agile 2: "Enormous PA"  | **Queller Class**          | *Has* the unique PA spinal, Slow (A0), Top computer, Anti-agile role   | Its computer is not notably better than that of 3 other classes, and is smaller than the theoretical maximum of 9fib. |
| Warship as "Rotating Fuel Tender"  | **Garter Class**           | Warship, Designed for drop tanks, Good agility (A4) for rotation         | Not mentioned in Lenat's *first* tactical summary.                          |
