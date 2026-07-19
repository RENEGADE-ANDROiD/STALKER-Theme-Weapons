// Dedicated thinker stat for spent brass / mags (PB STAT_PB_BULLETS pattern).
const STAT_CS_EJECTA = Thinker.STAT_USER_MAX - 1;

// Knife / walk push for floor ejecta (PB kick impulse, triggered by NR-40 / quick knife — no kick key).
class CS_EjectaPush play
{
    clearscope static Vector3 ViewDir(double ang, double pch)
    {
        double cosp = cos(pch);
        return (cos(ang) * cosp, sin(ang) * cosp, -sin(pch));
    }

    clearscope static bool IsPushableEjecta(Actor mo)
    {
        if (!mo)
            return false;
        return CasingBase(mo) || CS_MagazineEjecta(mo);
    }

    static bool TryPushOne(PlayerPawn pl, Actor mo, Vector3 dir, Vector2 fwdHoriz, double radius, double power)
    {
        if (!pl || !mo || mo == pl)
            return false;
        double dist = pl.Distance2D(mo);
        if (dist > radius || dist < 1.)
            return false;
        double dz = mo.pos.z - pl.pos.z;
        if (dz < -48 || dz > 42)
            return false;
        Vector2 toMo = mo.pos.xy - pl.pos.xy;
        double tlen = toMo.Length();
        if (tlen < 0.001)
            return false;
        toMo /= tlen;
        if (fwdHoriz.X * toMo.X + fwdHoriz.Y * toMo.Y < 0.42)
            return false;

        double falloff = clamp(1.0 - dist / radius, 0.22, 1.0);
        double massMul = clamp(9.0 / max(double(mo.Mass), 1.0), 0.28, 2.85);
        Vector3 impulse = dir * (power * falloff * massMul);
        impulse.Z += 2.75 * falloff * massMul;
        mo.Vel += impulse;
        if (mo.bROLLSPRITE)
            mo.A_SetRoll(mo.roll + frandom(-28., 28.), SPF_INTERPOLATE);
        return true;
    }

    // Call from knife melee — cone impulse on nearby ejecta (PB A_PB_KickClientsideEjecta).
    static void KnifePush(PlayerPawn pl, double radius = 88., double power = 7.)
    {
        if (!pl || !pl.player)
            return;

        Vector3 dir = ViewDir(pl.angle, pl.pitch);
        Vector2 fwdHoriz = (cos(pl.angle), sin(pl.angle));
        int budget = 52;
        bool any = false;

        ThinkerIterator it = ThinkerIterator.Create("Actor", STAT_CS_EJECTA);
        Actor mo;
        while (mo = Actor(it.Next()))
        {
            if (budget <= 0)
                break;
            if (!IsPushableEjecta(mo))
                continue;
            if (!TryPushOne(pl, mo, dir, fwdHoriz, radius, power))
                continue;
            budget--;
            any = true;
        }

        if (any)
            pl.A_StartSound("Weapons/Casing", CHAN_AUTO, CHANF_DEFAULT, 0.48, ATTN_IDLE);
    }
}

// PB-style ejected magazines / drums (clientside missiles; knife-pushable via STAT_CS_EJECTA).
class CS_MagazineEjecta : Actor abstract
{
	int settleTics;

	override void BeginPlay()
	{
		Super.BeginPlay();
		ChangeStatNum(STAT_CS_EJECTA);
	}

	// Spawn/Exist tumble (frames + A_SetRoll) must stop once the mag rests —
	// Doom bounce can leave +MISSILE mags looping Exist forever on the floor.
	override void Tick()
	{
		Super.Tick();
		CS_EjectaSettle.TrySettle(self, settleTics);
	}
}

class CasingBase : Actor
{
	int settleTics;

