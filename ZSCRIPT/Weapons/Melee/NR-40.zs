// NR-40 Combat Knife - ZScript version with forward lunge + damage
class NR40 : ClearSkyWeapon
{
    static vector3 VecFromAngles(double angle, double pitch, double mag = 1.0)
    {
        double cosp = cos(pitch);
        return (cos(angle) * cosp, sin(angle) * cosp, -sin(pitch)) * mag;
    }

    action void A_MeleeLungeStart(double range = 200)
    {
        FLineTraceData lt;
        LineTrace(angle, range, pitch, 0, player.viewheight, data:lt);
        if (lt.hitActor && lt.hitActor.bSOLID && !CS_EjectaPush.IsPushableEjecta(lt.hitActor))
            A_Face(lt.hitActor);
    }

    action Actor A_MeleeLungeAttack(double range = 200, name projectile = "None", double spawnheight = -7, bool doLunge = true)
    {
        Actor victim;
        FLineTraceData lt;
        double aimz = player ? player.viewheight : (height * 0.5);
        LineTrace(angle, range, pitch, 0, aimz, data:lt);
        victim = lt.hitActor;
        if (CS_EjectaPush.IsPushableEjecta(victim))
            victim = null;
        int aimCheck = -6;
        while (aimCheck++ < 6 && !victim)
        {
            LineTrace(angle + (aimCheck * 8), range, pitch, 0, aimz, data:lt);
            victim = lt.hitActor;
            if (CS_EjectaPush.IsPushableEjecta(victim))
                victim = null;
        }
        if (victim && victim.bSHOOTABLE)
        {
            A_Face(victim);
            if (doLunge && victim.bSOLID)
            {
                vel = (0,0,0);
                vel += VecFromAngles(angle, pitch, 12);
            }
        }
        if (projectile != "None")
        {
            actor proj = A_FireProjectile(projectile, 0, 0, 0, spawnheight);
            if (proj && victim && victim.bSHOOTABLE)
                proj.SetOrigin(victim.pos, false);
        }
        return victim;
    }

    Default
    {
        Weapon.SlotNumber 1;
        Weapon.SelectionOrder 3700;
        Weapon.Kickback 100;
        Weapon.AmmoUse 0;
        Weapon.AmmoGive 0;
        +WEAPON.WIMPY_WEAPON
        +WEAPON.MELEEWEAPON
        +WEAPON.NOALERT
        +WEAPON.NOAUTOFIRE
        +NOEXTREMEDEATH
        Tag "NR-40 Combat Knife";
        Obituary "%o was shanked by %k";
        Inventory.PickupMessage "Picked up a NR-40 Combat Knife";
        Inventory.PickupSound "NR40/Up";
        AttackSound "NR40/Swing";
        Scale 1.0;
    }

    States
    {
        Spawn:
            NR40 P -1;
            Stop;

        Ready:
            NR40 A 0 A_PlaySound("NR40/Up", 9);
            NR40 A 1 A_WeaponOffset(12, 100, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(11, 81, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(9, 69, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(7, 58, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(6, 47, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(4, 39, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(2, 34, WOF_INTERPOLATE);
            Goto RealReady;

        RealReady:
            NR40 A 0 A_JumpIfInventory("UseMolotov", 1, "CS_CheckMolUse");
            NR40 A 0 A_JumpIfInventory("UseF1Grenade", 1, "CS_CheckF1Use");
            NR40 A 0 A_JumpIfInventory("UseStimInjector", 1, "CS_CheckStimUse");
            NR40 A 1 A_WeaponReady;
            Loop;

        Deselect:
            NR40 A 0 A_PlaySound("NR40/Down", 8);
            NR40 A 1 A_WeaponOffset(2, 34, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(4, 39, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(6, 47, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(7, 58, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(9, 69, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(11, 81, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(12, 100, WOF_INTERPOLATE);
            TNT1 A Random(4,9) A_WeaponOffset(12, 130, WOF_INTERPOLATE);
            TNT1 A Random(4,9) A_WeaponOffset(12, 160, WOF_INTERPOLATE);
            TNT1 A 1 A_Lower;
            Wait;

        Select:
            TNT1 A 0 A_Raise;
            Wait;

        Fire:
            TNT1 A 0 A_MeleeLungeStart(200);
            NR40 A 1 A_CS_KnifeFeelWind();
            NR40 H 1 A_CS_KnifeFeelStep(0.970);
            NR40 B 1 A_CS_KnifeFeelStep(0.965);
            NR40 C 1 A_CS_KnifeFeelStep(0.955);
            NR40 D 1
            {
                A_PlaySound("NR40/Swing", 6);
                A_CS_KnifeFeelCommit();
            }
            NR40 E 1
            {
                A_MeleeLungeAttack(200, "None", -7, true);
                A_CS_KnifeMelee(25, 78);
                Radius_Quake(2, 4, 0, 12, 0);
            }
            NR40 F 1 A_CS_KnifeFeelReturn(0.975);
            NR40 G 1 A_CS_KnifeFeelReturn(0.990);
            NR40 H 1 A_CS_KnifeFeelEnd();
            Goto RealReady;

        // Equipment use states (unchanged from your DECORATE)
        UseF1GrenadeState:
            NR40 A 0 A_PlaySound("NR40/Down", 8);
            NR40 A 1 A_WeaponOffset(5, 40, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(15, 56, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(35, 88, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(55, 120, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(75, 152, WOF_INTERPOLATE);
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
            NR40 A 0 A_PlaySound("NR40/Down", 8);
            NR40 A 1 A_WeaponOffset(5, 40, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(15, 56, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(35, 88, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(55, 120, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(75, 152, WOF_INTERPOLATE);
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

        UseInjectorState:
            NR40 A 0 A_PlaySound("NR40/Down", 8);
            NR40 A 1 A_WeaponOffset(5, 40, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(15, 56, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(35, 88, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(55, 120, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(75, 152, WOF_INTERPOLATE);
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
            NR40 A 0 A_PlaySound("NR40/Up", 9);
            TNT1 A 2 A_WeaponOffset(75, 152, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(67, 100, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(32, 69, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(10, 47, WOF_INTERPOLATE);
            NR40 A 1 A_WeaponOffset(2, 34, WOF_INTERPOLATE);
            Goto RealReady;
    }
}

class NR40Puff : Actor
{
    Default
    {
        +NOBLOCKMAP;
        +NOGRAVITY;
        +PUFFONACTORS;
        RenderStyle "Add";
        Scale 0.2;
        AttackSound "NR40/Wall";
        SeeSound "NR40/Hit";
    }
    States
    {
        Spawn:
            TNT1 A 0 NoDelay A_Jump(255, "Spawn1", "Spawn2");
        Spawn1:
            PUF6 AB 1 Bright;
            PUF6 CD 2 Bright;
            Stop;
        Spawn2:
            PUF6 EF 1 Bright;
            PUF6 GH 2 Bright;
            Stop;
        XDeath:
            TNT1 A 0;
            TNT1 A 1;
            Stop;
    }
}