class ExplosionFlames : Actor
{
    Default
    {
        Radius 1;
        Height 1;
        Projectile;
        +NOGRAVITY;
        +FORCEXYBILLBOARD;
        +CLIENTSIDEONLY;
        +THRUACTORS;
        RenderStyle "Add";
        Scale 1.2;
        Speed 1;
    }
    States
    {
    Spawn:
        CX03 AA 0 A_CustomMissile("ExplosionSmoke", 0, 0, random(0, 360), 2, random(0, 360));
        CX03 A 0 A_CustomMissile("BigNeoSmoke", 0, 0, random(0, 360), 2, random(0, 360));
        CX03 ABCDEFGHIJKLMNOPQRSTUVWXYZ 1 Bright A_FadeOut(0.03);
        Stop;
    }
}

class NapalmExplosionFlames : ExplosionFlames
{
    Default
    {
        Scale 1.6;
        Speed 2;
    }
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_Jump(96, "Alt");
        CFR3 AA 0 A_CustomMissile("ExplosionSmoke", 0, 0, random(0, 360), 2, random(0, 360));
        CFR3 A 0 A_CustomMissile("BurnedSmoke", 0, 0, random(0, 360), 2, random(70, 120));
        CFR3 ABCDEFGHIJKLMNOP 2 Bright A_FadeOut(0.03);
        Stop;
    Alt:
        FIR5 AA 0 A_CustomMissile("ExplosionSmoke", 0, 0, random(0, 360), 2, random(0, 360));
        FIR5 A 0 A_CustomMissile("BurnedSmoke", 0, 0, random(0, 360), 2, random(70, 120));
        FIR5 ABCDEFGHIJKLMNOP 2 Bright A_FadeOut(0.03);
        Stop;
    }
}

class MediumExplosionFlames : ExplosionFlames
{
    Default
    {
        Scale 0.95;
        Speed 2;
    }
}

class BurnParticles : Actor
{
    Default
    {
        Radius 8;
        Height 8;
        Speed 5;
        Mass 6;
        BounceFactor 0.5;
        BounceType "Doom";
        +NOBLOCKMAP;
        +MISSILE;
        +NOTELEPORT;
        +DONTSPLASH;
        +MOVEWITHSECTOR;
        +NODAMAGETHRUST;
        +NOCLIP;
        +CLIENTSIDEONLY;
        +RIPPER;
        +BLOODLESSIMPACT;
        DamageType "Fire";
    }
    States
    {
    Spawn:
        TNT1 A 0 Bright A_CustomMissile("BurnedSmoke", 3, 0, random(0, 360), 2, random(60, 130));
        TNT1 A 0 Bright A_CustomMissile("FlameTrails", 0, 0, random(0, 360), 2, random(60, 130));
        Stop;
    }
}

class SmallBurnParticles : BurnParticles
{
    Default
    {
        DamageType "Fire";
    }
    States
    {
    Spawn:
        TNT1 A 0 Bright A_CustomMissile("BurnedSmoke", 3, 0, random(0, 360), 2, random(60, 130));
        TNT1 A 0 Bright A_CustomMissile("SmallFlameTrails", 0, 0, random(0, 360), 2, random(60, 130));
        Stop;
    }
}

class BigBurnParticles : BurnParticles
{
    Default
    {
        DamageType "Fire";
    }
    States
    {
    Spawn:
        TNT1 A 0 Bright A_CustomMissile("BurnedSmoke", 3, 0, random(0, 360), 2, random(60, 130));
        TNT1 A 0 Bright A_CustomMissile("BigFlameTrails", 0, 0, random(0, 360), 2, random(60, 130));
        Stop;
    }
}

class BarrelBurnParticles : BurnParticles
{
    States
    {
    Spawn:
        TNT1 A 0 Bright A_CustomMissile("BurnedSmoke", 3, 0, random(0, 360), 2, random(60, 130));
        TNT1 A 0 Bright A_CustomMissile("FlameTrails", 0, 0, random(0, 360), 2, random(60, 130));
        Stop;
    }
}

class FlameTrails : Actor
{
    Default
    {
        Radius 1;
        Height 1;
        Speed 3;
        Damage 0;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +DONTSPLASH;
        +MISSILE;
        +FORCEXYBILLBOARD;
        +CLIENTSIDEONLY;
        +NOINTERACTION;
        RenderStyle "Add";
        DamageType "Flames";
        Scale 0.4;
        Alpha 1;
        Gravity 0;
    }
    States
    {
    Spawn:
        TNT1 A 2;
        CFRP ABCDEFGH 3 Bright A_FadeOut(0.005);
        Stop;
    }
}