	Default
	{
		// Low mass + Doom bounce (not +MISSILE: we need +SOLID/+PUSHABLE so the player can shove brass).
		-NOGRAVITY;
		+WINDTHRUST;
		+CLIENTSIDEONLY;
		+MOVEWITHSECTOR;
		+SOLID;
		+PUSHABLE;
		BounceType "Doom";
		BounceFactor 0.5;
		WallBounceFactor 0.22;
		+NOTELEPORT;
		+FORCEXYBILLBOARD;
		+NOTDMATCH;
		Mass 1;
	}

	override void BeginPlay()
	{
		Super.BeginPlay();
		ChangeStatNum(STAT_CS_EJECTA);
	}

	// Without +MISSILE, floor impact never enters Death — Spawn frame loops look like
	// endless spinning on the ground. Settle when nearly still on the floor.
	override void Tick()
	{
		Super.Tick();
		CS_EjectaSettle.TrySettle(self, settleTics);
	}

	override void Touch(Actor other)
	{
		Super.Touch(other);
		if (!other || !other.player) return;
		double spd = sqrt(other.vel.x * other.vel.x + other.vel.y * other.vel.y);
		if (spd < 1.25) return;
		vector2 v = (other.vel.x, other.vel.y);
		double vl = v.Length();
		if (vl < 0.001) return;
		v /= vl;
		double imp = min(spd * 0.14, 3.8);
		double vz = 0.0;
		if (abs(other.vel.z) > 0.35)
			vz = (other.vel.z > 0 ? 1.0 : -1.0) * min(spd / 10.0, 0.35);
		vel += (v.x * imp, v.y * imp, vz);
	}
}

// Shared floor-settle helper for brass + magazines.
class CS_EjectaSettle play
{
	static void TrySettle(Actor mo, out int settleTics)
	{
		if (!mo || !mo.CurState)
			return;
		if (mo.InStateSequence(mo.CurState, mo.ResolveState("Death")))
			return;

		bool onFloor = (mo.pos.z <= mo.floorz + 1.0) || mo.bOnMObj;
		if (onFloor && mo.Vel.Length() < 1.15)
		{
			settleTics++;
			if (settleTics >= 3)
			{
				mo.Vel = (0, 0, 0);
				if (mo.bROLLSPRITE)
					mo.A_SetRoll(0);
				mo.SetStateLabel("Death");
			}
		}
		else
		{
			settleTics = 0;
		}
	}
}

// Pistol Casings
class PistolCasingSpawn : Actor
{
    Default
    {
        Speed 25;
        Projectile;
        +NOCLIP;
        +CLIENTSIDEONLY;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 1 A_CustomMissile("PistolCasing", -5, 0, random(-80, -100), 2, random(45, 80));
        Stop;
    }
}

class PistolCasing : CasingBase
{
    Default
    {
        Radius 3;
        Height 3;
        Speed 9;
        Scale 0.12;
        WallBounceSound "Weapons/Casing";
        BounceSound "Weapons/Casing";
    }
    States
    {
    Spawn:
        TNT1 A 0 A_SpawnItemEx("CasingSmokes", flags:SXF_CLIENTSIDE);
        PCAS ABCDEFGH 1;
        Loop;
    Death:
        TNT1 A 0;
        TNT1 A 0 A_Jump(256, "Death1", "Death2");
    Death1:
        PCAS AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 8 A_SpawnItemEx("CasingSmokesEnd", flags:SXF_CLIENTSIDE);
        PCAS AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 8;
        PCAS AAAAAA 1 A_FadeOut(0.1);
        Stop;
    Death2:
        PCAS EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE 8 A_SpawnItemEx("CasingSmokesEnd", flags:SXF_CLIENTSIDE);
        PCAS EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE 8;
        PCAS EEEEEE 1 A_FadeOut(0.1);
        Stop;
    }
}

class PistolClipSpawn : Actor
{
    Default
    {
        Speed 20;
        Projectile;
        +NOCLIP;
        +CLIENTSIDEONLY;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 1 A_CustomMissile("PistolClip", 0, 0, random(80, 100), 2, random(40, 60));
        Stop;
    }
}

