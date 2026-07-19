class CS_CombatDamageHandler : EventHandler
{
    Array<Actor> qVictim;
    Array<Actor> qInflictor;
    Array<Actor> qSource;
    Array<int> qAmount;
    Array<Name> qDmgType;

    Array<Actor> qExploder;
    Array<int> qExplodeDamage;
    Array<int> qExplodeDist;

    static bool IsCombatTarget(Actor victim, Actor attacker)
    {
        if (!victim || !attacker || victim == attacker)
            return false;
        if (victim.health <= 0)
            return false;
        if (!victim.bSHOOTABLE)
            return false;
        if (CasingBase(victim))
            return false;
        if (CS_MagazineEjecta(victim))
            return false;
        return true;
    }

    clearscope static CS_CombatDamageHandler Get()
    {
        return CS_CombatDamageHandler(EventHandler.Find("CS_CombatDamageHandler"));
    }

    static void Schedule(Actor victim, Actor inflictor, Actor source, int amount, Name dmgType)
    {
        if (!IsCombatTarget(victim, source ? source : inflictor))
            return;
        if (!inflictor)
            inflictor = source;
        if (!source)
            source = inflictor;
        if (!source || amount <= 0)
            return;

        let h = Get();
        if (!h)
            return;

        h.qVictim.Push(victim);
        h.qInflictor.Push(inflictor);
        h.qSource.Push(source);
        h.qAmount.Push(amount);
        h.qDmgType.Push(dmgType);
    }

    static void ScheduleBulletHit(Actor victim, Actor shooter, int amount, Name dmgType)
    {
        if (!IsCombatTarget(victim, shooter))
            return;
        // Use shooter as inflictor — tracers are destroyed on hit and ReadyWeapon may be mid-reload.
        Schedule(victim, shooter, shooter, amount, dmgType);
    }

    static void ScheduleExplode(Actor exploder, int damage, int distance)
    {
        if (!exploder || damage <= 0 || distance <= 0)
            return;

        let h = Get();
        if (!h)
            return;

        h.qExploder.Push(exploder);
        h.qExplodeDamage.Push(damage);
        h.qExplodeDist.Push(distance);
    }

    override void WorldTick()
    {
        let count = qVictim.Size();
        for (uint i = 0; i < count; i++)
        {
            let victim = qVictim[i];
            let source = qSource[i];
            if (victim && source && IsCombatTarget(victim, source))
            {
                Actor inf = qInflictor[i] ? qInflictor[i] : source;
                victim.DamageMobj(inf, source, qAmount[i], qDmgType[i]);
            }
        }
        if (count)
        {
            qVictim.Clear();
            qInflictor.Clear();
            qSource.Clear();
            qAmount.Clear();
            qDmgType.Clear();
        }

        let ecount = qExploder.Size();
        for (uint i = 0; i < ecount; i++)
        {
            let ex = qExploder[i];
            if (ex)
                ex.A_Explode(qExplodeDamage[i], qExplodeDist[i]);
        }
        if (ecount)
        {
            qExploder.Clear();
            qExplodeDamage.Clear();
            qExplodeDist.Clear();
        }
    }
}

// Shared knife hitscan — next-tick damage avoids gore/HUD addon reentrancy on hit.
class CS_WeaponBase : DoomWeapon
{
    action void A_CS_DestroyShieldProtection()
    {
        let ply = player;
        if (!ply || !ply.mo)
            return;

        BlockThingsIterator it = BlockThingsIterator.Create(ply.mo, 192);
        Actor mo;
        while (it.Next())
        {
            mo = it.Thing;
            if (mo && RiotShieldProtection(mo))
                mo.Destroy();
        }
    }

    action void A_CS_KnifeMelee(int damage = 25, double range = 78)
    {
        let ply = player;
        if (!ply || !ply.mo)
            return;

        let mo = ply.mo;

        // PB-style ejecta shove — knife cone instead of a kick key.
        CS_EjectaPush.KnifePush(PlayerPawn(mo), max(range + 10.0, 88.0), 6.5);

        FLineTraceData lt;
        double aimz = ply.viewheight;
        Actor victim = null;

        LineTrace(angle, range, pitch, 0, aimz, data: lt);
        if (CS_CombatDamageHandler.IsCombatTarget(lt.hitActor, mo))
            victim = lt.hitActor;

        if (!victim)
        {
            int step = -6;
            while (step++ < 6 && !victim)
            {
                LineTrace(angle + step * 8, range, pitch, 0, aimz, data: lt);
                if (CS_CombatDamageHandler.IsCombatTarget(lt.hitActor, mo))
                    victim = lt.hitActor;
            }
        }

        if (victim)
            CS_CombatDamageHandler.Schedule(victim, mo, mo, damage, 'Melee');
    }
}

