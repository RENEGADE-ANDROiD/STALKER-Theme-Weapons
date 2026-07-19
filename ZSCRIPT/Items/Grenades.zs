// Hidden ammo mirrors so SBARINFO can DrawNumber reliably (CustomInventory counts often fail there).
class F1GrenadeAmmo : Ammo
{
    Default
    {
        Inventory.Amount 0;
        Inventory.MaxAmount 8;
        +INVENTORY.IGNORESKILL;
        +INVENTORY.UNDROPPABLE;
        +INVENTORY.UNTOSSABLE;
    }
}

class MolotovAmmo : Ammo
{
    Default
    {
        Inventory.Amount 0;
        Inventory.MaxAmount 4;
        +INVENTORY.IGNORESKILL;
        +INVENTORY.UNDROPPABLE;
        +INVENTORY.UNTOSSABLE;
    }
}

// F-1 Grenade
class F1GrenadeItem : CustomInventory
{
    Default
    {
        +INVENTORY.INVBAR;
        -INVENTORY.KEEPDEPLETED;
        Inventory.Icon "HUDF1";
        Inventory.Amount 1;
        Inventory.MaxAmount 8;
        Inventory.PickupSound "Grenade/Pickup";
        Inventory.PickupMessage "Picked up a F-1 Hand Grenade";
        Tag "F-1 Hand Grenade";
        Scale 0.4;
    }

    override void DoEffect()
    {
        Super.DoEffect();
        CS_ConsumableHUD.SyncAmmo(Owner, "F1GrenadeAmmo", Amount);
    }

    override void DetachFromOwner()
    {
        if (Owner)
            Owner.TakeInventory("F1GrenadeAmmo", Owner.CountInv("F1GrenadeAmmo"));
        Super.DetachFromOwner();
    }

    States
    {
    Spawn:
        F1GR P -1;
        Stop;
    Use:
        NULL A 0 A_GiveInventory("UseF1Grenade", 1);
        Stop;
    }
}

class UseF1Grenade : Inventory
{
    Default
    {
        Inventory.MaxAmount 1;
    }
}