class SmallFlameTrails : FlameTrails
{
    Default
    {
        Scale 0.2;
    }
}

class BigFlameTrails : FlameTrails
{
    Default
    {
        Scale 0.7;
    }
}

class MolotovFire : Actor
{
    Default
    {
        DamageType "Fire";
        Damage 1;
        ReactionTime 80;
        +STRIFEDAMAGE;
        +NOBLOCKMAP;
        +FLOORCLIP;
        +NOTELEPORT;
        +NODAMAGETHRUST;
        +DONTSPLASH;
        +BLOODLESSIMPACT;
        Decal "Scorch";
        XScale 1.15;
        YScale 1.2;
    }
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_PlaySound("Barrel/Burn", CHAN_5, 0.5, true);
        NULL A 0 A_SetTranslucent(0.75);
        NULL A 0 A_SetScale(0.45);
        C1RE A 2 Bright A_Explode(5, 5);
        NULL A 0 A_SetScale(0.5);
        C1RE B 2 Bright A_Explode(8, 12);
        NULL A 0 A_SetScale(0.65);
        C1RE C 2 Bright A_Explode(12, 16);
        NULL A 0 A_SetScale(0.7);
        C1RE D 2 Bright A_Explode(16, 24);
        NULL A 0 A_SetScale(0.85);
        C1RE E 2 Bright A_Explode(18, 32);
        NULL A 0 A_SetScale(0.9);
    FlameOn:
        NULL A 0;
        NULL A 0 A_SetTranslucent(0.75);
        NULL A 0 A_SetScale(1.05);
        NULL A 0 Bright;
        C1RE A 2 Bright A_Explode(22, 35);
        C1RE B 2 Bright A_CountDown();
        NULL A 0 Bright;
        C1RE C 2 Bright A_Explode(22, 35);
        C1RE D 2 Bright A_CountDown();
        NULL A 0 Bright;
        C1RE E 2 Bright A_Explode(22, 35);
        C1RE F 2 Bright A_CountDown();
        NULL A 0 Bright;
        C1RE G 2 Bright A_Explode(22, 35);
        C1RE H 2 Bright A_CountDown();
        Goto FlameOn+5;
    Death:
        C1RE ABCDEFG 2 Bright A_FadeOut();
        TNT1 A 0 A_StopSound(CHAN_5);
        Stop;
    }
}

class MolotovFire2 : MolotovFire
{
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_PlaySound("Barrel/Burn", CHAN_5, 0.5, true);
        NULL A 0 A_SetTranslucent(0.75);
        NULL A 0 A_SetScale(0.45);
        C2RE A 2 Bright A_Explode(5, 5);
        NULL A 0 A_SetScale(0.5);
        C2RE B 2 Bright A_Explode(8, 12);
        NULL A 0 A_SetScale(0.65);
        C2RE C 2 Bright A_Explode(12, 16);
        NULL A 0 A_SetScale(0.7);
        C2RE D 2 Bright A_Explode(16, 24);
        NULL A 0 A_SetScale(0.85);
        C2RE E 2 Bright A_Explode(18, 32);
        NULL A 0 A_SetScale(0.9);
    FlameOn:
        NULL A 0;
        NULL A 0 A_SetTranslucent(0.75);
        NULL A 0 A_SetScale(1.05);
        NULL A 0 Bright;
        C2RE A 2 Bright A_Explode(22, 35);
        C2RE B 2 Bright A_CountDown();
        NULL A 0 Bright;
        C2RE C 2 Bright A_Explode(22, 35);
        C2RE D 2 Bright A_CountDown();
        NULL A 0 Bright;
        C2RE E 2 Bright A_Explode(22, 35);
        C2RE F 2 Bright A_CountDown();
        NULL A 0 Bright;
        C2RE G 2 Bright A_Explode(22, 35);
        C2RE H 2 Bright A_CountDown();
        Goto FlameOn+5;
    Death:
        C2RE ABCDEFG 2 Bright A_FadeOut();
        TNT1 A 0 A_StopSound(CHAN_5);
        Stop;
    }
}

class MolotovFireSpawner : RandomSpawner
{
    Default
    {
        DropItem "MolotovFire", 255, 8;
        DropItem "MolotovFire2", 255, 8;
    }
}