class PistolClip : CasingBase
{
    Default
    {
        Radius 3;
        Height 3;
        Speed 4;
        Scale 0.5;
        WallBounceSound "Weapons/PistolClip";
        BounceSound "Weapons/PistolClip";
    }
    States
    {
    Spawn:
        PCLP ABCDEFGH 1;
        Loop;
    Death:
        TNT1 A 0;
        TNT1 A 0 A_Jump(256, "Death1", "Death2");
    Death1:
        PCLP CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC 8;
        PCLP CCCCCC 1 A_FadeOut(0.1);
        Stop;
    Death2:
        PCLP GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG 8;
        PCLP GGGGGG 1 A_FadeOut(0.1);
        Stop;
    }
}

class EmptyPPShDrumSpawn : Actor
{
    Default
    {
        Speed 20;
        Projectile;
        +NOCLIP;
        +CLIENTSIDEONLY;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 1 A_CustomMissile("EmptyPPShDrum", 0, 0, random(80, 100), 2, random(40, 60));
        Stop;
    }
}

class EmptyPPShDrum : CS_MagazineEjecta
{
    Default
    {
        Radius 9;
        Height 12;
        Speed 4;
        Scale 0.5;
        BounceType "Doom";
        -NOGRAVITY;
        +WINDTHRUST;
        +CLIENTSIDEONLY;
        +MOVEWITHSECTOR;
        +MISSILE;
        +NOBLOCKMAP;
        -DROPOFF;
        +NOTELEPORT;
        +FORCEXYBILLBOARD;
        +NOTDMATCH;
        +GHOST;
        +ROLLSPRITE;
        +ROLLCENTER;
        Mass 1;
        SeeSound "weapons/largemagdrop";
        WallBounceSound "Weapons/PistolClip";
        BounceSound "Weapons/PistolClip";
    }
    States
    {
    Spawn:
        PPSD A 1 A_SetRoll(roll + 90);
    Exist:
        PPSD ABCDEFGH 1 A_SetRoll(roll + 8, SPF_INTERPOLATE);
        Loop;
    Death:
        PPSD A 0 A_SetScale(0.3);
        PPSD IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII 8;
        PPSD IIIIII 1 A_FadeOut(0.1);
        Stop;
    }
}

// Rifle Casings
class RifleCasingSpawn : Actor
{
    Default
    {
        Speed 25;
        Projectile;
        +NOCLIP;
        +CLIENTSIDEONLY;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 1 A_CustomMissile("RifleCasing", -5, 0, random(-80, -100), 2, random(45, 80));
        Stop;
    }
}

class RifleCasing : CasingBase
{
    Default
    {
        Radius 3;
        Height 3;
        Speed 9;
        Scale 0.15;
        WallBounceSound "Weapons/Casing";
        BounceSound "Weapons/Casing";
    }
    States
    {
    Spawn:
        TNT1 A 0 A_SpawnItemEx("CasingSmokes", flags:SXF_CLIENTSIDE);
        RCAS ABCDEFGH 1;
        Loop;
    Death:
        TNT1 A 0;
        TNT1 A 0 A_Jump(256, "Death1", "Death2", "Death3", "Death4");
    Death1:
        RCAS IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII 8 A_SpawnItemEx("CasingSmokesEnd", flags:SXF_CLIENTSIDE);
        RCAS IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII 8;
        RCAS IIIIII 1 A_FadeOut(0.1);
        Stop;
    Death2:
        RCAS JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ 8 A_SpawnItemEx("CasingSmokesEnd", flags:SXF_CLIENTSIDE);
        RCAS JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ 8;
        RCAS JJJJJJ 1 A_FadeOut(0.1);
        Stop;
    Death3:
        RCAS KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK 8 A_SpawnItemEx("CasingSmokesEnd", flags:SXF_CLIENTSIDE);
        RCAS KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK 8;
        RCAS KKKKKK 1 A_FadeOut(0.1);
        Stop;
    Death4:
        RCAS LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL 8 A_SpawnItemEx("CasingSmokesEnd", flags:SXF_CLIENTSIDE);
        RCAS LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL 8;
        RCAS LLLLLL 1 A_FadeOut(0.1);
        Stop;
    }
}

