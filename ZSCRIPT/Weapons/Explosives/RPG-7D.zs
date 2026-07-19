class RPG7D : ClearSkyWeapon
{
    Default
    {
        Weapon.Kickback 60;
        Weapon.AmmoType "RPG7DLoaded";
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 1;
        Weapon.AmmoType2 "RPGAmmo";
        Weapon.AmmoUse2 0;
        Weapon.AmmoGive2 15;
        Tag "RPG-7D";
        Scale 0.4;
        Inventory.PickupMessage "You got the RPG-7D!";
        +Weapon.Ammo_Optional;
        +Weapon.Alt_Ammo_Optional;
        +Weapon.Ammo_CheckBoth;
        +Weapon.NoAutoFire;
    }

    States
    {
    Ready:
        RPGG A 0 A_JumpIfInventory("RPG7DLoaded", 1, 1);
        Goto EmptyReady;
        RPGG A 0 A_PlaySound("RPG7D/Up", 9);
        RPGG A 1 A_WeaponOffset(12, 100, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(11, 81, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(9, 69, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(7, 58, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(6, 47, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(4, 39, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(2, 34, WOF_INTERPOLATE);
        // fall through

    RealReady:
        RPGG A 0 A_JumpIfInventory("UseMolotov", 1, "CS_CheckMolUse");
        RPGG A 0 A_JumpIfInventory("UseF1Grenade", 1, "CS_CheckF1Use");
        RPGG A 0 A_JumpIfInventory("UseStimInjector", 1, "CS_CheckStimUse");
        RPGG A 0 A_JumpIfInventory("RPG7DLoaded", 0, 2);
        RPGG A 0 A_JumpIfInventory("RPGAmmo", 1, 2);
        RPGG A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWUSER1);
        Loop;
        RPGG A 0 A_JumpIfInventory("UseMolotov", 1, "CS_CheckMolUse");
        RPGG A 0 A_JumpIfInventory("UseF1Grenade", 1, "CS_CheckF1Use");
        RPGG A 0 A_JumpIfInventory("UseStimInjector", 1, "CS_CheckStimUse");
        RPGG B 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWUSER1);
        Loop;

    EmptyReady:
        RPGG B 0 A_PlaySound("RPG7D/Up", 9);
        RPGG B 1 A_WeaponOffset(12, 100, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(11, 81, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(9, 69, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(7, 58, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(6, 47, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(4, 39, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(2, 34, WOF_INTERPOLATE);
        Goto RealReady;

    Deselect:
        RPGG A 0 A_JumpIfInventory("RPG7DLoaded", 1, 1);
        Goto EmptyDeselect;
        RPGG A 0 A_PlaySound("RPG7D/Down", 8);
        RPGG A 4 A_WeaponOffset(2, 34, WOF_INTERPOLATE);
        RPGG A 3 A_WeaponOffset(4, 39, WOF_INTERPOLATE);
        RPGG A 2 A_WeaponOffset(6, 47, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(7, 58, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(9, 69, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(11, 81, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(12, 100, WOF_INTERPOLATE);
        TNT1 A random(4, 9) A_WeaponOffset(12, 130, WOF_INTERPOLATE);
        TNT1 A random(4, 9) A_WeaponOffset(12, 160, WOF_INTERPOLATE);
        TNT1 A 1 A_Lower();
        Wait;

    EmptyDeselect:
        RPGG A 0 A_PlaySound("RPG7D/Down", 8);
        RPGG B 4 A_WeaponOffset(2, 34, WOF_INTERPOLATE);
        RPGG B 3 A_WeaponOffset(4, 39, WOF_INTERPOLATE);
        RPGG B 2 A_WeaponOffset(6, 47, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(7, 58, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(9, 69, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(11, 81, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(12, 100, WOF_INTERPOLATE);
        TNT1 A random(4, 9) A_WeaponOffset(12, 130, WOF_INTERPOLATE);
        TNT1 A random(4, 9) A_WeaponOffset(12, 160, WOF_INTERPOLATE);
        TNT1 A 1 A_Lower();
        Wait;

    Select:
        TNT1 A 0 A_Raise();
        Wait;

    Fire:
        RPGG A 0 A_JumpIfInventory("RPG7DLoaded", 1, 1);
        Goto Dryfire;
        RPGG A 0 A_GunFlash();
        RPGG A 0 A_TakeInventory("RPG7DLoaded", 1);
        RPGG A 0 A_PlaySound("RPG7D/Fire", 6);
        RPGG A 0 A_AlertMonsters();
        RPGG A 0 A_FireCustomMissile("SmokeSpawner", frandom(-2, 2), 0, 7, 0, 0, frandom(-5, 5));
        RPGG A 0 A_FireCustomMissile("SmokeSpawner", frandom(-2, 2), 0, 7, 0, 0, frandom(-5, 5));
        RPGG A 0 A_FireCustomMissile("SmokeSpawner", frandom(-2, 2), 0, 7, 0, 0, frandom(-5, 5));
        RPGG A 0 A_ZoomFactor(0.95);
        RPGG A 0 A_FireCustomMissile("WeaponRedFlareSpawn", 0, 0, 0, 7);
        RPGG B 1 Bright Offset(0, 38) A_FireCustomMissile("RPG7DMissile", 0, 0);
        RPGG B 0 A_FireCustomMissile("WeaponRedFlareSpawn", 0, 0, 0, 11);
        RPGG B 0 A_Recoil(2);
        RPGG B 0 A_SetPitch(pitch - 2.6);
        RPGG B 0 A_SetAngle(angle - 1.4);
        RPGG B 1 Offset(0, 44);
        RPGG B 0 A_ZoomFactor(1.0);
        RPGG B 0 A_SetPitch(pitch + 0.2);
        RPGG B 0 A_SetAngle(angle + 0.1);
        RPGG B 1 Offset(0, 43);
        RPGG B 0 A_SetPitch(pitch + 0.2);
        RPGG B 0 A_SetAngle(angle + 0.1);
        RPGG B 1 Offset(0, 40);
        RPGG B 0 A_SetPitch(pitch + 0.2);
        RPGG B 0 A_SetAngle(angle + 0.1);
        RPGG B 1 Offset(0, 36);
        RPGG B 0 A_SetPitch(pitch + 0.2);
        RPGG B 0 A_SetAngle(angle + 0.1);
        RPGG B 1 Offset(0, 32);
        RPGG B 0 A_SetPitch(pitch + 0.2);
        RPGG B 0 A_SetAngle(angle + 0.1);
        RPGG B 1;
        RPGG B 0 A_SetPitch(pitch + 0.2);
        RPGG B 0 A_SetAngle(angle + 0.1);
        RPGG B 1;
        RPGG B 0 A_SetPitch(pitch + 0.2);
        RPGG B 0 A_SetAngle(angle + 0.1);
        RPGG B 0 A_SetPitch(pitch + 0.2);
        RPGG B 0 A_SetAngle(angle + 0.1);
        RPGG B 1;
        RPGG B 0 A_SetPitch(pitch + 0.2);
        RPGG B 0 A_SetAngle(angle + 0.1);
        RPGG B 1;
        RPGG B 0 A_SetPitch(pitch + 0.2);
        RPGG B 0 A_SetAngle(angle + 0.1);
        RPGG B 1;
        RPGG B 0 A_SetPitch(pitch + 0.2);
        RPGG B 0 A_SetAngle(angle + 0.1);
        RPGG B 1;
        RPGG B 0 A_SetPitch(pitch + 0.2);
        RPGG B 0 A_SetAngle(angle + 0.1);
        RPGG B 1;
        RPGG B 0 A_SetPitch(pitch + 0.2);
        RPGG B 0 A_SetAngle(angle + 0.1);
        RPGG B 5;
        Goto RealReady;

    Dryfire:
        RPGG A 0 A_JumpIfInventory("RPGAmmo", 1, "Reload");
        RPGG A 0 A_PlaySound("RPG7D/Dryfire", 7);
        Goto RealReady;

    Spawn:
        RPGP A -1;
        Stop;

    Reload:
        RPGG A 0 A_JumpIfInventory("RPG7DLoaded", 1, 2);
        RPGG A 0 A_JumpIfNoAmmo(1);
        Goto ProperReload;
        RPGG B 1;
        Goto RealReady;

    ProperReload:
        RPGG B 1 Offset(0, 32);
        RPGG B 1 Offset(2, 38);
        RPGG B 1 Offset(4, 44);
        RPGG B 1 Offset(6, 50);
        RPGG B 1 Offset(8, 56);
        RPGR B 0 A_PlaySound("RPG7D/Reload", 5);
        RPGG B 1 Offset(10, 62);
        RPGG B 1 Offset(12, 72);
        RPGG B 1 Offset(14, 84);
        RPGG B 1 Offset(16, 96);
        RPGR A 1 Offset(14, 84);
        RPGR A 1 Offset(12, 72);
        RPGR A 1 Offset(10, 62);
        RPGR A 1 Offset(8, 56);
        RPGR A 1 Offset(6, 50);
        RPGR A 1 Offset(4, 44);
        RPGR A 1 Offset(2, 38);
        RPGR A 1 Offset(0, 32);
        RPGR BCDE 1;
        RPGR F 5;
        RPGR GHIJKKKLMNOP 1;
        RPGR Q 5;
        RPGR RSTUUU 1;
        RPGR VWX 1;
        RPGR Y 1 Offset(0, 32);
        RPGR Y 1 Offset(2, 38);
        RPGR Y 1 Offset(4, 44);
        RPGR Y 1 Offset(6, 50);
        RPGR Y 1 Offset(8, 56);
        RPGR Y 1 Offset(10, 62);
        RPGR Y 1 Offset(12, 72);
        RPGR Y 1 Offset(14, 84);
        RPGR Y 1 Offset(16, 96);
        // fall through

    ReloadLoop:
        RPGR Y 2 Offset(16, 96) A_CS_FillMagazine("RPG7DLoaded", "RPGAmmo", 1);
        Goto ReloadFinish;

    ReloadFinish:
        RPGG A 1 Offset(14, 84);
        RPGG A 1 Offset(12, 72);
        RPGG A 1 Offset(10, 62);
        RPGG A 1 Offset(8, 56);
        RPGG A 1 Offset(6, 50);
        RPGG A 1 Offset(4, 44);
        RPGG A 1 Offset(2, 38);
        RPGG A 1 Offset(0, 32);
        Goto RealReady;

    Flash:
        TNT1 A 2 Bright A_Light2();
        TNT1 A 2 Bright A_Light1();
        TNT1 A 0 A_Light0();
        Stop;

    UseF1GrenadeState:
        RPGG A 0 A_JumpIfInventory("RPG7DLoaded", 1, 1);
        Goto UseF1GrenadeStateNoAmmo;
        RPGG A 0 A_PlaySound("RPG7D/Down", 8);
        RPGG A 1 A_WeaponOffset(5, 40, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(15, 56, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(35, 88, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(55, 120, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(75, 152, WOF_INTERPOLATE);
        Goto ThrowF1;

    UseF1GrenadeStateNoAmmo:
        RPGG B 0 A_PlaySound("RPG7D/Down", 8);
        RPGG B 1 A_WeaponOffset(5, 40, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(15, 56, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(35, 88, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(55, 120, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(75, 152, WOF_INTERPOLATE);
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
        RPGG A 0 A_JumpIfInventory("RPG7DLoaded", 1, 1);
        Goto UseMolotovStateNoAmmo;
        RPGG A 0 A_PlaySound("RPG7D/Down", 8);
        RPGG A 1 A_WeaponOffset(5, 40, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(15, 56, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(35, 88, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(55, 120, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(75, 152, WOF_INTERPOLATE);
        Goto ThrowMolotov;

    UseMolotovStateNoAmmo:
        RPGG B 0 A_PlaySound("RPG7D/Down", 8);
        RPGG B 1 A_WeaponOffset(5, 40, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(15, 56, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(35, 88, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(55, 120, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(75, 152, WOF_INTERPOLATE);
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
        RPGG A 0 A_JumpIfInventory("RPG7DLoaded", 1, 1);
        Goto UseInjectorStateNoAmmo;
        RPGG A 0 A_PlaySound("RPG7D/Down", 8);
        RPGG A 1 A_WeaponOffset(5, 40, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(15, 56, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(35, 88, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(55, 120, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(75, 152, WOF_INTERPOLATE);
        Goto HealInjector;

    UseInjectorStateNoAmmo:
        RPGG B 0 A_PlaySound("RPG7D/Down", 8);
        RPGG B 1 A_WeaponOffset(5, 40, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(15, 56, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(35, 88, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(55, 120, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(75, 152, WOF_INTERPOLATE);
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
        RPGG A 0 A_JumpIfInventory("RPG7DLoaded", 1, 1);
        Goto AfterUseNoAmmo;
        RPGG A 0 A_PlaySound("RPG7D/Up", 9);
        TNT1 A 2 A_WeaponOffset(75, 152, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(67, 100, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(32, 69, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(10, 47, WOF_INTERPOLATE);
        RPGG A 1 A_WeaponOffset(2, 34, WOF_INTERPOLATE);
        Goto RealReady;

    AfterUseNoAmmo:
        RPGG B 0 A_PlaySound("RPG7D/Up", 9);
        TNT1 A 2 A_WeaponOffset(75, 152, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(67, 100, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(32, 69, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(10, 47, WOF_INTERPOLATE);
        RPGG B 1 A_WeaponOffset(2, 34, WOF_INTERPOLATE);
        Goto RealReady;
    }
}

class RPG7DLoaded : Ammo
{
    Default
    {
        Inventory.MaxAmount 1;
    }
}

class RPG7DMissile : Rocket replaces Rocket
{
    Default
    {
        Radius 11;
        Height 8;
        Speed 70;
        Projectile;
        -NOTELEPORT;
        Damage 150;
        Decal "BigScorch";
        DeathSound "Explosion/Near";
    }

    States
    {
    Spawn:
        RP7R A 0 NoDelay Bright A_PlaySound("RPG7D/Fly", CHAN_VOICE, 0.5, true);
        // fall through
    Fly:
        TNT1 A 0 A_CustomMissile("ShotSmoke", 2, 0, random(70, 110), 2, random(0, 360));
        TNT1 A 0 A_SpawnItem("ShotSmoke");
        RP7R A 1 Bright;
        TNT1 A 0 A_CustomMissile("ShotSmoke", 2, 0, random(70, 110), 2, random(0, 360));
        TNT1 A 0 A_SpawnItem("ShotSmoke");
        RP7R A 1 Bright;
        TNT1 A 0 A_CustomMissile("ShotSmoke", 2, 0, random(70, 110), 2, random(0, 360));
        TNT1 A 0 A_SpawnItem("ShotSmoke");
        Loop;

    Death:
        EXPL A 0 A_CheckFloor("DeathFloor");
        EXLA A 0 A_CheckCeiling("DeathCeiling");
        EXPL A 0 Radius_Quake(3, 12, 0, 30, 0);
        TNT1 A 0 A_PlaySound("Explosion/Far", 3);
        TNT1 A 0 A_AlertMonsters();
        TNT1 A 0 A_CustomMissile("MetalShard1", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_CustomMissile("MetalShard2", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_CustomMissile("MetalShard3", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_SpawnItemEx("RPGExplosion", flags:SXF_NOCHECKPOSITION);
        TNT1 AAAAAA 0 A_CustomMissile("ExplosionShrapnel", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleWithSmoke", 5, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleVeryFast", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAA 0 A_CustomMissile("ExplosionFlames", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 1 A_CustomMissile("ExplosionSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 2 A_CustomMissile("BigNeoSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        Stop;

    DeathFloor:
        EXPL A 0 Radius_Quake(3, 12, 0, 30, 0);
        TNT1 A 0 A_SpawnItemEx("DetectFloorCrater", flags:SXF_NOCHECKPOSITION);
        TNT1 A 0 A_PlaySound("Explosion/Far", 3);
        TNT1 A 0 A_AlertMonsters();
        TNT1 A 0 A_CustomMissile("MetalShard1", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_CustomMissile("MetalShard2", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_CustomMissile("MetalShard3", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_SpawnItemEx("RPGExplosion", flags:SXF_NOCHECKPOSITION);
        TNT1 AAAAAA 0 A_CustomMissile("ExplosionShrapnel", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleWithSmoke", 5, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleVeryFast", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAA 0 A_CustomMissile("ExplosionFlames", 0, 0, random(0, 360), 2, random(0, 360));
        EXPL AAA 0 A_CustomMissile("BigNeoSmoke", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 1 A_CustomMissile("ExplosionSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 2 A_CustomMissile("BigNeoSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        Stop;

    DeathCeiling:
        EXPL A 0 Radius_Quake(3, 12, 0, 30, 0);
        TNT1 A 0 A_SpawnItemEx("DetectCeilCrater", flags:SXF_NOCHECKPOSITION);
        TNT1 A 0 A_PlaySound("Explosion/Far", 3);
        TNT1 A 0 A_AlertMonsters();
        TNT1 A 0 A_CustomMissile("MetalShard1", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_CustomMissile("MetalShard2", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_CustomMissile("MetalShard3", 5, 0, random(0, 360), 2, random(30, 160));
        TNT1 A 0 A_SpawnItemEx("RPGExplosion", flags:SXF_NOCHECKPOSITION);
        TNT1 AAAAAA 0 A_CustomMissile("ExplosionShrapnel", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleWithSmoke", 5, 0, random(0, 360), 2, random(0, 180));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleVeryFast", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAAAAA 0 A_CustomMissile("ExplosionFlames", 0, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 1 A_CustomMissile("ExplosionSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        TNT1 AAAAA 2 A_CustomMissile("BigNeoSmoke", 2, 0, random(0, 360), 2, random(0, 360));
        Stop;
    }
}

class RPGExplosion : Actor
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
        CS_CombatDamageHandler.ScheduleExplode(self, 150, 200);
    }

    States
    {
    Spawn:
        TNT1 A 0;
        Stop;
    }
}