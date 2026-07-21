class BloodGrind : Blood replaces Blood
{
    Default
    {
        -ALLOWPARTICLES;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_CustomMissile("GoreMistTiny", 0, 0, random(0, 360), 2, random(0, 90));
        TNT1 A 0 A_CustomMissile("FlyingBloodParticle", 0, 0, random(0, 360), 2, random(0, 90));
        TNT1 A 0 A_CustomMissile("FlyingBloodParticleFast", 0, 0, random(0, 360), 2, random(0, 90));
        Stop;
    }
}

class BloodGrind2 : BloodGrind replaces BloodSplatter
{
    Default
    {
        Speed 10;
    }
}

// Hit sparks / droplets — air flash only (no floor litter when shot).
class FlyingBloodParticle : Actor
{
    Default
    {
        Projectile;
        +MISSILE;
        +THRUACTORS;
        +CLIENTSIDEONLY;
        +NOGRAVITY;
        +NOINTERACTION;
        +DONTSPLASH;
        +FORCEXYBILLBOARD;
        Radius 2;
        Height 2;
        Speed 5;
        Decal "BrutalBloodSuper";
    }
    States
    {
    Spawn:
        BSPR ABCDEFGH 2;
        BSPR IJ 1 A_FadeOut(0.2);
        Stop;
    Death:
    XDeath:
    Crash:
        TNT1 A 0;
        Stop;
    NoSpawn:
    Splash:
        TNT1 A 0;
        Stop;
    }
}

class FlyingBloodParticleFast : FlyingBloodParticle
{
    Default
    {
        Speed 10;
    }
}

class FlyingBloodParticleCrushed : FlyingBloodParticleFast
{
    Default
    {
        Speed 2;
        +NOCLIP;
    }
    States
    {
    Spawn:
        BSPR ABCDEFGHIJ 2;
        Stop;
    }
}

class FlyingBloodParticleBig : FlyingBloodParticle
{
    Default
    {
        Speed 8;
    }
    States
    {
    Spawn:
        BLHT ABCDEF 2;
        BLHT F 1 A_FadeOut(0.25);
        Stop;
    Death:
    XDeath:
    Crash:
        TNT1 A 0;
        Stop;
    }
}

class FlyingBloodParticleHuge : FlyingBloodParticleBig
{
    Default
    {
        Speed 14;
        Scale 2.0;
    }
}

// Gibs keep gravity / bounce (override air-only blood hit particles).
class XGibBase : FlyingBloodParticle
{
    Default
    {
        -NOGRAVITY;
        -NOINTERACTION;
        +BOUNCEONFLOORS;
        +BOUNCEONCEILINGS;
        +MOVEWITHSECTOR;
        BounceCount 2;
        BounceSound "Misc/XDeath1";
        DeathSound "Misc/XDeath1";
        Gravity 0.7;
    }
}

class GibEyeball : XGibBase
{
    States
    {
    Spawn:
        BRIB EFGH 4;
        Loop;
    Death:
        BRIB E 1;
        TNT1 A 0 A_QueueCorpse();
        BRIB E -1;
        Stop;
    }
}

class GibTeeth : XGibBase
{
    Default
    {
        BounceSound "None";
        DeathSound "None";
    }
    States
    {
    Spawn:
        BRIB ABCD 4;
        Loop;
    Death:
        BRIB A 1;
        TNT1 A 0 A_QueueCorpse();
        BRIB A -1;
        Stop;
    }
}

// Meat actors
class XDeath1 : Actor
{
    Default
    {
        Radius 1;
        Height 1;
        Speed 0;
        Scale 0.6;
        Mass 1;
        +NOBLOCKMAP;
        +MISSILE;
        +NOTELEPORT;
        +MOVEWITHSECTOR;
        +CLIENTSIDEONLY;
        -DONTSPLASH;
        +THRUGHOST;
        +THRUACTORS;
        +FLOORCLIP;
    }
    States
    {
    Spawn:
        BLHT ABCDEFGHI 2;
        Stop;
    Death:
        XDT1 EF 3;
        TNT1 A 0 A_PlaySound("BloodDrop");
        TNT1 A 0 A_SpawnItem("GreatBloodSpot");
        Stop;
    Splash:
    NoSpawn:
        TNT1 A 0;
        Stop;
    }
}

class XDeath1b : XDeath1
{
    Default
    {
        Speed 5;
        +BOUNCEONWALLS;
    }
    States
    {
    Death:
        XDT1 EF 3;
        TNT1 A 0 A_PlaySound("BloodDrop");
        TNT1 A 0 A_SpawnItem("GreatBloodSpot2");
        Stop;
    }
}

class CeilingBloodChecker : FlyingBloodParticle
{
    Default
    {
        Speed 12;
        Mass 1;
        -BOUNCEONCEILINGS;
    }
    States
    {
    Spawn:
        TNT1 A 5;
        Stop;
    Death:
        TNT1 A 0;
        TNT1 A 0 A_CheckCeiling("Ceiling");
        Stop;
    Splash:
    NoSpawn:
        TNT1 A 0;
        Stop;
    Ceiling:
        TNT1 A 0;
        TNT1 A 0 A_SpawnItem("CeilBloodTinyBloodSpawnerSmall");
        TNT1 A 0 A_SpawnItem("CeilBloodSpot");
        Stop;
    }
}

