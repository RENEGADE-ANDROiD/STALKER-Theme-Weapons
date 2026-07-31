// Shared: A_FireCustomMissile sets target to the shooter — heat the ready ClearSkyWeapon.
class CS_MuzzleSmokeSpawnerBase : Actor
{
    int barrelHeatAdd;

    Default
    {
        Speed 20;
        +NOCLIP;
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        if (barrelHeatAdd <= 0) return;

        let p = PlayerPawn(target);
        if (!p || !p.player) return;

        let w = ClearSkyWeapon(p.player.ReadyWeapon);
        if (w) w.CS_AddBarrelHeat(barrelHeatAdd);
    }
}

class SmokeSpawner : CS_MuzzleSmokeSpawnerBase
{
    override void PostBeginPlay()
    {
        barrelHeatAdd = 75;
        Super.PostBeginPlay();
    }

    States
    {
    Spawn:
        TNT1 A 1;
        TNT1 A 0 Thing_ChangeTID(0, 390);
        TNT1 A 0 A_CustomMissile("CS_ShotSmoke", 0, 0, frandom(0, 360), 2, frandom(0, 180));
        Stop;
    }
}

// Callsign Zero–style small muzzle puffs (shotgun cloud offsets) — no extra barrel heat.
class SmokeSpawnerSmall : CS_MuzzleSmokeSpawnerBase
{
    States
    {
    Spawn:
        TNT1 A 1;
        TNT1 A 0 Thing_ChangeTID(0, 390);
        TNT1 A 0 A_CustomMissile("ShotSmokeSmall", 0, 0, frandom(0, 360), 2, frandom(0, 180));
        Stop;
    }
}

// Full-auto / high RoF — lighter cloud so sustained fire does not white-out the view
class AutomaticSmokeSpawner : CS_MuzzleSmokeSpawnerBase
{
    override void PostBeginPlay()
    {
        barrelHeatAdd = 22;
        Super.PostBeginPlay();
    }

    States
    {
    Spawn:
        TNT1 A 1;
        TNT1 A 0 Thing_ChangeTID(0, 390);
        TNT1 A 0 A_CustomMissile("AutomaticShotSmoke", 0, 0, frandom(0, 360), 2, frandom(0, 180));
        Stop;
    }
}

class AutomaticSmokeSpawnerSmall : CS_MuzzleSmokeSpawnerBase
{
    override void PostBeginPlay()
    {
        barrelHeatAdd = 22;
        Super.PostBeginPlay();
    }

    States
    {
    Spawn:
        TNT1 A 1;
        TNT1 A 0 Thing_ChangeTID(0, 390);
        TNT1 A 0 A_CustomMissile("AutomaticShotSmokeSmall", 0, 0, frandom(0, 360), 2, frandom(0, 180));
        Stop;
    }
}

// Thin rising trail from the muzzle while barrelHeat > 0 (PB GunBarrelSmoke / PB_BarrelHeatSmoke).
class CS_GunBarrelSmoke : Actor
{
    Default
    {
        +NOGRAVITY;
        +NOBLOCKMAP;
        +FLOORCLIP;
        +FORCEXYBILLBOARD;
        +CLIENTSIDEONLY;
        +NOINTERACTION;
        +DONTSPLASH;
        +MISSILE;
        +ROLLSPRITE;
        +ROLLCENTER;
        RenderStyle "Add";
        Alpha 0.14;
        XScale 0.07;
        YScale 0.22;
        Radius 0;
        Height 0;
        Speed 0;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_Stop;
        GSMK ACEGIKMOQ 2
        {
            A_SetScale(Scale.X + 0.0035, Scale.Y + 0.0025);
            A_FadeOut(0.012);
            Vel.Z += 0.05;
            Vel.XY *= 0.88;
            A_SetRoll(Roll + frandom(1, 4), SPF_INTERPOLATE);
        }
        Stop;
    }
}

// Semi / slow fire — CSZ Smoke scale (~0.9), GSMK frames
class CS_ShotSmoke : Actor
{
    Default
    {
        +NOGRAVITY;
        +NOBLOCKMAP;
        +FLOORCLIP;
        +FORCEXYBILLBOARD;
        +CLIENTSIDEONLY;
        +NOINTERACTION;
        +DONTSPLASH;
        +MISSILE;
        +ROLLSPRITE;
        +ROLLCENTER;
        +INTERPOLATEANGLES;
        RenderStyle "Add";
        Scale 0.9;
        Alpha 0.4;
        Radius 0;
        Height 0;
        Speed 0.5;
    }
    States
    {
    Spawn:
        NULL A 1 A_SetTranslucent(0.25);
        GSMK ABCDEFGHIJKLMNOPQR random(1, 2)
        {
            A_FadeOut(0.005);
            A_SetRoll(Roll + frandom(1, 3), SPF_INTERPOLATE);
        }
        TNT1 A 0;
        Stop;
    }
}

