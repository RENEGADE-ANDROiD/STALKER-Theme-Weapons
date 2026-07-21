class ShotgunParticles : Actor
{
    Default
    {
        Speed 15;
        Radius 8;
        Height 1;
        RenderStyle "Add";
        Alpha 0.9;
        Scale 0.01;
        +MISSILE;
        +NOBLOCKMAP;
        +DONTSPLASH;
        +FORCEXYBILLBOARD;
        +CLIENTSIDEONLY;
        +THRUACTORS;
        +GHOST;
        +NOGRAVITY;
        +THRUGHOST;
        +NOTELEPORT;
    }
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_Jump(64, "Blue", "Green");
        CSKO A 2 Bright;
        CSKO AAAA 1 Bright A_FadeOut(0.15);
        Stop;
    Blue:
        CSKB A 2 Bright;
        CSKB AAAA 1 Bright A_FadeOut(0.15);
        Stop;
    Green:
        SPKG A 2 Bright;
        SPKG AAAA 1 Bright A_FadeOut(0.15);
        Stop;
    Death:
        TNT1 A 0;
        Stop;
    }
}

class ShotgunParticles2 : ShotgunParticles
{
    Default
    {
        Speed 10;
        Alpha 0.9;
        Scale 0.01;
    }
}

class ExplosionParticleHeavy : Actor
{
    Default
    {
        Speed 11;
        Radius 8;
        Height 1;
        RenderStyle "Add";
        Alpha 0.88;
        Scale 0.07;
        +MISSILE;
        +NOTELEPORT;
        +NOBLOCKMAP;
        +BLOODLESSIMPACT;
        +FORCEXYBILLBOARD;
        +CLIENTSIDEONLY;
        +DONTSPLASH;
        +THRUACTORS;
        +GHOST;
        +NOGRAVITY;
        +NOINTERACTION;
    }
    States
    {
    Spawn:
        CSKO AAAAAAAA 1 Bright A_FadeOut(0.1);
        Stop;
    Death:
        Stop;
    }
}

class ExplosionParticleVeryFast : ExplosionParticleHeavy
{
    Default
    {
        Speed 22;
        Scale 0.09;
    }
}

class ExplosionParticleWithSmoke : ExplosionParticleHeavy
{
    States
    {
    Spawn:
        TNT1 A 0;
        Goto Fly;
    Fly:
        TNT1 A 0 A_SpawnItemEx("ShotSmoke", flags:SXF_CLIENTSIDE);
        CSKO AAAA 1 Bright A_FadeOut(0.2);
        Stop;
    Death:
        Stop;
    }
}

class ExplosionParticleWithFire : ExplosionParticleHeavy
{
    States
    {
    Spawn:
        TNT1 A 0;
        Goto Fly;
    Fly:
        TNT1 A 0 A_SpawnItemEx("SmallFlameTrails", flags:SXF_CLIENTSIDE);
        CSKO AAAA 1 Bright A_FadeOut(0.2);
        Stop;
    Death:
        Stop;
    }
}

class PixelDebris : Actor
{
    Default
    {
        +MISSILE;
        +NOGRAVITY;
        +NOINTERACTION;
        +DONTSPLASH;
        +NOTELEPORT;
        +FORCEXYBILLBOARD;
        +CLIENTSIDEONLY;
        Health 4;
        Radius 2;
        Height 3;
        Speed 5;
        Scale 0.1;
        Mass 1;
        RenderStyle "Add";
    }
    States
    {
    Spawn:
        WPPX AA 1 Bright;
        WPPX AA 1 Bright A_FadeOut(0.3);
        Stop;
    Death:
        TNT1 A 0;
        Stop;
    }
}

class PingPuff : Actor
{
    Default
    {
        Health 4;
        Radius 3;
        Height 6;
        Speed 0.1;
        RenderStyle "Add";
        Alpha 1;
        Scale 0.01;
        Mass 0;
        +MISSILE;
        +NOGRAVITY;
        +NOINTERACTION;
        +DONTSPLASH;
        +NOTELEPORT;
        +FORCEXYBILLBOARD;
        +CLIENTSIDEONLY;
    }
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_Jump(48, "Blue", "Green");
        CSKO A 1 Bright;
        CSKO AA 1 Bright A_SetTranslucent(0.7);
        CSKO AA 1 Bright A_SetTranslucent(0.35);
        Stop;
    Blue:
        CSKB A 1 Bright;
        CSKB AA 1 Bright A_SetTranslucent(0.7);
        CSKB AA 1 Bright A_SetTranslucent(0.35);
        Stop;
    Green:
        SPKG A 1 Bright;
        SPKG AA 1 Bright A_SetTranslucent(0.7);
        SPKG AA 1 Bright A_SetTranslucent(0.35);
        Stop;
    }
}