class GreatBloodSpot : Actor
{
    Default
    {
        +CLIENTSIDEONLY;
        +THRUACTORS;
        +DONTGIB;
        +NOCLIP;
        XScale 1.0;
        YScale 0.3;
        Radius 1;
        Height 1;
    }
    States
    {
    Spawn:
        BSPR C 1;
        TNT1 A 0 A_SetAngle(random(0, 360));
        NULL A 0 A_Jump(255, "Spawn1", "Spawn2", "Spawn3", "Spawn4", "Spawn5", "Spawn6", "Spawn7", "Spawn8", "Spawn9", "Live");
    Spawn1:
        NULL A 0 A_SetScale(1.08, 0.38);
        Goto Live;
    Spawn2:
        NULL A 0 A_SetScale(1.06, 0.36);
        Goto Live;
    Spawn3:
        NULL A 0 A_SetScale(1.04, 0.34);
        Goto Live;
    Spawn4:
        NULL A 0 A_SetScale(1.02, 0.32);
        Goto Live;
    Spawn5:
        NULL A 0 A_SetScale(0.98, 0.28);
        Goto Live;
    Spawn6:
        NULL A 0 A_SetScale(0.96, 0.24);
        Goto Live;
    Spawn7:
        NULL A 0 A_SetScale(0.94, 0.22);
        Goto Live;
    Spawn8:
        NULL A 0 A_SetScale(0.92, 0.20);
        Goto Live;
    Spawn9:
        NULL A 0 A_SetScale(0.90, 0.18);
        Goto Live;
    Live:
        BSPR C 1 A_QueueCorpse();
        BSPR C -1;
        Stop;
    }
}

class MeatBloodSpot : Actor
{
    Default
    {
        +CLIENTSIDEONLY;
        +THRUACTORS;
        +DONTGIB;
        +NOCLIP;
        XScale 1.0;
        YScale 0.3;
        Radius 1;
        Height 1;
    }
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_SetAngle(random(0, 360));
        NULL A 0 A_Jump(255, "Spawn1", "Spawn2", "Spawn3", "Spawn4", "Spawn5", "Spawn6", "Spawn7", "Spawn8", "Spawn9", "Live");
    Spawn1:
        NULL A 0 A_SetScale(0.58, 0.58);
        Goto Live;
    Spawn2:
        NULL A 0 A_SetScale(0.56, 0.56);
        Goto Live;
    Spawn3:
        NULL A 0 A_SetScale(0.54, 0.54);
        Goto Live;
    Spawn4:
        NULL A 0 A_SetScale(0.52, 0.52);
        Goto Live;
    Spawn5:
        NULL A 0 A_SetScale(0.48, 0.48);
        Goto Live;
    Spawn6:
        NULL A 0 A_SetScale(0.46, 0.46);
        Goto Live;
    Spawn7:
        NULL A 0 A_SetScale(0.44, 0.44);
        Goto Live;
    Spawn8:
        NULL A 0 A_SetScale(0.42, 0.42);
        Goto Live;
    Spawn9:
        NULL A 0 A_SetScale(0.40, 0.40);
        Goto Live;
    Live:
        TNT1 A 1;
        TNT1 A 0 A_QueueCorpse();
        TNT1 A 0 A_Jump(255, "SpawnAFrameOnly", "SpawnBFrameOnly", "SpawnCFrameOnly");
    SpawnAFrameOnly:
        BPDL A -1;
        Loop;
    SpawnBFrameOnly:
        BPDL B -1;
        Loop;
    SpawnCFrameOnly:
        BPDL C -1;
        Loop;
    }
}

class GreatBloodSpot2 : GreatBloodSpot
{
    Default
    {
        Radius 1;
    }
}

class CeilBloodSpot : GreatBloodSpot2
{
    Default
    {
        +NOGRAVITY;
        XScale 0.6;
        YScale 0.15;
        Radius 1;
        Gravity 0.0;
        Height 1;
    }
    States
    {
    Spawn:
        BSPR C 1;
        TNT1 A 0 A_SetAngle(random(0, 360));
        BSPR C 1 A_QueueCorpse();
        TNT1 A 0 A_SpawnItem("CeilBloodSpawner");
    Live:
        BSPR C 10 ThrustThingZ(0, 20, 0, 1);
        Loop;
    }
}

