class ShotgunParticles : Actor
{
    Default
    {
        Speed 15;
        Radius 8;
        Height 1;
        Gravity 0.6;
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
        -NOGRAVITY;
        +THRUGHOST;
        +NOTELEPORT;
    }
    States
    {
    Spawn:
        SPKO A 2;
        SPKO AAAA 1 Bright A_FadeOut(0.02);
        SPKO A 0 A_ChangeFlag("NOGRAVITY", false);
        SPKO AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 Bright A_FadeOut(0.04);
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
        Gravity 0.5;
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
        Gravity 0.42;
        RenderStyle "Add";
        Alpha 0.88;
        Scale 0.07;
        +MISSILE;
        +NOTELEPORT;
        +NOBLOCKMAP;
        +RIPPER;
        +BLOODLESSIMPACT;
        +FORCEXYBILLBOARD;
        +CLIENTSIDEONLY;
        BounceType "Doom";
        +BOUNCEONWALLS;
        +BOUNCEONCEILINGS;
        +DONTSPLASH;
        +THRUACTORS;
        +GHOST;
        BounceFactor 0.01;
    }
    States
    {
    Spawn:
        SPKO AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 Bright A_FadeOut(0.02);
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
        Gravity 0.8;
        Scale 0.09;
    }
}

class ExplosionParticleWithSmoke : ExplosionParticleHeavy
{
    Default
    {
        BounceFactor 0.4;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        Goto Fly;
    Fly:
        TNT1 A 0 A_SpawnItemEx("ShotSmoke", flags:SXF_CLIENTSIDE);
        SPKO A 1 Bright;
        Loop;
    Death:
        SPKO AAAAAAAAAAAAA 1 A_SpawnItemEx("ShotSmoke", flags:SXF_CLIENTSIDE);
        Stop;
    }
}

class ExplosionParticleWithFire : ExplosionParticleHeavy
{
    Default
    {
        BounceFactor 0.4;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        Goto Fly;
    Fly:
        TNT1 A 0 A_SpawnItemEx("SmallFlameTrails", flags:SXF_CLIENTSIDE);
        SPKO A 1 Bright;
        Loop;
    Death:
        SPKO AAAAAAAAAAAAA 1 A_SpawnItemEx("SmallFlameTrails", flags:SXF_CLIENTSIDE);
        Stop;
    }
}

class PixelDebris : Actor
{
    Default
    {
        +MISSILE;
        +FLOORCLIP;
        +DONTSPLASH;
        +NOTELEPORT;
        +BOUNCELIKEHERETIC;
        Health 4;
        Radius 2;
        Height 3;
        Speed 5;
        Scale 0.1;
        Mass 1;
    }
    States
    {
    Spawn:
        WPPX A 1;
        Loop;
    Death:
        WPPX A 175 A_FadeOut(0.005);
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
        BounceType "Doom";
        +FLOORCLIP;
        +DONTSPLASH;
        +NOTELEPORT;
    }
    States
    {
    Spawn:
        SPKO A 1;
        SPKO AAAAA 1 Bright A_SetTranslucent(0.8);
        SPKO AAAAAA 1 Bright A_SetTranslucent(0.6);
        SPKO AAAAAAAA 1 Bright A_SetTranslucent(0.4);
        SPKO AAAAAAAAAA 1 Bright A_SetTranslucent(0.2);
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
        SPKS ABCDEFGHI 1 Bright;
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
        SPKS JKLMN 1 Bright;
        SPKS O 35 Bright;
        SPKS OOOOOOOOOO 1 Bright A_FadeOut(0.1);
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
    Default
    {
        BounceFactor 0.4;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        Goto Fly;
    Fly:
        TNT1 A 0 A_SpawnItemEx("SmallBurnParticles", flags:SXF_CLIENTSIDE);
        TNT1 A 1 Bright;
        Loop;
    Death:
        TNT1 AAAAAAAAAAAAA 1 A_SpawnItemEx("SmallBurnParticles", flags:SXF_CLIENTSIDE);
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