class AKClipSpawn : Actor
{
    Default
    {
        Speed 20;
        Projectile;
        +NOCLIP;
        +CLIENTSIDEONLY;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 1 A_CustomMissile("AKClip", 0, 0, random(80, 100), 2, random(40, 60));
        Stop;
    }
}

class AKClip : CasingBase
{
    Default
    {
        Radius 3;
        Height 3;
        Speed 4;
        Scale 0.6;
        WallBounceSound "Weapons/RifleClip";
        BounceSound "Weapons/RifleClip";
    }
    States
    {
    Spawn:
        AKCL ABCDEFGH 1;
        Loop;
    Death:
        AKCL GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG 8;
        AKCL GGGGGG 1 A_FadeOut(0.1);
        Stop;
    }
}

class MachineGunCasingSpawn : Actor
{
    Default
    {
        Speed 25;
        Projectile;
        +NOCLIP;
        +CLIENTSIDEONLY;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 1 A_CustomMissile("RifleCasing", -2, 0, random(-80, -100), 2, random(45, 80));
        TNT1 A 1 A_CustomMissile("MGLinks", -4, 0, random(-80, -100), 2, random(40, 80));
        Stop;
    }
}

class MGLinks : CasingBase
{
    Default
    {
        Radius 3;
        Height 3;
        Speed 9;
        Scale 0.25;
        WallBounceSound "Weapons/Casing";
        BounceSound "Weapons/Casing";
    }
    States
    {
    Spawn:
        TNT1 A 0 A_SpawnItemEx("CasingSmokes", flags:SXF_CLIENTSIDE);
        CLIN ABCDEFGH 1;
        Loop;
    Death:
        TNT1 A 0;
        TNT1 A 0 A_Jump(256, "Death1", "Death2");
    Death1:
        CLIN BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 8 A_SpawnItemEx("CasingSmokesEnd", flags:SXF_CLIENTSIDE);
        CLIN BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 8;
        CLIN BBBBBB 1 A_FadeOut(0.1);
        Stop;
    Death2:
        CLIN FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF 8 A_SpawnItemEx("CasingSmokesEnd", flags:SXF_CLIENTSIDE);
        CLIN FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF 8;
        CLIN FFFFFF 1 A_FadeOut(0.1);
        Stop;
    }
}

class ExplosiveCasingSpawn : Actor
{
    Default
    {
        Speed 25;
        Projectile;
        +NOCLIP;
        +CLIENTSIDEONLY;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 1 A_CustomMissile("ExplosiveCasing", -5, 0, random(-80, -100), 2, random(45, 80));
        Stop;
    }
}

class ExplosiveCasing : CasingBase
{
    Default
    {
        Scale 0.6;
        Gravity 0.8;
        Speed 12;
        WallBounceSound "Weapons/50CalCasing";
        BounceSound "Weapons/50CalCasing";
    }
    States
    {
    Spawn:
        TNT1 A 0 A_SpawnItemEx("CasingSmokes", flags:SXF_CLIENTSIDE);
        EXPC AABBCCDDEEFF 1;
        Loop;
    Death:
        TNT1 A 0;
        TNT1 A 0 A_Jump(256, "Death1", "Death2");
    Death1:
        EXPC CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC 8 A_SpawnItemEx("CasingSmokesEnd", flags:SXF_CLIENTSIDE);
        EXPC CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC 8;
        EXPC CCCCCC 1 A_FadeOut(0.1);
        Stop;
    Death2:
        EXPC FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF 8 A_SpawnItemEx("CasingSmokesEnd", flags:SXF_CLIENTSIDE);
        EXPC FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF 8;
        EXPC FFFFFF 1 A_FadeOut(0.1);
        Stop;
    }
}