class F1Grenade : Actor
{
    Default
    {
        Radius 2;
        Height 2;
        Speed 35;
        Damage 1;
        Projectile;
        +RANDOMIZE;
        -NOGRAVITY;
        BounceType "Doom";
        BounceFactor 0.25;
        WallBounceFactor 0.4;
        Scale 0.3;
        BounceSound "F1/Bounce";
        DeathSound "Explosion/Near";
        Obituary "%o ate %k grenade.";
    }
    States
    {
    Spawn:
        F1GR ABCDEF 2;
        Loop;
    Death:
        EXPL A 0 Light("ROCKET_X1") A_ChangeFlag("NOGRAVITY", true);
        EXPL A 0 A_CheckFloor("DeathFloor");
        EXLA A 0 A_CheckCeiling("DeathCeiling");
        EXPL A 0 Radius_Quake(3, 8, 0, 30, 0);
        TNT1 A 0 A_PlaySound("Explosion/Far", 3);
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
        Stop;
    DeathFloor:
        EXPL A 0 Light("ROCKET_X1") A_ChangeFlag("NOGRAVITY", true);
        EXPL A 0 Radius_Quake(3, 8, 0, 30, 0);
        TNT1 A 0 A_SpawnItemEx("DetectFloorCrater", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        TNT1 A 0 A_PlaySound("Explosion/Far", 3);
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
        EXPL AAA 0 A_CustomMissile("BigNeoSmoke", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 1 A_CustomMissile("ExplosionSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 2 A_CustomMissile("BigNeoSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        Stop;
    DeathCeiling:
        EXPL A 0 Light("ROCKET_X1") A_ChangeFlag("NOGRAVITY", true);
        EXPL A 0 Radius_Quake(3, 8, 0, 30, 0);
        TNT1 A 0 A_SpawnItemEx("DetectCeilCrater", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        TNT1 A 0 A_PlaySound("Explosion/Far", 3);
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
        Stop;
    }
}

class GrenadeExplosion : Actor
{
    Default
    {
        +MISSILE;
        +NOBLOCKMAP;
        +NOTELEPORT;
        Radius 2;
        Height 2;
    }

    override void BeginPlay()
    {
        Super.BeginPlay();
        CS_CombatDamageHandler.ScheduleExplode(self, 80, 120);
    }

    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_SpawnItemEx("ExplosionBurst", 0, 0, 0, 0, 0, 0, 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        Stop;
    }
}

// Molotov
class MolotovItem : CustomInventory
{
    Default
    {
        +INVENTORY.INVBAR;
        -INVENTORY.KEEPDEPLETED;
        Inventory.Icon "HUDMol";
        Inventory.Amount 1;
        Inventory.MaxAmount 4;
        Inventory.PickupSound "Molotov/Pickup";
        Inventory.PickupMessage "Picked up a Molotov Cocktail";
        Tag "Molotov Cocktail";
        Scale 0.5;
    }

    override void DoEffect()
    {
        Super.DoEffect();
        CS_ConsumableHUD.SyncAmmo(Owner, "MolotovAmmo", Amount);
    }

    override void DetachFromOwner()
    {
        if (Owner)
            Owner.TakeInventory("MolotovAmmo", Owner.CountInv("MolotovAmmo"));
        Super.DetachFromOwner();
    }

    States
    {
    Spawn:
        MOLO P -1;
        Stop;
    Use:
        NULL A 0 A_GiveInventory("UseMolotov", 1);
        Stop;
    }
}

class UseMolotov : Inventory
{
    Default
    {
        Inventory.MaxAmount 1;
    }
}

class MolotovCocktail : Actor
{
    Default
    {
        Radius 2;
        Height 2;
        Speed 35;
        Damage 1;
        Projectile;
        +RANDOMIZE;
        -NOGRAVITY;
        DamageType "Fire";
        DeathSound "LampGlassBreak";
        Obituary "%o ate %k grenade.";
        Scale 0.5;
    }
    States
    {
    Spawn:
        MOLO PABCDEFGHI 2 A_CustomMissile("SmallBurnParticles", 0, 0, random(0, 360), 2, random(0, 360));
        Loop;
    Death:
        EXPL A 0 Light("ROCKET_X1") A_ChangeFlag("NOGRAVITY", true);
        EXPL A 0 A_CheckFloor("DeathFloor");
        EXLA A 0 A_CheckCeiling("DeathCeiling");
        TNT1 AAAAAAAAA 0 A_CustomMissile("LampGlassShard", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_SpawnItemEx("MolotovExplosion", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleWithFire", 5, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleVeryFast", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAA 0 A_CustomMissile("NapalmExplosionFlames", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 1 A_CustomMissile("ExplosionSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 2 A_CustomMissile("BigNeoSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        Stop;
    DeathFloor:
        EXPL A 0 Light("ROCKET_X1") A_ChangeFlag("NOGRAVITY", true);
        TNT1 A 0 A_SpawnItemEx("DetectFloorCraterWithFire", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAAAAA 0 A_CustomMissile("LampGlassShard", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_SpawnItemEx("MolotovExplosion", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleWithFire", 5, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleVeryFast", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAA 0 A_CustomMissile("NapalmExplosionFlames", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 1 A_CustomMissile("ExplosionSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 2 A_CustomMissile("BigNeoSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        Stop;
    DeathCeiling:
        EXPL A 0 Light("ROCKET_X1") A_ChangeFlag("NOGRAVITY", true);
        TNT1 A 0 A_SpawnItemEx("DetectCeilCrater", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAAAAA 0 A_CustomMissile("LampGlassShard", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_SpawnItemEx("MolotovExplosion", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleWithFire", 5, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleVeryFast", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAA 0 A_CustomMissile("NapalmExplosionFlames", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 1 A_CustomMissile("ExplosionSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 2 A_CustomMissile("BigNeoSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        Stop;
    }
}

class MolotovExplosion : Actor
{
    Default
    {
        DamageType "Fire";
        +MISSILE;
        +NOBLOCKMAP;
        +NOTELEPORT;
        Radius 2;
        Height 2;
    }

    override void BeginPlay()
    {
        Super.BeginPlay();
        CS_CombatDamageHandler.ScheduleExplode(self, 80, 120);
    }

    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_SpawnItemEx("FireExplosionBurst", 0, 0, 0, 0, 0, 0, 0, SXF_CLIENTSIDE | SXF_NOCHECKPOSITION);
        Stop;
    }
}