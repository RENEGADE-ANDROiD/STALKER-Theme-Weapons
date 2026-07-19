// Zone affliction controllers (STALKER-themed traits).

class SEM_ChemicalController : SEM_BaseController
{
	override Color GetParticleColour()
	{
		static const Color Colours[] = { "00b300", "008000", "88ff88", "66aa00" };
		return Colours[random(0, Colours.Size() - 1)];
	}

	override void GiveToken() { host.A_GiveInventory("SEM_ChemicalToken"); }

	override void InitEffect() { eftic = 10; }

	override void TickEffect()
	{
		if (host.target)
		{
			host.A_SpawnItemEx("SEM_ChemicalCreep",
				xofs: -16, yofs: frandom(-16.0, 16.0),
				angle: frandom(0.0, 360.0), flags: SXF_SETTARGET);
		}
	}
}

class SEM_ThermalController : SEM_BaseController
{
	override Color GetParticleColour()
	{
		static const Color Colours[] = { "ff9900", "ff5c33", "ff3300", "ffcc66" };
		return Colours[random(0, Colours.Size() - 1)];
	}

	override void GiveToken() { host.A_GiveInventory("SEM_ThermalToken"); }

	override void DeathEffect()
	{
		host.A_SpawnItemEx("SEM_ThermalBurst", 0, 0, host.Height * 0.5,
			0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_SETTARGET);
	}
}

class SEM_ElectroController : SEM_BaseController
{
	override Color GetParticleColour()
	{
		static const Color Colours[] = { "66ccff", "3399ff", "ffffff", "99eeff" };
		return Colours[random(0, Colours.Size() - 1)];
	}

	override void GiveToken() { host.A_GiveInventory("SEM_ElectroToken"); }

	override void InitEffect() { eftic = 14; }

	override void TickEffect()
	{
		if (!host.target || !host.CheckSight(host.target))
			return;
		if (host.Distance3D(host.target) > 220)
			return;

		if (CosmeticOK())
		{
			for (int i = 0; i < 3; i++)
			{
				host.A_SpawnParticle("66ccff",
					flags: SPF_FULLBRIGHT | SPF_RELPOS,
					lifetime: 12,
					size: frandom(2.0, 4.0),
					angle: frandom(0, 360),
					zoff: frandom(0, host.Height),
					velz: frandom(-0.2, 0.8));
			}
		}

		// Player-only: avoid direct DamageMobj on addon monster stacks.
		if (host.target is "PlayerPawn")
			host.target.A_DamageSelf(4, "Electric", flags: 0);
	}
}

class SEM_GravityController : SEM_BaseController
{
	override Color GetParticleColour()
	{
		static const Color Colours[] = { "8866aa", "aa88cc", "664488", "ccccff" };
		return Colours[random(0, Colours.Size() - 1)];
	}

	override void GiveToken() { host.A_GiveInventory("SEM_GravityToken"); }

	override void InitEffect() { eftic = 6; }

	override void TickEffect()
	{
		if (!host.target || !(host.target is "PlayerPawn"))
			return;
		if (!host.CheckSight(host.target))
			return;

		double dist = host.Distance3D(host.target);
		if (dist < 48 || dist > 280)
			return;

		Vector3 dir = host.pos - host.target.pos;
		dir.z = 0;
		if (dir.Length() < 1)
			return;
		dir = dir.Unit() * 1.8;
		host.target.Vel.x += dir.x;
		host.target.Vel.y += dir.y;
		if (host.target.pos.z <= host.target.floorz + 2)
			host.target.Vel.z += 0.6;
	}
}

class SEM_PsiController : SEM_BaseController
{
	override Color GetParticleColour()
	{
		static const Color Colours[] = { "8844cc", "aa66ff", "cc99ff", "662288" };
		return Colours[random(0, Colours.Size() - 1)];
	}

	override void GiveToken() { host.A_GiveInventory("SEM_PsiToken"); }

	override void InitEffect() { eftic = 18; }

	override void TickEffect()
	{
		if (!host.target || !(host.target is "PlayerPawn"))
			return;
		if (host.Distance3D(host.target) > 320 || !host.CheckSight(host.target))
			return;

		host.target.GiveInventory("SEM_PsiShock", 1);
	}
}

class SEM_BloodsuckerController : SEM_BaseController
{
	override Color GetParticleColour()
	{
		static const Color Colours[] = { "404040", "808080", "cccccc", "222222" };
		return Colours[random(0, Colours.Size() - 1)];
	}

	override void GiveToken() { host.A_GiveInventory("SEM_BloodsuckerToken"); }

	override void InitEffect()
	{
		eftic = 8;
		host.bSHADOW = true;
		host.Alpha = 0.45;
	}

	override void TickEffect()
	{
		if (!host.target || !random(0, 1) || !host.CheckSight(host.target))
			return;

		if (random(0, 1) && host.CheckIfInTargetLOS(30, 0, 500))
		{
			host.A_FaceTarget();
			host.A_ChangeVelocity(0, frandompick(-16, 16), 0, CVF_RELATIVE);
			host.Alpha = 0.25;
			return;
		}

		if (!random(0, 3) && host.CheckIfInTargetLOS(30, 0, 500))
		{
			host.A_FaceTarget();
			host.A_ChangeVelocity(42.0, 0, 2.0, CVF_RELATIVE);
			host.Alpha = 0.55;
			host.A_StartSound("misc/teleport", CHAN_BODY, CHANF_OVERLAP, 0.35, ATTN_NORM, 1.4);
		}
	}
}

class SEM_SnorkController : SEM_BaseController
{
	double factor;

	override Color GetParticleColour()
	{
		static const Color Colours[] = { "ffffb3", "ffff4d", "e6e600", "ffffff" };
		return Colours[random(0, Colours.Size() - 1)];
	}

	override void GiveToken() { host.A_GiveInventory("SEM_SnorkToken"); }

	override void InitEffect()
	{
		eftic = 1;
		factor = 1.5;
	}

	override void TickEffect()
	{
		if (!host || host.health < 1 || host.tics <= 0)
			return;

		double speed = factor * GetSpeedFactor();
		if (prevState != host.curState)
			host.A_SetTics(int(host.tics / speed));
		prevState = host.curState;
	}
}

class SEM_PseudogiantController : SEM_BaseController
{
	override Color GetParticleColour()
	{
		static const Color Colours[] = { "000000", "4d4d4d", "999999", "666666" };
		return Colours[random(0, Colours.Size() - 1)];
	}

	override void GiveToken() { host.A_GiveInventory("SEM_PseudogiantToken"); }

	override void InitEffect()
	{
		host.DamageMultiply *= 2.0;
		host.DamageFactor *= 2.0;
		host.Scale *= 1.1;
	}
}
