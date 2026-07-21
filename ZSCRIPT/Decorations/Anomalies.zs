// Zone map anomalies — chance on host props; shootable cores clear the field.
// Assets: PB BlackHole (ORBP/BHOL/BH05), Staging/PB ice (ICRL/CSC), UKS Frost/Electric aura (VFRA/VLGA/VELA).

class CS_AnomalySpawner play
{
    static double Chance()
    {
        CVar cv = CVar.FindCVar("cs_anomaly_spawn_chance");
        double c = cv ? cv.GetFloat() : 0.22;
        if (c < 0.0) c = 0.0;
        if (c > 1.0) c = 1.0;
        return c;
    }

    // chanceScale > 1 for rare hosts (Duty, blue torches) so they still show up in play.
    static Actor TryAttach(Actor host, class<Actor> cls, double zOff = 24.0, double distMin = 12.0, double distMax = 28.0, double chanceScale = 1.0)
    {
        if (!host || !cls) return null;

        double c = Chance() * chanceScale;
        if (c > 1.0) c = 1.0;
        if (c <= 0.0 || frandom[cs_anom](0.0, 1.0) >= c) return null;

        double dist = (distMax > distMin) ? frandom[cs_anom](distMin, distMax) : distMin;
        double ang = frandom[cs_anom](0.0, 360.0);
        Vector3 pos = host.Vec3Offset(cos(ang) * dist, sin(ang) * dist, zOff);
        Actor mo = Actor.Spawn(cls, pos, ALLOW_REPLACE);
        if (mo)
        {
            mo.Angle = frandom[cs_anom](0.0, 360.0);
            mo.master = host;
        }
        return mo;
    }
}

class CS_AnomalyBase : Actor abstract
{
    Default
    {
        +SHOOTABLE;
        +NOBLOOD;
        +DONTTHRUST;
        +NOGRAVITY;
        +FORCEYBILLBOARD;
        +MOVEWITHSECTOR;
        +BRIGHT;
        -SOLID;
        -COUNTKILL;
        -ISMONSTER;
        Radius 20;
        Height 32;
        Mass 9999;
        Health 40;
        PainChance 0;
    }

    // Floor ring + spray so anomalies read from a distance.
    void A_CS_AnomalyHalo(Color col, double rad = 56.0, int spokes = 10)
    {
        double spin = level.time * 3.0;
        for (int i = 0; i < spokes; i++)
        {
            double a = spin + (360.0 / spokes) * i;
            A_SpawnParticle(col,
                flags: SPF_FULLBRIGHT | SPF_RELATIVE,
                lifetime: 10,
                size: frandom(3.0, 5.5),
                xoff: cos(a) * rad,
                yoff: sin(a) * rad,
                zoff: 4,
                velz: frandom(0.1, 0.6),
                startalphaf: 0.9);
        }
        A_SpawnParticle(col,
            flags: SPF_FULLBRIGHT,
            lifetime: 16,
            size: frandom(4.0, 8.0),
            zoff: height * 0.5,
            velx: frandom(-0.4, 0.4),
            vely: frandom(-0.4, 0.4),
            velz: frandom(0.5, 1.8),
            startalphaf: 0.75);
    }

    void A_CS_AnomalyLight(Color col, double size = 72.0)
    {
        A_AttachLight("CSAnomL1", DynamicLight.PulseLight, col, size, size * 1.25,
            flags: DYNAMICLIGHT.LF_ATTENUATE | DYNAMICLIGHT.LF_NOSHADOWMAP,
            ofs: (0, 0, height * 0.4), param: 1.4);
        A_AttachLight("CSAnomL2", DynamicLight.PointLight, col, size * 0.35, size * 0.45,
            flags: DYNAMICLIGHT.LF_ATTENUATE | DYNAMICLIGHT.LF_NOSHADOWMAP,
            ofs: (0, 0, height * 0.5));
    }

    override void OnDestroy()
    {
        A_StopSound(CHAN_BODY);
        A_StopSound(CHAN_6);
        A_RemoveLight("CSAnomL1");
        A_RemoveLight("CSAnomL2");
        Super.OnDestroy();
    }
}

// ---------------------------------------------------------------------------
// 1) Gravity well — columns (intact + broken)
// ---------------------------------------------------------------------------
class CS_GravityWellAnomaly : CS_AnomalyBase
{
    Default
    {
        Health 50;
        Scale 0.72;
        RenderStyle "Add";
        Alpha 0.95;
        DeathSound "BHole/Explosion";
        Obituary "%o was pulled into a gravitational anomaly.";
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        A_CS_AnomalyLight("8844CC", 96);
    }

