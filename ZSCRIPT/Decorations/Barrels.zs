class ClearSkyExpBarrel : ExplosiveBarrel replaces ExplosiveBarrel
{
    Default
    {
        Health 20;
        Radius 10;
        Height 34;
        Mass 500;
        +SOLID;
        +SHOOTABLE;
        +NOBLOOD;
        +ACTIVATEMCROSS;
        +NOICEDEATH;
        +PUSHABLE;
        +WINDTHRUST;
        +TELESTOMP;
        Scale 0.65;
        DeathSound "Explosion/Near";
        Obituary "$OB_BARREL";
    }
    States
    {
    Spawn:
        BAR1 AAABBB 2 NoDelay A_SpawnItem("GreenBarrelLensFlare", 0, 30);
        TNT1 A 0 A_CustomMissile("GreenSmoke", 32, 0, random(0, 360), 2, random(50, 130));
        Loop;
    Death:
        BAR1 AAABBB 1 Bright;
        EXPL A 0 Radius_Quake(3, 12, 0, 30, 0);
        TNT1 A 0 A_Scream;
        TNT1 A 0 A_SpawnItemEx("DetectFloorCrater", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        TNT1 A 0 A_PlaySound("Explosion/Far", 3);
        TNT1 A 0 A_AlertMonsters;
        TNT1 A 0 A_CustomMissile("MetalShard1", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_CustomMissile("MetalShard2", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_CustomMissile("MetalShard3", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_SpawnItemEx("GrenadeExplosion", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAA 0 A_CustomMissile("ExplosionShrapnel", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleWithSmoke", 5, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleVeryFast", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAA 0 A_CustomMissile("MediumExplosionFlames", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 1 A_CustomMissile("ExplosionSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 2 A_CustomMissile("BigNeoSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        TNT1 A 1050 A_BarrelDestroy;
        TNT1 A 5 A_Respawn;
        Wait;
    }
}

class ClearSkyBurningBarrel : BurningBarrel replaces BurningBarrel
{
    Default
    {
        Radius 10;
        Height 34;
        Scale 0.65;
    }
    States
    {
    Spawn:
        BAR2 A 0 NoDelay A_Jump(256, "Spawn1", "Spawn2", "Spawn3");
        Goto Spawn1;
    Spawn1:
        BAR2 A 0 A_PlaySound("Barrel/Burn", CHAN_AUTO, 0.5, true);
        BAR2 A 0 A_CustomMissile("BarrelBurnParticles", 32, 0, random(0, 360), 2, random(50, 130));
        BAR2 A 2 A_SpawnItem("YellowBarrelLensFlare", 0, 30);
        Loop;
    Spawn2:
        BAR2 B 0 A_PlaySound("Barrel/Burn", CHAN_AUTO, 0.5, true);
        BAR2 B 0 A_CustomMissile("BarrelBurnParticles", 32, 0, random(0, 360), 2, random(50, 130));
        BAR2 B 2 A_SpawnItem("YellowBarrelLensFlare", 0, 30);
        Loop;
    Spawn3:
        BAR2 C 0 A_PlaySound("Barrel/Burn", CHAN_AUTO, 0.5, true);
        BAR2 C 0 A_CustomMissile("BarrelBurnParticles", 32, 0, random(0, 360), 2, random(50, 130));
        BAR2 C 2 A_SpawnItem("YellowBarrelLensFlare", 0, 30);
        Loop;
    }
}