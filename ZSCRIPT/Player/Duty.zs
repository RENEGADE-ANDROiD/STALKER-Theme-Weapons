class DutyBase : Actor
{
    Default
    {
        Health 160;
        Radius 20;
        Height 56;
        Speed 8;
        PainChance 200;
        Monster;
        +FLOORCLIP;
        +FRIENDLY;
        +QUICKTORETALIATE;
        +DONTHARMCLASS;
        +DONTHARMSPECIES;
        SeeSound "Duty/See";
        PainSound "Duty/Pain";
        DeathSound "Duty/Death";
        ActiveSound "Duty/Active";
        Obituary "$o was shot by Duty.";
        DamageFactor "Duty", 0.0;
        Species "Duty";
        DropItem "PP19";
    }

    States
    {
    Spawn:
        DTY1 A 0 A_Look;
        DTY1 A 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 A 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 B 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 B 3 A_Wander;
        DTY1 B 0 A_SpawnItem("BootStep", 0, 0, 0, 0);
        DTY1 A 0 A_Look;
        DTY1 C 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 C 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 D 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 D 3 A_Wander;
        DTY1 D 0 A_SpawnItem("BootStep", 0, 0, 0, 0);
        DTY1 A 0 A_Look;
        DTY1 A 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 A 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 B 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 B 3 A_Wander;
        DTY1 B 0 A_SpawnItem("BootStep", 0, 0, 0, 0);
        DTY1 A 0 A_Look;
        DTY1 C 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 C 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 D 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 D 3 A_Wander;
        DTY1 D 0 A_SpawnItem("BootStep", 0, 0, 0, 0);
        DTY1 A 0 A_Look;
        DTY1 A 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 A 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 B 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 B 3 A_Wander;
        DTY1 B 0 A_SpawnItem("BootStep", 0, 0, 0, 0);
        DTY1 A 0 A_Look;
        DTY1 C 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 C 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 D 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 D 3 A_Wander;
        DTY1 D 0 A_SpawnItem("BootStep", 0, 0, 0, 0);
        DTY1 A 0 A_Look;
        DTY1 A 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 A 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 B 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 B 3 A_Wander;
        DTY1 B 0 A_SpawnItem("BootStep", 0, 0, 0, 0);
        DTY1 A 0 A_Look;
        DTY1 C 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 C 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 D 3 A_Wander;
        DTY1 A 0 A_Look;
        DTY1 D 3 A_Wander;
        DTY1 D 0 A_SpawnItem("BootStep", 0, 0, 0, 0);
        DTY1 E 0 A_Look;
        DTY1 E 45 A_ActiveSound;
        DTY1 E 5 A_Look;
        Loop;
    See:
        DTY1 AABB 2 A_Chase;
        DTY1 B 0 A_SpawnItem("BootStep", 0, 0, 0, 0);
        DTY1 CCDD 2 A_Chase;
        DTY1 B 0 A_SpawnItem("BootStep", 0, 0, 0, 0);
        Loop;
    Missile:
        DTY1 A 0 A_JumpIfInventory("DutyPP19Ammo", 64, "Reload");
        DTY1 E 5 A_FaceTarget;
        goto FirePP19;
    FirePP19:
        DTY1 E 0 A_GiveInventory("DutyPP19Ammo", 1);
        DTY1 E 0 A_PlaySound("PP19/Fire", CHAN_WEAPON);
        DTY1 E 0 A_SpawnItem("PistolCasingSpawn", 0, 30, 0);
        DTY1 E 0 A_CustomMissile("SmokeSpawner", 32, 8, 0);
        DTY1 F 1 Bright A_CustomMissile("DutyPP19Tracer", 32, 8, random(-6, 6));
        DTY1 E 2 A_CPosRefire;
        DTY1 A 0 A_JumpIfInventory("DutyPP19Ammo", 64, "Reload");
        Loop;
    Reload:
        DTY1 A 0 A_ChangeFlag("NOPAIN", true);
        DTY1 A 0 A_PlaySound("PP19/Out");
        DTY1 E 45 A_TakeInventory("DutyPP19Ammo", 64);
        DTY1 A 0 A_PlaySound("PP19/In");
        DTY1 A 0 A_ChangeFlag("NOPAIN", false);
        goto See;
    Pain:
        DTY1 G 2;
        DTY1 G 2 A_Pain;
        goto See;
    Death:
        DTY1 H 10;
        DTY1 I 10 A_PlayerScream;
        DTY1 J 10 A_NoBlocking;
        DTY1 K 0 A_CustomMissile("GrowingBloodPool", 0, 0, random(0, 360), 2, random(0, 90));
        DTY1 KLM 10;
        DTY1 N -1;
        Stop;
    XDeath:
        TNT1 AA 0 A_CustomMissile("FlyingBloodParticleFast", 60, 0, random(0, 360), 2, random(0, 90));
        TNT1 AA 0 A_CustomMissile("FlyingBloodParticleBig", 50, 0, random(0, 360), 2, random(30, 90));
        TNT1 AAAA 0 A_CustomMissile("FlyingBloodParticleBig", 30, 0, random(0, 360), 2, random(10, 45));
        TNT1 A 0 A_CustomMissile("XDeath1", 40, 0, random(0, 360), 2, random(10, 45));
        TNT1 AA 0 A_CustomMissile("XDeath1b", 40, 0, random(0, 360), 2, random(45, 50));
        TNT1 AAA 0 A_CustomMissile("XDeath2", 50, 0, random(0, 360), 2, random(10, 45));
        TNT1 AAA 0 A_CustomMissile("XDeath3", 50, 0, random(0, 360), 2, random(10, 45));
        TNT1 AA 0 A_CustomMissile("XDeath4", 50, 0, random(0, 360), 2, random(40, 60));
        TNT1 AA 0 A_CustomMissile("XDeath5", 50, 0, random(0, 360), 2, random(10, 45));
        TNT1 A 0 A_CustomMissile("XDeath7", 50, 0, random(0, 360), 2, random(40, 60));
        TNT1 A 0 A_CustomMissile("XDeath7b", 50, 0, random(0, 360), 2, random(40, 60));
        TNT1 AAA 0 A_CustomMissile("Guts", 32, 0, random(0, 360), 2, random(20, 30));
        TNT1 AA 0 A_CustomMissile("SuperGoreMist", 32, 0, random(0, 360), 2, random(20, 60));
        XMED A 5 A_Stop;
        XMED B 5 A_XScream;
        XMED C 5;
        XMED D 5 A_NoBlocking;
        XMED E 5;
        XMED E -1;
        Stop;
    Crush:
        TNT1 AAAAAAAAAA 0 A_CustomMissile("FlyingBloodParticleCrushed", 0, 0, random(0, 360), 2, random(0, 90));
        TNT1 AA 0 A_CustomMissile("XDeath2", 50, 0, random(0, 360), 2, random(10, 45));
        TNT1 AA 0 A_CustomMissile("XDeath3", 50, 0, random(0, 360), 2, random(10, 45));
        CRSH A -1;
        Stop;
    }
}