class ShotSmokeSmall : CS_ShotSmoke
{
    Default
    {
        Scale 0.4;
    }
}

class AutomaticShotSmoke : Actor
{
    Default
    {
        +NOGRAVITY;
        +NOBLOCKMAP;
        +FLOORCLIP;
        +FORCEXYBILLBOARD;
        +CLIENTSIDEONLY;
        +NOINTERACTION;
        +DONTSPLASH;
        +MISSILE;
        +ROLLSPRITE;
        +ROLLCENTER;
        +INTERPOLATEANGLES;
        RenderStyle "Add";
        Scale 0.9;
        Alpha 0.2;
        Radius 0;
        Height 0;
        Speed 0.5;
    }
    States
    {
    Spawn:
        NULL A 1 A_SetTranslucent(0.25);
        GSMK ABDFHJLNPR 1
        {
            A_FadeOut(0.005);
            A_SetRoll(Roll + frandom(1, 3), SPF_INTERPOLATE);
        }
        TNT1 A 0;
        Stop;
    }
}

class AutomaticShotSmokeSmall : AutomaticShotSmoke
{
    Default
    {
        Scale 0.4;
    }
}

class CasingSmokes : CS_ShotSmoke
{
    Default
    {
        XScale 0.035;
        YScale 0.060;
        RenderStyle "Add";
    }
    States
    {
    Spawn:
        NULL A 1 A_SetTranslucent(0.25);
        GSMK ABCDEFGHIJKLMNOPQR 1 A_FadeOut(0.005);
        TNT1 A 0;
        Stop;
    }
}

class CasingSmokesEnd : CasingSmokes
{
    Default
    {
        XScale 0.020;
        YScale 0.095;
        RenderStyle "Add";
        Speed 8;
    }
    States
    {
    Spawn:
        NULL A 1 A_SetTranslucent(0.25);
        TNT1 A 0 ThrustThingZ(0, 1, 0, 0);
        GSMK ABCDEFGHIJKLMNOPQR 1 A_FadeOut(0.005);
        TNT1 A 0;
        Stop;
    }
}

class ExplosionSmoke : Actor
{
    Default
    {
        +NOBLOCKMAP;
        +NOTELEPORT;
        +DONTSPLASH;
        +MISSILE;
        +FORCEXYBILLBOARD;
        +CLIENTSIDEONLY;
        +NOINTERACTION;
        +NOGRAVITY;
        BounceType "Doom";
        +THRUACTORS;
        BounceFactor 0.5;
        Mass 0;
        Radius 0;
        Height 0;
        Speed 1;
        RenderStyle "Translucent";
        Alpha 0.72;
        Scale 1.9;
    }
    States
    {
    Spawn:
        SM7K ABCDEFGHIJKLMNOPQRSTUVWXYZ 3 A_FadeOut(0.005);
        Stop;
    }
}

class SmokeColumn : Actor
{
    Default
    {
        Radius 0;
        Height 0;
        XScale 1.0;
        YScale 1.0;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +DONTSPLASH;
        +CLIENTSIDEONLY;
        RenderStyle "Translucent";
        Alpha 0.95;
    }
    States
    {
    Spawn:
        SB3M ABCDEFGHIJKLMNOPQRSTUVWXABCDEFGHIJKLMNOPQRSTUVWXABCDEFGHIJKLMNOPQRSTUVWX 2;
        SB3M ABCDEFGHIJKLMNOPQRSTUVWXABCDEFGHIJKLMNOPQRSTUVWXABCDEFGHIJKLMNOPQRSTUVWX 2;
        SB3M ABCDEFGHIJKLMNOPQRSTUVWXABCDEFGHIJKLMNOPQRSTUVWXABCDEFGHIJKLMNOPQRSTUVWX 2;
        SB3M ABCDEFGHIJKLMNOPQRSTUVWX 2 A_FadeOut(0.03);
        SB3M ABCDEFGHIJKLMNOPQRSTUVWX 2 A_FadeOut(0.03);
        Stop;
    }
}