class PingTracer : FastProjectile
{
    Default
    {
        Radius 2;
        Height 2;
        Projectile;
        +NOEXTREMEDEATH;
        RenderStyle "Add";
        Alpha 0.9;
        Scale 0.15;
        Decal "BulletChip";
    }

    override int SpecialMissileHit(Actor victim)
    {
        if (!victim || !target || victim == target)
            return MHIT_DEFAULT;
        if (!CS_CombatDamageHandler.IsCombatTarget(victim, target))
            return MHIT_DEFAULT;

        int dmg = damage;
        if (dmg > 0)
        {
            CS_CombatDamageHandler.ScheduleBulletHit(victim, target, dmg, DamageType);
            return MHIT_DESTROY;
        }
        return MHIT_DEFAULT;
    }

    States
    {
    Spawn:
        TNT1 A 0 NoDelay;
        TRAC A 15 Bright A_PlaySound("Bullet/Whip");
        Loop;
    Death:
        TRAC A 0 Bright;
        Goto XDeath;
    Crash:
        PUF6 A 0 Bright A_Jump(80, "Crash2");
        PUF6 A 0 A_CheckFloor("CrashFloor");
        PUF6 A 0 A_CheckCeiling("CrashCeiling");
        PUF6 A 1 Bright A_PlaySound("Bullet/Ricochet", CHAN_AUTO, 0.3);
        PUF6 A 0 A_SpawnItem("SmokeSpawner");
        PUF6 AAAA 0 A_SpawnDebris("PixelDebris");
        PUF6 B 1 Bright A_SpawnDebris("PingPuff");
        PUF6 C 2 Bright;
        PUF6 D 2 Bright A_SetTranslucent(0.9);
        Stop;
    Crash2:
        PUF6 A 0 A_CheckFloor("CrashFloor2");
        PUF6 A 0 A_CheckCeiling("CrashCeiling2");
        PUF6 E 1 Bright A_PlaySound("Bullet/Ricochet", CHAN_AUTO, 0.3);
        PUF6 AA 0 A_SpawnItem("SmokeSpawner");
        PUF6 AAAA 0 A_SpawnDebris("PixelDebris");
        PUF6 F 1 Bright A_SpawnDebris("PingPuff");
        PUF6 G 2 Bright;
        PUF6 H 2 Bright A_SetTranslucent(0.9);
        Stop;
    CrashFloor:
        PUF6 A 0 A_SpawnItemEx("DetectFloorBullet", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        PUF6 A 1 Bright A_PlaySound("Bullet/Ricochet", CHAN_AUTO, 0.3);
        PUF6 AA 0 A_SpawnItem("SmokeSpawner");
        PUF6 AAAA 0 A_SpawnDebris("PixelDebris");
        PUF6 B 1 Bright A_SpawnDebris("PingPuff");
        PUF6 C 2 Bright;
        PUF6 D 2 Bright A_SetTranslucent(0.9);
        Stop;
    CrashCeiling:
        PUF6 A 0 A_SpawnItemEx("DetectCeilBullet", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        PUF6 A 1 Bright A_PlaySound("Bullet/Ricochet", CHAN_AUTO, 0.3);
        PUF6 AA 0 A_SpawnItem("SmokeSpawner");
        PUF6 AAAA 0 A_SpawnDebris("PixelDebris");
        PUF6 B 1 Bright A_SpawnDebris("PingPuff");
        PUF6 C 2 Bright;
        PUF6 D 2 Bright A_SetTranslucent(0.9);
        Stop;
    CrashFloor2:
        PUF6 A 0 A_SpawnItemEx("DetectFloorBullet", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        PUF6 E 1 Bright A_PlaySound("Bullet/Ricochet", CHAN_AUTO, 0.3);
        PUF6 AA 0 A_SpawnItem("SmokeSpawner");
        PUF6 AAAA 0 A_SpawnDebris("PixelDebris");
        PUF6 F 1 Bright A_SpawnDebris("PingPuff");
        PUF6 G 2 Bright;
        PUF6 H 2 Bright A_SetTranslucent(0.9);
        Stop;
    CrashCeiling2:
        PUF6 A 0 A_SpawnItemEx("DetectCeilBullet", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        PUF6 E 1 Bright A_PlaySound("Bullet/Ricochet", CHAN_AUTO, 0.3);
        PUF6 AA 0 A_SpawnItem("SmokeSpawner");
        PUF6 AAAA 0 A_SpawnDebris("PixelDebris");
        PUF6 F 1 Bright A_SpawnDebris("PingPuff");
        PUF6 G 2 Bright;
        PUF6 H 2 Bright A_SetTranslucent(0.9);
        Stop;
    XDeath:
        TNT1 A 3 A_PlaySound("Bullet/HitFlesh", CHAN_AUTO, 0.3);
        Stop;
    }
}

// Weapon Tracers – single damage value (average of original range)
class Fort12Tracer : PingTracer
{
    Default
    {
        +NOEXTREMEDEATH;
        Damage 10;
        Speed 90;
        Scale 0.2;
    }
}

class PP19Tracer : PingTracer
{
    Default
    {
        +NOEXTREMEDEATH;
        Damage 12;
        Speed 100;
        Scale 0.2;
    }
}

class TT33Tracer : PingTracer
{
    Default
    {
        +NOEXTREMEDEATH;
        Damage 13;
        Speed 105;
        Scale 0.2;
    }
}

class PPSh41Tracer : PingTracer
{
    Default
    {
        +NOEXTREMEDEATH;
        Damage 15;
        Speed 105;
        Scale 0.2;
    }
}

class AK47Tracer : PingTracer
{
    Default
    {
        +NOEXTREMEDEATH;
        Damage 22;
        Speed 115;
        Scale 0.4;
    }
}

class SKSTracer : PingTracer
{
    Default
    {
        +NOEXTREMEDEATH;
        Damage 25;
        Speed 115;
        Scale 0.4;
    }
}

class ShotgunTracer : PingTracer
{
    Default
    {
        +NOEXTREMEDEATH;
        Damage 14;
        Speed 120;
        Scale 0.4;
    }
}

class KS23Tracer : PingTracer
{
    Default
    {
        +NOEXTREMEDEATH;
        Damage 21;
        Speed 115;
        Scale 0.4;
    }
}

class ASVALTracer : PingTracer
{
    Default
    {
        +NOEXTREMEDEATH;
        Damage 21;
        Speed 225;
        Scale 0.4;
    }
}

class GrozaTracer : PingTracer
{
    Default
    {
        +NOEXTREMEDEATH;
        Damage 24;
        Speed 225;
        Scale 0.4;
    }
}

class MosinNagantTracer : PingTracer
{
    Default
    {
        Damage 53;
        Speed 200;
        Scale 0.6;
    }
}

class SVDTracer : PingTracer
{
    Default
    {
        Damage 42;
        Speed 200;
        Scale 0.6;
    }
}

class RP46Tracer : PingTracer
{
    Default
    {
        Damage 50;
        Speed 200;
        Scale 0.6;
    }
}

// Duty variants
class DutyPPSh41Tracer : PingTracer
{
    Default
    {
        +NOEXTREMEDEATH;
        DamageType "Duty";
        Damage 13;
        Speed 100;
        Scale 0.3;
    }
}

class DutyPP19Tracer : PingTracer
{
    Default
    {
        +NOEXTREMEDEATH;
        DamageType "Duty";
        Damage 10;
        Speed 95;
        Scale 0.2;
    }
}

class DutyAK47Tracer : PingTracer
{
    Default
    {
        +NOEXTREMEDEATH;
        DamageType "Duty";
        Damage 18;
        Speed 110;
        Scale 0.4;
    }
}

class DutyASVALTracer : PingTracer
{
    Default
    {
        +NOEXTREMEDEATH;
        DamageType "Duty";
        Damage 17;
        Speed 225;
        Scale 0.4;
    }
}

class DutyGrozaTracer : PingTracer
{
    Default
    {
        +NOEXTREMEDEATH;
        DamageType "Duty";
        Damage 21;
        Speed 225;
        Scale 0.4;
    }
}