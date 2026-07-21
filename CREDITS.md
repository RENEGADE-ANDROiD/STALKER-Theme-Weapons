# Credits — S.T.A.L.K.E.R. Theme Weapons

Consolidated from the legacy `Readme.MD` and in-mod authorship notes. For maintainer shout-outs and bundled packs, see **`README.md`**.

## Code

| Contribution | Author / source |
| ------------ | ---------------- |
| Bullet tracer | Pans |
| Reloading weapons code | WildWeasel |
| Craters, bullet holes, explosion smoke / flames | SGTMarkIV |
| Casing code | Dr_Cosmobyte, TheRailgunner |
| Corpse and spawners code | Dr_Cosmobyte |
| Ambient **CasingSpawner** (thing 32010) + CAS1/2/7 litter sprites | Legacy bundled `CasingSpawners.wad` (author not recorded in-repo); integrated into ZScript / `Sprites/CasingSpawners/` |
| **FX_TeleSmoke** (thing 32011) + HSM2/HSMX/HSPX red smoke / glitter | Legacy bundled `HexenSmoke.wad` (author not recorded in-repo); integrated into ZScript / `Sprites/HexenSmoke/` + `GLDefs.txt` |
| Meatgrinder base | SGTMarkIV |
| Riot shield tweaks / integration | RENEGADE ANDROiD (per `Weapons.zs` header) |
| **Knife-pushable casings / mags** (`CS_EjectaPush`, `STAT_CS_EJECTA`) | Impulse pattern from **Project Brutality** kickable ejecta; triggered by knife melee instead of kick |
| **Tilt++** camera roll (`Z_TiltMe`) | Nash Muhandes — folded from Project Survival |
| **Yaw weapon sway** (`zm_yawsway*`) | ZMove / Project Survival Separated Movement Modes math on `STALKERPlayer` |
| **Weapon rotational tilt** (`CS_WeaponRotTilter*`, `wt_*`) | Project Survival `PS_WeaponTilter` — profiled for Clear Sky weapons |
| **Zone map anomalies** (gravity / frost / electro / burner) | PB2022 BlackHole/VORTEX + ORBP/BHOL/BH05; PB ice crystals; UKS Frost/Electric aura (DeVloek); TC Flames for Burner |
| **Universal Kick** (kick / slide / ledge / FP legs / taunt) | Mickromash UniversalKick logic — legs/ledge SFX Project Brutality; **FPS kick/slide/air sheets + red/blue/green boot smears** from Sergeant_Mark_IV Brutal Doom 22 (`KICK`/`SLID`/`1–3ICK`/`1–3LID`); taunt gloves Sergeant_Mark_IV; Clmb2/3 ledge; FUCK* gesture sprites (no taunt voices); assets under `Sprites/MR_UKick/`, `Patches/MR_UKick/`, `Sounds/MR_UKick/` |

## Sprites

| Asset / weapon | Authors |
| -------------- | ------- |
| TT-33 | Captain J |
| Fort-12 | TheFunktasm |
| PPSh-41 | DenisBelmondo |
| PP-19 | Vostok, Captain J, Yukesvonfaust |
| RPK-16 / Vepr-12 | Sgt Shivers |
| TOZ-34 | Gollgagh, Batandy |
| KS-23 | Captain J |
| AK-47 | YukesvonFaust |
| SKS | Marrub, Captain J |
| OTs-14 | Tommy Galano, Lossforwords, Potebloke, DR_Cosmobyte |
| Mosin-Nagant | SGT.Shivers, Captain J |
| SVD Dragunov | YukesVonFaust |
| RP-46 | DR_Cosmobyte, Captain J |
| GM-94 | Sonik.o.Fan, DR_Cosmobyte |
| RPG-7D | SGTMarkIV, Thorir |
| Duty mugshot 1 | Melodica, Mark Quinn, Vegeta, Xim, Ghastly_dragon, MagicWazard |
| Duty mugshot 2 | Mike12 |
| Arachnids | Monolith, Id Software, Captain Toenail |
| Carcass | Horrormovierei |
| Blood Sucker | Carbine Dioxide |
| Boar | Id Software, Konami, Paddu, Neoworm, Craneo |

## Sounds

| Category | Authors |
| -------- | ------- |
| Weapons | Vonlichstein, Bossbobs |
| Ambient | GSC Game World, Autumn Aurora Team |

## Upstream

- Original **Clear Sky** mod thread: [ZDoom forums](https://forum.zdoom.org/viewtopic.php?t=74531).

If you add new art or code, append rows here and mention the change in `CHANGELOG.md`.