class ExplosionShrapnel : Actor
{
    Default
    {
        Radius 1;
        Height 1;
        Alpha 1.0;
        RenderStyle "Add";
        Scale 0.6;
        Speed 1;
        Gravity 0.7;
        +NOINTERACTION;
        +NOGRAVITY;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_Jump(255, "Spawn1", "Spawn2", "Spawn3", "Live");
    Spawn1:
        TNT1 A 0 A_SetScale(-0.7, -0.7);
        Goto Live;
    Spawn2:
        TNT1 A 0 A_SetScale(0.5, -0.5);
        Goto Live;
    Spawn3:
        TNT1 A 0 A_SetScale(-0.8, 0.8);
        Goto Live;
    Live:
        CSKS ABCDEFGHI 1 Bright;
        Stop;
    }
}

class ExplosionShrapnel2 : ExplosionShrapnel
{
    Default
    {
        -NOGRAVITY;
        +BOUNCEONWALLS;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_Jump(255, "Spawn1", "Spawn2", "Spawn3", "Live");
    Spawn1:
        TNT1 A 0 A_SetScale(-0.7, -0.7);
        Goto Live;
    Spawn2:
        TNT1 A 0 A_SetScale(0.5, -0.5);
        Goto Live;
    Spawn3:
        TNT1 A 0 A_SetScale(-0.8, 0.8);
        Goto Live;
    Live:
        CSKS JKLMN 1 Bright;
        CSKS O 35 Bright;
        CSKS OOOOOOOOOO 1 Bright A_FadeOut(0.1);
        Stop;
    }
}

class MetalShard1 : Actor
{
    Default
    {
        Radius 8;
        Height 8;
        Scale 0.2;
        Speed 7;
        Mass 1;
        Gravity 0.5;
        BounceFactor 0.4;
        +BOUNCEONWALLS;
        +BOUNCEONCEILINGS;
        BounceType "Doom";
        +MISSILE;
        +MOVEWITHSECTOR;
        +CLIENTSIDEONLY;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +THRUACTORS;
    }
    States
    {
    Spawn:
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Death");
        JNK1 ABCDEFGH 3;
        Loop;
    Death:
        JNK1 H 200;
        Stop;
    }
}

class MetalShard2 : MetalShard1
{
    States
    {
    Spawn:
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Death");
        JNK2 ABCDEFGH 3;
        Loop;
    Death:
        JNK2 H 200;
        Stop;
    }
}

class MetalShard3 : MetalShard1
{
    States
    {
    Spawn:
        TNT1 A 0 A_JumpIf(waterlevel > 1, "Death");
        JNK3 ABCDEFGH 3;
        Loop;
    Death:
        JNK3 H 200;
        Stop;
    }
}

class NapalmParticle : ExplosionParticleHeavy
{
    States
    {
    Spawn:
        TNT1 A 0;
        Goto Fly;
    Fly:
        TNT1 A 0 A_SpawnItemEx("SmallBurnParticles", flags:SXF_CLIENTSIDE);
        TNT1 AAAA 1 Bright A_FadeOut(0.2);
        Stop;
    Death:
        Stop;
    }
}

// Craters
class DetectFloorBullet : Actor
{
    Default
    {
        Scale 0.2;
        Speed 0;
        Health 1;
        Radius 8;
        Height 1;
        Gravity 0.9;
        Damage 0;
        RenderStyle "Translucent";
        Alpha 0.70;
        +MISSILE;
        +CLIENTSIDEONLY;
        +NOTELEPORT;
        +NOBLOCKMAP;
        +FORCEXYBILLBOARD;
        +NODAMAGETHRUST;
        +MOVEWITHSECTOR;
        -DONTSPLASH;
        BounceType "Doom";
        BounceFactor 0.01;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 ThrustThingZ(0, -10, 0, 1);
        TNT1 A 4;
        Stop;
    Death:
        TNT1 A 0 A_QueueCorpse();
        XXX1 A 2000;
        Stop;
    }
}