class BigNeoSmoke : Actor
{
    Default
    {
        Radius 0;
        Height 0;
        Alpha 0.48;
        RenderStyle "Translucent";
        Scale 2.2;
        Speed 1.2;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +DONTSPLASH;
        +MISSILE;
        +THRUACTORS;
        +FORCEXYBILLBOARD;
        +CLIENTSIDEONLY;
        +NOINTERACTION;
    }
    States
    {
    Spawn:
        SMK1 IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII 1 A_FadeOut(0.005);
        Stop;
    }
}

class ExplosionAfterglow : Actor
{
    Default
    {
        +NOGRAVITY;
        +NOBLOCKMAP;
        +NOINTERACTION;
        +NOTELEPORT;
        +CLIENTSIDEONLY;
        +FORCEXYBILLBOARD;
        RenderStyle "Add";
        Alpha 0.95;
        Scale 0.28;
    }
    States
    {
    Spawn:
        EXPL A 1 Bright;
        EXPL B 1 Bright A_FadeOut(0.16);
        EXPL C 1 Bright A_FadeOut(0.24);
        Stop;
    }
}

class ExplosionBurst : Actor
{
    Default
    {
        +NOGRAVITY;
        +NOBLOCKMAP;
        +NOINTERACTION;
        +NOTELEPORT;
        +CLIENTSIDEONLY;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_SpawnItemEx("ExplosionAfterglow", 0, 0, 8, 0, 0, 0, 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("ExplosionSmoke", random(-12, 12), random(-12, 12), random(0, 8), 0, 0, random(1, 3), 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("ExplosionSmoke", random(-12, 12), random(-12, 12), random(0, 8), 0, 0, random(1, 3), 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("BigNeoSmoke", random(-10, 10), random(-10, 10), random(0, 10), 0, 0, random(1, 2), 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("SmokeColumn", random(-6, 6), random(-6, 6), 0, 0, 0, 0, 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("ExplosionParticleVeryFast", 0, 0, 4, random(-4, 4), random(-4, 4), random(2, 6), 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("ExplosionParticleWithSmoke", 0, 0, 4, random(-3, 3), random(-3, 3), random(2, 5), 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        Stop;
    }
}

class FireExplosionBurst : ExplosionBurst
{
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_SpawnItemEx("ExplosionAfterglow", 0, 0, 10, 0, 0, 0, 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("ExplosionSmoke", random(-10, 10), random(-10, 10), random(0, 10), 0, 0, random(1, 3), 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("BigNeoSmoke", random(-12, 12), random(-12, 12), random(0, 10), 0, 0, random(1, 2), 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("SmokeColumn", random(-8, 8), random(-8, 8), 0, 0, 0, 0, 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("NapalmExplosionFlames", random(-6, 6), random(-6, 6), random(0, 6), 0, 0, random(1, 3), 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("ExplosionParticleWithFire", 0, 0, 5, random(-3, 3), random(-3, 3), random(2, 6), 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("ExplosionParticleWithFire", 0, 0, 5, random(-3, 3), random(-3, 3), random(2, 6), 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        Stop;
    }
}

class RocketExplosionBurst : ExplosionBurst
{
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_SpawnItemEx("ExplosionAfterglow", 0, 0, 12, 0, 0, 0, 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("ExplosionSmoke", random(-14, 14), random(-14, 14), random(0, 12), 0, 0, random(2, 4), 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("ExplosionSmoke", random(-14, 14), random(-14, 14), random(0, 12), 0, 0, random(2, 4), 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("BigNeoSmoke", random(-12, 12), random(-12, 12), random(0, 12), 0, 0, random(1, 3), 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("SmokeColumn", random(-10, 10), random(-10, 10), 0, 0, 0, 0, 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("SmokeColumn", random(-10, 10), random(-10, 10), 0, 0, 0, 0, 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("ExplosionParticleVeryFast", 0, 0, 6, random(-5, 5), random(-5, 5), random(3, 7), 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("ExplosionParticleVeryFast", 0, 0, 6, random(-5, 5), random(-5, 5), random(3, 7), 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        Stop;
    }
}

class BurnedSmoke : CS_ShotSmoke
{
    Default
    {
        Speed 1;
        Scale 0.300;
        +CLIENTSIDEONLY;
    }
}

class GreenSmoke : Actor
{
    Default
    {
        Radius 1;
        Height 1;
        Alpha 0.1;
        RenderStyle "Translucent";
        Scale 0.25;
        Gravity 0;
        Speed 1;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +DONTSPLASH;
        +MISSILE;
        +CLIENTSIDEONLY;
        +FORCEXYBILLBOARD;
    }
    States
    {
    Spawn:
        ESMK ABCDEFGH 5 Bright A_FadeOut(0.005);
        Stop;
    }
}