class CeilBloodSpawner : Actor
{
    Default
    {
        +NOGRAVITY;
        +THRUACTORS;
        +NOCLIP;
        Scale 0.5;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 3 A_SpawnItemEx("BloodDripingFromCeilingBig", random(-10,10), random(-10,10), 0, 0,0,0,0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAAAAAAAAAA 10 A_SpawnItemEx("BloodDripingFromCeilingBig", random(-10,10), random(-10,10), 0, 0,0,0,0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAAAAAAAAAA 15 A_SpawnItemEx("BloodDripingFromCeiling", random(-10,10), random(-10,10), 0, 0,0,0,0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAAAAAAAAAA 20 A_SpawnItemEx("BloodDripingFromCeiling", random(-10,10), random(-10,10), 0, 0,0,0,0, SXF_NOCHECKPOSITION);
        Stop;
    }
}

class CeilBloodTinyBloodSpawnerSmall : CeilBloodSpawner
{
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 AAAAAAAAAAAAAA 5 A_SpawnItemEx("BloodDripingFromCeiling", random(-5,5), random(-5,5), 0, 0,0,0,0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAAAAAAAAAA 10 A_SpawnItemEx("BloodDripingFromCeiling", random(-5,5), random(-5,5), 0, 0,0,0,0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAAAAAAAAAA 16 A_SpawnItemEx("BloodDripingFromCeiling", random(-5,5), random(-5,5), 0, 0,0,0,0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAAAAAAAAAA 26 A_SpawnItem("BloodDripingFromCeiling");
        Stop;
    }
}

class BloodDripingFromCeiling : FlyingBloodParticle
{
    Default
    {
        +THRUACTORS;
        +CLIENTSIDEONLY;
        -FORCEXYBILLBOARD;
        +FORCEYBILLBOARD;
        +TOUCHY;
        Gravity 0.6;
        Radius 2;
        Height 1;
        XScale 0.1;
        YScale 0.2;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_Jump(230, "NoSpawn");
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Splash");
        BLUD Z 500;
        Stop;
    Death:
        TNT1 A 0;
        TNT1 A 0 A_PlaySound("BloodDrop2");
        TNT1 A 0 A_SetScale(1.0, 1.0);
        XDT1 EFGHIJKL 2;
        Stop;
    }
}

class BloodDripingFromCeilingBig : BloodDripingFromCeiling
{
    Default
    {
        XScale 0.4;
        YScale 1.0;
        Gravity 0.8;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_Jump(160, "NoSpawn");
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Splash");
        BLUD Z 500;
        Stop;
    Death:
        TNT1 A 0;
        TNT1 A 0 A_PlaySound("BloodDrop2");
        TNT1 A 0 A_SetScale(1.0, 1.0);
        XDT1 EFGHIJKL 2;
        Stop;
    }
}

class XDeath2 : XDeath1
{
    Default
    {
        +CLIENTSIDEONLY;
        +DONTSPLASH;
        Radius 2;
        Height 2;
        Gravity 0.4;
        DeathSound "Misc/XDeath3";
        SeeSound "Misc/XDeath4";
        Decal "BrutalBloodSuper";
        Scale 1.1;
        Speed 8;
    }
    States
    {
    Spawn:
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Splash");
        XMT1 ABCDEFGH 2;
        Loop;
    Death:
        TNT1 A 0 A_CheckFloor("SpawnFloor");
        TNT1 A 0 A_CheckCeiling("SpawnCeiling");
        TNT1 A 0 A_SpawnItem("SmearingXDeath2");
        Stop;
    SpawnFloor:
        TNT1 A 0 A_QueueCorpse();
        TNT1 A 0 A_SpawnItem("MeatBloodSpot");
        XMT1 M -1;
        Stop;
    SpawnCeiling:
        TNT1 A 0;
        TNT1 A 0 A_SpawnItemEx("CeilXDeath2", 0,0,8, 0,0,0,0, SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("CeilBloodSpot", 0,0,1, 0,0,0,0, SXF_NOCHECKPOSITION);
        Stop;
    Vanish:
        TNT1 A 5;
        Stop;
    }
}

class XDeath2b : XDeath2
{
    Default
    {
        Speed 4;
    }
}

class SmearingXDeath2 : Actor
{
    Default
    {
        Radius 1;
        Height 1;
        Mass 1;
        Scale 1.0;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +THRUGHOST;
        +CLIENTSIDEONLY;
        +DONTSPLASH;
        +MOVEWITHSECTOR;
        +FORCEXYBILLBOARD;
        +NOGRAVITY;
    }
    States
    {
    Spawn:
        XMT1 N 10;
        TNT1 A 0 ThrustThingZ(0, 1, 1, 1);
        TNT1 A 0 A_Jump(255, "Spawn1", "Spawn2", "Spawn3", "Spawn4");
    Spawn1:
        XMT1 NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN 2 A_CheckFloor("Rest");
        Goto Death;
    Spawn2:
        XMT1 NNNNNNNNNNNNNNNNNNNNNNNN 2 A_CheckFloor("Rest");
        Goto Death;
    Spawn3:
        XMT1 NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN 2 A_CheckFloor("Rest");
        Goto Death;
    Spawn4:
        XMT1 NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN 2 A_CheckFloor("Rest");
        Goto Death;
    Death:
        TNT1 A 0;
        TNT1 A 0 A_SpawnItem("XDeath2NoStick");
        Stop;
    Rest:
        XMT1 M 1;
        TNT1 A 0 A_QueueCorpse();
        XMT1 M -1;
        Stop;
    Vanish:
        TNT1 A 5;
        Stop;
    }
}

class CeilXDeath2 : GreatBloodSpot
{
    Default
    {
        Projectile;
        +MISSILE;
        +SPAWNCEILING;
        +MOVEWITHSECTOR;
        +NOGRAVITY;
        +DONTSPLASH;
        +CEILINGHUGGER;
        RenderStyle "Normal";
        Scale 1.1;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_Jump(255, "Live1", "Live2", "Live3");
        Goto Live1;
    Live1:
        XMT1 IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII 5 ThrustThingZ(0, 20, 0, 1);
        Goto Fall;
    Live2:
        XMT1 IIIIIIIIIIIIIIIIIIIIIIIII 5 ThrustThingZ(0, 20, 0, 1);
        Goto Fall;
    Live3:
        XMT1 IIIIIIIIIIIIIIIII 5 ThrustThingZ(0, 20, 0, 1);
        Goto Fall;
    Fall:
        XMT1 F 0;
        XMT1 JJJKKLL 2;
        TNT1 A 0 A_SpawnItemEx("XDeath2NoStick", 0,0,0, 0,0,-1,0, SXF_NOCHECKPOSITION);
        Stop;
    Splash:
        BLOD A 0;
        Stop;
    }
}

class XDeath2NoStick : XDeath2
{
    Default
    {
        Speed 0;
        Gravity 0.4;
        DeathSound "Misc/XDeath2";
        SeeSound "None";
        Radius 1;
        Height 0;
    }
    States
    {
    Spawn:
        XMT1 FFFGGH 2;
    Live:
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Splash");
        TNT1 A 0 A_CheckFloor("Death");
        XMT1 ABCDEFGH 2;
        Loop;
    Death:
        XMT1 M 1;
        TNT1 A 0 A_QueueCorpse();
        XMT1 M 3;
        XMT1 M -1;
        Stop;
    }
}

class XDeath3 : XDeath2
{
    Default
    {
        DeathSound "Misc/XDeath3";
        SeeSound "Misc/XDeath4";
        Decal "BrutalBloodSuper";
        Scale 1.1;
    }
    States
    {
    Spawn:
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Splash");
        XMT2 ABCDEFGH 2;
        Loop;
    Death:
        TNT1 A 0;
        TNT1 A 0 A_CheckFloor("SpawnFloor");
        TNT1 A 0 A_CheckCeiling("SpawnCeiling");
        TNT1 A 0 A_SpawnItem("SmearingXDeath3");
        Stop;
    SpawnFloor:
        TNT1 A 0 A_QueueCorpse();
        TNT1 A 0 A_SpawnItem("MeatBloodSpot");
        XMT2 I -1;
        Stop;
    SpawnCeiling:
        TNT1 A 0;
        TNT1 A 0 A_SpawnItemEx("CeilXDeath3", 0,0,8, 0,0,0,0, SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("CeilBloodSpot", 0,0,1, 0,0,0,0, SXF_NOCHECKPOSITION);
        Stop;
    Vanish:
        TNT2 A 5;
        Stop;
    }
}

class XDeath3b : XDeath3
{
    Default
    {
        Speed 4;
    }
}

class XDeath4 : XGibBase
{
    Default
    {
        DeathSound "Misc/XDeath3";
        SeeSound "Misc/XDeath4";
        Decal "BrutalBloodSuper";
        Scale 1.1;
    }
    States
    {
    Spawn:
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Splash");
        XMT3 ABCDEFGH 3;
        Loop;
    Death:
        TNT1 A 0 A_CheckFloor("DeathFloor");
        TNT1 A 0 A_Jump(255, "Death1", "Death2");
    Death1:
        TNT1 A 0 A_QueueCorpse();
        XMT3 I -1;
        Goto DeathFloor1;
    Death2:
        TNT1 A 0 A_QueueCorpse();
        XMT3 A -1;
        Goto DeathFloor2;
    DeathFloor:
        TNT1 A 0 A_Jump(255, "DeathFloor1", "DeathFloor2");
    DeathFloor1:
        TNT1 A 0 A_QueueCorpse();
        TNT1 A 0 A_SpawnItem("MeatBloodSpot");
        XMT3 I -1;
        Stop;
    DeathFloor2:
        TNT1 A 0 A_QueueCorpse();
        TNT1 A 0 A_SpawnItem("MeatBloodSpot");
        XMT3 A -1;
        Stop;
    Splash:
    NoSpawn:
        TNT1 A 0;
        Stop;
    }
}

class XDeath5 : XDeath2
{
    Default
    {
        DeathSound "Misc/XDeath4";
        SeeSound "Misc/XDeath3";
        Decal "BrutalBloodSuper";
        Scale 1.1;
        Speed 4;
        Gravity 0.6;
    }
    States
    {
    Spawn:
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Splash");
        XMT4 ABCD 3;
        Loop;
    Death:
        TNT1 A 0 A_CheckFloor("SpawnFloor");
        TNT1 A 0 A_QueueCorpse();
        XMT4 E -1;
        Stop;
    SpawnFloor:
        TNT1 A 0 A_QueueCorpse();
        TNT1 A 0 A_SpawnItem("MeatBloodSpot");
        XMT4 E -1;
        Stop;
    Vanish:
        TNT2 A 5;
        Stop;
    }
}

class XDeath6 : XDeath2
{
    Default
    {
        DeathSound "Misc/XDeath1";
        SeeSound "Misc/XDeath";
        Decal "BrutalBloodSuper";
        Scale 0.5;
        Speed 9;
    }
    States
    {
    Spawn:
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Splash");
        XMT5 ABCD 3;
        Loop;
    Death:
        TNT1 A 0 A_Jump(255, "Death1", "Death2");
    Death1:
        TNT1 A 0 A_QueueCorpse();
        XMT5 E -1;
        Stop;
    Death2:
        TNT1 A 0 A_QueueCorpse();
        XMT5 F -1;
        Stop;
    }
}

class XDeath7 : XDeath2
{
    Default
    {
        DeathSound "Misc/XDeath4";
        SeeSound "Misc/XDeath3";
        Decal "BrutalBloodSuper";
        Speed 4;
        Gravity 0.6;
    }
    States
    {
    Spawn:
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Splash");
        XMT6 A 3;
        Loop;
    Death:
        TNT1 A 0 A_CheckFloor("SpawnFloor");
        TNT1 A 0 A_QueueCorpse();
        XMT6 B -1;
        Stop;
    SpawnFloor:
        TNT1 A 0 A_QueueCorpse();
        TNT1 A 0 A_SpawnItem("MeatBloodSpot");
        XMT6 B -1;
        Stop;
    Vanish:
        TNT2 A 5;
        Stop;
    }
}

class XDeath7B : XDeath2
{
    States
    {
    Spawn:
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Splash");
        XMT6 C 3;
        Loop;
    Death:
        TNT1 A 0 A_CheckFloor("SpawnFloor");
        TNT1 A 0 A_QueueCorpse();
        XMT6 D -1;
        Stop;
    SpawnFloor:
        TNT1 A 0 A_QueueCorpse();
        TNT1 A 0 A_SpawnItem("MeatBloodSpot");
        XMT6 D -1;
        Stop;
    Vanish:
        TNT2 A 5;
        Stop;
    }
}

class SmearingXDeath3 : SmearingXDeath2
{
    States
    {
    Spawn:
        XME2 G 10;
        TNT1 A 0 ThrustThingZ(0, 1, 1, 1);
        TNT1 A 0 A_Jump(255, "Spawn1", "Spawn2", "Spawn3", "Spawn4");
    Spawn1:
        XMT2 OOOOOOOOOOOOOOOO 2 A_CheckFloor("Rest");
        Goto Death;
    Spawn2:
        XMT2 OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO 2 A_CheckFloor("Rest");
        Goto Death;
    Spawn3:
        XMT2 OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO 2 A_CheckFloor("Rest");
        Goto Death;
    Spawn4:
        XMT2 OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO 2 A_CheckFloor("Rest");
        Goto Death;
    Death:
        TNT1 A 0;
        TNT1 A 0 A_SpawnItem("XDeath3NoStick");
        Stop;
    Rest:
        XMT2 I 1;
        TNT1 A 0 A_QueueCorpse();
        XMT2 I -1;
        Stop;
    Vanish:
        TNT1 A 5;
        Stop;
    }
}

class CeilXDeath3 : CeilXDeath2
{
    States
    {
    Spawn:
        Goto Crash;
    Death:
    Crash:
        TNT1 A 0;
        TNT1 A 0 A_Jump(255, "Live1", "Live2", "Live3");
        Goto Live1;
    Live1:
        XMT2 JJJJJJJJJJJJJJJJJ 4 ThrustThingZ(0, 20, 0, 1);
        Goto Fall;
    Live2:
        XMT2 JJJJJJJJJJJJJJJJJJJJJJJJJJJ 4 ThrustThingZ(0, 20, 0, 1);
        Goto Fall;
    Live3:
        XMT2 JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ 4 ThrustThingZ(0, 20, 0, 1);
        Goto Fall;
    Fall:
        XMT2 JJJJKKKLLM 2;
        TNT1 A 0 A_SpawnItemEx("XDeath3NoStick", 0,0,0, 0,0,-1,0, SXF_NOCHECKPOSITION);
        XMT2 MMN 2;
        Stop;
    Splash:
        BLOD A 0;
        Stop;
    }
}

class XDeath3NoStick : XDeath2NoStick
{
    States
    {
    Spawn:
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Splash");
        TNT1 A 0 A_CheckFloor("Death");
        XMT2 O 3;
        Loop;
    Death:
        XMT2 I 1;
        TNT1 A 0 A_QueueCorpse();
        XMT2 I 3;
        XMT2 I -1;
        Stop;
    }
}

class GibHeadPiece : XDeath2
{
    Default
    {
        Scale 0.5;
        Speed 5;
        Gravity 0.5;
        +BOUNCEONCEILINGS;
        +BOUNCEONWALLS;
    }
}

class GrowingBloodPool : Actor
{
    Default
    {
        Radius 1;
        Height 1;
        Mass 1;
        Health 600;
        +NOTELEPORT;
        +CLIENTSIDEONLY;
        +FORCEXYBILLBOARD;
        +MOVEWITHSECTOR;
        +FLOORCLIP;
        +DONTSPLASH;
        +MISSILE;
        -SOLID;
        +THRUACTORS;
        Alpha 0.99;
        Scale 0.3;
        RenderStyle "Normal";
        Decal "BrutalBloodSplat";
    }
    States
    {
    Spawn:
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Splash");
        TNT5 A 1;
        TNT5 A 2 A_QueueCorpse();
        TNT5 A 1 A_SetScale(0.33, 0.33);
        TNT5 A 1 A_SetScale(0.36, 0.36);
        TNT5 A 1 A_SetScale(0.39, 0.39);
        TNT5 A 1 A_SetScale(0.42, 0.42);
        TNT5 A 1 A_SetScale(0.45, 0.45);
        TNT5 A 1 A_SetScale(0.48, 0.48);
        TNT5 A 1 A_SetScale(0.50, 0.50);
        TNT5 A 2 A_SetScale(0.53, 0.53);
        TNT5 A 2 A_SetScale(0.56, 0.56);
        TNT5 A 2 A_SetScale(0.59, 0.59);
        TNT5 A 2 A_SetScale(0.62, 0.62);
        TNT5 A 2 A_SetScale(0.65, 0.65);
        TNT5 A 2 A_SetScale(0.68, 0.68);
        TNT5 A 2 A_SetScale(0.70, 0.70);
        TNT5 A 3 A_SetScale(0.73, 0.73);
        TNT5 A 3 A_SetScale(0.76, 0.76);
        TNT5 A 3 A_SetScale(0.79, 0.79);
        TNT5 A 3 A_SetScale(0.82, 0.82);
        TNT5 A 3 A_SetScale(0.85, 0.85);
        TNT5 A 3 A_SetScale(0.88, 0.88);
        TNT5 A 3 A_SetScale(0.90, 0.90);
        TNT5 A 3 A_SetScale(0.93, 0.93);
        TNT5 A 3 A_SetScale(0.96, 0.96);
        TNT5 A 3 A_SetScale(0.99, 0.99);
        TNT5 A 3 A_SetScale(1.02, 1.02);
        TNT5 A 3 A_SetScale(1.05, 1.05);
        TNT5 A 3 A_SetScale(1.08, 1.08);
        TNT5 A 3 A_SetScale(1.11, 1.11);
    Live:
        TNT5 A 1 A_QueueCorpse();
        TNT5 A -1;
        Stop;
    Splash:
        TNT1 A 0;
        Stop;
    }
}

class Guts : Actor
{
    Default
    {
        Radius 8;
        Height 12;
        Speed 4;
        Mass 1;
        BounceFactor 0.4;
        Alpha 0.9;
        +BOUNCEONWALLS;
        +BOUNCEONCEILINGS;
        +NOBLOCKMAP;
        +MISSILE;
        +NOTELEPORT;
        +MOVEWITHSECTOR;
        +CLIENTSIDEONLY;
        +FORCEXYBILLBOARD;
        -EXPLODEONWATER;
        Decal "BrutalBloodSplat";
        Gravity 0.4;
        DeathSound "Misc/XDeath2";
        SeeSound "Misc/XDeath1";
    }
    States
    {
    Spawn:
        CGUT A 1;
        TNT1 A 0 A_Jump(255, "Spawn1", "Spawn2", "Spawn3", "Spawn4");
    Spawn1:
        TNT1 A 0 A_SetScale(0.9, 0.8);
        Goto Live;
    Spawn2:
        TNT1 A 0 A_SetScale(-1.0, 1.0);
        Goto Live;
    Spawn3:
        TNT1 A 0 A_SetScale(1.2, 1.0);
        Goto Live;
    Spawn4:
        TNT1 A 0 A_SetScale(-0.6, 1.0);
        Goto Live;
    Live:
        CGUT ABCDEFGH 3 A_JumpIf(waterlevel > 1, "Water");
        CGUT H -1;
        Loop;
    Death:
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Water");
        TNT1 A 0;
        Goto Rest;
    Rest:
        TNT1 A 0;
        TNT1 A 0 A_QueueCorpse();
        TNT1 A 0 A_Jump(255, "Rest1", "Rest2");
    Rest1:
        CGUT K 1;
        CGUT K -1;
        Stop;
    Rest2:
        CGUT L 1;
        CGUT L -1;
        Stop;
    DoNothing:
        TNT1 A 0;
        Stop;
    Water:
        CGUT GHIH 10;
        Loop;
    }
}

class GoreMist : Actor
{
    Default
    {
        Decal "BloodSplat";
        Alpha 0.4;
        +FORCEXYBILLBOARD;
        +GHOST;
        +NOBLOCKMAP;
        +DONTSPLASH;
        -EXPLODEONWATER;
        -ALLOWPARTICLES;
        +CLIENTSIDEONLY;
        +NOGRAVITY;
        +THRUACTORS;
        +NOCLIP;
        +NOINTERACTION;
        Scale 0.4;
        Speed 3;
        Alpha 0.6;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        BLOR EFGHIJK 3 A_FadeOut(0.08);
        Stop;
    }
}

class SuperGoreMist : GoreMist
{
    Default
    {
        Scale 0.6;
        Speed 3;
        +NOGRAVITY;
    }
}

class GoreMistTiny : GoreMist
{
    Default
    {
        Scale 0.15;
        Alpha 0.7;
        Speed 0;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        BLOR EFGHIJK 2 A_FadeOut(0.005);
        Stop;
    }
}

class BigGoreMist : GoreMist
{
    Default
    {
        Scale 0.6;
        Speed 6;
    }
}

class GiantGoreMist : GoreMist
{
    Default
    {
        Scale 1.2;
        Speed 8;
    }
}

class GoreMistSpawner : Actor
{
    Default
    {
        Projectile;
        +MISSILE;
        +FORCEXYBILLBOARD;
        +THRUACTORS;
        Decal "BloodSuper";
        Radius 2;
        Height 2;
        Speed 15;
    }
    States
    {
    Spawn:
        TNT1 A 3;
        TNT1 AAA 3 A_CustomMissile("GoreMist", 7, 0, random(0, 360), 2, random(30, 60));
        Stop;
    Death:
    XDeath:
        TNT1 A 0;
        Stop;
    }
}

// Burn Gore
class XDeathBurnedMeat : Actor
{
    Default
    {
        Radius 8;
        Height 8;
        Speed 5;
        Mass 6;
        BounceFactor 0.5;
        +DOOMBOUNCE;
        +NOBLOCKMAP;
        +MISSILE;
        +NOTELEPORT;
        +DONTSPLASH;
        +MOVEWITHSECTOR;
        Scale 0.5;
    }
    States
    {
    Spawn:
        CARB A 10 A_CustomMissile("BurnedSmoke", 0, 0, 180, 2);
        Loop;
    Death:
        CARB AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 14 A_CustomMissile("BurnedSmoke", 1, 0, random(0, 360), 2, random(0, 160));
        CARB A -1;
        Stop;
    }
}

class XDeathBurnedMeat2 : XDeathBurnedMeat
{
    States
    {
    Spawn:
        CARB B 10 A_CustomMissile("BurnedSmoke", 0, 0, 180, 2);
        Loop;
    Death:
        CARB BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 14 A_CustomMissile("BurnedSmoke", 1, 0, random(0, 360), 2, random(0, 160));
        CARB B -1;
        Stop;
    }
}

class XDeathBurnedMeat3 : XDeathBurnedMeat
{
    States
    {
    Spawn:
        CARB C 10 A_CustomMissile("BurnedSmoke", 0, 0, 180, 2);
        Loop;
    Death:
        CARB CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC 14 A_CustomMissile("BurnedSmoke", 1, 0, random(0, 360), 2, random(0, 160));
        CARB C -1;
        Stop;
    }
}

class XDeathBurnedMeatBig : XDeathBurnedMeat
{
    Default
    {
        Scale 0.8;
    }
}

class XDeathBurnedMeat2Big : XDeathBurnedMeat2
{
    Default
    {
        Scale 0.8;
    }
}

class XDeathBurnedMeat3Big : XDeathBurnedMeat3
{
    Default
    {
        Scale 0.8;
    }
}

class BoarArm : XGibBase
{
    States
    {
    Spawn:
        PIGY OPQRSTUV 2;
        Loop;
    Death:
        PIGY W 1;
        TNT1 A 0 A_QueueCorpse();
        PIGY W -1;
        Stop;
    }
}

// Green Gore
class GreenBlood : Blood
{
    Default
    {
        Speed 10;
        -ALLOWPARTICLES;
        Translation "168:191=112:127", "16:47=123:127";
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_CustomMissile("GoreMistTinyGreen", 0, 0, random(0, 360), 2, random(0, 90));
        TNT1 A 0 A_CustomMissile("FlyingBloodParticleGreen", 0, 0, random(0, 360), 2, random(0, 90));
        TNT1 A 0 A_CustomMissile("FlyingBloodParticleFastGreen", 0, 0, random(0, 360), 2, random(0, 90));
        Stop;
    }
}

class FlyingBloodParticleGreen : FlyingBloodParticle
{
    Default
    {
        Translation "168:191=112:127", "16:47=123:127";
        Decal "GreenBloodSplat";
        Scale 0.6;
    }
}

class FlyingBloodParticleFastGreen : FlyingBloodParticleFast
{
    Default
    {
        Translation "168:191=112:127", "16:47=123:127";
        Decal "GreenBloodSplat";
        Scale 0.6;
    }
}

class FlyingBloodParticleBigGreen : FlyingBloodParticleBig
{
    Default
    {
        Translation "168:191=112:127", "16:47=123:127";
        Decal "GreenBloodSplat";
        Scale 0.6;
    }
}

class FlyingBloodParticleHugeGreen : FlyingBloodParticleHuge
{
    Default
    {
        Translation "168:191=112:127", "16:47=123:127";
        Scale 0.6;
    }
}

class FlyingBloodParticleCrushedGreen : FlyingBloodParticleCrushed
{
    Default
    {
        Translation "168:191=112:127", "16:47=123:127";
        Scale 0.6;
    }
}

class GoreMistGreen : GoreMist
{
    Default
    {
        Translation "168:191=112:127", "16:47=123:127";
        Alpha 0.3;
    }
}

class GoreMistTinyGreen : GoreMistTiny
{
    Default
    {
        Translation "168:191=112:127", "16:47=123:127";
        Alpha 0.3;
    }
}

class XDeath2Green : XDeath1
{
    Default
    {
        +CLIENTSIDEONLY;
        +DONTSPLASH;
        Radius 2;
        Height 2;
        Gravity 0.4;
        DeathSound "Misc/XDeath3";
        SeeSound "Misc/XDeath4";
        Decal "GreenBloodSuper";
        Translation "168:191=112:127", "16:47=123:127";
        Scale 0.8;
        Speed 8;
    }
    States
    {
    Spawn:
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Splash");
        XMT1 ABCDEFGH 2;
        Loop;
    Death:
        TNT1 A 0 A_CheckFloor("SpawnFloor");
        TNT1 A 0 A_CheckCeiling("SpawnCeiling");
        TNT1 A 0 A_SpawnItem("SmearingXDeath2Green");
        Stop;
    SpawnFloor:
        TNT1 A 0 A_QueueCorpse();
        TNT1 A 0 A_SpawnItem("MeatBloodSpotGreen");
        XMT1 M -1;
        Stop;
    SpawnCeiling:
        TNT1 A 0;
        TNT1 A 0 A_SpawnItemEx("CeilXDeath2Green", 0,0,8, 0,0,0,0, SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("CeilBloodSpotGreen", 0,0,1, 0,0,0,0, SXF_NOCHECKPOSITION);
        Stop;
    Vanish:
        TNT1 A 5;
        Stop;
    }
}

class XDeath2bGreen : XDeath2Green
{
    Default
    {
        Speed 4;
    }
}

class SmearingXDeath2Green : Actor
{
    Default
    {
        Radius 1;
        Height 1;
        Mass 1;
        Scale 0.8;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +THRUGHOST;
        +CLIENTSIDEONLY;
        +DONTSPLASH;
        +MOVEWITHSECTOR;
        +FORCEXYBILLBOARD;
        +NOGRAVITY;
        Translation "168:191=112:127", "16:47=123:127";
    }
    States
    {
    Spawn:
        XMT1 N 10;
        TNT1 A 0 ThrustThingZ(0, 1, 1, 1);
        TNT1 A 0 A_Jump(255, "Spawn1", "Spawn2", "Spawn3", "Spawn4");
    Spawn1:
        XMT1 NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN 2 A_CheckFloor("Rest");
        Goto Death;
    Spawn2:
        XMT1 NNNNNNNNNNNNNNNNNNNNNNNN 2 A_CheckFloor("Rest");
        Goto Death;
    Spawn3:
        XMT1 NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN 2 A_CheckFloor("Rest");
        Goto Death;
    Spawn4:
        XMT1 NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN 2 A_CheckFloor("Rest");
        Goto Death;
    Death:
        TNT1 A 0;
        TNT1 A 0 A_SpawnItem("XDeath2NoStickGreen");
        Stop;
    Rest:
        XMT1 M 1;
        TNT1 A 0 A_QueueCorpse();
        XMT1 M -1;
        Stop;
    Vanish:
        TNT1 A 5;
        Stop;
    }
}

class CeilXDeath2Green : GreatBloodSpot
{
    Default
    {
        Projectile;
        +MISSILE;
        +SPAWNCEILING;
        +MOVEWITHSECTOR;
        +NOGRAVITY;
        +DONTSPLASH;
        +CEILINGHUGGER;
        RenderStyle "Normal";
        Scale 0.8;
        Translation "168:191=112:127", "16:47=123:127";
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_Jump(255, "Live1", "Live2", "Live3");
        Goto Live1;
    Live1:
        XMT1 IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII 5 ThrustThingZ(0, 20, 0, 1);
        Goto Fall;
    Live2:
        XMT1 IIIIIIIIIIIIIIIIIIIIIIIII 5 ThrustThingZ(0, 20, 0, 1);
        Goto Fall;
    Live3:
        XMT1 IIIIIIIIIIIIIIIII 5 ThrustThingZ(0, 20, 0, 1);
        Goto Fall;
    Fall:
        XMT1 F 0;
        XMT1 JJJKKLL 2;
        TNT1 A 0 A_SpawnItemEx("XDeath2NoStickGreen", 0,0,0, 0,0,-1,0, SXF_NOCHECKPOSITION);
        Stop;
    Splash:
        BLOD A 0;
        Stop;
    }
}

class XDeath2NoStickGreen : XDeath2NoStick
{
    Default
    {
        Translation "168:191=112:127", "16:47=123:127";
        Scale 0.8;
    }
}

class XDeath3Green : XDeath2
{
    Default
    {
        DeathSound "Misc/XDeath3";
        SeeSound "Misc/XDeath4";
        Decal "GreenBloodSuper";
        Translation "168:191=112:127", "16:47=123:127";
        Scale 0.8;
    }
    States
    {
    Spawn:
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Splash");
        XMT2 ABCDEFGH 2;
        Loop;
    Death:
        TNT1 A 0;
        TNT1 A 0 A_CheckFloor("SpawnFloor");
        TNT1 A 0 A_CheckCeiling("SpawnCeiling");
        TNT1 A 0 A_SpawnItem("SmearingXDeath3Green");
        Stop;
    SpawnFloor:
        TNT1 A 0 A_QueueCorpse();
        TNT1 A 0 A_SpawnItem("MeatBloodSpotGreen");
        XMT2 I -1;
        Stop;
    SpawnCeiling:
        TNT1 A 0;
        TNT1 A 0 A_SpawnItemEx("CeilXDeath3Green", 0,0,8, 0,0,0,0, SXF_NOCHECKPOSITION);
        TNT1 A 0 A_SpawnItemEx("CeilBloodSpotGreen", 0,0,1, 0,0,0,0, SXF_NOCHECKPOSITION);
        Stop;
    Vanish:
        TNT2 A 5;
        Stop;
    }
}

class XDeath3bGreen : XDeath3Green
{
    Default
    {
        Speed 4;
    }
}

class SmearingXDeath3Green : SmearingXDeath2
{
    Default
    {
        Translation "168:191=112:127", "16:47=123:127";
        Scale 0.8;
    }
    States
    {
    Spawn:
        XME2 G 10;
        TNT1 A 0 ThrustThingZ(0, 1, 1, 1);
        TNT1 A 0 A_Jump(255, "Spawn1", "Spawn2", "Spawn3", "Spawn4");
    Spawn1:
        XMT2 OOOOOOOOOOOOOOOO 2 A_CheckFloor("Rest");
        Goto Death;
    Spawn2:
        XMT2 OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO 2 A_CheckFloor("Rest");
        Goto Death;
    Spawn3:
        XMT2 OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO 2 A_CheckFloor("Rest");
        Goto Death;
    Spawn4:
        XMT2 OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO 2 A_CheckFloor("Rest");
        Goto Death;
    Death:
        TNT1 A 0;
        TNT1 A 0 A_SpawnItem("XDeath3NoStickGreen");
        Stop;
    Rest:
        XMT2 I 1;
        TNT1 A 0 A_QueueCorpse();
        XMT2 I -1;
        Stop;
    Vanish:
        TNT1 A 5;
        Stop;
    }
}

class CeilXDeath3Green : CeilXDeath2Green
{
    Default
    {
        Translation "168:191=112:127", "16:47=123:127";
        Scale 0.8;
    }
    States
    {
    Spawn:
        Goto Crash;
    Death:
    Crash:
        TNT1 A 0;
        TNT1 A 0 A_Jump(255, "Live1", "Live2", "Live3");
        Goto Live1;
    Live1:
        XMT2 JJJJJJJJJJJJJJJJJ 4 ThrustThingZ(0, 20, 0, 1);
        Goto Fall;
    Live2:
        XMT2 JJJJJJJJJJJJJJJJJJJJJJJJJJJ 4 ThrustThingZ(0, 20, 0, 1);
        Goto Fall;
    Live3:
        XMT2 JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ 4 ThrustThingZ(0, 20, 0, 1);
        Goto Fall;
    Fall:
        XMT2 JJJJKKKLLM 2;
        TNT1 A 0 A_SpawnItemEx("XDeath3NoStickGreen", 0,0,0, 0,0,-1,0, SXF_NOCHECKPOSITION);
        XMT2 MMN 2;
        Stop;
    Splash:
        BLOD A 0;
        Stop;
    }
}

class XDeath3NoStickGreen : XDeath3NoStick
{
    Default
    {
        Translation "168:191=112:127", "16:47=123:127";
        Scale 0.8;
    }
}

class CeilBloodSpotGreen : GreatBloodSpot2
{
    Default
    {
        +NOGRAVITY;
        XScale 0.6;
        YScale 0.15;
        Radius 1;
        Gravity 0.0;
        Height 1;
        Translation "168:191=112:127", "16:47=123:127";
        Scale 0.6;
    }
    States
    {
    Spawn:
        BSPR C 1;
        TNT1 A 0 A_SetAngle(random(0, 360));
        BSPR C 1 A_QueueCorpse();
        TNT1 A 0 A_SpawnItem("CeilBloodSpawnerGreen");
    Live:
        BSPR C 10 ThrustThingZ(0, 20, 0, 1);
        Loop;
    }
}

class CeilBloodSpawnerGreen : Actor
{
    Default
    {
        +NOGRAVITY;
        +THRUACTORS;
        +NOCLIP;
        Scale 0.3;
        Translation "168:191=112:127", "16:47=123:127";
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 3 A_SpawnItemEx("BloodDripingFromCeilingBigGreen", random(-10,10), random(-10,10), 0, 0,0,0,0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAAAAAAAAAA 10 A_SpawnItemEx("BloodDripingFromCeilingBigGreen", random(-10,10), random(-10,10), 0, 0,0,0,0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAAAAAAAAAA 15 A_SpawnItemEx("BloodDripingFromCeilingGreen", random(-10,10), random(-10,10), 0, 0,0,0,0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAAAAAAAAAA 20 A_SpawnItemEx("BloodDripingFromCeilingGreen", random(-10,10), random(-10,10), 0, 0,0,0,0, SXF_NOCHECKPOSITION);
        Stop;
    }
}

class BloodDripingFromCeilingGreen : BloodDripingFromCeiling
{
    Default
    {
        Translation "168:191=112:127", "16:47=123:127";
        Scale 0.6;
    }
}

class BloodDripingFromCeilingBigGreen : BloodDripingFromCeilingBig
{
    Default
    {
        Translation "168:191=112:127", "16:47=123:127";
        Scale 0.6;
    }
}

class MeatBloodSpotGreen : MeatBloodSpot
{
    Default
    {
        Translation "168:191=112:127", "16:47=123:127";
    }
}