class DetectCeilBullet : Actor
{
    Default
    {
        Scale 0.2;
        Speed 0;
        Health 1;
        Radius 1;
        Height 1;
        Gravity 0.0;
        Damage 0;
        RenderStyle "Translucent";
        Alpha 0.70;
        +MISSILE;
        +CLIENTSIDEONLY;
        +NOTELEPORT;
        +NOBLOCKMAP;
        +FORCEXYBILLBOARD;
        +NODAMAGETHRUST;
        -DONTSPLASH;
        +NOGRAVITY;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 ThrustThingZ(0, 35, 0, 1);
        TNT1 A 2;
        Stop;
    Death:
        TNT1 A 0 A_QueueCorpse();
        XXX1 A 2000;
        Stop;
    }
}

class DetectFloorCrater : Actor
{
    Default
    {
        Scale 3.4;
        Speed 0;
        Health 1;
        Radius 8;
        Height 4;
        Gravity 0.9;
        Alpha 0.9;
        +MISSILE;
        +CLIENTSIDEONLY;
        +NOTELEPORT;
        +NOBLOCKMAP;
        +FORCEXYBILLBOARD;
        +NODAMAGETHRUST;
        +MOVEWITHSECTOR;
        -DONTSPLASH;
        BounceType "Doom";
        BounceFactor 0.01;
        RenderStyle "Shaded";
        StencilColor "Black";
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 ThrustThingZ(0, -10, 0, 1);
        TNT1 A 4;
        Stop;
    Death:
        TNT1 A 0 A_Jump(120, "DeathSmoke");
        TNT1 A 0 A_QueueCorpse();
        XXX1 A 2000;
        Stop;
    DeathSmoke:
        TNT1 A 0 A_QueueCorpse();
        TNT1 A 0 A_SpawnItem("SmokeColumn");
        XXX1 A 2000;
        Stop;
    }
}

class DetectFloorCraterWithFire : DetectFloorCrater
{
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 ThrustThingZ(0, -10, 0, 1);
        TNT1 A 4;
        Stop;
    Death:
        TNT1 A 0 A_QueueCorpse();
        TNT1 A 0 A_SpawnItem("SmokeColumn");
        TNT1 A 0 A_SpawnItem("MolotovFireSpawner");
        XXX1 A 2000;
        Stop;
    }
}

class DetectCeilCrater : Actor
{
    Default
    {
        Scale 3.4;
        Speed 0;
        Health 1;
        Radius 8;
        Height 4;
        Gravity 0.9;
        Alpha 0.9;
        +MISSILE;
        +CLIENTSIDEONLY;
        +NOTELEPORT;
        +NOBLOCKMAP;
        +FORCEXYBILLBOARD;
        +NODAMAGETHRUST;
        +MOVEWITHSECTOR;
        -DONTSPLASH;
        BounceType "Doom";
        BounceFactor 0.01;
        RenderStyle "Shaded";
        StencilColor "Black";
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 ThrustThingZ(0, 35, 0, 1);
        TNT1 A 2;
        Stop;
    Death:
        TNT1 A 0 A_QueueCorpse();
        XXX1 A 2000;
        Stop;
    }
}

// Glass
class LampGlassShard : Actor
{
    Default
    {
        Radius 1;
        Height 1;
        Speed 15;
        Projectile;
        -NOGRAVITY;
        +THRUACTORS;
        +MOVEWITHSECTOR;
        Gravity 0.6;
        RenderStyle "Add";
        Alpha 0.6;
        Scale 1.3;
        DeathSound "GlassShardImpact";
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_Jump(255, "Standard", "Small", "Tiny", "XLarge");
    Standard:
        PGSD ABCD 1;
        Loop;
    Small:
        TNT1 A 0 A_SetScale(0.8);
        PGSD ABCD 1;
        Loop;
    Tiny:
        TNT1 A 0 A_SetScale(0.4);
        PGSD ABCD 1;
        Loop;
    XLarge:
        TNT1 A 0 A_SetScale(1.6);
        PGSD ABCD 1;
        Loop;
    Death:
        TNT1 A 0 A_SetTranslucent(0.3);
        PGSD E 125;
        Stop;
    }
}

// Rocks
class Roc1 : Actor
{
    Default
    {
        Projectile;
        -NOGRAVITY;
        -NOBLOCKMAP;
        -NOTELEPORT;
        -SOLID;
        +RANDOMIZE;
        Scale 0.7;
        Speed 5;
    }
    States
    {
    Spawn:
        ROC1 A 0 A_SetGravity(0.5);
        ROC1 A 0 ThrustThingZ(0, random(5, 15), 0, 1);
        Goto See;
    See:
        ROC1 A 5;
        Loop;
    Death:
        ROC1 AAAAAA 1 A_FadeOut(0.1);
        Stop;
    }
}

