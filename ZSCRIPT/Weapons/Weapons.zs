// ============================================================================
// Riot Shield 
// Replaces Chainsaw.
// Main credit goes to:
// NEW and Old Sprites By mryayayify
// Original Decorate Script By XV117
// Tweaked by RENEGADE ANDROiD
// ============================================================================

class ShieldModeA : Inventory
{
    Default { Inventory.MaxAmount 1; }
}

// ------------------------------------------------------------------------
// Protection actor (blocks shots when shield is raised)
// ------------------------------------------------------------------------
class RiotShieldProtection : Actor
{
    Default
    {
        Speed 9;
        Health 99999;
        Radius 15;
        Height 55;
        BloodType "RiotShieldHit";
        PainChance 0;
        +NOTARGET;
        +NOGRAVITY;
        +SHOOTABLE;
        +NOTELEPORT;
        -SOLID;
        +NODAMAGETHRUST;
        +NORADIUSDMG;
        +NOPAIN;
    }
    States
    {
    Spawn:
        XXXX A 1;
        Loop;
    }
}

// ------------------------------------------------------------------------
// Hit puff for shield (simple bullet puff)
// ------------------------------------------------------------------------
class RiotShieldHit : BulletPuff
{
    Default
    {
        RenderStyle "Translucent";
        Scale 0.15;
        Alpha 0.7;
        +NOBLOCKMAP;
        +NOGRAVITY;
        +FORCEXYBILLBOARD;
    }
    States
    {
    Spawn:
    Death:
    XDeath:
    Melee:
        TNT1 A 0 A_PlaySound("barrel/pain");
        TNT1 A 0;
        TNT1 AB 1 Bright;
        Stop;
    }
}

// ------------------------------------------------------------------------
// Shield melee puff – does no damage (damage is handled manually)
// ------------------------------------------------------------------------
class Shield_melee : BulletPuff
{
    Default
    {
        Damage 0;
        +NOBLOCKMAP;
        +NOGRAVITY;
        +PUFFONACTORS;
        +HITTRACER;
        -SOLID;
        +NOBLOOD;
        Decal "None";
    }
    States
    {
    Spawn:
        TNT1 A 1;
        Stop;
    }
}

// ============================================================================
// Riot Shield Pickup
// ============================================================================
class RiotShieldPickup : CustomInventory
{
    Default
    {
        Inventory.PickupSound "barrel/pain";
        Inventory.PickupMessage "You got the UAC-33 Ballistic Shield";
        +INVENTORY.RESTRICTABSOLUTELY;
        -INVENTORY.ALWAYSPICKUP;
    }
    States
    {
    Spawn:
        5L1D I 1;
        5L1D I -1;
        Loop;
    Pickup:
        TNT1 A 0;
        TNT1 A 0 A_GiveInventory("RiotShield", 1);
        Stop;
    }
}

// ============================================================================
// Riot Shield Weapon
// ============================================================================
class RiotShield : ClearSkyWeapon
{
    Default
    {
        Weapon.SlotNumber 2;
        Weapon.SelectionOrder 3400;
        Weapon.KickBack 200;
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 0;
        Weapon.AmmoUse2 0;
        Weapon.AmmoGive2 0;
        Obituary "%o stood no chance against %k's riot shield";
        AttackSound "None";
        Inventory.PickupSound "barrel/pain";
        Inventory.PickupMessage "You got the UAC-33 Ballistic Shield";
        +INVENTORY.RESTRICTABSOLUTELY;
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOALERT;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
        +WEAPON.WIMPY_WEAPON;
        +FORCEXYBILLBOARD;
        Tag "Riot Shield";
        Scale 1.0;
    }

