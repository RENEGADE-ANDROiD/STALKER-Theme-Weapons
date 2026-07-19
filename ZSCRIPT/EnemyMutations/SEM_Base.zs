// Base Thinker controller + severity overlays.

class SEM_BaseController : Thinker
{
	Actor host;
	int tic;
	int eftic;
	int severity;
	State prevState;
	int oldhealth;
	int starthealth;
	int lastHitTick;
	bool particles;
	bool spawnFX;
	bool hitFX;
	bool setup;
	bool raging;
	bool deathHandled;
	int particleTic;
	double baseDamageMultiply;
	bool markers;
	double markerScale;

	virtual void GiveToken() {}
	virtual void InitEffect() {}
	virtual void TickEffect() {}
	virtual void HitEffect() {}
	virtual void DeathEffect() {}

	virtual Color GetParticleColour()
	{
		static const Color DefaultColours[] = { "cccccc", "ffffff", "999999" };
		return DefaultColours[random(0, DefaultColours.Size() - 1)];
	}

	bool CosmeticOK()
	{
		return SEM_Static.CosmeticFXVisible(host);
	}

	void SpawnParticles()
	{
		if (!host || !particles || !CosmeticOK())
			return;

		Color pColor = GetParticleColour();
		if (severity == sem_PhaseShift)
		{
			static const Color Wisp[] = { "aaccff", "ccdfff", "8899ff", "ffffff" };
			pColor = Wisp[random(0, Wisp.Size() - 1)];
		}

		host.A_SpawnParticle(pColor,
			flags: SPF_FULLBRIGHT | SPF_RELPOS,
			lifetime: 35,
			size: frandom(3.0, 5.0),
			angle: frandom(0.0, 359.9),
			xoff: host.Radius,
			zoff: frandom(host.Height * 0.25, host.Height * 0.75),
			velz: frandom(0.3, 0.6),
			accelz: 0.01);
	}

	void SpawnHitFX()
	{
		if (!host || !hitFX || !CosmeticOK())
			return;
		for (int i = 0; i < 4; i++)
		{
			double pAngle = frandom(0.0, 359.9);
			double pVel = frandom(0.4, 1.0);
			host.A_SpawnParticle(GetParticleColour(),
				flags: SPF_FULLBRIGHT | SPF_RELPOS,
				lifetime: 20,
				size: frandom(2.0, 4.0),
				angle: pAngle,
				xoff: frandom(-host.Radius, host.Radius),
				zoff: frandom(host.Height * 0.2, host.Height * 0.8),
				velx: cos(pAngle) * pVel,
				vely: sin(pAngle) * pVel,
				velz: frandom(0.2, 0.8));
		}
	}

	void SpawnBurstFX()
	{
		if (!host || !spawnFX || !CosmeticOK())
			return;
		for (int i = 0; i < 8; i++)
		{
			host.A_SpawnParticle(GetParticleColour(),
				flags: SPF_FULLBRIGHT | SPF_RELPOS,
				lifetime: 26,
				size: frandom(3.0, 6.0),
				angle: frandom(0, 360),
				xoff: frandom(-host.Radius, host.Radius),
				zoff: frandom(0, host.Height),
				velz: frandom(0.4, 1.4));
		}
	}

	double GetHealthFactor(int amt, bool minorboss, bool mainboss)
	{
		double factor = 1.75;
		double fac2 = 1.35;
		if (minorboss) { fac2 = 1.1; factor = 1.4; }
		if (mainboss) { fac2 = 1.0; factor = 1.12; }
		return ((amt * fac2) + 100) * factor;
	}

	void InitSeverity()
	{
		switch (severity)
		{
		case sem_AnomalyGrowth:
			host.Scale *= 1.25;
			host.Health = int(GetHealthFactor(host.Health, host.bBOSSDEATH, host.bBOSS));
			host.DamageMultiply *= 1.5;
			host.PainChance = int(host.PainChance * 0.5);
			host.A_GiveInventory("SEM_AnomalyGrowthToken");
			SpawnBurstFX();
			break;

		case sem_PhaseShift:
			host.bVISIBILITYPULSE = true;
			host.bBRIGHT = true;
			host.A_GiveInventory("SEM_PhaseShiftToken");
			break;

		case sem_EmissionRage:
			host.A_GiveInventory("SEM_EmissionRageToken");
			break;
		}
	}

	void UpdateEmissionRage()
	{
		if (severity != sem_EmissionRage || !host || starthealth < 1)
			return;

		bool should = host.Health <= int(starthealth * 0.5);
		if (should && !raging)
		{
			raging = true;
			host.A_StartSound("misc/pickup", CHAN_BODY, CHANF_NOPAUSE, 0.55, ATTN_NORM, 0.8);
			if (particles && CosmeticOK())
			{
				for (int i = 0; i < 8; i++)
				{
					host.A_SpawnParticle("ff4400",
						flags: SPF_FULLBRIGHT | SPF_RELPOS,
						lifetime: 28,
						size: frandom(4.0, 7.0),
						angle: frandom(0, 360),
						xoff: frandom(-host.Radius, host.Radius),
						zoff: frandom(0, host.Height),
						velz: frandom(0.8, 1.6));
				}
			}
		}
		if (!should && raging)
			raging = false;

		host.bALWAYSFAST = raging ? true : host.default.bALWAYSFAST;
	}

	double GetSpeedFactor()
	{
		return raging ? 1.65 : 1.0;
	}

	override void Tick()
	{
		Super.Tick();
		if (level.isFrozen())
			return;

		if (!SEM_Static.ActorIsUsable(host))
		{
			Destroy();
			return;
		}

		if (!setup)
		{
			GiveToken();
			InitEffect();
			InitSeverity();
			if (host && markers)
				host.Scale *= markerScale;
			host.starthealth = int(host.health / G_SkillPropertyFloat(SKILLP_MonsterHealth));
			starthealth = host.starthealth;
			oldhealth = host.Health;
			baseDamageMultiply = host.DamageMultiply;
			setup = true;
			SpawnBurstFX();
		}

		if (host.Health < 1)
		{
			if (!deathHandled)
			{
				deathHandled = true;
				DeathEffect();
			}
			host.StartHealth = host.Default.StartHealth;
			host.PainChance = host.Default.PainChance;
			host.DamageFactor = host.Default.DamageFactor;
			host.DamageMultiply = host.Default.DamageMultiply;
			Destroy();
			return;
		}

		UpdateEmissionRage();

		if (particles && (++particleTic % 3) == 0)
			SpawnParticles();

		if (host.Health > oldhealth)
			oldhealth = host.Health;

		if (host.Health < oldhealth && host.Health > 0)
		{
			oldhealth = host.Health;
			if (level.Time != lastHitTick)
			{
				lastHitTick = level.Time;
				HitEffect();
				SpawnHitFX();
			}
		}

		if (eftic && ++tic >= eftic)
		{
			TickEffect();
			tic = 0;
		}

		if (severity == sem_PhaseShift)
			host.bSPECTRAL = host.alpha < 0.5;

		if (raging)
			host.DamageMultiply = baseDamageMultiply * 1.35;
		else if (severity == sem_EmissionRage)
			host.DamageMultiply = baseDamageMultiply;
	}
}