class Roc2 : Actor
{
    Default
    {
        Projectile;
        -NOGRAVITY;
        -NOBLOCKMAP;
        -NOTELEPORT;
        -SOLID;
        +RANDOMIZE;
        Scale 0.5;
        Speed 5;
    }
    States
    {
    Spawn:
        ROC2 A 0 A_SetGravity(0.5);
        ROC2 A 0 ThrustThingZ(0, random(5, 15), 0, 1);
        Goto See;
    See:
        ROC2 A 5;
        Loop;
    Death:
        ROC2 AAAAAA 1 A_FadeOut(0.1);
        Stop;
    }
}

class Roc3 : Actor
{
    Default
    {
        Projectile;
        -NOGRAVITY;
        -NOBLOCKMAP;
        -NOTELEPORT;
        -SOLID;
        +RANDOMIZE;
        Scale 0.8;
        Speed 5;
    }
    States
    {
    Spawn:
        ROC3 A 0 A_SetGravity(0.5);
        ROC3 A 0 ThrustThingZ(0, random(5, 15), 0, 1);
        Goto See;
    See:
        ROC3 A 5;
        Loop;
    Death:
        ROC3 AAAAAA 1 A_FadeOut(0.1);
        Stop;
    }
}

class Roc4 : Actor
{
    Default
    {
        Projectile;
        -NOGRAVITY;
        -NOBLOCKMAP;
        -NOTELEPORT;
        -SOLID;
        +RANDOMIZE;
        Scale 0.6;
        Speed 5;
    }
    States
    {
    Spawn:
        ROC4 A 0 A_SetGravity(0.5);
        ROC4 A 0 ThrustThingZ(0, random(5, 15), 0, 1);
        Goto See;
    See:
        ROC4 A 5;
        Loop;
    Death:
        ROC4 AAAAAA 1 A_FadeOut(0.1);
        Stop;
    }
}

class Roc5 : Actor
{
    Default
    {
        Projectile;
        -NOGRAVITY;
        -NOBLOCKMAP;
        -NOTELEPORT;
        -SOLID;
        +RANDOMIZE;
        Scale 0.5;
        Speed 5;
    }
    States
    {
    Spawn:
        ROC5 A 0 A_SetGravity(0.5);
        ROC5 A 0 ThrustThingZ(0, random(5, 15), 0, 1);
        Goto See;
    See:
        ROC5 A 5;
        Loop;
    Death:
        ROC5 AAAAAA 1 A_FadeOut(0.1);
        Stop;
    }
}

class Roc6 : Actor
{
    Default
    {
        Projectile;
        -NOGRAVITY;
        -NOBLOCKMAP;
        -NOTELEPORT;
        -SOLID;
        +RANDOMIZE;
        Scale 0.5;
        Speed 5;
    }
    States
    {
    Spawn:
        ROC6 A 0 A_SetGravity(0.5);
        ROC6 A 0 ThrustThingZ(0, random(5, 15), 0, 1);
        Goto See;
    See:
        ROC6 A 5;
        Loop;
    Death:
        ROC6 AAAAAA 1 A_FadeOut(0.1);
        Stop;
    }
}

class Roc7 : Actor
{
    Default
    {
        Projectile;
        -NOGRAVITY;
        -NOBLOCKMAP;
        -NOTELEPORT;
        -SOLID;
        +RANDOMIZE;
        Scale 0.3;
        Speed 7;
    }
    States
    {
    Spawn:
        ROC5 A 0 A_SetGravity(0.5);
        ROC5 A 0 ThrustThingZ(0, random(5, 15), 0, 1);
        Goto See;
    See:
        ROC5 A 5;
        Loop;
    Death:
        ROC5 AAAAAA 1 A_FadeOut(0.1);
        Stop;
    }
}

class Roc8 : Actor
{
    Default
    {
        Projectile;
        -NOGRAVITY;
        -NOBLOCKMAP;
        -NOTELEPORT;
        -SOLID;
        +RANDOMIZE;
        Scale 0.3;
        Speed 7;
    }
    States
    {
    Spawn:
        ROC6 A 0 A_SetGravity(0.5);
        ROC6 A 0 ThrustThingZ(0, random(5, 15), 0, 1);
        Goto See;
    See:
        ROC6 A 5;
        Loop;
    Death:
        ROC6 AAAAAA 1 A_FadeOut(0.1);
        Stop;
    }
}