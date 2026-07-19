class GM94 : ClearSkyWeapon
{
    Default
    {
        Weapon.Kickback 50;
        Weapon.AmmoType "GM94Loaded";
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 3;
        Weapon.AmmoType2 "VGM93Ammo";
        Weapon.AmmoUse2 1;
        Weapon.AmmoGive2 30;
        Scale 0.4;
        Tag "GM-94";
        Inventory.PickupMessage "You got the GM-94 Grenade Launcher!";
        +Weapon.Ammo_Optional;
        +Weapon.Alt_Ammo_Optional;
        +Weapon.Ammo_CheckBoth;
        +Weapon.NoAutoFire;
    }

    States
    {
    Ready:
        G94G A 0 A_PlaySound("GM94/Up", 9);
        G94G A 1 A_WeaponOffset(12, 100, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(11, 81, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(9, 69, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(7, 58, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(6, 47, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(4, 39, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(2, 34, WOF_INTERPOLATE);
        // fall through
    RealReady:
        G94G A 0 A_JumpIfInventory("UseMolotov", 1, "CS_CheckMolUse");
        G94G A 0 A_JumpIfInventory("UseF1Grenade", 1, "CS_CheckF1Use");
        G94G A 0 A_JumpIfInventory("UseStimInjector", 1, "CS_CheckStimUse");
        G94G A 0 A_JumpIfInventory("GM94Loaded", 0, 2);
        G94G A 0 A_JumpIfInventory("VGM93Ammo", 1, 2);
        G94G A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWUSER1);
        Loop;
        G94G A 0 A_JumpIfInventory("UseMolotov", 1, "CS_CheckMolUse");
        G94G A 0 A_JumpIfInventory("UseF1Grenade", 1, "CS_CheckF1Use");
        G94G A 0 A_JumpIfInventory("UseStimInjector", 1, "CS_CheckStimUse");
        G94G A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWUSER1);
        Loop;

    Deselect:
        G94G A 0 A_PlaySound("GM94/Down", 8);
        G94G A 4 A_WeaponOffset(2, 34, WOF_INTERPOLATE);
        G94G A 3 A_WeaponOffset(4, 39, WOF_INTERPOLATE);
        G94G A 2 A_WeaponOffset(6, 47, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(7, 58, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(9, 69, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(11, 81, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(12, 100, WOF_INTERPOLATE);
        TNT1 A Random(4, 9) A_WeaponOffset(12, 130, WOF_INTERPOLATE);
        TNT1 A Random(4, 9) A_WeaponOffset(12, 160, WOF_INTERPOLATE);
        TNT1 A 1 A_Lower;
        Wait;

    Select:
        TNT1 A 0 A_Raise;
        Wait;

    Fire:
        G94G A 0 A_JumpIfInventory("GM94Reloading", 1, "ReloadFinish");
        G94G A 0 A_JumpIfInventory("GM94Loaded", 1, 1);
        Goto Dryfire;
        G94F A 0 A_FireCustomMissile("SmokeSpawner", 0, 0, 0, 2);
        G94F A 0 A_GunFlash;
        G94F A 0 A_PlaySound("GM94/Fire", 6);
        G94F A 0 A_AlertMonsters;
        G94F A 0 A_TakeInventory("GM94Loaded", 1);
        G94F A 0 A_ZoomFactor(0.95);
        G94F AAAAAAAAAAAAAAAA 0 Bright A_FireCustomMissile("ShotgunParticles", random(-12, 12), 0, -1, 0, 0, random(-9, 9));
        G94F AAAAAAAAAAAAA 0 Bright A_FireCustomMissile("ShotgunParticles2", random(-19, 19), 0, -1, 0, 0, random(-9, 9));
        G94F A 0 A_FireCustomMissile("WeaponRedFlareSpawn", 0, 0, 0, 7);
        G94F A 1 Bright A_FireCustomMissile("VGM93Projectile", 0, 0);
        G94F B 1 Bright Offset(0, 38);
        G94F C 1 Bright Offset(0, 44);
        G94F D 0 A_FireCustomMissile("WeaponRedFlareSpawn", 0, 0, 0, 7);
        G94F D 0 A_SetPitch(-8.0 + pitch);
        G94F D 0 A_ZoomFactor(1.0);
        G94F D 1 Bright Offset(0, 43) A_SetPitch(3.0 + pitch);
        G94F E 1 Offset(0, 40) A_SetPitch(1.0 + pitch);
        G94F A 1 Offset(0, 36) A_SetPitch(1.0 + pitch);
        G94G A 1 Offset(0, 32) A_SetPitch(1.0 + pitch);
        G94G A 1 A_SetPitch(1.0 + pitch);
        G94G A 6;
        G94G A 0 A_PlaySound("GM94/Pump", 4);
        G94G BCDDCB 2;
        G94G A 3;
        Goto RealReady;

    Spawn:
        G94P A -1;
        Stop;

    Dryfire:
        G94G A 0 A_JumpIfInventory("VGM93Ammo", 1, "Reload");
        G94G A 0 A_PlaySound("GM94/Dryfire", 7);
        Goto RealReady;

    Reload:
        G94G A 0 A_JumpIfInventory("GM94Loaded", 3, 2);
        G94G A 0 A_JumpIfNoAmmo(1);
        Goto ProperReload;
        G94G A 1;
        Goto RealReady;

    ProperReload:
        G94G A 1 A_GiveInventory("GM94Reloading", 1);
        G94R A 1 Offset(0, 33);
        G94R B 1 Offset(0, 34);
        G94R C 1 Offset(0, 36);
        G94R D 1 Offset(0, 38);
        G94R E 1 Offset(0, 41);
        G94R E 1 Offset(0, 46);
        G94R E 1 Offset(0, 51);
        G94R E 1 Offset(0, 56);
        G94R E 1 Offset(0, 60);
        // fall through

    ReloadLoop:
        G94R E 1 A_TakeInventory("VGM93Ammo", 1, TIF_NOTAKEINFINITE);
        G94R E 0 A_GiveInventory("GM94Loaded", 1);
        G94R E 1 Offset(0, 68) A_PlaySound("GM94/Reload", 4);
        G94R E 1 Offset(0, 74);
        G94R E 1 Offset(0, 80);
        G94R E 1 Offset(0, 78);
        G94R E 1 Offset(0, 76);
        G94R E 1 Offset(0, 74);
        G94R E 1 Offset(0, 72);
        G94R E 1 Offset(0, 71);
        G94R E 1 Offset(0, 70) A_WeaponReady(WRF_NOBOB | WRF_NOSECONDARY | WRF_NOSWITCH);
        G94R EE 1 Offset(0, 69) A_WeaponReady(WRF_NOBOB | WRF_NOSECONDARY | WRF_NOSWITCH);
        G94R EEE 1 Offset(0, 68) A_WeaponReady(WRF_NOBOB | WRF_NOSECONDARY | WRF_NOSWITCH);
        G94R E 0 A_JumpIfInventory("GM94Loaded", 3, "ReloadFinish");
        G94R E 0 A_JumpIfInventory("VGM93Ammo", 1, "ReloadLoop");
        // fall through

    ReloadFinish:
        G94R E 1 Offset(0, 74);
        G94R E 1 Offset(0, 72);
        G94R E 1 Offset(0, 66);
        G94R E 1 Offset(0, 55);
        G94R E 1 Offset(0, 46);
        G94R E 1 Offset(0, 42);
        G94R E 1 Offset(0, 38);
        G94R D 1 Offset(0, 35);
        G94R C 1 Offset(0, 34);
        G94R B 1 Offset(0, 33);
        G94R A 1 Offset(0, 32);
        G94G A 1 A_TakeInventory("GM94Reloading", 1);
        Goto RealReady;

    Flash:
        TNT1 A 2 Bright A_Light2;
        TNT1 A 2 Bright A_Light1;
        TNT1 A 0 A_Light0;
        Stop;

    UseF1GrenadeState:
        G94G A 0 A_PlaySound("GM94/Down", 8);
        G94G A 1 A_WeaponOffset(5, 40, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(15, 56, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(35, 88, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(55, 120, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(75, 152, WOF_INTERPOLATE);
        // fall through
    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0, 32, WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing", 4);
        HNGR D 0 A_TakeInventory("UseF1Grenade", 1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem", 1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2, 2), 0, 0, 0, 0, 0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;

    UseMolotovState:
        G94G A 0 A_PlaySound("GM94/Down", 8);
        G94G A 1 A_WeaponOffset(5, 40, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(15, 56, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(35, 88, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(55, 120, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(75, 152, WOF_INTERPOLATE);
        // fall through
    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0, 32, WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing", 4);
        HNGR D 0 A_TakeInventory("UseMolotov", 1);
        HNGR D 0 A_TakeInventory("MolotovItem", 1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2, 2), 0, 0, 0, 0, 0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;

    UseInjectorState:
        G94G A 0 A_PlaySound("GM94/Down", 8);
        G94G A 1 A_WeaponOffset(5, 40, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(15, 56, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(35, 88, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(55, 120, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(75, 152, WOF_INTERPOLATE);
        // fall through
    HealInjector:
        TNT1 A 2 A_WeaponOffset(0, 32, WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
        TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        TNT1 A 0 A_GiveInventory("StimInjectorHealthGiver", 1);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;

    AfterUse:
        G94G A 0 A_PlaySound("GM94/Up", 9);
        TNT1 A 2 A_WeaponOffset(75, 152, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(67, 100, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(32, 69, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(10, 47, WOF_INTERPOLATE);
        G94G A 1 A_WeaponOffset(2, 34, WOF_INTERPOLATE);
        Goto RealReady;
    }
}

class GM94Loaded : Ammo
{
    Default
    {
        Inventory.MaxAmount 3;
    }
}

class GM94Reloading : Inventory
{
    Default
    {
        Inventory.MaxAmount 1;
    }
}

class VGM93Projectile : Actor
{
    Default
    {
        Radius 11;
        Height 8;
        Speed 50;
        Damage 30;
        Projectile;
        +RANDOMIZE;
        +DEHEXPLOSION;
        +FOILBUDDHA;
        -ROCKETTRAIL;
        -NOEXTREMEDEATH;
        -NOGRAVITY;
        Gravity 0.4;
        Decal "BigScorch";
        DeathSound "Explosion/Near";
        Obituary "%o Was Pulverized by %k's VGM-93.";
    }

    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_CustomMissile("ShotSmoke", 2, 0, random(70, 110), 2, random(0, 360));
        TNT1 A 0 A_SpawnItem("ShotSmoke");
        VG93 A 1 Bright;
        Loop;
    Death:
        EXPL A 0 A_ChangeFlag("NOGRAVITY", 1);
        EXPL A 0 A_CheckFloor("DeathFloor");
        EXLA A 0 A_CheckCeiling("DeathCeiling");
        EXPL A 0 Radius_Quake(3, 8, 0, 30, 0);
        TNT1 A 0 A_PlaySound("Explosion/Far", 3);
        TNT1 A 0 A_AlertMonsters;
        TNT1 A 0 A_CustomMissile("MetalShard1", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_CustomMissile("MetalShard2", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_CustomMissile("MetalShard3", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_SpawnItemEx("MolotovExplosion", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAA 0 A_CustomMissile("ExplosionShrapnel", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleWithSmoke", 5, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleVeryFast", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAA 0 A_CustomMissile("NapalmExplosionFlames", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 1 A_CustomMissile("ExplosionSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 2 A_CustomMissile("BigNeoSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        Stop;
    DeathFloor:
        EXPL A 0 Bright A_ChangeFlag("NOGRAVITY", 1);
        EXPL A 0 Radius_Quake(3, 8, 0, 30, 0);
        TNT1 A 0 A_SpawnItemEx("DetectFloorCrater", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        TNT1 A 0 A_PlaySound("Explosion/Far", 3);
        TNT1 A 0 A_AlertMonsters;
        TNT1 A 0 A_CustomMissile("MetalShard1", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_CustomMissile("MetalShard2", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_CustomMissile("MetalShard3", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_SpawnItemEx("MolotovExplosion", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAA 0 A_CustomMissile("ExplosionShrapnel", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleWithSmoke", 5, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleVeryFast", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAA 0 A_CustomMissile("NapalmExplosionFlames", 0, 0, random(0, 360), 2, random(0, 360));
        EXPL AAA 0 A_CustomMissile("BigNeoSmoke", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 1 A_CustomMissile("ExplosionSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 2 A_CustomMissile("BigNeoSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        Stop;
    DeathCeiling:
        EXPL A 0 Bright A_ChangeFlag("NOGRAVITY", 1);
        EXPL A 0 Radius_Quake(3, 8, 0, 30, 0);
        TNT1 A 0 A_SpawnItemEx("DetectCeilCrater", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        TNT1 A 0 A_PlaySound("Explosion/Far", 3);
        TNT1 A 0 A_AlertMonsters;
        TNT1 A 0 A_CustomMissile("MetalShard1", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_CustomMissile("MetalShard2", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_CustomMissile("MetalShard3", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_SpawnItemEx("MolotovExplosion", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        TNT1 AAAAAA 0 A_CustomMissile("ExplosionShrapnel", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleWithSmoke", 5, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleVeryFast", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAA 0 A_CustomMissile("NapalmExplosionFlames", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 1 A_CustomMissile("ExplosionSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 2 A_CustomMissile("BigNeoSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        Stop;
    }
}