// STALKER Enemy Mutations — enums & helpers
// Architecture adapted from Champions Lite (Thinker + inventory tokens), Zone-themed.

enum SEM_Afflictions
{
	sem_Chemical,
	sem_Thermal,
	sem_Electro,
	sem_Gravity,
	sem_Psi,
	sem_Bloodsucker,
	sem_Snork,
	sem_Pseudogiant
}

enum SEM_Severities
{
	sem_SevNone,
	sem_AnomalyGrowth,   // Giant
	sem_PhaseShift,      // Spectral
	sem_EmissionRage     // Rampage
}

class SEM_Static
{
	static bool ActorIsUsable(Actor mob)
	{
		return mob && mob.bISMONSTER && mob.health > 0;
	}

	static bool CapsEnabled()
	{
		let c = CVar.FindCVar("sem_cap_enabled");
		return c == null || c.GetBool();
	}

	static int GetMapCap()
	{
		if (!CapsEnabled())
			return 99999;

		int total = level.total_monsters;
		int mediumAt = ReturnCVAR("sem_cap_medium_count");
		int largeAt = ReturnCVAR("sem_cap_large_count");

		if (total >= largeAt)
			return ReturnCVAR("sem_cap_large");
		if (total >= mediumAt)
			return ReturnCVAR("sem_cap_medium");
		return ReturnCVAR("sem_cap_small");
	}

	static bool VisibilityFXEnabled()
	{
		let c = CVar.FindCVar("sem_fx_visibility");
		return c == null || c.GetBool();
	}

	static bool PerformanceLite()
	{
		let c = CVar.FindCVar("sem_performance_lite");
		return c && c.GetBool();
	}

	static bool PlayerNear(Actor mo, double dist = 384)
	{
		if (!mo) return false;
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) continue;
			if (mo.Distance2D(players[i].mo) <= dist)
				return true;
		}
		return false;
	}

	static bool CosmeticFXVisible(Actor mo)
	{
		if (!ActorIsUsable(mo)) return false;
		if (PerformanceLite()) return false;
		if (!VisibilityFXEnabled()) return true;
		return PlayerNear(mo);
	}

	static bool OwnerResistsChemical(Actor mo)
	{
		if (!mo) return false;
		if (mo.CountInv("PowerIronFeet") || mo.CountInv("PowerMask"))
			return true;
		// Visual gas-mask overlay on: treat as light chemical resist.
		let cv = CVar.GetCVar("cs_gasmask", mo.player);
		return cv && cv.GetBool();
	}

	static int ReturnCVAR(Name c)
	{
		CVar cv = CVar.FindCVar(c);
		return cv ? cv.GetInt() : 0;
	}

	static double ReturnCVARFloat(Name c)
	{
		CVar cv = CVar.FindCVar(c);
		return cv ? cv.GetFloat() : 0;
	}
}
