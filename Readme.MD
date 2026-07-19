# S.T.A.L.K.E.R. Theme Weapons

A *Doom* / *Doom II* weapon set and player overhaul themed after the *S.T.A.L.K.E.R.* atmosphere (successor to the **Clear Sky** ZDoom forum release). The roster is implemented in **ZScript**, with extra binds for knife, grenades, molotov, stim, and PDA, plus HUD tweaks and bundled atmosphere add-ons.

Upstream thread for the original Clear Sky project: [ZDoom forums — Clear Sky](https://forum.zdoom.org/viewtopic.php?t=74531).

## Requirements

- **GZDoom** (or a compatible fork such as **UZDoom**) with ZScript support matching the pin in `zscript.zc` (**`version "4.13.0"`** at time of writing). Use a current 4.13.x or newer engine build if you hit parse errors.
- A valid **IWAD** (`doom2.wad`, `doom.wad`, Freedoom, etc.), same as any Doom gameplay mod.

## Installation

1. Install your engine and note the path to `gzdoom.exe` / `uzdoom.exe`.
2. Keep this folder intact (loose files + subfolders + optional `.wad` companions). This is a **directory load**, not a single PK3.
3. Launch with the folder on the command line, for example:

```text
gzdoom.exe -iwad doom2.wad -file "C:\path\to\STALKER-Theme-Weapons"
```

You can also drag the folder onto the executable or add it in a launcher (ZDL, DoomRunner, etc.).

## Controls (defaults)

Defined in `KEYCONF.txt` (rebind under **Options → Customize Controls → STALKER Theme Weapons**):

| Action            | Default key | Notes                                      |
| ----------------- | ----------- | ------------------------------------------ |
| Quick knife       | `V`         | `+user1` — NR-40 lunge via `ClearSkyWeapon`|
| Throw grenade     | `G`         | Uses `F1GrenadeItem`                       |
| Throw molotov     | `M`         | Uses `MolotovItem`                         |
| Stim injector     | `H`         | Uses `StimInjectorItem`                    |
| Duty PDA          | `P`         | Uses `DutyPDA`                             |

## Weapon slots (summary)

Slot numbers follow `STALKERPlayer` in `ZSCRIPT/Player/Player.zs`:

| Slot | Weapons |
| ---- | ------- |
| 1    | NR-40 (knife), Riot Shield (replaces chainsaw role) |
| 2    | Fort-12, TT-33 |
| 3    | Vepr-12, TOZ-34, KS-23 |
| 4    | PP-19, PPSh-41, AS VAL |
| 5    | SKS, Mosin-Nagant, SVD |
| 6    | AK-47, OTs-14, RP-46 |
| 7    | GM-94, RPG-7D (`ZSCRIPT/Weapons/Explosives/`) |

## Related documentation

| `CREDITS.md` | Code, sprite, and sound attribution. |