    States
    {
    Spawn:
        ORBP A 0 NoDelay
        {
            A_StartSound("Anomaly/PortalAppear", CHAN_AUTO, CHANF_OVERLAP, 0.85);
            A_StartSound("BHole/Suck", CHAN_BODY, CHANF_LOOPING, 0.9);
        }
        Goto Active;
    Active:
        ORBP ABCDCB 2 Bright
        {
            A_CS_AnomalyHalo("AA88FF", 72, 12);
            A_RadiusThrust(-420, 240, RTF_NOIMPACTDAMAGE | RTF_THRUSTZ);
            // No XF_HURTSOURCE — continuous explode was self-killing the anomaly.
            if (random[cs_anom](0, 1) == 0)
                A_Explode(2, 56, 0, false, 40);
            A_SpawnItemEx("CS_AnomalySingularityFX", random(-12, 12), random(-12, 12), random(4, 28), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        }
        Loop;
    Death:
        ORBP A 0
        {
            A_StopSound(CHAN_BODY);
            A_RemoveLight("CSAnomL1");
            A_RemoveLight("CSAnomL2");
            A_StartSound("Anomaly/PortalFade", CHAN_AUTO, CHANF_OVERLAP, 0.8);
            A_StartSound("BHole/Explosion", CHAN_AUTO, CHANF_OVERLAP, 1.0);
            A_RadiusThrust(500, 220, RTF_NOIMPACTDAMAGE | RTF_THRUSTZ);
            A_Explode(20, 96, XF_HURTSOURCE, false, 64);
        }
        BHOL ABCDEFGHI 2 Bright A_FadeOut(0.08);
        Stop;
    }
}

class CS_AnomalySingularityFX : Actor
{
    Default
    {
        +NOBLOCKMAP;
        +NOGRAVITY;
        +CLIENTSIDEONLY;
        +BRIGHT;
        RenderStyle "Add";
        Scale 0.45;
        Alpha 0.9;
    }
    States
    {
    Spawn:
        BH05 ABCDEFGHIJKLMNO 1 Bright;
        BH05 PQRSTUVWXYZ 1 Bright;
        Stop;
    }
}

// ---------------------------------------------------------------------------
// 2) Frost — blue/green torches
// ---------------------------------------------------------------------------
class CS_AnomalyChill : Powerup
{
    Default
    {
        Powerup.Duration -2;
        +INVENTORY.AUTOACTIVATE;
    }

    override void DoEffect()
    {
        Super.DoEffect();
        if (!Owner || !(Owner is "PlayerPawn")) return;
        Owner.Speed = Owner.Default.Speed * 0.55;
        if (level.time % 8 == 0)
            Owner.A_SetBlend("6080FF", 0.12, 10);
    }

    override void EndEffect()
    {
        if (Owner)
            Owner.Speed = Owner.Default.Speed;
        Super.EndEffect();
    }
}

class CS_AnomalyChillGiver : PowerupGiver
{
    Default
    {
        Powerup.Type "CS_AnomalyChill";
        Powerup.Duration -2;
        +INVENTORY.AUTOACTIVATE;
        +INVENTORY.ALWAYSPICKUP;
    }
}

class CS_FrostAnomaly : CS_AnomalyBase
{
    Array<Actor> crystals;

    Default
    {
        Health 45;
        Scale 1.05;
        RenderStyle "Add";
        Alpha 1.0;
        DeathSound "IceBreakMedium";
        Obituary "%o froze near a Zone frost anomaly.";
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        A_CS_AnomalyLight("88CCFF", 110);
        A_StartSound("FrostAura/aura", CHAN_BODY, CHANF_LOOPING, 0.65);
        int n = random[cs_anom](3, 5);
        for (int i = 0; i < n; i++)
        {
            double ang = frandom[cs_anom](0, 360);
            double dist = frandom[cs_anom](20, 48);
            Actor c = Spawn("CS_AnomalyIceCrystal", Vec3Offset(cos(ang) * dist, sin(ang) * dist, 0), ALLOW_REPLACE);
            if (c)
            {
                c.master = self;
                crystals.Push(c);
            }
        }
    }