class DutyPP19Ammo : Ammo
{
    Default
    {
        Inventory.MaxAmount 64;
    }
}

class DutySupport : DutyBase
{
    Default
    {
        Health 190;
        Speed 9;
        DropItem "None";
    }
}

class DutyPDA : CustomInventory
{
    private static int CountNearbyDuty(PlayerPawn pl, double maxDist)
    {
        int count = 0;
        ThinkerIterator it = ThinkerIterator.Create("DutyBase");
        Thinker th;
        while ((th = it.Next()) != null)
        {
            let duty = DutyBase(Actor(th));
            if (!duty || duty.health <= 0) continue;
            if ((duty.pos - pl.pos).Length() > maxDist) continue;
            count++;
        }
        return count;
    }

    private static DutyBase TrySummonDuty(PlayerPawn pl, double ang, double dist)
    {
        vector3 spot = pl.pos + (cos(ang) * dist, sin(ang) * dist, 8);
        let duty = DutyBase(Spawn("DutySupport", spot));
        if (!duty) return null;
        if (!duty.TestMobjLocation())
        {
            duty.Destroy();
            return null;
        }
        duty.angle = pl.angle;
        Spawn("TeleportFog", spot);
        return duty;
    }

    override bool Use(bool pickup)
    {
        if (!Owner || !(Owner is "PlayerPawn")) return false;

        let pl = PlayerPawn(Owner);
        if (!pl) return false;

        if (CountNearbyDuty(pl, 1024.0) >= 2)
        {
            Owner.A_StartSound("PDA/Use", CHAN_AUTO);
            if (pl.CheckLocalView())
                Console.MidPrint(null, "Duty channel busy: support is already nearby.", true);
            return false;
        }

        DutyBase duty = TrySummonDuty(pl, pl.angle, 72);
        if (!duty) duty = TrySummonDuty(pl, pl.angle + 0.45, 64);
        if (!duty) duty = TrySummonDuty(pl, pl.angle - 0.45, 64);
        if (!duty) duty = TrySummonDuty(pl, pl.angle + 1.2, 56);
        if (!duty) duty = TrySummonDuty(pl, pl.angle - 1.2, 56);

        Owner.A_StartSound("PDA/Use", CHAN_AUTO);
        if (!duty)
        {
            if (pl.CheckLocalView())
                Console.MidPrint(null, "No room to deploy Duty support.", true);
            return false;
        }

        if (pl.CheckLocalView())
            Console.MidPrint(null, "Duty support inbound.", true);
        return true;
    }

    Default
    {
        +COUNTITEM;
        +INVENTORY.INVBAR;
        Inventory.MaxAmount 3;
        Inventory.Icon "HUDPDA";
        Inventory.PickupSound "PDA/Pickup";
        Inventory.UseSound "PDA/Use";
        Inventory.PickupMessage "Picked up a Duty PDA beacon";
        Tag "Duty PDA Beacon";
    }

    States
    {
    Spawn:
        3PDA A Random(28, 180);
        3PDA A 15 A_PlaySound("Duty/Radio", CHAN_AUTO, 0.8, false);
        3PDA A Random(1200, 1800);
        Loop;
    }
}