// Zone infection growths — sprout on map corpses; shootable; pop into spore / acid pool.

class CS_InfectionGrowth : Actor abstract
{
    Default
    {
        +SHOOTABLE;
        +NOBLOOD;
        +DONTTHRUST;
        +FORCEYBILLBOARD;
        +MOVEWITHSECTOR;
        +FLOORCLIP;
        -SOLID;
        -COUNTKILL;
        -ISMONSTER;
        Radius 12;
        Height 16;
        Mass 500;
        Health 12;
        Scale 0.55;
        DeathSound "Roach/Squish";
        Obituary "%o was choked by anomalous spores.";
    }

    // Chance-spawn a random growth offset on a corpse (map DeadMarine bodies / DeadZombieman, etc.).
    static void TryAttachToCorpse(Actor corpse)
    {
        if (!corpse) return;

        CVar cv = CVar.FindCVar("cs_infection_spawn_chance");
        double chance = cv ? cv.GetFloat() : 0.4;
        if (chance <= 0.0) return;
        if (chance > 1.0) chance = 1.0;
        if (frandom[cs_inf](0.0, 1.0) >= chance) return;

        static const class<Actor> kinds[] = {
            "CS_InfectionEgg",
            "CS_InfectionFleshEgg",
            "CS_InfectionFloorPod",
            "CS_InfectionVein"
        };

        class<Actor> cls = kinds[random[cs_inf](0, kinds.Size() - 1)];
        double dist = frandom[cs_inf](6.0, 22.0);
        double ang = frandom[cs_inf](0.0, 360.0);
        Vector3 pos = corpse.Vec3Offset(
            cos(ang) * dist,
            sin(ang) * dist,
            frandom[cs_inf](0.0, 10.0));

        Actor growth = Spawn(cls, pos, ALLOW_REPLACE);
        if (growth)
        {
            growth.Angle = frandom[cs_inf](0.0, 360.0);
            growth.Scale.X *= frandom[cs_inf](0.85, 1.15);
            growth.Scale.Y = growth.Scale.X;
        }
    }

    void A_CS_InfectionBurst()
    {
        A_NoBlocking();
        A_Scream();
        A_SpawnItemEx("CS_InfectionSporeCloud", 0, 0, 4, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        A_SpawnItemEx("CS_InfectionAcidPuddle", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        A_SpawnItemEx("CS_GrowingAcidPool", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        A_SpawnItemEx("MeatBloodSpotGreen", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);

        for (int i = 0; i < 4; i++)
            A_CustomMissile("GreenSmoke", 8, 0, random(0, 360), 2, random(40, 120));
        for (int i = 0; i < 6; i++)
            A_CustomMissile("GreenBlood", 10, 0, random(0, 360), 2, random(10, 70));
        for (int i = 0; i < 3; i++)
            A_CustomMissile("XDeath2Green", 12, 0, random(0, 360), 2, random(20, 80));
    }
}

class CS_InfectionEgg : CS_InfectionGrowth
{
    Default
    {
        Radius 14;
        Height 20;
        Health 14;
        Scale 0.6;
    }
    States
    {
    Spawn:
        CEGG ABCD 4;
        Loop;
    Death:
        CEGG A 0 A_CS_InfectionBurst();
        TNT1 A 1;
        Stop;
    }
}

class CS_InfectionFleshEgg : CS_InfectionGrowth
{
    Default
    {
        Radius 14;
        Height 20;
        Health 14;
        Scale 0.6;
    }
    States
    {
    Spawn:
        FEGG ABCD 4;
        Loop;
    Death:
        FEGG A 0 A_CS_InfectionBurst();
        TNT1 A 1;
        Stop;
    }
}

class CS_InfectionFloorPod : CS_InfectionGrowth
{
    Default
    {
        Radius 10;
        Height 12;
        Health 10;
        Scale 0.5;
    }
    States
    {
    Spawn:
        FPOD AB 5;
        Loop;
    Death:
        FPOD A 0 A_CS_InfectionBurst();
        TNT1 A 1;
        Stop;
    }
}

class CS_InfectionVein : CS_InfectionGrowth
{
    Default
    {
        Radius 10;
        Height 18;
        Health 8;
        Scale 0.7;
    }
    States
    {
    Spawn:
        VEIN ABC 5;
        Loop;
    Death:
        VEIN A 0 A_CS_InfectionBurst();
        TNT1 A 1;
        Stop;
    }
}

// Manual / editor placement (also used if you summon a random growth).
class CS_InfectionRandom : RandomSpawner
{
    Default
    {
        DropItem "CS_InfectionEgg", 255, 3;
        DropItem "CS_InfectionFleshEgg", 255, 3;
        DropItem "CS_InfectionFloorPod", 255, 4;
        DropItem "CS_InfectionVein", 255, 3;
    }
}

// Damaging spore mist (longer than SEM_ChemicalCreep; soft chemical DoT grant).
class CS_InfectionSporeCloud : Actor
{
    Default
    {
        Radius 20;
        Height 8;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +DONTSPLASH;
        +NOGRAVITY;
        RenderStyle "Stencil";
        StencilColor "44AA22";
        Alpha 0.4;
        DamageType "sem_Chemical";
        Obituary "%o was choked by anomalous spores.";
    }

    States
    {
    Spawn:
        TNT1 A 0 NoDelay
        {
            A_SetScale(frandom(0.8, 1.3));
            A_StartSound("Roach/Squish", CHAN_BODY, CHANF_OVERLAP, 0.45);
        }
        TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 3
        {
            A_Explode(2, 56, XF_HURTSOURCE, false, 56);
            A_RadiusGive("SEM_ChemicalPoison", 56, RGF_PLAYERS | RGF_MONSTERS | RGF_CUBE, 1);
        }
        Stop;
    }
}

// Floor hazard — linger with light chemical ticks while the visual pool sits underneath.
class CS_InfectionAcidPuddle : Actor
{
    Default
    {
        Radius 40;
        Height 6;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +DONTSPLASH;
        +FLOORCLIP;
        -SOLID;
        DamageType "sem_Chemical";
        Obituary "%o stepped in anomalous acid spores.";
    }

    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_SetScale(1.0);
        // ~8 seconds of soft ticks
        TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 6 A_Explode(1, 48, XF_HURTSOURCE, false, 48);
        Stop;
    }
}

// Cosmetic green floor bloom (clientside — pairs with CS_InfectionAcidPuddle).
class CS_GrowingAcidPool : GrowingBloodPool
{
    Default
    {
        Translation "168:191=112:127", "16:47=123:127";
        Decal "GreenBloodSplat";
        Scale 0.35;
    }
}

// Sprout infection pods on map corpses without replacing the body.
class CS_InfectionCorpseHandler : EventHandler
{
    override void WorldThingSpawned(WorldEvent e)
    {
        Actor mo = e.Thing;
        if (!mo) return;

        if (!(mo is "DeadBodyNoFlies"
            || mo is "DeadBodyWithFlies"
            || mo is "GibbedBodyNoFlies"
            || mo is "GibbedBodyWithFlies"
            || mo is "DeadDutyNoFlies"
            || mo is "DeadDutyWithFlies"
            || mo is "DeadZombieman"))
            return;

        CS_InfectionGrowth.TryAttachToCorpse(mo);
    }
}