    action void A_ShieldBashHit()
    {
        let ply = player;
        if (!ply) return;

        // PB2022 ShieldMeele A_CustomPunch range 150 / damage 20-40.
        double range = 150;
        double aimZ = ply.viewheight;

        FLineTraceData lt;
        LineTrace(angle, range, pitch, 0, aimZ, data:lt);
        Actor victim = lt.hitActor;

        if (!victim)
        {
            for (int i = -6; i <= 6; i += 6)
            {
                LineTrace(angle + i, range, pitch, 0, aimZ, data:lt);
                victim = lt.hitActor;
                if (victim) break;
            }
        }

        if (victim && victim.bSHOOTABLE && victim != ply.mo)
        {
            A_Face(victim);
            CS_CombatDamageHandler.Schedule(victim, ply.mo, ply.mo, random(20, 40), 'Melee');
            A_SpawnItemEx("Shield_melee", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
            A_PlaySound("BASH1", CHAN_WEAPON);
            A_Quake(0.2, 1.0, 0, 1, 0);
        }
    }

    // ------------------------------------------------------------
    // States
    // ------------------------------------------------------------
    States
    {
    Select:
        TNT1 A 0 A_Raise();
        RSWR F 1 Offset(0, 102);
        RSWR G 1 Offset(0, 92);
        RSWR H 1 Offset(0, 82);
        RSWR I 1 Offset(0, 72);
        RSWR J 1 Offset(0, 62);
        RSWR K 1 Offset(0, 52);
        RSWF C 1 Offset(0, 42);
        RSWG A 1 Offset(0, 32);
        TNT1 A 0 A_GunFlash();
        Goto Ready;

    Deselect:
        TNT1 A 0 A_JumpIfInventory("ShieldModeA", 1, "DeselectLower");
        RSWG A 1 Offset(0, 32);
        RSWF C 1 Offset(0, 42);
        RSWR K 1 Offset(0, 52);
        RSWR J 1 Offset(0, 62);
        RSWR I 1 Offset(0, 72);
        RSWR H 1 Offset(0, 82);
        RSWR G 1 Offset(0, 92);
        RSWR F 1 Offset(0, 102);
        TNT1 A 0 A_Lower();
        Wait;

    DeselectLower:
        TNT1 A 0 A_CS_DestroyShieldProtection();
        TNT1 A 0 A_TakeInventory("ShieldModeA", 1);
        RSWT F 1;
        RSWB FEDCBA 1;
        Goto Deselect;

    // ------------------------------------------------------------
    // Ready state – conditionally show shield
    // ------------------------------------------------------------
    RealReady:
        Goto Ready;

    Ready:
        RSWG A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        TNT1 A 0 A_JumpIfInventory("ShieldModeA", 1, "ReadyRaised");
        TNT1 A 0 A_JumpIfInventory("UseMolotov", 1, "LowerForMolotov");
        TNT1 A 0 A_JumpIfInventory("UseF1Grenade", 1, "LowerForGrenade");
        TNT1 A 0 A_JumpIfInventory("UseStimInjector", 1, "LowerForInjector");
        Loop;

    ReadyRaised:
        TNT1 A 0 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        RSWT A 1;
        TNT1 A 0 A_JumpIfInventory("UseMolotov", 1, "LowerForMolotov");
        TNT1 A 0 A_JumpIfInventory("UseF1Grenade", 1, "LowerForGrenade");
        TNT1 A 0 A_JumpIfInventory("UseStimInjector", 1, "LowerForInjector");
        Loop;

    // ------------------------------------------------------------
    // Lower shield before equipment use
    // ------------------------------------------------------------
    LowerForMolotov:
        TNT1 A 0 A_JumpIfInventory("ShieldModeA", 1, "DoLowerMolotov");
        Goto CS_CheckMolUse;
    DoLowerMolotov:
        TNT1 A 0 A_CS_DestroyShieldProtection();
        TNT1 A 0 A_TakeInventory("ShieldModeA", 1);
        RSWT F 1;
        RSWB FEDCBA 1;
        Goto CS_CheckMolUse;

    LowerForGrenade:
        TNT1 A 0 A_JumpIfInventory("ShieldModeA", 1, "DoLowerGrenade");
        Goto CS_CheckF1Use;
    DoLowerGrenade:
        TNT1 A 0 A_CS_DestroyShieldProtection();
        TNT1 A 0 A_TakeInventory("ShieldModeA", 1);
        RSWT F 1;
        RSWB FEDCBA 1;
        Goto CS_CheckF1Use;

    LowerForInjector:
        TNT1 A 0 A_JumpIfInventory("ShieldModeA", 1, "DoLowerInjector");
        Goto CS_CheckStimUse;
    DoLowerInjector:
        TNT1 A 0 A_CS_DestroyShieldProtection();
        TNT1 A 0 A_TakeInventory("ShieldModeA", 1);
        RSWT F 1;
        RSWB FEDCBA 1;
        Goto CS_CheckStimUse;

    // ------------------------------------------------------------
    // Equipment use – override to ensure shield is cleared and we return to clean ready
    // ------------------------------------------------------------
    UseInjectorState:
        TNT1 A 0 A_TakeInventory("ShieldModeA", 1);
        TNT1 A 0 A_PlaySound("weapon/down", 8);
        Goto HealInjector;

    HealInjector:
        TNT1 A 2 A_WeaponOffset(0, 32, WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
                TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_TakeInventory("StimInjectorItem", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        TNT1 A 0 { GiveBody(40); }
        TNT1 A 0 A_SpawnItemEx("StimInjectorBurst", 0, 0, 32, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;

    AfterUse:
        TNT1 A 0 A_TakeInventory("ShieldModeA", 1);
        TNT1 A 0 A_PlaySound("weapon/up", 9);
        TNT1 A 2 A_WeaponOffset(0, 32, WOF_INTERPOLATE);
        RSWG A 1 A_WeaponOffset(12, 100, WOF_INTERPOLATE);
        RSWG A 1 A_WeaponOffset(11, 81, WOF_INTERPOLATE);
        RSWG A 1 A_WeaponOffset(9, 69, WOF_INTERPOLATE);
        RSWG A 1 A_WeaponOffset(7, 58, WOF_INTERPOLATE);
        RSWG A 1 A_WeaponOffset(6, 47, WOF_INTERPOLATE);
        RSWG A 1 A_WeaponOffset(4, 39, WOF_INTERPOLATE);
        RSWG A 1 A_WeaponOffset(2, 34, WOF_INTERPOLATE);
        Goto Ready;

    UseF1GrenadeState:
        TNT1 A 0 A_TakeInventory("ShieldModeA", 1);
        TNT1 A 0 A_PlaySound("weapon/down", 8);
        Goto ThrowF1;
    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0, 32, WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing", 4);
        HNGR D 0 A_TakeInventory("UseF1Grenade", 1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem", 1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2,2), 0, 0, 0, 0, 0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;

    UseMolotovState:
        TNT1 A 0 A_TakeInventory("ShieldModeA", 1);
        TNT1 A 0 A_PlaySound("weapon/down", 8);
        Goto ThrowMolotov;
    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0, 32, WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing", 4);
        HNGR D 0 A_TakeInventory("UseMolotov", 1);
        HNGR D 0 A_TakeInventory("MolotovItem", 1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2,2), 0, 0, 0, 0, 0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;

    // ------------------------------------------------------------
    // Fire: shield bash — PB2022 ShieldMeele (hit first, then CDEF A @ 1 tic)
    // ------------------------------------------------------------
    Fire:
        TNT1 A 0 A_ShieldBashHit();
        RSWT C 1;
        RSWT D 1;
        RSWT E 1;
        RSWT F 1;
        RSWT A 1;
        TNT1 A 0 A_JumpIfInventory("ShieldModeA", 1, "ReadyRaised");
        Goto Ready;

    // ------------------------------------------------------------
    // AltFire: raise / lower shield (PB ReadyShield settle: RSWT F F)
    // ------------------------------------------------------------
    AltFire:
        TNT1 A 0 A_JumpIfInventory("ShieldModeA", 1, "UnShield");
        TNT1 A 0 A_GiveInventory("ShieldModeA", 1);
        RSWB ABCDEF 1;
        TNT1 A 0 A_SpawnItemEx("RiotShieldProtection", 20, 0, 15, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        RSWT F 1;
        RSWT F 1;
        Goto ReadyRaised;

    UnShield:
        TNT1 A 0 A_CS_DestroyShieldProtection();
        TNT1 A 0 A_TakeInventory("ShieldModeA", 1);
        RSWT F 1;
        RSWT F 1;
        RSWB FEDCBA 1;
        Goto Ready;

    Spawn:
        5L1D I -1;
        Stop;
    }
}

// ============================================================================
// 1. Vepr-12
// ============================================================================
class Vepr12 : ClearSkyWeapon
{
    Default
    {
        Weapon.Kickback 50;
        Weapon.AmmoType "Vepr12Loaded";
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 10;
        Weapon.AmmoType2 "_12GaugeShell";
        Weapon.AmmoUse2 1;
        Weapon.AmmoGive2 30;
        Tag "Vepr-12";
        Inventory.PickupMessage "You got the Vepr-12!";
        +Weapon.Ammo_Optional;
        +Weapon.Alt_Ammo_Optional;
        +Weapon.Ammo_CheckBoth;
        +Weapon.NoAutoFire;
        Scale 0.8;
    }

    States
    {
    Ready:
        V12G A 0 A_PlaySound("Vepr12/Up",9);
        V12G A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;

    RealReady:
        V12G A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        V12G A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        V12G A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        V12G A 0 A_JumpIfInventory("Vepr12Loaded",0,2);
        V12G A 0 A_JumpIfInventory("_12GaugeShell",1,2);
        V12G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;
        V12G A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        V12G A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        V12G A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        V12G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;

    Deselect:
        V12G A 0 A_PlaySound("Vepr12/Down",8);
        V12G A 3 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        V12G A 2 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,130,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,160,WOF_INTERPOLATE);
        TNT1 A 1 A_Lower;
        Wait;

    Select:
        TNT1 A 0 A_Raise;
        Wait;

    Fire:
        V12G A 0 A_JumpIfInventory("Vepr12Loaded",1,1);
        Goto Dryfire;
        V12G A 0 A_FireCustomMissile("SmokeSpawner", frandom(-5, 5), 0, 7, 0, 0, frandom(-5, 5));
        V12G A 0 A_FireCustomMissile("SmokeSpawnerSmall", frandom(-2, 2), 0, -2, -15);
        V12G A 0 A_FireCustomMissile("SmokeSpawnerSmall", frandom(-2, 2), 0, 2, -10);
        V12G A 0 A_FireCustomMissile("SmokeSpawnerSmall", frandom(-2, 2), 0, -8, -15);
        V12G A 0 A_FireCustomMissile("SmokeSpawnerSmall", frandom(-2, 2), 0, 12, -10);
        V12G A 0 A_GunFlash;
        V12G A 0 A_PlaySound("Vepr12/Fire",6);
        V12G A 0 A_TakeInventory("Vepr12Loaded",1);
        V12G D 0 A_ZoomFactor(0.97);
        V12G AAAAAAAAAAAAAAAA 0 Bright A_FireCustomMissile("ShotgunParticles", random(-12,12),0,-1,0,0,random(-9,9));
        V12G AAAAA 0 Bright A_FireCustomMissile("ShotgunParticles2", random(-12,12),0,-1,0,0,random(-9,9));
        V12G AAAAA 0 A_FireCustomMissile("ShotgunTracer", frandom(-2.0,2.0),0,0,0,0,frandom(-1.5,1.5));
        V12G A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,7);
        V12F A 1 Bright Offset(0,38);
        V12F B 1 Bright Offset(0,44);
        V12F B 0 A_FireCustomMissile("Vepr12CasingSpawn",0,0,2,-2);
        V12G A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,7);
        V12G A 0 A_SetPitch(-8.0 + pitch);
        V12G A 0 A_ZoomFactor(1.0);
        V12G A 1 Offset(0,43) A_SetPitch(+3.0 + pitch);
        V12G A 1 Offset(0,40) A_SetPitch(+1.0 + pitch);
        V12G A 1 Offset(0,36) A_SetPitch(+1.0 + pitch);
        V12G A 1 Offset(0,32) A_SetPitch(+1.0 + pitch);
        V12G A 1 A_SetPitch(+1.0 + pitch);
        Goto RealReady;

    Spawn:
        V12P A -1;
        Stop;

    Dryfire:
        V12G A 0 A_JumpIfInventory("_12GaugeShell",1,"Reload");
        V12G A 0 A_PlaySound("Vepr12/Dryfire",7);
        Goto RealReady;

    Reload:
        V12G A 0 A_JumpIfInventory("Vepr12Loaded",10,2);
        V12G A 0 A_JumpIfNoAmmo(1);
        Goto ProperReload;
        V12G A 1;
        Goto RealReady;

    ProperReload:
        V12G A 1 Offset(0,35);
        V12R A 1 Offset(0,38);
        V12R B 1 Offset(0,44);
        V12R C 1 Offset(2,46);
        V12R D 1 Offset(4,52);
        V12R E 1 Offset(7,56) A_PlaySound("AK47/Out",5);
        V12R E 1 Offset(10,57) A_FireCustomMissile("AKClipSpawn",25,0,8,-32);
        V12R E 10 Offset(11,58);
        Goto ReloadLoop;

    ReloadLoop:
        V12R E 3 Offset(11,58) A_CS_FillMagazine("Vepr12Loaded","_12GaugeShell",10);
        Goto ReloadFinish;

    ReloadFinish:
        V12R E 1 Offset(10,58);
        V12R E 1 Offset(10,61);
        V12R E 1 Offset(10,65) A_PlaySound("AK47/In",5);
        V12R E 1 Offset(10,71);
        V12R E 1 Offset(10,65);
        V12R E 1 Offset(10,60);
        V12R E 1 Offset(10,55);
        V12R E 1 Offset(10,53);
        V12R D 1 Offset(10,51);
        V12R C 1 Offset(9,50);
        V12R B 1 Offset(8,46);
        V12R A 1 Offset(7,43);
        V12G A 1 Offset(5,40);
        V12G A 1 Offset(3,37);
        V12G A 1 Offset(1,34);
        V12G A 1 Offset(0,32);
        Goto RealReady;

    Flash:
        TNT1 A 2 Bright A_Light2;
        TNT1 A 2 Bright A_Light1;
        TNT1 A 0 A_Light0;
        Stop;

    UseF1GrenadeState:
        V12G A 0 A_PlaySound("Vepr12/Down",8);
        V12G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowF1;
    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseF1Grenade",1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem",1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseMolotovState:
        V12G A 0 A_PlaySound("Vepr12/Down",8);
        V12G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowMolotov;
    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseMolotov",1);
        HNGR D 0 A_TakeInventory("MolotovItem",1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseInjectorState:
        V12G A 0 A_PlaySound("Vepr12/Down",8);
        V12G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto HealInjector;
    HealInjector:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
                TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_TakeInventory("StimInjectorItem", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        TNT1 A 0 { GiveBody(40); }
        TNT1 A 0 A_SpawnItemEx("StimInjectorBurst", 0, 0, 32, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;
    AfterUse:
        V12G A 0 A_PlaySound("Vepr12/Up",9);
        TNT1 A 2 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(67,100,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(32,69,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(10,47,WOF_INTERPOLATE);
        V12G A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;
    }
}

class Vepr12Loaded : Ammo
{
    Default
    {
        Inventory.MaxAmount 10;
    }
}
class Vepr12Dragon : Inventory
{
    Default { Inventory.MaxAmount 1; }
}

class Vepr12DragonBreath : FastProjectile
{
    Default
    {
        Speed 28;
        Radius 16;
        Height 16;
        +BLOODLESSIMPACT;
        ReactionTime 16;
        DamageType "Fire";
        Damage 6;
    }
    States
    {
    Spawn:
        TNT1 A 1 A_SpawnItemEx("Vepr12FlameTrail", random(-3,3), random(-3,3), random(-3,3));
        TNT1 A 0 A_Countdown;
        Loop;
    Death:
        TNT1 AAA 3 A_CustomMissile("BurnParticles", 0,0, random(0,180), 2, random(0,180));
        Stop;
    Crash:
        TNT1 A 0;
        Stop;
    }
}

class Vepr12FlameTrail : Actor
{
    Default
    {
        Radius 2;
        Height 2;
        RenderStyle "Add";
        Scale 0.4;
        Alpha 0.75;
        +NOINTERACTION;
        +CLIENTSIDEONLY;
    }
    States
    {
    Spawn:
        CFR3 ABCDEFGHIJKLMNOP 1 Bright;
        Stop;
    Death:
        TNT1 AAAAAAAAA 4 A_CustomMissile("BurnedSmoke", 1,0, random(0,360), 2, random(0,160));
        Stop;
    }
}

// ============================================================================
// 2. Mosin Nagant
// ============================================================================
class MosinNagant : ClearSkyWeapon
{
    Default
    {
        Weapon.Kickback 50;
        Weapon.AmmoType "MosinNagantLoaded";
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 10;
        Weapon.AmmoType2 "_762RAmmo";
        Weapon.AmmoUse2 1;
        Weapon.AmmoGive2 30;
        Scale 0.6;
        Tag "Mosin Nagant M-1891";
        Inventory.PickupMessage "You got the Mosin Nagant M-1891!";
        +Weapon.Ammo_Optional;
        +Weapon.Alt_Ammo_Optional;
        +Weapon.Ammo_CheckBoth;
        +Weapon.NoAutoFire;
    }

    States
    {
    Ready:
        MOSG A 0 A_PlaySound("MosinNagant/Up",9);
        MOSG A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;

    RealReady:
        MOSG A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        MOSG A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        MOSG A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        MOSG A 0 A_JumpIfInventory("MosinNagantLoaded",0,2);
        MOSG A 0 A_JumpIfInventory("_762RAmmo",1,2);
        MOSG A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;
        MOSG A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        MOSG A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        MOSG A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        MOSG A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;

    Deselect:
        MOSG A 0 A_PlaySound("MosinNagant/Down",8);
        MOSG A 3 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        MOSG A 2 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,130,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,160,WOF_INTERPOLATE);
        TNT1 A 1 A_Lower;
        Wait;

    Select:
        TNT1 A 0 A_Raise;
        Wait;

    Fire:
        MOSG A 0 A_JumpIfInventory("MosinNagantReloading",1,"ReloadFinish");
        MOSG A 0 A_JumpIfInventory("MosinNagantLoaded",1,1);
        Goto Dryfire;
        MOSF A 0 A_GunFlash;
        MOSF A 0 A_TakeInventory("MosinNagantLoaded",1);
        MOSF A 0 A_PlaySound("MosinNagant/Fire",6);
        MOSF A 0 A_FireCustomMissile("SmokeSpawner",0,0,0,2);
        MOSF A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,6);
        MOSF A 1 Bright A_ZoomFactor(0.95);
        MOSF B 1 Bright Offset(0,38) A_FireCustomMissile("MosinNagantTracer", frandom(-0.6,0.6),0,0,0,0,frandom(-0.4,0.4));
        MOSF A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,6);
        MOSG A 0 A_SetPitch(pitch-2.6);
        MOSG A 0 A_SetAngle(angle-1.4);
        MOSG A 1 Offset(0,42);
        MOSG A 0 A_ZoomFactor(1.0);
        MOSG A 0 A_SetPitch(pitch+0.2);
        MOSG A 0 A_SetAngle(angle+0.1);
        MOSG A 1 Offset(0,44);
        MOSG A 0 A_SetPitch(pitch+0.2);
        MOSG A 0 A_SetAngle(angle+0.1);
        MOSG A 1 Offset(0,43);
        MOSG A 0 A_SetPitch(pitch+0.2);
        MOSG A 0 A_SetAngle(angle+0.1);
        MOSG A 1 Offset(0,40);
        MOSG A 0 A_SetPitch(pitch+0.2);
        MOSG A 0 A_SetAngle(angle+0.1);
        MOSG A 1 Offset(0,36);
        MOSG A 0 A_SetPitch(pitch+0.2);
        MOSG A 0 A_SetAngle(angle+0.1);
        MOSG A 1 Offset(0,32);
        MOSG A 0 A_SetPitch(pitch+0.2);
        MOSG A 0 A_SetAngle(angle+0.1);
        MOSG A 1;
        MOSG A 0 A_SetPitch(pitch+0.2);
        MOSG A 0 A_SetAngle(angle+0.1);
        MOSG A 0 A_SetPitch(pitch+0.2);
        MOSG A 0 A_SetAngle(angle+0.1);
        MOSG A 1;
        MOSG A 0 A_SetPitch(pitch+0.2);
        MOSG A 0 A_SetAngle(angle+0.1);
        MOSG A 1;
        MOSG A 0 A_SetPitch(pitch+0.2);
        MOSG A 0 A_SetAngle(angle+0.1);
        MOSG A 1;
        MOSG A 0 A_SetPitch(pitch+0.2);
        MOSG A 0 A_SetAngle(angle+0.1);
        MOSG A 1;
        MOSG A 0 A_SetPitch(pitch+0.2);
        MOSG A 0 A_SetAngle(angle+0.1);
        MOSG A 1;
        MOSG A 0 A_SetPitch(pitch+0.2);
        MOSG A 0 A_SetAngle(angle+0.1);
        MOSG A 1 Offset(-2,33) A_PlaySound("MosinNagant/Open",5);
        MOSG B 1 Offset(-4,34);
        MOSG C 1 Offset(-6,35) A_FireCustomMissile("RifleCasingSpawn",5,0,6,-14);
        MOSG D 2 Offset(-8,36);
        MOSG D 2 Offset(-4,42);
        MOSG E 1 Offset(0,51);
        MOSG E 1 Offset(4,60);
        MOSG E 2 Offset(5,74);
        MOSG E 3 Offset(6,76);
        MOSG E 2 Offset(5,74) A_PlaySound("MosinNagant/Close",5);
        MOSG D 1 Offset(4,60);
        MOSG C 1 Offset(0,51);
        MOSG B 1 Offset(-4,42);
        MOSG A 2 Offset(-8,36);
        MOSG A 1 Offset(-6,35);
        MOSG A 1 Offset(-4,34);
        MOSG A 1 Offset(-2,33);
        Goto RealReady;

    Spawn:
        MOSP A -1;
        Stop;

    Dryfire:
        MOSG A 0 A_JumpIfInventory("_762RAmmo",1,"Reload");
        MOSG A 0 A_PlaySound("MosinNagant/Dryfire",7);
        Goto RealReady;

    Reload:
        MOSG A 0 A_JumpIfInventory("MosinNagantLoaded",10,2);
        MOSG A 0 A_JumpIfNoAmmo(1);
        Goto ProperReload;
        MOSG A 1;
        Goto RealReady;

    ProperReload:
        MOSG A 1 Offset(-4,34) A_GiveInventory("MosinNagantReloading",1);
        MOSG A 1 Offset(-6,35);
        MOSG A 2 Offset(-8,36);
        MOSG A 2 Offset(-4,42);
        MOSG A 1 Offset(0,51);
        MOSG A 1 Offset(4,60);
        MOSG A 2 Offset(5,74);
        MOSG A 3 Offset(6,76);
        Goto ReloadLoop;

    ReloadLoop:
        MOSG A 0 A_TakeInventory("_762RAmmo",1,TIF_NOTAKEINFINITE);
        MOSG A 0 A_GiveInventory("MosinNagantLoaded");
        MOSG A 1 Offset(6,80) A_PlaySound("MosinNagant/Load",5);
        MOSG A 1 Offset(6,84);
        MOSG A 1 Offset(6,87);
        MOSG A 1 Offset(7,90);
        MOSG A 1 Offset(8,92);
        MOSG A 5 Offset(8,92);
        MOSG A 1 Offset(9,88) A_WeaponReady(WRF_NOBOB|WRF_NOSECONDARY|WRF_NOSWITCH);
        MOSG A 1 Offset(8,82) A_WeaponReady(WRF_NOBOB|WRF_NOSECONDARY|WRF_NOSWITCH);
        MOSG A 1 Offset(7,77) A_WeaponReady(WRF_NOBOB|WRF_NOSECONDARY|WRF_NOSWITCH);
        TNT1 A 0 A_JumpIfInventory("MosinNagantLoaded",10,"ReloadFinish");
        TNT1 A 0 A_JumpIfInventory("_762RAmmo",1,"ReloadLoop");
        Goto ReloadFinish;

    ReloadFinish:
        MOSG A 1 Offset(4,60);
        MOSG A 1 Offset(0,51);
        MOSG A 1 Offset(-4,42);
        MOSG A 2 Offset(-8,36);
        MOSG A 1 Offset(-6,35);
        MOSG A 1 Offset(-4,34);
        MOSG A 2 Offset(-2,33) A_TakeInventory("MosinNagantReloading",1);
        Goto RealReady;

    Flash:
        TNT1 A 3 A_Light2;
        TNT1 A 3 A_Light1;
        TNT1 A 0 A_Light0;
        Goto LightDone;

    UseF1GrenadeState:
        MOSG A 0 A_PlaySound("MosinNagant/Down",8);
        MOSG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowF1;
    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseF1Grenade",1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem",1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseMolotovState:
        MOSG A 0 A_PlaySound("MosinNagant/Down",8);
        MOSG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowMolotov;
    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseMolotov",1);
        HNGR D 0 A_TakeInventory("MolotovItem",1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseInjectorState:
        MOSG A 0 A_PlaySound("MosinNagant/Down",8);
        MOSG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto HealInjector;
    HealInjector:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
                TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_TakeInventory("StimInjectorItem", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        TNT1 A 0 { GiveBody(40); }
        TNT1 A 0 A_SpawnItemEx("StimInjectorBurst", 0, 0, 32, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;
    AfterUse:
        MOSG A 0 A_PlaySound("MosinNagant/Up",9);
        TNT1 A 2 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(67,100,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(32,69,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(10,47,WOF_INTERPOLATE);
        MOSG A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;
    }
}

class MosinNagantLoaded : Ammo
{
    Default
    {
        Inventory.MaxAmount 10;
    }
}
class MosinNagantReloading : Inventory
{
    Default { Inventory.MaxAmount 1; }
}

// ============================================================================
// 3. RP-46
// ============================================================================
class RP46 : ClearSkyWeapon
{
    Default
    {
        Weapon.Kickback 60;
        Weapon.AmmoType "RP46Loaded";
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 47;
        Weapon.AmmoType2 "_762RAmmo";
        Weapon.AmmoUse2 0;
        Weapon.AmmoGive2 30;
        Scale 0.6;
        Tag "RP-46";
        Inventory.PickupMessage "You got the RP-46!";
        +Weapon.Ammo_Optional;
        +Weapon.Alt_Ammo_Optional;
        +Weapon.Ammo_CheckBoth;
        +Weapon.NoAutoFire;
    }

    States
    {
    Ready:
        RP4G A 0 A_PlaySound("RP46/Up",9);
        RP4G A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;

    RealReady:
        RP4G A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        RP4G A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        RP4G A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        RP4G A 0 A_JumpIfInventory("RP46Loaded",0,2);
        RP4G A 0 A_JumpIfInventory("_762RAmmo",1,2);
        RP4G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;
        RP4G A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        RP4G A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        RP4G A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        RP4G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;

    Deselect:
        RP4G A 0 A_PlaySound("RP46/Down",8);
        RP4G A 4 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        RP4G A 3 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        RP4G A 2 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,130,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,160,WOF_INTERPOLATE);
        TNT1 A 1 A_Lower;
        Wait;

    Select:
        TNT1 A 0 A_Raise;
        Wait;

    Fire:
        RP4G A 0 A_JumpIfInventory("RP46Loaded",1,1);
        Goto Dryfire;
        RP4F A 0 A_GunFlash;
        RP4F A 0 A_TakeInventory("RP46Loaded",1);
        RP4F A 0 A_PlaySound("RP46/Fire",6);
        RP4F A 0 A_FireCustomMissile("AutomaticSmokeSpawnerSmall", frandom(-4, 4), 0, 4, -1, 0, frandom(-4, 4));
        RP4F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        RP4F A 1 Bright A_ZoomFactor(0.95);
        RP4F B 1 Bright Offset(0,38) A_FireCustomMissile("RP46Tracer", frandom(-2.5,2.5),1,0,0,0,frandom(-1.0,1.0));
        RP4F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        RP4G A 0 A_SetPitch(pitch-2.0);
        RP4G A 0 A_SetAngle(angle-0.6);
        RP4G A 1 Offset(0,37) A_FireCustomMissile("RifleCasingSpawn",0,0,2,-2);
        RP4G A 0 A_SetPitch(pitch-0.8);
        RP4G A 0 A_SetAngle(angle-0.4);
        RP4G A 0 A_ZoomFactor(1.0);
        RP4G A 1 Offset(0,35);
        RP4G A 1 Offset(0,33) A_Refire;
        Goto RealReady;

    Dryfire:
        RP4G A 0 A_JumpIfInventory("_762RAmmo",1,"Reload");
        RP4G A 0 A_PlaySound("RP46/Dryfire",7);
        Goto RealReady;

    Reload:
        RP4G A 0 A_JumpIfInventory("RP46Loaded",47,2);
        RP4G A 0 A_JumpIfNoAmmo(1);
        Goto ProperReload;
        RP4G A 1;
        Goto RealReady;

    ProperReload:
        RP4G A 1 Offset(0,35);
        RP4R A 1 Offset(2,38);
        RP4R B 1 Offset(4,44);
        RP4R C 1 Offset(6,52);
        RP4R D 1 Offset(7,57);
        RP4R E 1 Offset(8,62);
        RP4R F 1 Offset(9,67);
        RP4R G 1 Offset(10,72);
        RP4R H 1 Offset(11,77);
        RP4R I 1 Offset(11,80);
        RP4R J 1 Offset(12,82);
        RP4R K 1 Offset(12,84) A_PlaySound("RP46/Out",5);
        RP4R L 1 Offset(13,86);
        RP4R M 1 Offset(13,87);
        RP4R N 1 Offset(14,88) A_FireCustomMissile("EmptyPPShDrumSpawn",25,0,8,-32);
        RP4R O 18 Offset(14,89);
        Goto ReloadLoop;

    ReloadLoop:
        RP4R O 3 Offset(14,89) A_CS_FillMagazine("RP46Loaded","_762RAmmo",47);
        Goto ReloadFinish;

    ReloadFinish:
        RP4R N 1 Offset(10,96);
        RP4R M 1 Offset(6,100);
        RP4R L 1 Offset(7,90);
        RP4R K 1 Offset(6,80) A_PlaySound("RP46/In",5);
        RP4R J 1 Offset(4,70);
        RP4R I 1 Offset(2,60);
        RP4R H 1 Offset(0,50);
        RP4R G 1 Offset(0,40);
        RP4R F 1 Offset(0,32);
        RP4R E 1 Offset(0,32);
        RP4R DCBA 1;
        RP4G A 1;
        Goto RealReady;

    Flash:
        TNT1 A 2 Bright A_Light2;
        TNT1 A 2 Bright A_Light1;
        TNT1 A 0 A_Light0;
        Stop;

    Spawn:
        RP4P A -1;
        Stop;

    UseF1GrenadeState:
        RP4G A 0 A_PlaySound("RP46/Down",8);
        RP4G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowF1;
    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseF1Grenade",1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem",1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseMolotovState:
        RP4G A 0 A_PlaySound("RP46/Down",8);
        RP4G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowMolotov;
    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseMolotov",1);
        HNGR D 0 A_TakeInventory("MolotovItem",1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseInjectorState:
        RP4G A 0 A_PlaySound("RP46/Down",8);
        RP4G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto HealInjector;
    HealInjector:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
                TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_TakeInventory("StimInjectorItem", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        TNT1 A 0 { GiveBody(40); }
        TNT1 A 0 A_SpawnItemEx("StimInjectorBurst", 0, 0, 32, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;
    AfterUse:
        RP4G A 0 A_PlaySound("RP46/Up",9);
        TNT1 A 2 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(67,100,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(32,69,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(10,47,WOF_INTERPOLATE);
        RP4G A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;
    }
}

class RP46Loaded : Ammo
{
    Default
    {
        Inventory.MaxAmount 47;
    }
}

// ============================================================================
// 4. SVD Dragunov
// ============================================================================
class SVD : ClearSkyWeapon
{
    Default
    {
        Weapon.Kickback 60;
        Weapon.AmmoType "SVDLoaded";
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 10;
        Weapon.AmmoType2 "_762RAmmo";
        Weapon.AmmoUse2 0;
        Weapon.AmmoGive2 30;
        Decal "BulletChip";
        Scale 0.7;
        Tag "SVD Dragunov";
        Inventory.PickupMessage "You got the SVD Dragunov!";
        +Weapon.Ammo_Optional;
        +Weapon.Alt_Ammo_Optional;
        +Weapon.Ammo_CheckBoth;
        +Weapon.NoAutoFire;
    }

    States
    {
    Ready:
        SVDG A 0 A_PlaySound("SVD/Up",9);
        SVDG A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;

    RealReady:
        SVDG A 0 A_JumpIfInventory("SVDZoom",1,"ScopedReady");
        SVDG A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        SVDG A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        SVDG A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        SVDG A 0 A_JumpIfInventory("SVDLoaded",0,2);
        SVDG A 0 A_JumpIfInventory("_762RAmmo",1,2);
        SVDG A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;
        SVDG A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        SVDG A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        SVDG A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        SVDG A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;

    ScopedReady:
        SVDZ A 0 A_JumpIfInventory("SVDLoaded",0,2);
        SVDZ A 0 A_JumpIfInventory("_762RAmmo",1,2);
        SVDZ A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;
        SVDZ A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;

    Deselect:
        SVDG A 0 A_JumpIfInventory("SVDZoom",1,"ScopedDeselect");
        SVDG A 0 A_PlaySound("SVD/Down",8);
        SVDG A 3 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        SVDG A 2 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,130,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,160,WOF_INTERPOLATE);
        TNT1 A 1 A_Lower;
        Wait;

    ScopedDeselect:
        SVDZ A 0 A_TakeInventory("SVDZoom");
        SVDZ A 15 A_ZoomFactor(1.0);
        Goto Deselect;

    Select:
        SVDG A 0 A_Raise;
        Wait;

    Fire:
        SVDG A 0 A_JumpIfInventory("SVDLoaded",1,1);
        Goto Dryfire;
        SVDF A 0 A_JumpIfInventory("SVDZoom",1,"ScopedFire");
        SVDF A 0 A_GunFlash;
        SVDF A 0 A_TakeInventory("SVDLoaded",1);
        SVDF A 0 A_PlaySound("SVD/Fire",6);
        SVDF A 0 A_FireCustomMissile("SmokeSpawner",0,0,0,2);
        SVDF A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,6);
        SVDF A 1 Bright A_ZoomFactor(0.95);
        SVDF B 1 Bright Offset(0,38) A_FireCustomMissile("SVDTracer", frandom(-2.5,2.5),1,0,0,0,frandom(-1.0,1.0));
        SVDF A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,6);
        SVDG A 0 A_SetPitch(pitch-2.6);
        SVDG A 0 A_SetAngle(angle-1.4);
        SVDG B 1 Offset(0,42) A_FireCustomMissile("RifleCasingSpawn",0,0,2,-2);
        SVDG A 0 A_ZoomFactor(1.0);
        SVDG A 0 A_SetPitch(pitch+0.2);
        SVDG A 0 A_SetAngle(angle+0.1);
        SVDG B 1 Offset(0,44);
        SVDG A 0 A_SetPitch(pitch+0.2);
        SVDG A 0 A_SetAngle(angle+0.1);
        SVDG A 1 Offset(0,43);
        SVDG A 0 A_SetPitch(pitch+0.2);
        SVDG A 0 A_SetAngle(angle+0.1);
        SVDG A 1 Offset(0,40);
        SVDG A 0 A_SetPitch(pitch+0.2);
        SVDG A 0 A_SetAngle(angle+0.1);
        SVDG A 1 Offset(0,36);
        SVDG A 0 A_SetPitch(pitch+0.2);
        SVDG A 0 A_SetAngle(angle+0.1);
        SVDG A 1 Offset(0,32);
        SVDG A 0 A_SetPitch(pitch+0.2);
        SVDG A 0 A_SetAngle(angle+0.1);
        SVDG A 1;
        SVDG A 0 A_SetPitch(pitch+0.2);
        SVDG A 0 A_SetAngle(angle+0.1);
        SVDG A 0 A_SetPitch(pitch+0.2);
        SVDG A 0 A_SetAngle(angle+0.1);
        SVDG A 1;
        SVDG A 0 A_SetPitch(pitch+0.2);
        SVDG A 0 A_SetAngle(angle+0.1);
        SVDG A 1;
        SVDG A 0 A_SetPitch(pitch+0.2);
        SVDG A 0 A_SetAngle(angle+0.1);
        SVDG A 1;
        SVDG A 0 A_SetPitch(pitch+0.2);
        SVDG A 0 A_SetAngle(angle+0.1);
        SVDG A 1;
        SVDG A 0 A_SetPitch(pitch+0.2);
        SVDG A 0 A_SetAngle(angle+0.1);
        SVDG A 1;
        SVDG A 0 A_SetPitch(pitch+0.2);
        SVDG A 0 A_SetAngle(angle+0.1);
        SVDG A 1;
        SVDG A 5;
        Goto RealReady;

    ScopedFire:
        SVDZ A 0 A_JumpIfInventory("SVDLoaded",1,1);
        Goto Dryfire;
        SVDZ A 0 A_GunFlash;
        SVDZ A 0 A_TakeInventory("SVDLoaded",1);
        SVDZ A 0 A_PlaySound("SVD/Fire",6);
        SVDZ A 0 A_FireCustomMissile("SmokeSpawner",0,0,0,2);
        SVDZ A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        SVDZ A 1 Bright A_FireCustomMissile("SVDTracer", frandom(-1,1),0);
        SVDZ A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        SVDZ A 0 A_SetPitch(pitch-2.6);
        SVDZ A 0 A_SetAngle(angle-1.4);
        SVDZ A 1 A_FireCustomMissile("RifleCasingSpawn",0,0,2,-2);
        SVDZ A 0 A_SetPitch(pitch+0.2);
        SVDZ A 0 A_SetAngle(angle+0.1);
        SVDZ A 1;
        SVDZ A 0 A_SetPitch(pitch+0.2);
        SVDZ A 0 A_SetAngle(angle+0.1);
        SVDZ A 1;
        SVDZ A 0 A_SetPitch(pitch+0.2);
        SVDZ A 0 A_SetAngle(angle+0.1);
        SVDZ A 1;
        SVDZ A 0 A_SetPitch(pitch+0.2);
        SVDZ A 0 A_SetAngle(angle+0.1);
        SVDZ A 1;
        SVDZ A 0 A_SetPitch(pitch+0.2);
        SVDZ A 0 A_SetAngle(angle+0.1);
        SVDZ A 1;
        SVDZ A 0 A_SetPitch(pitch+0.2);
        SVDZ A 0 A_SetAngle(angle+0.1);
        SVDZ A 1;
        SVDZ A 0 A_SetPitch(pitch+0.2);
        SVDZ A 0 A_SetAngle(angle+0.1);
        SVDZ A 0 A_SetPitch(pitch+0.2);
        SVDZ A 0 A_SetAngle(angle+0.1);
        SVDZ A 1;
        SVDZ A 0 A_SetPitch(pitch+0.2);
        SVDZ A 0 A_SetAngle(angle+0.1);
        SVDZ A 1;
        SVDZ A 0 A_SetPitch(pitch+0.2);
        SVDZ A 0 A_SetAngle(angle+0.1);
        SVDZ A 1;
        SVDZ A 0 A_SetPitch(pitch+0.2);
        SVDZ A 0 A_SetAngle(angle+0.1);
        SVDZ A 1;
        SVDZ A 0 A_SetPitch(pitch+0.2);
        SVDZ A 0 A_SetAngle(angle+0.1);
        SVDZ A 1;
        SVDZ A 0 A_SetPitch(pitch+0.2);
        SVDZ A 0 A_SetAngle(angle+0.1);
        SVDZ A 1;
        SVDZ A 5;
        Goto RealReady;

    AltFire:
        SVDZ A 0 A_JumpIfInventory("SVDZoom",1,"ZoomOut");
        SVDZ A 0 A_GiveInventory("SVDZoom");
        SVDZ A 15 A_ZoomFactor(8.0);
        Goto RealReady;
    ZoomOut:
        SVDZ A 0 A_TakeInventory("SVDZoom");
        SVDZ A 15 A_ZoomFactor(1.0);
        Goto RealReady;

    Spawn:
        SVDP A -1;
        Stop;

    Dryfire:
        SVDG A 0 A_JumpIfInventory("SVDZoom",1,"ScopedDryFire");
        SVDG A 0 A_JumpIfInventory("_762RAmmo",1,"Reload");
        SVDG A 0 A_PlaySound("SVD/Dryfire",7);
        Goto RealReady;
    ScopedDryFire:
        SVDZ A 0 A_JumpIfInventory("_762RAmmo",1,"Reload");
        SVDZ A 0 A_PlaySound("SVD/Dryfire",7);
        Goto RealReady;

    Reload:
        SVDG A 0 A_JumpIfInventory("SVDLoaded",10,2);
        SVDG A 0 A_JumpIfNoAmmo(1);
        Goto ProperReload;
        SVDG A 1;
        Goto Ready;

    ProperReload:
        SVDG A 1 Offset(0,35);
        SVDR A 1 Offset(0,38);
        SVDR B 1 Offset(0,44);
        SVDR C 1 Offset(2,46);
        SVDR D 1 Offset(4,52);
        SVDR E 1 Offset(7,56) A_PlaySound("SVD/Out",5);
        SVDR E 1 Offset(10,57) A_FireCustomMissile("RifleClipSpawn",25,0,8,-32);
        SVDR E 16 Offset(11,58);
        Goto ReloadLoop;

    ReloadLoop:
        SVDR E 3 Offset(11,58) A_CS_FillMagazine("SVDLoaded","_762RAmmo",10);
        Goto ReloadFinish;

    ReloadFinish:
        SVDR E 1 Offset(10,58);
        SVDR E 1 Offset(10,61);
        SVDR E 1 Offset(10,65) A_PlaySound("SVD/In",5);
        SVDR E 1 Offset(10,71);
        SVDR E 1 Offset(10,65);
        SVDR E 1 Offset(10,60);
        SVDR E 1 Offset(10,55);
        SVDR E 1 Offset(10,53);
        SVDR D 1 Offset(10,51);
        SVDR C 1 Offset(9,50);
        SVDR B 1 Offset(8,46);
        SVDR A 1 Offset(7,43);
        SVDG A 1 Offset(5,40);
        SVDG A 1 Offset(3,37);
        SVDG A 1 Offset(1,34);
        SVDG A 1 Offset(0,32);
        Goto RealReady;

    Flash:
        TNT1 A 2 Bright A_Light2;
        TNT1 A 2 Bright A_Light1;
        TNT1 A 0 A_Light0;
        Stop;

    UseF1GrenadeState:
        SVDG A 0 A_PlaySound("SVD/Down",8);
        SVDG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowF1;
    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseF1Grenade",1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem",1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseMolotovState:
        SVDG A 0 A_PlaySound("SVD/Down",8);
        SVDG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowMolotov;
    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseMolotov",1);
        HNGR D 0 A_TakeInventory("MolotovItem",1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseInjectorState:
        SVDG A 0 A_PlaySound("SVD/Down",8);
        SVDG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto HealInjector;
    HealInjector:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
                TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_TakeInventory("StimInjectorItem", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        TNT1 A 0 { GiveBody(40); }
        TNT1 A 0 A_SpawnItemEx("StimInjectorBurst", 0, 0, 32, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;
    AfterUse:
        SVDG A 0 A_PlaySound("SVD/Up",9);
        TNT1 A 2 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(67,100,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(32,69,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(10,47,WOF_INTERPOLATE);
        SVDG A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;
    }
}

class SVDZoom : Inventory { Default { Inventory.MaxAmount 1; } }
class SVDLoaded : Ammo
{
    Default
    {
        Inventory.MaxAmount 10;
    }
}

// ============================================================================
// 5. TOZ-34
// ============================================================================
class TOZ34 : ClearSkyWeapon
{
    Default
    {
        Weapon.Kickback 50;
        Weapon.AmmoType "TOZ34Loaded";
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 2;
        Weapon.AmmoType2 "_12GaugeShell";
        Weapon.AmmoUse2 1;
        Weapon.AmmoGive2 30;
        Tag "TOZ-34";
        Inventory.PickupMessage "You got the TOZ-34!";
        +Weapon.Ammo_Optional;
        +Weapon.Alt_Ammo_Optional;
        +Weapon.Ammo_CheckBoth;
        +Weapon.NoAutoFire;
    }

    States
    {
    Ready:
        T34G A 0 A_PlaySound("TOZ34/Up",9);
        T34G A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;

    RealReady:
        T34G A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        T34G A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        T34G A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        T34G A 0 A_JumpIfInventory("TOZ34Loaded",0,2);
        T34G A 0 A_JumpIfInventory("_12GaugeShell",1,2);
        T34G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;
        T34G A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        T34G A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        T34G A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        T34G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;

    Deselect:
        T34G A 0 A_PlaySound("TOZ34/Down",8);
        T34G A 3 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        T34G A 2 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,130,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,160,WOF_INTERPOLATE);
        TNT1 A 1 A_Lower;
        Wait;

    Select:
        TNT1 A 0 A_Raise;
        Wait;

    Fire:
        T34G A 0 A_JumpIfInventory("TOZ34Loaded",1,1);
        Goto Dryfire;
        T34G A 3;
        T34G A 0 A_GunFlash;
        T34G A 0 A_TakeInventory("TOZ34Loaded",2);
        T34G A 0 A_PlaySound("TOZ34/Fire",6);
        T34G A 0 A_FireCustomMissile("SmokeSpawner", frandom(-5, 5), 0, 7, 0, 0, frandom(-5, 5));
        T34G A 0 A_FireCustomMissile("SmokeSpawnerSmall", frandom(-5, 5), 0, 5, -10, 0, frandom(-5, 5));
        T34G A 0 A_FireCustomMissile("SmokeSpawnerSmall", frandom(-5, 5), 0, 20, -5, 0, frandom(-5, 5));
        T34G A 0 A_FireCustomMissile("SmokeSpawnerSmall", frandom(-5, 5), 0, -9, -12, 0, frandom(-5, 5));
        T34G A 0 A_FireCustomMissile("SmokeSpawnerSmall", frandom(-5, 5), 0, 26, 0, 0, frandom(-5, 5));
        T34G AAAAAAAAAAAAAAAAAAAA 0 Bright A_FireCustomMissile("ShotgunParticles", random(-19,19),0,-1,0,0,random(-9,9));
        T34G AAAAAAAAAAAAA 0 Bright A_FireCustomMissile("ShotgunParticles2", random(-19,19),0,-1,0,0,random(-9,9));
        T34G BBBBBBBBBBBBBBBBBBBB 0 A_FireCustomMissile("ShotgunTracer", random(-6,6),0,-1,-12,0,random(-5,5));
        T34F A 0 A_ZoomFactor(0.75);
        T34G A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        T34F B 1 Bright Offset(0,44) A_SetPitch(pitch-4);
        T34G A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        T34G A 1 Offset(0,43) A_SetPitch(pitch+2.6);
        T34G A 0 A_ZoomFactor(1.0);
        T34G A 1 Offset(0,40) A_SetPitch(pitch+1.2);
        T34G A 1 Offset(0,36) A_SetPitch(pitch+0.8);
        T34G A 1 Offset(0,32) A_SetPitch(pitch+0.4);
        T34G A 3 A_WeaponReady(WRF_NOFIRE|WRF_NOBOB);
        Goto RealReady;

    Dryfire:
        T34G A 0 A_JumpIfInventory("_12GaugeShell",1,"Reload");
        T34G A 0 A_PlaySound("TOZ34/Dryfire",7);
        Goto RealReady;

    Reload:
        T34G A 0 A_JumpIfInventory("TOZ34Loaded",2,2);
        T34G A 0 A_JumpIfNoAmmo(1);
        Goto ProperReload;
        T34G A 1;
        Goto RealReady;

    ProperReload:
        T34G A 1 Offset(-4,34) A_PlaySound("TOZ34/Open",5);
        T34G AA 0 A_FireCustomMissile("TOZ34CasingSpawn",0,0,-10);
        T34G A 1 Offset(-6,35);
        T34G A 1 Offset(-8,36);
        T34R A 1 Offset(-4,42);
        T34R A 1 Offset(0,51);
        T34R B 1 Offset(4,60);
        T34R B 1 Offset(5,74);
        T34R C 1 Offset(6,76);
        Goto ReloadLoop;

    ReloadLoop:
        T34G C 0 A_TakeInventory("_12GaugeShell",1,TIF_NOTAKEINFINITE);
        T34G C 0 A_GiveInventory("TOZ34Loaded");
        T34G C 1 Offset(6,80) A_PlaySound("TOZ34/Load",5);
        T34G C 1 Offset(6,84);
        T34G C 1 Offset(6,87);
        T34G C 1 Offset(7,90);
        T34G C 1 Offset(8,92);
        T34G C 5 Offset(8,92);
        T34G C 1 Offset(9,88);
        T34G C 1 Offset(8,82);
        T34G C 1 Offset(7,77);
        TNT1 A 0 A_JumpIfInventory("TOZ34Loaded",2,"ReloadFinish");
        TNT1 A 0 A_JumpIfInventory("_12GaugeShell",1,"ReloadLoop");
        Goto ReloadFinish;

    ReloadFinish:
        T34R D 1 Offset(4,60) A_PlaySound("TOZ34/Close",5);
        T34R D 1 Offset(0,51);
        T34R D 1 Offset(-4,42);
        T34R E 1 Offset(-8,36);
        T34R E 1 Offset(-6,35);
        T34R A 1 Offset(-4,34);
        T34R A 1 Offset(-2,33);
        Goto RealReady;

    Flash:
        TNT1 A 4 Bright A_Light1;
        TNT1 A 3 Bright A_Light2;
        Goto LightDone;

    Spawn:
        T34P A -1;
        Stop;

    UseF1GrenadeState:
        T34G A 0 A_PlaySound("TOZ34/Down",8);
        T34G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowF1;
    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseF1Grenade",1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem",1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseMolotovState:
        T34G A 0 A_PlaySound("TOZ34/Down",8);
        T34G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowMolotov;
    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseMolotov",1);
        HNGR D 0 A_TakeInventory("MolotovItem",1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseInjectorState:
        T34G A 0 A_PlaySound("TOZ34/Down",8);
        T34G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto HealInjector;
    HealInjector:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
                TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_TakeInventory("StimInjectorItem", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        TNT1 A 0 { GiveBody(40); }
        TNT1 A 0 A_SpawnItemEx("StimInjectorBurst", 0, 0, 32, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;
    AfterUse:
        T34G A 0 A_PlaySound("TOZ34/Up",9);
        TNT1 A 2 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(67,100,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(32,69,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(10,47,WOF_INTERPOLATE);
        T34G A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;
    }
}

class TOZ34Loaded : Ammo
{
    Default
    {
        Inventory.MaxAmount 2;
    }
}

// ============================================================================
// 6. KS-23
// ============================================================================
class KS23 : ClearSkyWeapon
{
    Default
    {
        Weapon.Kickback 50;
        Weapon.AmmoType "KS23Loaded";
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 4;
        Weapon.AmmoType2 "_23RAmmo";
        Weapon.AmmoUse2 1;
        Weapon.AmmoGive2 30;
        Tag "KS-23";
        Inventory.PickupMessage "You got the KS-23!";
        +Weapon.Ammo_Optional;
        +Weapon.Alt_Ammo_Optional;
        +Weapon.Ammo_CheckBoth;
        +Weapon.NoAutoFire;
    }

    States
    {
    Ready:
        K23G A 0 A_PlaySound("KS23/Up",9);
        K23G A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;

    RealReady:
        K23G A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        K23G A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        K23G A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        K23G A 0 A_JumpIfInventory("KS23Loaded",0,2);
        K23G A 0 A_JumpIfInventory("_23RAmmo",1,2);
        K23G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;
        K23G A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        K23G A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        K23G A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        K23G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;

    Deselect:
        K23G A 0 A_PlaySound("KS23/Down",8);
        K23G A 3 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        K23G A 2 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,130,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,160,WOF_INTERPOLATE);
        TNT1 A 1 A_Lower;
        Wait;

    Select:
        TNT1 A 0 A_Raise;
        Wait;

    Fire:
        K23G A 0 A_JumpIfInventory("KS23Reloading",1,"ReloadFinish");
        K23G A 0 A_JumpIfInventory("KS23Loaded",1,1);
        Goto Dryfire;
        K23G A 0 A_FireCustomMissile("SmokeSpawner", frandom(-5, 5), 0, 7, 0, 0, frandom(-5, 5));
        K23G A 0 A_FireCustomMissile("SmokeSpawnerSmall", frandom(-5, 5), 0, 5, -10, 0, frandom(-5, 5));
        K23G A 0 A_FireCustomMissile("SmokeSpawnerSmall", frandom(-5, 5), 0, 20, -5, 0, frandom(-5, 5));
        K23G A 0 A_FireCustomMissile("SmokeSpawnerSmall", frandom(-5, 5), 0, -9, -12, 0, frandom(-5, 5));
        K23G A 0 A_FireCustomMissile("SmokeSpawnerSmall", frandom(-5, 5), 0, 26, 0, 0, frandom(-5, 5));
        K23G A 0 A_GunFlash;
        K23G A 0 A_PlaySound("KS23/Fire",6);
        K23G A 0 A_TakeInventory("KS23Loaded",1);
        K23G A 0 A_ZoomFactor(0.95);
        K23G AAAAAAAAAAAAAAAA 0 Bright A_FireCustomMissile("ShotgunParticles", random(-12,12),0,-1,0,0,random(-9,9));
        K23G AAAAAAAAAAAAA 0 Bright A_FireCustomMissile("ShotgunParticles2", random(-19,19),0,-1,0,0,random(-9,9));
        K23G AAAAAAAA 0 A_FireCustomMissile("KS23Tracer", frandom(-2.0,2.0),0,0,0,0,frandom(-1.5,1.5));
        K23G A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,7);
        K23F A 1 Bright Offset(0,38);
        K23F B 1 Bright Offset(0,44);
        K23G A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,7);
        K23G A 0 A_SetPitch(-8.0 + pitch);
        K23G A 0 A_ZoomFactor(1.0);
        K23G A 1 Offset(0,43) A_SetPitch(+3.0 + pitch);
        K23G A 1 Offset(0,40) A_SetPitch(+1.0 + pitch);
        K23G A 1 Offset(0,36) A_SetPitch(+1.0 + pitch);
        K23G A 1 Offset(0,32) A_SetPitch(+1.0 + pitch);
        K23G A 1 A_SetPitch(+1.0 + pitch);
        K23G A 6;
        K23G BCDEFGG 1;
        K23G A 0 A_FireCustomMissile("KS23CasingSpawn",0,0,-4,-4);
        K23G A 0 A_PlaySound("KS23/Pump",4);
        K23G HHIIIHHGGFEDCB 1;
        K23G A 3;
        Goto RealReady;

    Spawn:
        K23P A -1;
        Stop;

    Dryfire:
        K23G A 0 A_JumpIfInventory("_23RAmmo",1,"Reload");
        K23G A 0 A_PlaySound("KS23/Dryfire",7);
        Goto RealReady;

    Reload:
        K23G A 0 A_JumpIfInventory("KS23Loaded",4,2);
        K23G A 0 A_JumpIfNoAmmo(1);
        Goto ProperReload;
        K23G A 1;
        Goto RealReady;

    ProperReload:
        K23G A 1 A_GiveInventory("KS23Reloading",1);
        K23G BCDEF 1;
        Goto ReloadLoop;

    ReloadLoop:
        K23G G 1 A_TakeInventory("_23RAmmo",1);
        K23G G 0 A_PlaySound("KS23/Reload",4);
        K23G G 0 A_GiveInventory("KS23Loaded",1);
        K23G G 1 Offset(-8,58);
        K23G G 1 Offset(-9,64);
        K23G G 1 Offset(-10,70);
        K23G G 1 Offset(-10,68);
        K23G G 1 Offset(-9,66);
        K23G G 1 Offset(-9,64);
        K23G G 1 Offset(-9,62);
        K23G G 1 Offset(-8,61);
        K23G G 1 Offset(-8,60) A_WeaponReady(WRF_NOBOB|WRF_NOSECONDARY|WRF_NOSWITCH);
        K23G G 2 Offset(-8,59) A_WeaponReady(WRF_NOBOB|WRF_NOSECONDARY|WRF_NOSWITCH);
        K23G G 3 Offset(-8,58) A_WeaponReady(WRF_NOBOB|WRF_NOSECONDARY|WRF_NOSWITCH);
        K23G G 0 A_JumpIfInventory("KS23Loaded",4,"ReloadFinish");
        K23G G 0 A_JumpIfInventory("_23RAmmo",1,"ReloadLoop");
        Goto ReloadFinish;

    ReloadFinish:
        K23G A 0 A_PlaySound("KS23/Pump",4);
        K23G HHIIIHHGGFEDCB 1;
        K23G A 1 A_TakeInventory("KS23Reloading",1);
        Goto RealReady;

    Flash:
        TNT1 A 2 Bright A_Light2;
        TNT1 A 2 Bright A_Light1;
        TNT1 A 0 A_Light0;
        Stop;

    UseF1GrenadeState:
        K23G A 0 A_PlaySound("KS23/Down",8);
        K23G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowF1;
    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseF1Grenade",1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem",1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseMolotovState:
        K23G A 0 A_PlaySound("KS23/Down",8);
        K23G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowMolotov;
    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseMolotov",1);
        HNGR D 0 A_TakeInventory("MolotovItem",1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseInjectorState:
        K23G A 0 A_PlaySound("KS23/Down",8);
        K23G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto HealInjector;
    HealInjector:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
                TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_TakeInventory("StimInjectorItem", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        TNT1 A 0 { GiveBody(40); }
        TNT1 A 0 A_SpawnItemEx("StimInjectorBurst", 0, 0, 32, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;
    AfterUse:
        K23G A 0 A_PlaySound("KS23/Up",9);
        TNT1 A 2 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(67,100,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(32,69,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(10,47,WOF_INTERPOLATE);
        K23G A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;
    }
}

class KS23Loaded : Ammo
{
    Default
    {
        Inventory.MaxAmount 4;
    }
}
class KS23Reloading : Inventory
{
    Default { Inventory.MaxAmount 1; }
}

// ============================================================================
// 7. AK-47
// ============================================================================
class AK47 : ClearSkyWeapon
{
    Default
    {
        Weapon.Kickback 60;
        Weapon.AmmoType "AK47Loaded";
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 30;
        Weapon.AmmoType2 "KalashnikovClip";
        Weapon.AmmoUse2 0;
        Weapon.AmmoGive2 30;
        Tag "AK-47";
        Scale 0.6;
        Inventory.PickupMessage "You got the AK-47!";
        +Weapon.Ammo_Optional;
        +Weapon.Alt_Ammo_Optional;
        +Weapon.Ammo_CheckBoth;
        +Weapon.NoAutoFire;
    }

    States
    {
    Ready:
        AK4G A 0 A_PlaySound("AK47/Up",9);
        AK4G A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;

    RealReady:
        AK4G A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        AK4G A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        AK4G A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        AK4G A 0 A_JumpIfInventory("AK47Loaded",0,2);
        AK4G A 0 A_JumpIfInventory("KalashnikovClip",1,2);
        AK4G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;
        AK4G A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        AK4G A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        AK4G A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        AK4G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;

    Deselect:
        AK4G A 0 A_PlaySound("AK47/Down",8);
        AK4G A 3 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        AK4G A 2 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,130,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,160,WOF_INTERPOLATE);
        TNT1 A 1 A_Lower;
        Wait;

    Select:
        TNT1 A 0 A_Raise;
        Wait;

    Fire:
        AK4G A 0 A_JumpIfInventory("AK47Loaded",1,1);
        Goto Dryfire;
        AK4F A 0 A_JumpIfInventory("AK47SemiAuto",1,"FireSemi");
        AK4F A 0 A_GunFlash;
        AK4F A 0 A_TakeInventory("AK47Loaded",1);
        AK4F A 0 A_PlaySound("AK47/Fire",6);
        AK4F A 0 A_FireCustomMissile("AutomaticSmokeSpawnerSmall", frandom(-4, 4), 0, 4, -1, 0, frandom(-4, 4));
        AK4F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        AK4F A 1 Bright A_ZoomFactor(0.97);
        AK4F B 1 Bright Offset(0,38) A_FireCustomMissile("AK47Tracer", frandom(-2.5,2.5),1,0,0,0,frandom(-1.0,1.0));
        AK4F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        AK4G A 0 A_SetPitch(pitch-0.8);
        AK4G A 0 A_SetAngle(angle-0.2);
        AK4G B 1 Offset(0,37) A_FireCustomMissile("RifleCasingSpawn",0,0,2,-2);
        AK4G A 0 A_SetPitch(pitch-0.4);
        AK4G A 0 A_SetAngle(angle-0.1);
        AK4G A 0 A_ZoomFactor(1.0);
        AK4G A 1 Offset(0,35);
        AK4G A 1 Offset(0,33) A_Refire;
        Goto RealReady;

    FireSemi:
        AK4G A 0 A_JumpIfInventory("AK47Loaded",1,1);
        Goto Dryfire;
        AK4F A 0 A_GunFlash;
        AK4F A 0 A_TakeInventory("AK47Loaded",1);
        AK4F A 0 A_PlaySound("AK47/Fire",6);
        AK4G A 0 A_ZoomFactor(0.97);
        AK4F A 0 A_FireCustomMissile("AutomaticSmokeSpawnerSmall", frandom(-4, 4), 0, 4, -1, 0, frandom(-4, 4));
        AK4F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        AK4F A 1 Bright A_ZoomFactor(0.97);
        AK4F B 1 Bright Offset(0,38) A_FireCustomMissile("AK47Tracer", frandom(-2.5,2.5),1,0,0,0,frandom(-1.0,1.0));
        AK4F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        AK4G A 0 A_SetPitch(pitch-2.0);
        AK4G A 0 A_SetAngle(angle-1.0);
        AK4G B 1 Offset(0,44) A_FireCustomMissile("RifleCasingSpawn",0,0,2,-2);
        AK4G A 0 A_ZoomFactor(1.0);
        AK4G A 0 A_SetPitch(pitch+0.4);
        AK4G A 0 A_SetAngle(angle+0.2);
        AK4G A 1 Offset(0,40) A_WeaponReady(WRF_NOBOB);
        AK4G A 0 A_SetPitch(pitch+0.4);
        AK4G A 0 A_SetAngle(angle+0.2);
        AK4G A 1 Offset(0,36) A_WeaponReady(WRF_NOBOB);
        AK4G A 0 A_SetPitch(pitch+0.4);
        AK4G A 0 A_SetAngle(angle+0.2);
        AK4G A 1 A_WeaponReady(WRF_NOBOB);
        AK4G A 0 A_SetPitch(pitch+0.4);
        AK4G A 0 A_SetAngle(angle+0.1);
        AK4G A 1 A_WeaponReady(WRF_NOBOB);
        AK4G A 0 A_SetPitch(pitch+0.2);
        AK4G A 0 A_SetAngle(angle+0.1);
        AK4G A 1 A_WeaponReady(WRF_NOBOB);
        Goto RealReady;

    AltFire:
        TNT1 A 0 A_JumpIfInventory("AK47SemiAuto",1,"SelectAuto");
        TNT1 A 0 A_GiveInventory("AK47SemiAuto",1);
        TNT1 A 0 A_Print("= Semi-Auto =");
        TNT1 A 0 A_PlaySound("AK47/Dryfire",4);
        Goto RealReady;
    SelectAuto:
        TNT1 A 0 A_TakeInventory("AK47SemiAuto",1);
        TNT1 A 0 A_Print("= Full-Auto =");
        TNT1 A 0 A_PlaySound("AK47/Dryfire",4);
        Goto RealReady;

    Spawn:
        AK4P A -1;
        Stop;

    Dryfire:
        AK4G A 0 A_JumpIfInventory("KalashnikovClip",1,"Reload");
        AK4G A 0 A_PlaySound("AK47/Dryfire",7);
        Goto RealReady;

    Reload:
        AK4G A 0 A_JumpIfInventory("AK47Loaded",30,2);
        AK4G A 0 A_JumpIfNoAmmo(1);
        Goto ProperReload;
        AK4G A 1;
        Goto RealReady;

    ProperReload:
        AK4G A 1 Offset(0,35);
        AK4R A 1 Offset(0,38);
        AK4R B 1 Offset(0,44);
        AK4R C 1 Offset(2,46);
        AK4R D 1 Offset(4,52);
        AK4R E 1 Offset(7,56) A_PlaySound("AK47/Out",5);
        AK4R E 1 Offset(10,57) A_FireCustomMissile("AKClipSpawn",25,0,8,-32);
        AK4R E 10 Offset(11,58);
        Goto ReloadLoop;

    ReloadLoop:
        AK4R E 3 Offset(11,58) A_CS_FillMagazine("AK47Loaded","KalashnikovClip",30);
        Goto ReloadFinish;

    ReloadFinish:
        AK4R E 1 Offset(10,58);
        AK4R E 1 Offset(10,61);
        AK4R E 1 Offset(10,65) A_PlaySound("AK47/In",5);
        AK4R E 1 Offset(10,71);
        AK4R E 1 Offset(10,65);
        AK4R E 1 Offset(10,60);
        AK4R E 1 Offset(10,55);
        AK4R E 1 Offset(10,53);
        AK4R D 1 Offset(10,51);
        AK4R C 1 Offset(9,50);
        AK4R B 1 Offset(8,46);
        AK4R A 1 Offset(7,43);
        AK4G A 1 Offset(5,40);
        AK4G A 1 Offset(3,37);
        AK4G A 1 Offset(1,34);
        AK4G A 1 Offset(0,32);
        Goto RealReady;

    Flash:
        TNT1 A 2 Bright A_Light2;
        TNT1 A 2 Bright A_Light1;
        TNT1 A 0 A_Light0;
        Stop;

    UseF1GrenadeState:
        AK4G A 0 A_PlaySound("AK47/Down",8);
        AK4G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowF1;
    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseF1Grenade",1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem",1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseMolotovState:
        AK4G A 0 A_PlaySound("AK47/Down",8);
        AK4G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowMolotov;
    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseMolotov",1);
        HNGR D 0 A_TakeInventory("MolotovItem",1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseInjectorState:
        AK4G A 0 A_PlaySound("AK47/Down",8);
        AK4G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto HealInjector;
    HealInjector:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
                TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_TakeInventory("StimInjectorItem", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        TNT1 A 0 { GiveBody(40); }
        TNT1 A 0 A_SpawnItemEx("StimInjectorBurst", 0, 0, 32, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;
    AfterUse:
        AK4G A 0 A_PlaySound("AK47/Up",9);
        TNT1 A 2 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(67,100,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(32,69,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(10,47,WOF_INTERPOLATE);
        AK4G A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;
    }
}

class AK47SemiAuto : Inventory { Default { Inventory.MaxAmount 1; } }
class AK47Loaded : Ammo
{
    Default
    {
        Inventory.MaxAmount 30;
    }
}

// ============================================================================
// 8. SKS
// ============================================================================
class SKS : ClearSkyWeapon
{
    Default
    {
        Weapon.Kickback 60;
        Weapon.AmmoType "SKSLoaded";
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 10;
        Weapon.AmmoType2 "KalashnikovClip";
        Weapon.AmmoUse2 0;
        Weapon.AmmoGive2 30;
        Tag "SKS";
        Scale 0.4;
        Inventory.PickupMessage "You got the SKS!";
        +Weapon.Ammo_Optional;
        +Weapon.Alt_Ammo_Optional;
        +Weapon.Ammo_CheckBoth;
        +Weapon.NoAutoFire;
    }

    States
    {
    Ready:
        SKSG B 0 A_PlaySound("SKS/Up",9);
        SKSG A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;

    RealReady:
        SKSG A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        SKSG A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        SKSG A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        SKSG A 0 A_JumpIfInventory("SKSLoaded",0,2);
        SKSG A 0 A_JumpIfInventory("KalashnikovClip",1,2);
        SKSG A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;
        SKSG A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        SKSG A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        SKSG A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        SKSG A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;

    Deselect:
        SKSG A 0 A_PlaySound("SKS/Down",8);
        SKSG A 3 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        SKSG A 2 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,130,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,160,WOF_INTERPOLATE);
        TNT1 A 1 A_Lower;
        Wait;

    Select:
        TNT1 A 0 A_Raise;
        Wait;

    Fire:
        SKSG A 0 A_JumpIfInventory("SKSLoaded",1,1);
        Goto Dryfire;
        SKSF A 0 A_GunFlash;
        SKSF A 0 A_TakeInventory("SKSLoaded",1);
        SKSF A 0 A_PlaySound("SKS/Fire",6);
        SKSF A 0 A_FireCustomMissile("SmokeSpawner",0,0,0,2);
        SKSF A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,11);
        SKSF A 1 Bright A_ZoomFactor(0.97);
        SKSF B 1 Bright Offset(0,38) A_FireCustomMissile("SKSTracer", frandom(-1.0,1.0),1,0,0,0,frandom(-0.8,0.8));
        SKSF A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,11);
        SKSG A 0 A_SetPitch(pitch-2.0);
        SKSG A 0 A_SetAngle(angle-1.0);
        SKSG B 1 Offset(0,44) A_FireCustomMissile("RifleCasingSpawn",5,0,6,-14);
        SKSG A 0 A_ZoomFactor(1.0);
        SKSG A 0 A_SetPitch(pitch+0.4);
        SKSG A 0 A_SetAngle(angle+0.2);
        SKSG A 1 Offset(0,40) A_WeaponReady(WRF_NOBOB);
        SKSG A 0 A_SetPitch(pitch+0.4);
        SKSG A 0 A_SetAngle(angle+0.2);
        SKSG A 1 Offset(0,36) A_WeaponReady(WRF_NOBOB);
        SKSG A 0 A_SetPitch(pitch+0.4);
        SKSG A 0 A_SetAngle(angle+0.2);
        SKSG A 1 A_WeaponReady(WRF_NOBOB);
        SKSG A 0 A_SetPitch(pitch+0.4);
        SKSG A 0 A_SetAngle(angle+0.1);
        SKSG A 1 A_WeaponReady(WRF_NOBOB);
        SKSG A 0 A_SetPitch(pitch+0.2);
        SKSG A 0 A_SetAngle(angle+0.1);
        SKSG A 1 A_WeaponReady(WRF_NOBOB);
        Goto RealReady;

    Spawn:
        SKSP A -1;
        Stop;

    Dryfire:
        SKSG A 0 A_JumpIfInventory("KalashnikovClip",1,"Reload");
        SKSG A 0 A_PlaySound("SKS/Dryfire",7);
        Goto RealReady;

    Reload:
        SKSG A 0 A_JumpIfInventory("SKSLoaded",10,2);
        SKSG A 0 A_JumpIfNoAmmo(1);
        Goto ProperReload;
        SKSG A 1;
        Goto RealReady;

    ProperReload:
        SKSG B 1 Offset(0,35) A_PlaySound("SKS/Out",5);
        SKSR A 1 Offset(0,38);
        SKSR B 1 Offset(0,44);
        SKSR C 1 Offset(2,46);
        SKSR D 1 Offset(4,52);
        SKSR E 1 Offset(7,56);
        SKSR E 1 Offset(10,57);
        SKSR E 8 Offset(11,58);
        SKSR E 8 Offset(11,58) A_PlaySound("SKS/In",5);
        Goto ReloadLoop;

    ReloadLoop:
        SKSR E 3 Offset(11,58) A_CS_FillMagazine("SKSLoaded","KalashnikovClip",10);
        Goto ReloadFinish;

    ReloadFinish:
        SKSR E 1 Offset(10,58) A_PlaySound("SKS/In2",5);
        SKSR E 1 Offset(10,61);
        SKSR E 1 Offset(10,65);
        SKSR E 1 Offset(10,71);
        SKSR E 1 Offset(10,65);
        SKSR E 1 Offset(10,60);
        SKSR E 1 Offset(10,55);
        SKSR E 1 Offset(10,53);
        SKSR D 1 Offset(10,51);
        SKSR C 1 Offset(9,50);
        SKSR B 1 Offset(8,46);
        SKSR A 1 Offset(7,43);
        SKSG A 1 Offset(5,40);
        SKSG A 1 Offset(3,37);
        SKSG A 1 Offset(1,34);
        SKSG A 1 Offset(0,32);
        Goto RealReady;

    Flash:
        TNT1 A 2 Bright A_Light2;
        TNT1 A 2 Bright A_Light1;
        TNT1 A 0 A_Light0;
        Stop;

    UseF1GrenadeState:
        SKSG A 0 A_PlaySound("SKS/Down",8);
        SKSG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowF1;
    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseF1Grenade",1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem",1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseMolotovState:
        SKSG A 0 A_PlaySound("SKS/Down",8);
        SKSG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowMolotov;
    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseMolotov",1);
        HNGR D 0 A_TakeInventory("MolotovItem",1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseInjectorState:
        SKSG A 0 A_PlaySound("SKS/Down",8);
        SKSG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto HealInjector;
    HealInjector:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
                TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_TakeInventory("StimInjectorItem", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        TNT1 A 0 { GiveBody(40); }
        TNT1 A 0 A_SpawnItemEx("StimInjectorBurst", 0, 0, 32, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;
    AfterUse:
        SKSG A 0 A_PlaySound("SKS/Up",9);
        TNT1 A 2 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(67,100,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(32,69,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(10,47,WOF_INTERPOLATE);
        SKSG A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;
    }
}

class SKSLoaded : Ammo
{
    Default
    {
        Inventory.MaxAmount 10;
    }
}

// ============================================================================
// 9. Fort-12
// ============================================================================
class Fort12 : ClearSkyWeapon
{
    Default
    {
        Scale 0.5;
        Tag "Fort-12";
        Weapon.Kickback 50;
        Weapon.AmmoType "Fort12Loaded";
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 12;
        Weapon.AmmoType2 "MakarovClip";
        Weapon.AmmoUse2 1;
        Weapon.AmmoGive2 30;
        Inventory.PickupMessage "You got the Fort-12!";
        +Weapon.Ammo_Optional;
        +Weapon.Alt_Ammo_Optional;
        +Weapon.Ammo_CheckBoth;
        +Weapon.NoAutoFire;
    }

    States
    {
    Ready:
        F12G A 0 A_PlaySound("Fort12/Up",9);
        F12G A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;

    RealReady:
        F12G A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        F12G A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        F12G A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        F12G A 0 A_JumpIfInventory("Fort12Loaded",0,2);
        F12G A 0 A_JumpIfInventory("MakarovClip",1,2);
        F12G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;
        F12G A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        F12G A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        F12G A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        F12G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;

    Deselect:
        F12G B 0 A_PlaySound("Fort12/Down",8);
        F12G A 2 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,130,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,160,WOF_INTERPOLATE);
        TNT1 A 1 A_Lower;
        Wait;

    Select:
        TNT1 A 0 A_Raise;
        Wait;

    Fire:
        F12G A 0 A_JumpIfInventory("Fort12Loaded",1,1);
        Goto Dryfire;
        F12F A 0 A_GunFlash;
        F12F A 0 A_FireCustomMissile("SmokeSpawner",0,0,0,2);
        F12F A 0 A_SetPitch(pitch-0.2);
        F12F A 0 A_PlaySound("Fort12/Fire",6);
        F12G A 0 A_ZoomFactor(0.99);
        F12F A 0 A_TakeInventory("Fort12Loaded",1);
        F12F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,9);
        F12F A 1 Bright A_FireCustomMissile("Fort12Tracer", frandom(-1.4,1.4),0);
        F12F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,9);
        F12F A 0 A_FireCustomMissile("PistolCasingSpawn",0,0,2,-2);
        F12G A 0 A_SetPitch(pitch-0.2);
        F12G A 0 A_ZoomFactor(1.0);
        F12G B 1 Offset(0,43);
        F12G C 1 Offset(0,40);
        F12G C 1 Offset(0,36) A_WeaponReady(1);
        F12G B 1 Offset(0,32) A_WeaponReady(1);
        F12G A 1 A_WeaponReady(1);
        F12G A 1 A_WeaponReady(1);
        Goto RealReady;

    Spawn:
        F12P A -1;
        Stop;

    Dryfire:
        F12G A 0 A_JumpIfInventory("MakarovClip",1,"Reload");
        F12G A 0 A_PlaySound("Fort12/Dryfire",7);
        Goto RealReady;

    Reload:
        F12G A 0 A_JumpIfInventory("Fort12Loaded",12,2);
        F12G A 0 A_JumpIfNoAmmo(1);
        Goto ProperReload;
        F12G A 1;
        Goto RealReady;

    ProperReload:
        F12G A 1 Offset(0,35);
        F12R F 1 Offset(0,38) A_PlaySound("Fort12/Out",5);
        F12R E 1 Offset(0,44) A_FireCustomMissile("PistolClipSpawn",25,0,8,-32);
        F12R D 1 Offset(2,46);
        F12R C 1 Offset(4,52);
        F12R B 1 Offset(7,56);
        F12R A 1 Offset(10,57);
        F12R A 10 Offset(11,58);
        Goto ReloadLoop;

    ReloadLoop:
        F12R A 3 Offset(11,58) A_CS_FillMagazine("Fort12Loaded","MakarovClip",12);
        Goto ReloadFinish;

    ReloadFinish:
        F12R A 1 Offset(10,58);
        F12R A 1 Offset(10,61);
        F12R A 1 Offset(10,65);
        F12R A 1 Offset(10,71);
        F12R A 1 Offset(10,65);
        F12R A 1 Offset(10,60) A_PlaySound("Fort12/In",5);
        F12R A 1 Offset(10,55);
        F12R A 1 Offset(10,53);
        F12R B 1 Offset(10,51);
        F12R C 1 Offset(9,50);
        F12R D 1 Offset(8,46);
        F12R E 1 Offset(7,43);
        F12R F 1 Offset(5,40);
        F12G A 1 Offset(3,37);
        F12G A 1 Offset(1,34);
        F12G A 1 Offset(0,32);
        Goto RealReady;

    Flash:
        TNT1 A 3 A_Light2;
        TNT1 A 3 A_Light1;
        TNT1 A 0 A_Light0;
        Goto LightDone;

    UseF1GrenadeState:
        F12G A 0 A_PlaySound("Fort12/Down",8);
        F12G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowF1;
    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseF1Grenade",1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem",1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseMolotovState:
        F12G A 0 A_PlaySound("Fort/Down",8);
        F12G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowMolotov;
    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseMolotov",1);
        HNGR D 0 A_TakeInventory("MolotovItem",1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseInjectorState:
        F12G A 0 A_PlaySound("Fort12/Down",8);
        F12G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto HealInjector;
    HealInjector:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
                TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_TakeInventory("StimInjectorItem", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        TNT1 A 0 { GiveBody(40); }
        TNT1 A 0 A_SpawnItemEx("StimInjectorBurst", 0, 0, 32, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;
    AfterUse:
        F12G A 0 A_PlaySound("Fort12/Up",9);
        TNT1 A 2 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(67,100,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(32,69,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(10,47,WOF_INTERPOLATE);
        F12G A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;
    }
}

class Fort12Loaded : Ammo
{
    Default
    {
        Inventory.MaxAmount 12;
    }
}

// ============================================================================
// 10. PP-19 Bizon
// ============================================================================
class PP19 : ClearSkyWeapon
{
    Default
    {
        Weapon.Kickback 50;
        Weapon.AmmoType "PP19Loaded";
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 64;
        Weapon.AmmoType2 "MakarovClip";
        Weapon.AmmoUse2 1;
        Weapon.AmmoGive2 30;
        Scale 0.5;
        Tag "PP-19 Bizon";
        Inventory.PickupMessage "You got the PP-19 Bizon!";
        +Weapon.Ammo_Optional;
        +Weapon.Alt_Ammo_Optional;
        +Weapon.Ammo_CheckBoth;
        +Weapon.NoAutoFire;
    }

    States
    {
    Ready:
        P19G A 0 A_PlaySound("PP19/Up",9);
        P19G A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;

    RealReady:
        P19G A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        P19G A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        P19G A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        P19G A 0 A_JumpIfInventory("PP19Loaded",0,2);
        P19G A 0 A_JumpIfInventory("MakarovClip",1,2);
        P19G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;
        P19G A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        P19G A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        P19G A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        P19G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;

    Deselect:
        P19G B 0 A_PlaySound("PP19/Down",8);
        P19G A 2 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,130,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,160,WOF_INTERPOLATE);
        TNT1 A 1 A_Lower;
        Wait;

    Select:
        TNT1 A 0 A_Raise;
        Wait;

    Fire:
        P19G A 0 A_JumpIfInventory("PP19Loaded",1,1);
        Goto Dryfire;
        P19G A 0 A_JumpIfInventory("BizonBurst",1,"FireBurst");
        P19G A 0 A_JumpIfInventory("BizonSemi",1,"FireSemi");
        P19G A 0 A_FireCustomMissile("AutomaticSmokeSpawnerSmall", frandom(-2, 2), 0, 7, 0, 0, frandom(-5, 5));
        P19G A 0 A_GunFlash;
        P19G A 0 A_PlaySound("PP19/Fire",6);
        P19G A 0 A_TakeInventory("PP19Loaded",1);
        P19F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        P19F A 1 Bright A_FireCustomMissile("PP19Tracer", frandom(-1.4,1.4),0);
        P19G A 0 A_ZoomFactor(0.98);
        P19F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        P19F A 0 A_SetPitch(pitch-0.3);
        P19F A 0 A_SetAngle(angle-0.1);
        P19G B 1 Offset(0,38) A_FireCustomMissile("PistolCasingSpawn",0,0,2,-2);
        P19G A 0 A_SetPitch(pitch-0.3);
        P19G A 0 A_SetAngle(angle-0.1);
        P19G A 0 A_ZoomFactor(1.0);
        P19G A 1 Offset(0,37);
        P19G A 1 A_Refire;
        Goto RealReady;

    FireBurst:
        P19G A 0 A_JumpIfInventory("PP19Loaded",3,1);
        Goto Dryfire;
        P19G A 0 A_FireCustomMissile("AutomaticSmokeSpawnerSmall", frandom(-2, 2), 0, 7, 0, 0, frandom(-5, 5));
        P19G A 0 A_SetPitch(pitch-0.2);
        P19G A 0 A_GunFlash;
        P19G A 0 A_PlaySound("PP19/Fire",6);
        P19G A 0 A_TakeInventory("PP19Loaded",1);
        P19F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        P19F A 1 Bright A_FireCustomMissile("PP19Tracer", frandom(-1.4,1.4),0);
        P19G A 0 A_ZoomFactor(0.98);
        P19F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        P19G B 1 Offset(0,38) A_FireCustomMissile("PistolCasingSpawn",0,0,2,-2);
        P19G A 0 A_SetPitch(pitch-0.2);
        P19G A 0 A_ZoomFactor(1.0);
        P19G A 0 A_FireCustomMissile("AutomaticSmokeSpawnerSmall", frandom(-2, 2), 0, 7, 0, 0, frandom(-5, 5));
        P19G A 0 A_SetPitch(pitch-0.2);
        P19G A 0 A_GunFlash;
        P19G A 0 A_PlaySound("PP19/Fire",6);
        P19G A 0 A_TakeInventory("PP19Loaded",1);
        P19F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        P19F A 1 Bright A_FireCustomMissile("PP19Tracer", frandom(-1.4,1.4),0);
        P19G A 0 A_ZoomFactor(0.98);
        P19F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        P19G B 1 Offset(0,38) A_FireCustomMissile("PistolCasingSpawn",0,0,2,-2);
        P19G A 0 A_SetPitch(pitch-0.2);
        P19G A 0 A_ZoomFactor(1.0);
        P19G A 0 A_FireCustomMissile("AutomaticSmokeSpawnerSmall", frandom(-2, 2), 0, 7, 0, 0, frandom(-5, 5));
        P19G A 0 A_SetPitch(pitch-0.2);
        P19G A 0 A_GunFlash;
        P19G A 0 A_PlaySound("PP19/Fire",6);
        P19G A 0 A_TakeInventory("PP19Loaded",1);
        P19F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        P19F A 1 Bright A_FireCustomMissile("PP19Tracer", frandom(-1.4,1.4),0);
        P19G A 0 A_ZoomFactor(0.98);
        P19F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        P19G B 1 Offset(0,38) A_FireCustomMissile("PistolCasingSpawn",0,0,2,-2);
        P19G A 0 A_SetPitch(pitch-0.2);
        P19G A 0 A_ZoomFactor(1.0);
        P19G A 1 Offset(0,37);
        Goto RealReady;

    FireSemi:
        P19G A 0 A_JumpIfInventory("PP19Loaded",1,1);
        Goto Dryfire;
        P19G A 0 A_FireCustomMissile("AutomaticSmokeSpawnerSmall", frandom(-2, 2), 0, 7, 0, 0, frandom(-5, 5));
        P19G A 0 A_GunFlash;
        P19G A 0 A_PlaySound("PP19/Fire",6);
        P19G A 0 A_TakeInventory("PP19Loaded",1);
        P19F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        P19F A 1 Bright A_FireCustomMissile("PP19Tracer", frandom(-1.4,1.4),0);
        P19G A 0 A_ZoomFactor(0.98);
        P19F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        P19F A 0 A_SetPitch(pitch-0.3);
        P19F A 0 A_SetAngle(angle-0.1);
        P19G B 1 Offset(0,38) A_FireCustomMissile("PistolCasingSpawn",0,0,2,-2);
        P19G A 0 A_SetPitch(pitch-0.3);
        P19G A 0 A_SetAngle(angle-0.1);
        P19G A 0 A_ZoomFactor(1.0);
        P19G A 1 Offset(0,37);
        Goto RealReady;

    AltFire:
        TNT1 A 0 A_JumpIfInventory("BizonBurst",1,"SelectSemi");
        TNT1 A 0 A_JumpIfInventory("BizonSemi",1,"SelectAuto");
        TNT1 A 0 A_GiveInventory("BizonBurst",1);
        TNT1 A 0 A_Print("= Burst-Fire =");
        TNT1 A 0 A_PlaySound("PP19/Dryfire",4);
        Goto RealReady;
    SelectSemi:
        TNT1 A 0 A_TakeInventory("BizonBurst",1);
        TNT1 A 0 A_GiveInventory("BizonSemi",1);
        TNT1 A 0 A_Print("= Semi-Auto =");
        TNT1 A 0 A_PlaySound("PP19/Dryfire",4);
        Goto RealReady;
    SelectAuto:
        TNT1 A 0 A_TakeInventory("BizonBurst",1);
        TNT1 A 0 A_TakeInventory("BizonSemi",1);
        TNT1 A 0 A_Print("= Full-Auto =");
        TNT1 A 0 A_PlaySound("PP19/Dryfire",4);
        Goto RealReady;

    Spawn:
        P19P A -1;
        Stop;

    Dryfire:
        P19G A 0 A_JumpIfInventory("MakarovClip",1,"Reload");
        P19G A 0 A_PlaySound("PP19/Dryfire",7);
        Goto RealReady;

    Reload:
        P19G A 0 A_JumpIfInventory("PP19Loaded",64,2);
        P19G A 0 A_JumpIfNoAmmo(1);
        Goto ProperReload;
        P19G A 1;
        Goto RealReady;

    ProperReload:
        P19G A 1 Offset(0,35);
        P19R A 1 Offset(0,38);
        P19R B 1 Offset(0,44);
        P19R C 1 Offset(2,46);
        P19R D 1 Offset(4,52);
        P19R E 1 Offset(7,56) A_PlaySound("PP19/Out",5);
        P19R E 1 Offset(10,57) A_FireCustomMissile("PistolClipSpawn",25,0,8,-32);
        P19R E 10 Offset(11,58);
        Goto ReloadLoop;

    ReloadLoop:
        P19R E 3 Offset(11,58) A_CS_FillMagazine("PP19Loaded","MakarovClip",64);
        Goto ReloadFinish;

    ReloadFinish:
        P19R E 1 Offset(10,58);
        P19R E 1 Offset(10,61);
        P19R E 1 Offset(10,65) A_PlaySound("PP19/In",5);
        P19R E 1 Offset(10,71);
        P19R E 1 Offset(10,65);
        P19R E 1 Offset(10,60);
        P19R E 1 Offset(10,55);
        P19R E 1 Offset(10,53);
        P19R D 1 Offset(10,51);
        P19R C 1 Offset(9,50);
        P19R B 1 Offset(8,46);
        P19R A 1 Offset(7,43);
        P19G A 1 Offset(5,40);
        P19G A 1 Offset(3,37);
        P19G A 1 Offset(1,34);
        P19G A 1 Offset(0,32);
        Goto RealReady;

    Flash:
        TNT1 A 3 A_Light2;
        TNT1 A 3 A_Light1;
        TNT1 A 0 A_Light0;
        Goto LightDone;

    UseF1GrenadeState:
        P19G A 0 A_PlaySound("PP19/Down",8);
        P19G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowF1;
    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseF1Grenade",1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem",1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseMolotovState:
        P19G A 0 A_PlaySound("PP19/Down",8);
        P19G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowMolotov;
    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseMolotov",1);
        HNGR D 0 A_TakeInventory("MolotovItem",1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseInjectorState:
        P19G A 0 A_PlaySound("PP19/Down",8);
        P19G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto HealInjector;
    HealInjector:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
                TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_TakeInventory("StimInjectorItem", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        TNT1 A 0 { GiveBody(40); }
        TNT1 A 0 A_SpawnItemEx("StimInjectorBurst", 0, 0, 32, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;
    AfterUse:
        P19G A 0 A_PlaySound("PP19/Up",9);
        TNT1 A 2 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(67,100,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(32,69,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(10,47,WOF_INTERPOLATE);
        P19G A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;
    }
}

class BizonBurst : Inventory { Default { Inventory.MaxAmount 1; } }
class BizonSemi : Inventory { Default { Inventory.MaxAmount 1; } }
class PP19Loaded : Ammo
{
    Default
    {
        Inventory.MaxAmount 64;
    }
}

// ============================================================================
// 11. AS-VAL
// ============================================================================
class ASVAL : ClearSkyWeapon
{
    Default
    {
        Weapon.Kickback 50;
        Weapon.AmmoType "ASVALLoaded";
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 20;
        Weapon.AmmoType2 "SP6Clip";
        Weapon.AmmoUse2 1;
        Weapon.AmmoGive2 30;
        Scale 0.5;
        Tag "AS-VAL";
        Inventory.PickupMessage "You got the AS-VAL!";
        +Weapon.Ammo_Optional;
        +Weapon.Alt_Ammo_Optional;
        +Weapon.Ammo_CheckBoth;
        +Weapon.NoAlert;
        +Weapon.NoAutoFire;
    }

    States
    {
    Ready:
        ASVG A 0 A_PlaySound("ASVAL/Up",9);
        ASVG A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;

    RealReady:
        ASVG A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        ASVG A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        ASVG A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        ASVG A 0 A_JumpIfInventory("ASVALLoaded",0,2);
        ASVG A 0 A_JumpIfInventory("SP6Clip",1,2);
        ASVG A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;
        ASVG A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        ASVG A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        ASVG A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        ASVG A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;

    Deselect:
        ASVG B 0 A_PlaySound("ASVAL/Down",8);
        ASVG A 2 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,130,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,160,WOF_INTERPOLATE);
        TNT1 A 1 A_Lower;
        Wait;

    Select:
        TNT1 A 0 A_Raise;
        Wait;

    Fire:
        ASVG A 0 A_JumpIfInventory("ASVALLoaded",1,1);
        Goto Dryfire;
        ASVG A 0 A_FireCustomMissile("AutomaticSmokeSpawnerSmall", frandom(-2, 2), 0, 7, 0, 0, frandom(-5, 5));
        ASVG A 0 A_GunFlash;
        ASVG A 0 A_PlaySound("ASVAL/Fire",6);
        ASVG A 0 A_TakeInventory("ASVALLoaded",1);
        ASVF A 0 A_FireCustomMissile("ASVALRedFlareSpawn",0,0,0,8);
        ASVF A 1 Bright A_FireCustomMissile("ASVALTracer", frandom(-1.4,1.4),0);
        ASVG A 0 A_ZoomFactor(0.98);
        ASVF A 0 A_FireCustomMissile("ASVALRedFlareSpawn",0,0,0,8);
        ASVF A 0 A_SetPitch(pitch-0.3);
        ASVF A 0 A_SetAngle(angle-0.1);
        ASVG B 1 Offset(0,38) A_FireCustomMissile("RifleCasingSpawn",0,0,2,-2);
        ASVG A 0 A_SetPitch(pitch-0.3);
        ASVG A 0 A_SetAngle(angle-0.1);
        ASVG A 0 A_ZoomFactor(1.0);
        ASVG A 1 Offset(0,37);
        ASVG A 1 A_Refire;
        Goto RealReady;

    Spawn:
        ASVP A -1;
        Stop;

    Dryfire:
        ASVG A 0 A_JumpIfInventory("SP6Clip",1,"Reload");
        ASVG A 0 A_PlaySound("ASVAL/Dryfire",7);
        Goto RealReady;

    Reload:
        ASVG A 0 A_JumpIfInventory("ASVALLoaded",20,2);
        ASVG A 0 A_JumpIfNoAmmo(1);
        Goto ProperReload;
        ASVG A 1;
        Goto RealReady;

    ProperReload:
        ASVG A 1 Offset(0,35);
        ASVR A 1 Offset(0,38);
        ASVR B 1 Offset(0,44);
        ASVR C 1 Offset(2,46);
        ASVR D 1 Offset(4,52);
        ASVR E 1 Offset(7,56) A_PlaySound("ASVAL/Out",5);
        ASVR E 1 Offset(10,57) A_FireCustomMissile("AKClipSpawn",25,0,8,-32);
        ASVR E 10 Offset(11,58);
        Goto ReloadLoop;

    ReloadLoop:
        ASVR E 3 Offset(11,58) A_CS_FillMagazine("ASVALLoaded","SP6Clip",20);
        Goto ReloadFinish;

    ReloadFinish:
        ASVR E 1 Offset(10,58);
        ASVR E 1 Offset(10,61);
        ASVR E 1 Offset(10,65) A_PlaySound("ASVAL/In",5);
        ASVR E 1 Offset(10,71);
        ASVR E 1 Offset(10,65);
        ASVR E 1 Offset(10,60);
        ASVR E 1 Offset(10,55);
        ASVR E 1 Offset(10,53);
        ASVR D 1 Offset(10,51);
        ASVR C 1 Offset(9,50);
        ASVR B 1 Offset(8,46);
        ASVR A 1 Offset(7,43);
        ASVG A 1 Offset(5,40);
        ASVG A 1 Offset(3,37);
        ASVG A 1 Offset(1,34);
        ASVG A 1 Offset(0,32);
        Goto RealReady;

    Flash:
        TNT1 A 3 A_Light2;
        TNT1 A 3 A_Light1;
        TNT1 A 0 A_Light0;
        Goto LightDone;

    UseF1GrenadeState:
        ASVG A 0 A_PlaySound("ASVAL/Down",8);
        ASVG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowF1;
    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseF1Grenade",1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem",1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseMolotovState:
        ASVG A 0 A_PlaySound("ASVAL/Down",8);
        ASVG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowMolotov;
    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseMolotov",1);
        HNGR D 0 A_TakeInventory("MolotovItem",1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseInjectorState:
        ASVG A 0 A_PlaySound("ASVAL/Down",8);
        ASVG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto HealInjector;
    HealInjector:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
                TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_TakeInventory("StimInjectorItem", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        TNT1 A 0 { GiveBody(40); }
        TNT1 A 0 A_SpawnItemEx("StimInjectorBurst", 0, 0, 32, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;
    AfterUse:
        ASVG A 0 A_PlaySound("ASVAL/Up",9);
        TNT1 A 2 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(67,100,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(32,69,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(10,47,WOF_INTERPOLATE);
        ASVG A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;
    }
}

class ASVALLoaded : Ammo
{
    Default
    {
        Inventory.MaxAmount 20;
    }
}

// ============================================================================
// 12. OTS-14 Groza-4
// ============================================================================
class OTS14 : ClearSkyWeapon
{
    Default
    {
        Weapon.Kickback 60;
        Weapon.AmmoType "OTS14Loaded";
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 20;
        Weapon.AmmoType2 "SP6Clip";
        Weapon.AmmoUse2 0;
        Weapon.AmmoGive2 30;
        Scale 0.35;
        Tag "OTS-14 Groza-4";
        Inventory.PickupMessage "You got the OTS-14 Groza-4!";
        +Weapon.Ammo_Optional;
        +Weapon.Alt_Ammo_Optional;
        +Weapon.Ammo_CheckBoth;
        +Weapon.NoAutoFire;
    }

    States
    {
    Ready:
        OTSG A 0 A_PlaySound("OTS14/Up",9);
        OTSG A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;

    RealReady:
        OTSG A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        OTSG A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        OTSG A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        OTSG A 0 A_JumpIfInventory("OTS14Loaded",0,2);
        OTSG A 0 A_JumpIfInventory("SP6Clip",1,2);
        OTSG A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;
        OTSG A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        OTSG A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        OTSG A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        OTSG A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;

    Deselect:
        OTSG A 0 A_PlaySound("OTS14/Down",8);
        OTSG A 3 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        OTSG A 2 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,130,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,160,WOF_INTERPOLATE);
        TNT1 A 1 A_Lower;
        Wait;

    Select:
        TNT1 A 0 A_Raise;
        Wait;

    Fire:
        OTSG A 0 A_JumpIfInventory("OTS14Loaded",1,1);
        Goto Dryfire;
        OTSG A 0 A_FireCustomMissile("AutomaticSmokeSpawnerSmall", frandom(-4, 4), 0, 4, -1, 0, frandom(-4, 4));
        OTSG A 0 A_GunFlash;
        OTSG A 0 A_PlaySound("OTS14/Fire",6);
        OTSG A 0 A_TakeInventory("OTS14Loaded",1);
        OTSF A 1 Bright A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        OTSF B 1 Bright Offset(0,38) A_FireCustomMissile("GrozaTracer", frandom(-1.5,1.5),0,0,0,0,frandom(-0.8,0.8));
        OTSG A 0 A_ZoomFactor(0.97);
        OTSF A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        OTSF A 0 A_SetPitch(pitch-0.8);
        OTSF A 0 A_SetAngle(angle-0.2);
        OTSG B 1 Offset(0,37) A_FireCustomMissile("RifleCasingSpawn",0,0,2,-2);
        OTSG A 0 A_SetPitch(pitch-0.4);
        OTSG A 0 A_SetAngle(angle-0.1);
        OTSG A 0 A_ZoomFactor(1.0);
        OTSG A 1 A_Refire;
        Goto RealReady;

    AltFire:
        OTSG A 0 A_JumpIfInventory("OTS14Loaded",10,1);
        Goto Dryfire;
        OTS2 A 0 A_FireCustomMissile("SmokeSpawner",0,0,0,2);
        OTS2 A 0 A_GunFlash;
        OTS2 A 0 A_PlaySound("OTS14/Grenade",6);
        OTS2 A 0 A_AlertMonsters;
        OTS2 A 0 A_TakeInventory("OTS14Loaded",10);
        OTS2 D 0 A_ZoomFactor(0.95);
        OTS2 AAAAAAAAAAAAAAAA 0 Bright A_FireCustomMissile("ShotgunParticles", random(-12,12),0,-1,0,0,random(-9,9));
        OTS2 AAAAA 0 Bright A_FireCustomMissile("ShotgunParticles2", random(-12,12),0,-1,0,0,random(-9,9));
        OTS2 A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,7);
        OTS2 A 1 Bright A_FireCustomMissile("GP25",0,0);
        OTS2 B 1 Bright Offset(0,38);
        OTS2 C 1 Bright Offset(0,44);
        OTS2 D 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,7);
        OTS2 D 0 A_SetPitch(-8.0 + pitch);
        OTS2 D 0 A_ZoomFactor(1.0);
        OTS2 D 1 Bright Offset(0,43) A_SetPitch(+3.0 + pitch);
        OTS2 E 1 Offset(0,40) A_SetPitch(+1.0 + pitch);
        OTS2 F 1 Offset(0,36) A_SetPitch(+1.0 + pitch);
        OTSG A 1 Offset(0,32) A_SetPitch(+1.0 + pitch);
        OTSG A 1 A_SetPitch(+1.0 + pitch);
        OTSG A 4;
        Goto RealReady;

    Spawn:
        OTSP A -1;
        Stop;

    Dryfire:
        OTSG A 0 A_JumpIfInventory("SP6Clip",1,"Reload");
        OTSG A 0 A_PlaySound("OTS14/Dryfire",7);
        Goto RealReady;

    Reload:
        OTSG A 0 A_JumpIfInventory("OTS14Loaded",20,2);
        OTSG A 0 A_JumpIfNoAmmo(1);
        Goto ProperReload;
        OTSG A 1;
        Goto RealReady;

    ProperReload:
        OTSG A 1 Offset(0,35);
        OTSR A 1 Offset(0,38);
        OTSR B 1 Offset(0,44);
        OTSR C 1 Offset(2,46);
        OTSR D 1 Offset(4,52);
        OTSR E 1 Offset(7,56) A_PlaySound("OTS14/Out",5);
        OTSR E 1 Offset(10,57) A_FireCustomMissile("AKClipSpawn",25,0,8,-32);
        OTSR E 12 Offset(11,58);
        Goto ReloadLoop;

    ReloadLoop:
        OTSR E 3 Offset(11,58) A_CS_FillMagazine("OTS14Loaded","SP6Clip",20);
        Goto ReloadFinish;

    ReloadFinish:
        OTSR E 1 Offset(10,58);
        OTSR E 1 Offset(10,61);
        OTSR E 1 Offset(10,65) A_PlaySound("OTS14/In",5);
        OTSR E 1 Offset(10,71);
        OTSR E 1 Offset(10,65);
        OTSR E 1 Offset(10,60);
        OTSR E 1 Offset(10,55);
        OTSR E 1 Offset(10,53);
        OTSR D 1 Offset(10,51);
        OTSR C 1 Offset(9,50);
        OTSR B 1 Offset(8,46);
        OTSR A 1 Offset(7,43);
        OTSG A 1 Offset(5,40);
        OTSG A 1 Offset(3,37);
        OTSG A 1 Offset(1,34);
        OTSG A 1 Offset(0,32);
        Goto RealReady;

    Flash:
        TNT1 A 2 Bright A_Light2;
        TNT1 A 2 Bright A_Light1;
        TNT1 A 0 A_Light0;
        Stop;

    UseF1GrenadeState:
        OTSG A 0 A_PlaySound("OTS14/Down",8);
        OTSG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowF1;
    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseF1Grenade",1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem",1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseMolotovState:
        OTSG A 0 A_PlaySound("OTS14/Down",8);
        OTSG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowMolotov;
    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseMolotov",1);
        HNGR D 0 A_TakeInventory("MolotovItem",1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseInjectorState:
        OTSG A 0 A_PlaySound("OTS14/Down",8);
        OTSG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto HealInjector;
    HealInjector:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
                TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_TakeInventory("StimInjectorItem", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        TNT1 A 0 { GiveBody(40); }
        TNT1 A 0 A_SpawnItemEx("StimInjectorBurst", 0, 0, 32, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;
    AfterUse:
        OTSG A 0 A_PlaySound("OTS14/Up",9);
        TNT1 A 2 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(67,100,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(32,69,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(10,47,WOF_INTERPOLATE);
        OTSG A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;
    }
}

class OTS14Loaded : Ammo
{
    Default
    {
        Inventory.MaxAmount 20;
    }
}

// GP25 projectile
class GP25 : Actor
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
        Obituary "%o Was Thumped by %k's GP-25.";
    }
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_CustomMissile("ShotSmoke",2,0,random(70,110),2,random(0,360));
        TNT1 A 0 A_SpawnItem("ShotSmoke");
        GP25 A 1 Bright;
        Loop;
    Death:
        EXPL A 0 A_ChangeFlag("NOGRAVITY",1);
        EXPL A 0 A_CheckFloor("DeathFloor");
        EXLA A 0 A_CheckCeiling("DeathCeiling");
        EXPL A 0 Radius_Quake(3,8,0,30,0);
        TNT1 A 0 A_PlaySound("Explosion/Far",3);
        TNT1 A 0 A_AlertMonsters;
        TNT1 A 0 A_CustomMissile("MetalShard1",5,0,random(0,360),2,random(30,160));
        TNT1 A 0 A_CustomMissile("MetalShard2",5,0,random(0,360),2,random(30,160));
        TNT1 A 0 A_CustomMissile("MetalShard3",5,0,random(0,360),2,random(30,160));
        TNT1 A 0 A_SpawnItemEx("GrenadeExplosion",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
        TNT1 AAAAAA 0 A_CustomMissile("ExplosionShrapnel",0,0,random(0,360),2,random(0,360));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy",0,0,random(0,360),2,random(0,180));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleWithSmoke",5,0,random(0,360),2,random(0,180));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy",0,0,random(0,360),2,random(0,360));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleVeryFast",0,0,random(0,360),2,random(0,360));
        TNT1 AAAAAAAA 0 A_CustomMissile("MediumExplosionFlames",0,0,random(0,360),2,random(0,360));
        TNT1 AAAAA 1 A_CustomMissile("ExplosionSmoke",2,0,random(0,360),2,random(0,360));
        TNT1 AAAAA 2 A_CustomMissile("BigNeoSmoke",2,0,random(0,360),2,random(0,360));
        Stop;
    DeathFloor:
        EXPL A 0 Bright A_ChangeFlag("NOGRAVITY",1);
        EXPL A 0 Radius_Quake(3,8,0,30,0);
        TNT1 A 0 A_SpawnItemEx("DetectFloorCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
        TNT1 A 0 A_PlaySound("Explosion/Far",3);
        TNT1 A 0 A_AlertMonsters;
        TNT1 A 0 A_CustomMissile("MetalShard1",5,0,random(0,360),2,random(30,160));
        TNT1 A 0 A_CustomMissile("MetalShard2",5,0,random(0,360),2,random(30,160));
        TNT1 A 0 A_CustomMissile("MetalShard3",5,0,random(0,360),2,random(30,160));
        TNT1 A 0 A_SpawnItemEx("GrenadeExplosion",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
        TNT1 AAAAAA 0 A_CustomMissile("ExplosionShrapnel",0,0,random(0,360),2,random(0,360));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy",0,0,random(0,360),2,random(0,180));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleWithSmoke",5,0,random(0,360),2,random(0,180));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy",0,0,random(0,360),2,random(0,360));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleVeryFast",0,0,random(0,360),2,random(0,360));
        TNT1 AAAAAAAA 0 A_CustomMissile("MediumExplosionFlames",0,0,random(0,360),2,random(0,360));
        TNT1 AAAAA 1 A_CustomMissile("ExplosionSmoke",2,0,random(0,360),2,random(0,360));
        TNT1 AAAAA 2 A_CustomMissile("BigNeoSmoke",2,0,random(0,360),2,random(0,360));
        Stop;
    DeathCeiling:
        EXPL A 0 Bright A_ChangeFlag("NOGRAVITY",1);
        EXPL A 0 Radius_Quake(3,8,0,30,0);
        TNT1 A 0 A_SpawnItemEx("DetectCeilCrater",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
        TNT1 A 0 A_PlaySound("Explosion/Far",3);
        TNT1 A 0 A_AlertMonsters;
        TNT1 A 0 A_CustomMissile("MetalShard1",5,0,random(0,360),2,random(30,160));
        TNT1 A 0 A_CustomMissile("MetalShard2",5,0,random(0,360),2,random(30,160));
        TNT1 A 0 A_CustomMissile("MetalShard3",5,0,random(0,360),2,random(30,160));
        TNT1 A 0 A_SpawnItemEx("GrenadeExplosion",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,0);
        TNT1 AAAAAA 0 A_CustomMissile("ExplosionShrapnel",0,0,random(0,360),2,random(0,360));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy",0,0,random(0,360),2,random(0,180));
        TNT1 AAAAAAAAA 0 A_CustomMissile("ExplosionParticleWithSmoke",5,0,random(0,360),2,random(0,180));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleHeavy",0,0,random(0,360),2,random(0,360));
        TNT1 AAAAAAAAAAA 0 A_CustomMissile("ExplosionParticleVeryFast",0,0,random(0,360),2,random(0,360));
        TNT1 AAAAAAAA 0 A_CustomMissile("MediumExplosionFlames",0,0,random(0,360),2,random(0,360));
        TNT1 AAAAA 1 A_CustomMissile("ExplosionSmoke",2,0,random(0,360),2,random(0,360));
        TNT1 AAAAA 2 A_CustomMissile("BigNeoSmoke",2,0,random(0,360),2,random(0,360));
        Stop;
    }
}

// ============================================================================
// 13. PPSh-41
// ============================================================================
class PPSh41 : ClearSkyWeapon
{
    Default
    {
        Weapon.Kickback 50;
        Weapon.AmmoType "PPShLoaded";
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 71;
        Weapon.AmmoType2 "TokarevClip";
        Weapon.AmmoUse2 1;
        Weapon.AmmoGive2 30;
        Tag "PPSh-41";
        Scale 0.6;
        Inventory.PickupMessage "You got the PPSh-41!";
        +Weapon.Ammo_Optional;
        +Weapon.Alt_Ammo_Optional;
        +Weapon.Ammo_CheckBoth;
        +Weapon.NoAutoFire;
    }

    States
    {
    Ready:
        PPSG A 0 A_PlaySound("PPSh/Up",9);
        PPSG A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;

    RealReady:
        PPSG A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        PPSG A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        PPSG A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        PPSG A 0 A_JumpIfInventory("PPShLoaded",0,2);
        PPSG A 0 A_JumpIfInventory("TokarevClip",1,2);
        PPSG A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;
        PPSG A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        PPSG A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        PPSG A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        PPSG A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;

    Deselect:
        PPSG A 0 A_PlaySound("PPSh/Down",8);
        PPSG A 2 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,130,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,160,WOF_INTERPOLATE);
        TNT1 A 1 A_Lower;
        Wait;

    Select:
        TNT1 A 0 A_Raise;
        Wait;

    Fire:
        PPSG A 0 A_JumpIfInventory("PPShLoaded",1,1);
        Goto Dryfire;
        PPSG A 0 A_FireCustomMissile("AutomaticSmokeSpawnerSmall", frandom(-2, 2), 0, 7, 0, 0, frandom(-5, 5));
        PPSG A 0 Bright A_GunFlash;
        PPSG A 0 A_PlaySound("PPSh/Fire",6);
        PPSG A 0 A_TakeInventory("PPShLoaded",1);
        PPSF A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        PPSF A 1 Bright Offset(0,38) A_FireCustomMissile("PPSh41Tracer", frandom(-2.5,2.5),1,0,0,0,frandom(-1.0,1.0));
        PPSG A 0 A_ZoomFactor(0.98);
        PPSF A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        PPSG A 0 A_SetPitch(pitch-0.5);
        PPSG A 0 A_SetPitch(pitch-0.5);
        PPSG A 1 A_FireCustomMissile("PistolCasingSpawn",0,0,2,-2);
        PPSG A 0 A_SetAngle(angle+random(-1,1));
        PPSG A 0 A_ZoomFactor(1.0);
        PPSG A 0 A_Refire;
        Goto RealReady;

    Spawn:
        PPSP A -1;
        Stop;

    Dryfire:
        PPSG A 0 A_JumpIfInventory("TokarevClip",1,"Reload");
        PPSG A 0 A_PlaySound("PPSh/Dryfire",7);
        Goto RealReady;

    Reload:
        PPSG A 0 A_JumpIfInventory("PPShLoaded",71,2);
        PPSG A 0 A_JumpIfNoAmmo(1);
        Goto ProperReload;
        PPSG A 1;
        Goto RealReady;

    ProperReload:
        PPSG A 1 Offset(0,35);
        PPSR A 1 Offset(0,38);
        PPSR B 1 Offset(0,44);
        PPSR C 1 Offset(2,46);
        PPSR D 1 Offset(4,52);
        PPSR E 1 Offset(7,56) A_PlaySound("PPSh/Out",5);
        PPSR E 1 Offset(10,57) A_FireCustomMissile("EmptyPPShDrumSpawn",25,0,8,-32);
        PPSR F 10 Offset(11,58);
        Goto ReloadLoop;

    ReloadLoop:
        PPSR F 3 Offset(11,58) A_CS_FillMagazine("PPShLoaded","TokarevClip",71);
        Goto ReloadFinish;

    ReloadFinish:
        PPSR F 1 Offset(10,58);
        PPSR F 1 Offset(10,61);
        PPSR F 1 Offset(10,65) A_PlaySound("PPSh/In",5);
        PPSR E 1 Offset(10,71);
        PPSR E 1 Offset(10,65);
        PPSR E 1 Offset(10,60);
        PPSR E 1 Offset(10,55);
        PPSR E 1 Offset(10,53);
        PPSR D 1 Offset(10,51);
        PPSR C 1 Offset(9,50);
        PPSR B 1 Offset(8,46);
        PPSR A 1 Offset(7,43);
        PPSG A 1 Offset(5,40);
        PPSG A 1 Offset(3,37);
        PPSG A 1 Offset(1,34);
        PPSG A 1 Offset(0,32);
        Goto RealReady;

    Flash:
        TNT1 A 3 A_Light2;
        TNT1 A 3 A_Light1;
        TNT1 A 0 A_Light0;
        Goto LightDone;

    UseF1GrenadeState:
        PPSG A 0 A_PlaySound("PPSh/Down",8);
        PPSG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowF1;
    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseF1Grenade",1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem",1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseMolotovState:
        PPSG A 0 A_PlaySound("PPSh/Down",8);
        PPSG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowMolotov;
    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseMolotov",1);
        HNGR D 0 A_TakeInventory("MolotovItem",1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseInjectorState:
        PPSG A 0 A_PlaySound("PPSh/Down",8);
        PPSG A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto HealInjector;
    HealInjector:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
                TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_TakeInventory("StimInjectorItem", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        TNT1 A 0 { GiveBody(40); }
        TNT1 A 0 A_SpawnItemEx("StimInjectorBurst", 0, 0, 32, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;
    AfterUse:
        PPSG A 0 A_PlaySound("PPSh/Up",9);
        TNT1 A 2 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(67,100,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(32,69,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(10,47,WOF_INTERPOLATE);
        PPSG A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;
    }
}

class PPShLoaded : Ammo
{
    Default
    {
        Inventory.MaxAmount 71;
    }
}

// ============================================================================
// 14. TT-33
// ============================================================================
class TT33 : ClearSkyWeapon
{
    Default
    {
        Scale 0.4;
        Tag "TT-33";
        Weapon.Kickback 50;
        Weapon.AmmoType "TT33Loaded";
        Weapon.AmmoUse1 0;
        Weapon.AmmoGive1 8;
        Weapon.AmmoType2 "TokarevClip";
        Weapon.AmmoUse2 1;
        Weapon.AmmoGive2 30;
        Inventory.PickupMessage "You got the TT-33!";
        +Weapon.Ammo_Optional;
        +Weapon.Alt_Ammo_Optional;
        +Weapon.Ammo_CheckBoth;
        +Weapon.NoAutoFire;
    }

    States
    {
    Ready:
        T33G B 0 A_PlaySound("TT33/Up",9);
        T33G A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;

    RealReady:
        T33G A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        T33G A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        T33G A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        T33G A 0 A_JumpIfInventory("TT33Loaded",0,2);
        T33G A 0 A_JumpIfInventory("TokarevClip",1,2);
        T33G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;
        T33G A 0 A_JumpIfInventory("UseMolotov",1,"CS_CheckMolUse");
        T33G A 0 A_JumpIfInventory("UseF1Grenade",1,"CS_CheckF1Use");
        T33G A 0 A_JumpIfInventory("UseStimInjector",1,"CS_CheckStimUse");
        T33G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Loop;

    Deselect:
        T33G B 0 A_PlaySound("TT33/Down",8);
        T33G A 2 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(4,39,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(6,47,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(7,58,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(9,69,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(11,81,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(12,100,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,130,WOF_INTERPOLATE);
        TNT1 A Random(4,9) A_WeaponOffset(12,160,WOF_INTERPOLATE);
        TNT1 A 1 A_Lower;
        Wait;

    Select:
        TNT1 A 0 A_Raise;
        Wait;

    Fire:
        T33G A 0 A_JumpIfInventory("TT33Loaded",1,1);
        Goto Dryfire;
        T33G A 0 A_FireCustomMissile("SmokeSpawner",0,0,0,2);
        T33G A 0 Bright A_GunFlash;
        T33G A 0 A_SetPitch(pitch-0.6);
        T33G A 0 A_PlaySound("TT33/Fire",6);
        T33G A 0 A_ZoomFactor(0.99);
        T33F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        T33G A 0 A_TakeInventory("TT33Loaded",1);
        T33F A 1 Bright A_FireCustomMissile("TT33Tracer", frandom(-1,1),0);
        T33F A 0 A_FireCustomMissile("WeaponRedFlareSpawn",0,0,0,8);
        T33G A 0 A_FireCustomMissile("PistolCasingSpawn",0,0,2,-2);
        T33G A 0 A_ZoomFactor(1.0);
        T33G B 1 A_SetPitch(pitch+0.2);
        T33G B 1 Offset(0,36);
        T33G A 1 Offset(0,41);
        T33G A 1 Offset(0,35) A_SetPitch(pitch+0.2);
        T33G A 1 Offset(0,32);
        T33G A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1);
        Goto RealReady;

    Spawn:
        TT3P A -1;
        Stop;

    Dryfire:
        T33G A 0 A_JumpIfInventory("TokarevClip",1,"Reload");
        T33G A 0 A_PlaySound("TT33/Dryfire",7);
        Goto RealReady;

    Reload:
        T33G A 0 A_JumpIfInventory("TT33Loaded",8,2);
        T33G A 0 A_JumpIfNoAmmo(1);
        Goto ProperReload;
        T33G A 1;
        Goto RealReady;

    ProperReload:
        T33G A 1 Offset(0,35);
        T33R F 1 Offset(0,38) A_PlaySound("TT33/Out",5);
        T33R E 1 Offset(0,44) A_FireCustomMissile("PistolClipSpawn",25,0,8,-32);
        T33R D 1 Offset(2,46);
        T33R C 1 Offset(4,52);
        T33R B 1 Offset(7,56);
        T33R A 1 Offset(10,57);
        T33R A 10 Offset(11,58);
        Goto ReloadLoop;

    ReloadLoop:
        T33R A 3 Offset(11,58) A_CS_FillMagazine("TT33Loaded","TokarevClip",8);
        Goto ReloadFinish;

    ReloadFinish:
        T33R A 1 Offset(10,58);
        T33R A 1 Offset(10,61);
        T33R A 1 Offset(10,65);
        T33R A 1 Offset(10,71);
        T33R A 1 Offset(10,65);
        T33R A 1 Offset(10,60) A_PlaySound("TT33/In",5);
        T33R A 1 Offset(10,55);
        T33R A 1 Offset(10,53);
        T33R B 1 Offset(10,51);
        T33R C 1 Offset(9,50);
        T33R D 1 Offset(8,46);
        T33R E 1 Offset(7,43);
        T33R F 1 Offset(5,40);
        T33G A 1 Offset(3,37);
        T33G A 1 Offset(1,34);
        T33G A 1 Offset(0,32);
        Goto RealReady;

    Flash:
        TNT1 A 3 A_Light2;
        TNT1 A 3 A_Light1;
        TNT1 A 0 A_Light0;
        Goto LightDone;

    UseF1GrenadeState:
        T33G A 0 A_PlaySound("TT33/Down",8);
        T33G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowF1;
    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseF1Grenade",1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem",1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseMolotovState:
        T33G A 0 A_PlaySound("TT33/Down",8);
        T33G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto ThrowMolotov;
    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing",4);
        HNGR D 0 A_TakeInventory("UseMolotov",1);
        HNGR D 0 A_TakeInventory("MolotovItem",1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2,2),0,0,0,0,0);
        HNGR DF 1;
        TNT1 A 4;
        Goto AfterUse;
    UseInjectorState:
        T33G A 0 A_PlaySound("TT33/Down",8);
        T33G A 1 A_WeaponOffset(5,40,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(15,56,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(35,88,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(55,120,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        Goto HealInjector;
    HealInjector:
        TNT1 A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
                TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_TakeInventory("StimInjectorItem", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        TNT1 A 0 { GiveBody(40); }
        TNT1 A 0 A_SpawnItemEx("StimInjectorBurst", 0, 0, 32, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;
    AfterUse:
        T33G A 0 A_PlaySound("TT33/Up",9);
        TNT1 A 2 A_WeaponOffset(75,152,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(67,100,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(32,69,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(10,47,WOF_INTERPOLATE);
        T33G A 1 A_WeaponOffset(2,34,WOF_INTERPOLATE);
        Goto RealReady;
    }
}

class TT33Loaded : Ammo
{
    Default
    {
        Inventory.MaxAmount 8;
    }
}