    override void Tick()
    {
        Super.Tick();
        if (health <= 0 || bDestroyed) return;

        if (level.time % 3 == 0)
            A_CS_AnomalyHalo("C0E8FF", 64, 10);

        if (level.time % 10 != 0) return;

        let it = BlockThingsIterator.Create(self, 200);
        while (it.Next())
        {
            Actor t = it.Thing;
            if (!t || t == self || Distance3D(t) > 200) continue;

            if (t is "PlayerPawn")
            {
                t.A_DamageSelf(1, "Ice", flags: 0);
                t.A_GiveInventory("CS_AnomalyChillGiver", 1);
            }
            else if (t.bIsMonster && !t.bKilled && CheckSight(t))
            {
                if (t.tics > 0)
                    t.tics += random[cs_anom](1, 3);
                Actor fro = Spawn("CS_AnomalyFrostBite", t.pos);
                if (fro)
                {
                    fro.target = self;
                    fro.A_SetSize(t.radius, t.height);
                    fro.DoMissileDamage(t);
                }
            }
        }

        for (int i = 0; i < 3; i++)
        {
            A_SpawnParticle("E8F0FF", flags: SPF_FULLBRIGHT, lifetime: 90, size: frandom(2.0, 4.0),
                xoff: frandom(-120, 120), yoff: frandom(-120, 120), zoff: 80,
                velx: frandom(-0.2, 0.2), vely: frandom(-0.2, 0.2), velz: frandom(-2.5, -1.0),
                startalphaf: 0.65);
        }
    }

    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
    {
        A_StopSound(CHAN_BODY);
        A_RemoveLight("CSAnomL1");
        A_RemoveLight("CSAnomL2");
        for (int i = 0; i < crystals.Size(); i++)
        {
            if (crystals[i] && !crystals[i].bDestroyed)
                crystals[i].DamageMobj(self, self, crystals[i].health + 10, "None");
        }
        crystals.Clear();
        Super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }

    States
    {
    Spawn:
        VFRA ABCDEFGHGFEDCB 3 Bright;
        Loop;
    Death:
        VFRA A 0
        {
            A_StopSound(CHAN_BODY);
            A_StartSound("IceBreakLarge", CHAN_AUTO, CHANF_OVERLAP, 1.0);
            A_StartSound("IceMelt", CHAN_AUTO, CHANF_OVERLAP, 0.8);
            for (int i = 0; i < 8; i++)
                A_SpawnItemEx("CS_AnomalyIceShard", 0, 0, 8, frandom(-3, 3), frandom(-3, 3), frandom(1, 5), random(0, 360), SXF_NOCHECKPOSITION);
        }
        VFRA ABCDEFGH 2 Bright A_FadeOut(0.1);
        Stop;
    }
}

class CS_AnomalyFrostBite : Actor
{
    Default
    {
        +NOBLOCKMAP;
        +NOGRAVITY;
        +PAINLESS;
        +BLOODLESSIMPACT;
        DamageFunction random(1, 4);
        DamageType "Ice";
    }
    States
    {
    Spawn:
        TNT1 AAAAAAAAAA 1
        {
            A_SpawnParticle("BFBFFF", lifetime: 40, size: random(2, 5),
                xoff: frandom(-radius, radius), yoff: frandom(-radius, radius), zoff: frandom(height * 0.2, height),
                velx: frandom(-0.8, 0.8), vely: frandom(-0.8, 0.8), velz: frandom(-0.5, 0.5),
                startalphaf: 0.35, fadestepf: -1, sizestep: 0.3);
        }
        Stop;
    }
}

class CS_AnomalyIceCrystal : Actor
{
    Default
    {
        +SHOOTABLE;
        +NOBLOOD;
        +SOLID;
        +DONTTHRUST;
        +FORCEXYBILLBOARD;
        +BRIGHT;
        -COUNTKILL;
        Radius 10;
        Height 28;
        Mass 50000;
        Health 22;
        Scale 0.9;
        DeathSound "IceBreakSmall";
    }