// Shotgun Casings
class ShotgunCasingSpawn : Actor
{
    Default
    {
        Speed 25;
        Projectile;
        +NOCLIP;
        +CLIENTSIDEONLY;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 1 A_CustomMissile("NewShotgunCasing", 0, 0, random(-80, -100), 2, random(40, 60));
        Stop;
    }
}

class TOZ34CasingSpawn : ShotgunCasingSpawn
{
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 Thing_ChangeTID(0, 390);
        TNT1 A 1;
        Goto Death;
    Death:
        TNT1 A 0 A_CustomMissile("NewShotgunCasing", 0, 0, random(80, 100), 2, random(50, 70));
        Stop;
    }
}

class Vepr12CasingSpawn : Actor
{
    Default
    {
        Speed 25;
        Projectile;
        +NOCLIP;
        +CLIENTSIDEONLY;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 1 A_CustomMissile("NewShotgunCasing", -5, 0, random(-80, -100), 2, random(45, 80));
        Stop;
    }
}

class NewShotgunCasing : CasingBase
{
    Default
    {
        Radius 3;
        Height 3;
        Speed 9;
        Scale 0.25;
        WallBounceSound "Weapons/Shell";
        BounceSound "Weapons/Shell";
    }
    States
    {
    Spawn:
        TNT1 A 0 A_SpawnItemEx("CasingSmokes", flags:SXF_CLIENTSIDE);
        SCAS ABCDEFGH 1;
        Loop;
    Death:
        TNT1 A 0;
        TNT1 A 0 A_Jump(256, "Death1", "Death2", "Death3", "Death4", "Death5", "Death6");
    Death1:
        SCAS IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII 8 A_SpawnItemEx("CasingSmokesEnd", flags:SXF_CLIENTSIDE);
        SCAS IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII 8;
        SCAS IIIIII 1 A_FadeOut(0.1);
        Stop;
    Death2:
        SCAS JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ 8 A_SpawnItemEx("CasingSmokesEnd", flags:SXF_CLIENTSIDE);
        SCAS JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ 8;
        SCAS JJJJJJ 1 A_FadeOut(0.1);
        Stop;
    Death3:
        SCAS KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK 8 A_SpawnItemEx("CasingSmokesEnd", flags:SXF_CLIENTSIDE);
        SCAS KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK 8;
        SCAS KKKKKK 1 A_FadeOut(0.1);
        Stop;
    Death4:
        SCAS LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL 8 A_SpawnItemEx("CasingSmokesEnd", flags:SXF_CLIENTSIDE);
        SCAS LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL 8;
        SCAS LLLLLL 1 A_FadeOut(0.1);
        Stop;
    Death5:
        SCAS MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM 8 A_SpawnItemEx("CasingSmokesEnd", flags:SXF_CLIENTSIDE);
        SCAS MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM 8;
        SCAS MMMMMM 1 A_FadeOut(0.1);
        Stop;
    Death6:
        SCAS NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN 8 A_SpawnItemEx("CasingSmokesEnd", flags:SXF_CLIENTSIDE);
        SCAS NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN 8;
        SCAS NNNNNN 1 A_FadeOut(0.1);
        Stop;
    }
}

class KS23CasingSpawn : Actor
{
    Default
    {
        Speed 25;
        Projectile;
        +NOCLIP;
        +CLIENTSIDEONLY;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 1 A_CustomMissile("KS23Casing", 0, 0, random(-80, -100), 2, random(40, 60));
        Stop;
    }
}

class KS23Casing : NewShotgunCasing
{
    Default
    {
        Radius 3;
        Height 3;
        Speed 12;
        Scale 0.38;
    }
}