    States
    {
    Spawn:
        ICRL A 0 NoDelay A_Jump(256, "FrA", "FrB", "FrC", "FrD", "FrE");
    FrA:
        ICRL A 6 Bright;
        Loop;
    FrB:
        ICRL B 6 Bright;
        Loop;
    FrC:
        ICRL C 6 Bright;
        Loop;
    FrD:
        ICRL D 6 Bright;
        Loop;
    FrE:
        ICRL E 6 Bright;
        Loop;
    Death:
        ICRL A 0
        {
            A_NoBlocking();
            A_Scream();
            for (int i = 0; i < 5; i++)
                A_SpawnItemEx("CS_AnomalyIceShard", 0, 0, 10, frandom(-4, 4), frandom(-4, 4), frandom(2, 6), random(0, 360), SXF_NOCHECKPOSITION);
        }
        ICRL A 1 A_FadeOut(0.15);
        Wait;
    }
}

class CS_AnomalyIceShard : Actor
{
    Default
    {
        Projectile;
        +CLIENTSIDEONLY;
        +BOUNCEONWALLS;
        +BOUNCEONFLOORS;
        +BRIGHT;
        BounceType "Doom";
        BounceCount 3;
        Speed 6;
        Gravity 0.6;
        -NOGRAVITY;
        Scale 0.5;
        DeathSound "IceShardBounce";
    }
    States
    {
    Spawn:
        CSC1 ABCD 2 Bright;
        Loop;
    Death:
        CSC1 A 1 A_FadeOut(0.2);
        Wait;
    }
}

// ---------------------------------------------------------------------------
// 3) Electro — tech lamps (intact + broken)
// ---------------------------------------------------------------------------
class CS_ElectroNestAnomaly : CS_AnomalyBase
{
    Default
    {
        Health 40;
        Scale 0.85;
        RenderStyle "Add";
        Alpha 1.0;
        DeathSound "ElectricAura/electric";
        Obituary "%o was cooked by an anomalous electro field.";
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        A_CS_AnomalyLight("AADDFF", 100);
        A_StartSound("ElectricAura/aura", CHAN_BODY, CHANF_LOOPING, 0.55);
    }

    override void Tick()
    {
        Super.Tick();
        if (health <= 0 || bDestroyed) return;

        if (level.time % 2 == 0)
            A_CS_AnomalyHalo("99EEFF", 48, 8);

        if (level.time % 14 != 0) return;

        Actor best = null;
        double bestDist = 180;
        let it = BlockThingsIterator.Create(self, 180);
        while (it.Next())
        {
            Actor t = it.Thing;
            if (!t || t == self) continue;
            bool valid = (t is "PlayerPawn") || (t.bIsMonster && !t.bKilled);
            if (!valid || !CheckSight(t)) continue;
            double d = Distance3D(t);
            if (d < bestDist)
            {
                bestDist = d;
                best = t;
            }
        }

        if (best)
        {
            Actor beam = Spawn("CS_AnomalyElectroBeam", pos + (0, 0, height * 0.5));
            if (beam)
            {
                beam.target = self;
                Vector3 mid = (pos + best.pos) * 0.5;
                mid.z = (pos.z + best.pos.z + best.height * 0.4) * 0.5;
                beam.SetOrigin(mid, false);
                beam.Angle = AngleTo(best);
                if (best is "PlayerPawn")
                    best.A_DamageSelf(5, "Electric", flags: 0);
                else
                    best.DamageMobj(self, self, random[cs_anom](4, 8), "Electric");
            }
            A_StartSound("ElectricAura/electric", CHAN_AUTO, CHANF_OVERLAP, 0.55);
            A_SpawnItemEx("GreenBarrelLensFlare", 0, 0, height * 0.6, 0, 0, 0, 0, SXF_CLIENTSIDE);
        }
    }

    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
    {
        A_RemoveLight("CSAnomL1");
        A_RemoveLight("CSAnomL2");
        Super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }

    States
    {
    Spawn:
        VELA ABCDEFGH 3 Bright;
        Loop;
    Death:
        VELA A 0
        {
            A_StopSound(CHAN_BODY);
            A_StartSound("ElectricAura/electric", CHAN_AUTO, CHANF_OVERLAP, 1.0);
            A_Explode(12, 80, XF_HURTSOURCE, false, 64);
        }
        VELA HGFEDCBA 2 Bright A_FadeOut(0.12);
        Stop;
    }
}

class CS_AnomalyElectroBeam : Actor
{
    Default
    {
        +NOBLOCKMAP;
        +NOGRAVITY;
        +CLIENTSIDEONLY;
        +FLATSPRITE;
        +BRIGHT;
        RenderStyle "Add";
        Alpha 0.95;
        Scale 1.1;
    }
    States
    {
    Spawn:
        VLGA A 0 NoDelay A_Jump(256, "B1", "B2", "B3", "B4", "B5");
    B1: VLGA A 4 Bright; Stop;
    B2: VLGA C 4 Bright; Stop;
    B3: VLGA E 4 Bright; Stop;
    B4: VLGA G 4 Bright; Stop;
    B5: VLGA I 4 Bright; Stop;
    }
}

// ---------------------------------------------------------------------------
// 4) Burner — explosive + burning barrels
// ---------------------------------------------------------------------------
class CS_BurnerPlumeAnomaly : CS_AnomalyBase
{
    Default
    {
        Health 35;
        Scale 1.15;
        RenderStyle "Add";
        Alpha 1.0;
        DeathSound "Barrel/Burn";
        DamageType "Fire";
        Obituary "%o was roasted by a Burner anomaly.";
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        A_CS_AnomalyLight("FF6600", 120);
        A_StartSound("Barrel/Burn", CHAN_BODY, CHANF_LOOPING, 0.5);
    }

    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
    {
        A_RemoveLight("CSAnomL1");
        A_RemoveLight("CSAnomL2");
        Super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }

    States
    {
    Spawn:
        CFR3 A 0 NoDelay;
        Goto Active;
    Active:
        CFR3 ABCDEFGH 2 Bright
        {
            A_CS_AnomalyHalo("FFAA44", 52, 8);
            // No XF_HURTSOURCE — continuous explode was self-killing the anomaly.
            A_Explode(3, 72, 0, false, 56);
            A_CustomMissile("FlameTrails", 12, 0, random(0, 360), 2, random(60, 120));
            if (random[cs_anom](0, 2) == 0)
                A_CustomMissile("BurnedSmoke", 16, 0, random(0, 360), 2, random(50, 110));
            if (random[cs_anom](0, 3) == 0)
                A_CustomMissile("MediumExplosionFlames", 10, 0, random(0, 360), 2, random(20, 80));
            if (random[cs_anom](0, 1) == 0)
                A_SpawnItemEx("YellowBarrelLensFlare", 0, 0, 28, 0, 0, 0, 0, SXF_CLIENTSIDE);
        }
        Loop;
    Death:
        CFR3 A 0
        {
            A_StopSound(CHAN_BODY);
            A_StartSound("Explosion/Near", CHAN_AUTO, CHANF_OVERLAP, 0.7);
            A_Explode(28, 112, XF_HURTSOURCE, false, 80);
            for (int i = 0; i < 5; i++)
                A_CustomMissile("MediumExplosionFlames", 8, 0, random(0, 360), 2, random(0, 360));
        }
        CFR3 IJKLMNOP 2 Bright A_FadeOut(0.1);
        Stop;
    }
}

class CS_AnomalyHostHandler : EventHandler
{
    override void WorldThingSpawned(WorldEvent e)
    {
        Actor mo = e.Thing;
        if (!mo) return;
        if (mo is "CS_AnomalyBase" || mo is "CS_AnomalyIceCrystal") return;

        // Gravity — intact OR broken columns (broken is twice as common on maps)
        if (mo is "ClearSkyColumn" || mo is "BrokenColumn")
        {
            CS_AnomalySpawner.TryAttach(mo, "CS_GravityWellAnomaly", 36.0, 20.0, 36.0, 1.35);
            return;
        }

        // Frost — blue (primary) + green torches (more map coverage)
        if (mo is "BlueTorch" || mo is "ShortBlueTorch"
            || mo is "GreenTorch" || mo is "ShortGreenTorch")
        {
            double z = (mo is "ShortBlueTorch" || mo is "ShortGreenTorch") ? 36.0 : 52.0;
            double boost = (mo is "BlueTorch" || mo is "ShortBlueTorch") ? 2.0 : 1.4;
            CS_AnomalySpawner.TryAttach(mo, "CS_FrostAnomaly", z, 16.0, 28.0, boost);
            return;
        }

        // Electro — vanilla tech lamps (custom Clear Sky lamps removed)
        if (mo is "TechLamp" || mo is "TechLamp2")
        {
            double z = (mo is "TechLamp2") ? 44.0 : 60.0;
            CS_AnomalySpawner.TryAttach(mo, "CS_ElectroNestAnomaly", z, 14.0, 24.0, 1.0);
            return;
        }

        // Burner — vanilla explosive / burning barrels
        if (mo is "ExplosiveBarrel" || mo is "BurningBarrel")
        {
            CS_AnomalySpawner.TryAttach(mo, "CS_BurnerPlumeAnomaly", 42.0, 18.0, 30.0, 1.35);
            return;
        }
    }
}
