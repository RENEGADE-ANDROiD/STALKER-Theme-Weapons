// Event handler: weighted Zone affliction rolls on monsters (Champions Lite architecture).

class SEM_Handler : EventHandler
{
	static const Name WeightVars[] =
	{
		'sem_weight_Chemical', 'sem_weight_Thermal', 'sem_weight_Electro', 'sem_weight_Gravity',
		'sem_weight_Psi', 'sem_weight_Bloodsucker', 'sem_weight_Snork', 'sem_weight_Pseudogiant'
	};

	static const Name WeightVars_Severity[] =
	{
		'sem_weight_AnomalyGrowth', 'sem_weight_PhaseShift', 'sem_weight_EmissionRage'
	};

	static const class<Thinker> Controllers[] =
	{
		"SEM_ChemicalController", "SEM_ThermalController", "SEM_ElectroController", "SEM_GravityController",
		"SEM_PsiController", "SEM_BloodsuckerController", "SEM_SnorkController", "SEM_PseudogiantController"
	};

	static const int SeverityIds[] =
	{
		sem_AnomalyGrowth, sem_PhaseShift, sem_EmissionRage
	};

	Array<class<Thinker> > WeightedAfflictions;
	Array<int> WeightedSeverities;

	bool markers;
	double markerScale;
	bool particles;
	bool spawnFX;
	bool hitFX;
	int severityChance;
	int mutatedThisMap;
	int mapCap;
	bool worldReady;
	Array<Actor> pendingRolls;
	int pendingCursor;

	int ControllerID(Name controller)
	{
		for (int i = 0; i < Controllers.Size(); i++)
		{
			if (controller == Controllers[i].GetClassName())
				return i;
		}
		return 0;
	}

	void BuildWeightedAfflictions()
	{
		WeightedAfflictions.Clear();

		int forced = SEM_Static.ReturnCVAR("sem_debug_forced");
		if (forced != -1)
		{
			if (forced >= 0 && forced < Controllers.Size())
				WeightedAfflictions.Push(Controllers[forced]);
			return;
		}

		for (int i = 0; i < WeightVars.Size(); i++)
		{
			int weight = SEM_Static.ReturnCVAR(WeightVars[i]);
			for (int j = 0; j < weight; j++)
				WeightedAfflictions.Push(Controllers[i]);
		}
	}

	void BuildSeverityArray()
	{
		WeightedSeverities.Clear();
		for (int i = 0; i < WeightVars_Severity.Size(); i++)
		{
			int weight = SEM_Static.ReturnCVAR(WeightVars_Severity[i]);
			for (int j = 0; j < weight; j++)
				WeightedSeverities.Push(SeverityIds[i]);
		}
	}

	override void WorldLoaded(WorldEvent e)
	{
		pendingRolls.Clear();
		pendingCursor = 0;
		worldReady = false;
		mutatedThisMap = 0;
		mapCap = SEM_Static.GetMapCap();
		BuildWeightedAfflictions();
		BuildSeverityArray();
		markers = SEM_Static.ReturnCVAR("sem_Markers");
		markerScale = SEM_Static.ReturnCVARFloat("sem_MarkerScale");
		particles = SEM_Static.ReturnCVAR("sem_Particles");
		bool visualFX = SEM_Static.ReturnCVAR("sem_VisualFX");
		spawnFX = visualFX;
		hitFX = visualFX;
		severityChance = SEM_Static.ReturnCVAR("sem_SeverityChance");
		worldReady = true;
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		if (!e || !e.Thing)
			return;

		let missileTarget = e.Thing.Target;
		if (e.Thing.bMISSILE && SEM_Static.ActorIsUsable(missileTarget) &&
			missileTarget.CountInv("SEM_SnorkToken"))
			e.Thing.A_ScaleVelocity(1.35);

		if (!CanMutate(e.Thing))
			return;

		if (!worldReady || level.maptime < 1)
		{
			pendingRolls.Push(e.Thing);
			return;
		}

		TryMutate(e.Thing);
	}

	override void WorldThingDestroyed(WorldEvent e)
	{
		if (!e || !e.Thing)
			return;
		if (!e.Thing.bCOUNTKILL || !e.Thing.bISMONSTER)
			return;

		for (int i = pendingRolls.Size() - 1; i >= 0; i--)
		{
			if (pendingRolls[i] == e.Thing)
			{
				if (i < pendingCursor)
					pendingCursor--;
				pendingRolls.Delete(i);
			}
		}
		if (pendingCursor < 0)
			pendingCursor = 0;
	}

	bool CanMutate(Actor mob)
	{
		if (!SEM_Static.ActorIsUsable(mob))
			return false;
		return mob.bCOUNTKILL
			&& !mob.bSPECIAL
			&& !mob.bBOSS
			&& !mob.CountInv("SEM_NullToken")
			&& !mob.CountInv("SEM_PersistentInfo");
	}

	void TryMutate(Actor mob)
	{
		if (!CanMutate(mob) || WeightedAfflictions.Size() < 1)
			return;

		if (SEM_Static.CapsEnabled() && mutatedThisMap >= mapCap)
			return;

		int sk = G_SkillPropertyInt(SKILLP_ACSReturn);
		int chance = (4 + (sk * 10)) * (sk + 1);
		int or = SEM_Static.ReturnCVAR("sem_OverrideChance");
		if (or != -1)
			chance = or;

		if (random(0, 255) >= chance)
			return;

		int i = random(0, WeightedAfflictions.Size() - 1);
		mob.A_GiveInventory("SEM_PersistentInfo");
		let info = SEM_PersistentInfo(mob.FindInventory("SEM_PersistentInfo"));
		if (info)
		{
			info.c = WeightedAfflictions[i];
			info.i = ControllerID(WeightedAfflictions[i].GetClassName());
		}

		let controller = SEM_BaseController(new(WeightedAfflictions[i]));
		if (controller)
		{
			controller.host = mob;
			controller.markers = markers;
			controller.markerScale = markerScale;
			controller.particles = particles;
			controller.spawnFX = spawnFX;
			controller.hitFX = hitFX;
			controller.severity = DoSeverity(mob);
			mutatedThisMap++;
		}
	}

	override void WorldTick()
	{
		if (!worldReady)
			return;
		if (pendingCursor >= pendingRolls.Size())
			return;

		int processed = 0;
		while (pendingCursor < pendingRolls.Size() && processed < 8)
		{
			let mob = pendingRolls[pendingCursor];
			if (SEM_Static.ActorIsUsable(mob))
				TryMutate(mob);
			pendingCursor++;
			processed++;
		}

		if (pendingCursor >= pendingRolls.Size())
		{
			pendingRolls.Clear();
			pendingCursor = 0;
		}
	}

	int DoSeverity(Actor mob)
	{
		if (!SEM_Static.ActorIsUsable(mob) || random(0, 255) >= severityChance || WeightedSeverities.Size() == 0)
			return sem_SevNone;

		let info = SEM_PersistentInfo(mob.FindInventory("SEM_PersistentInfo"));
		if (!info)
			return sem_SevNone;

		int pick = WeightedSeverities[random(0, WeightedSeverities.Size() - 1)];
		if (mob.bBOSS && pick == sem_AnomalyGrowth)
			pick = WeightedSeverities[random(0, WeightedSeverities.Size() - 1)];

		info.m = pick;
		return pick;
	}

	override void WorldThingRevived(WorldEvent e)
	{
		if (!e || !SEM_Static.ActorIsUsable(e.Thing))
			return;
		let info = SEM_PersistentInfo(e.Thing.FindInventory("SEM_PersistentInfo"));
		if (!info)
			return;

		let controller = SEM_BaseController(new(info.c));
		if (controller)
		{
			controller.severity = info.m;
			controller.host = e.Thing;
			controller.markers = markers;
			controller.markerScale = markerScale;
			controller.particles = particles;
			controller.spawnFX = spawnFX;
			controller.hitFX = hitFX;
		}
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		Actor victim = e.Thing;
		if (!victim)
			return;
		if (victim is "PlayerPawn" && SEM_Static.ActorIsUsable(e.DamageSource) &&
			e.DamageSource.CountInv("SEM_ChemicalToken"))
		{
			if (!SEM_Static.OwnerResistsChemical(victim))
				victim.GiveInventory("SEM_ChemicalPoison", 1);
		}
	}

	override void ConsoleProcess(ConsoleEvent e)
	{
		if (e.Name == 'sem_reset_weights')
		{
			CVar.GetCVar("sem_weight_Chemical").ResetToDefault();
			CVar.GetCVar("sem_weight_Thermal").ResetToDefault();
			CVar.GetCVar("sem_weight_Electro").ResetToDefault();
			CVar.GetCVar("sem_weight_Gravity").ResetToDefault();
			CVar.GetCVar("sem_weight_Psi").ResetToDefault();
			CVar.GetCVar("sem_weight_Bloodsucker").ResetToDefault();
			CVar.GetCVar("sem_weight_Snork").ResetToDefault();
			CVar.GetCVar("sem_weight_Pseudogiant").ResetToDefault();
			return;
		}

		if (e.Name == 'sem_preset_cordon')
			SEM_MenuPresets.ApplyCordon();
		if (e.Name == 'sem_preset_standard')
			SEM_MenuPresets.ApplyStandard();
		if (e.Name == 'sem_preset_emission')
			SEM_MenuPresets.ApplyEmission();
	}
}

class SEM_MenuPresets ui
{
	static void ApplyCordon()
	{
		CVar.GetCVar("sem_OverrideChance").SetInt(-1);
		CVar.GetCVar("sem_SeverityChance").SetInt(4);
		CVar.GetCVar("sem_VisualFX").SetInt(1);
		CVar.GetCVar("sem_fx_visibility").SetInt(1);
		CVar.GetCVar("sem_performance_lite").SetInt(1);
		CVar.GetCVar("sem_Particles").SetInt(0);
		CVar.GetCVar("sem_cap_enabled").SetInt(1);
		CVar.GetCVar("sem_cap_small").SetInt(8);
		CVar.GetCVar("sem_cap_medium").SetInt(16);
		CVar.GetCVar("sem_cap_large").SetInt(32);
		CVar.GetCVar("sem_weight_Chemical").SetInt(6);
		CVar.GetCVar("sem_weight_Thermal").SetInt(4);
		CVar.GetCVar("sem_weight_Electro").SetInt(5);
		CVar.GetCVar("sem_weight_Gravity").SetInt(4);
		CVar.GetCVar("sem_weight_Psi").SetInt(3);
		CVar.GetCVar("sem_weight_Bloodsucker").SetInt(5);
		CVar.GetCVar("sem_weight_Snork").SetInt(6);
		CVar.GetCVar("sem_weight_Pseudogiant").SetInt(3);
		CVar.GetCVar("sem_weight_AnomalyGrowth").SetInt(2);
		CVar.GetCVar("sem_weight_PhaseShift").SetInt(3);
		CVar.GetCVar("sem_weight_EmissionRage").SetInt(2);
	}

	static void ApplyStandard()
	{
		CVar.GetCVar("sem_OverrideChance").ResetToDefault();
		CVar.GetCVar("sem_SeverityChance").ResetToDefault();
		CVar.GetCVar("sem_VisualFX").ResetToDefault();
		CVar.GetCVar("sem_fx_visibility").ResetToDefault();
		CVar.GetCVar("sem_performance_lite").ResetToDefault();
		CVar.GetCVar("sem_Particles").ResetToDefault();
		CVar.GetCVar("sem_cap_enabled").ResetToDefault();
		CVar.GetCVar("sem_cap_small").ResetToDefault();
		CVar.GetCVar("sem_cap_medium").ResetToDefault();
		CVar.GetCVar("sem_cap_large").ResetToDefault();
		CVar.GetCVar("sem_weight_Chemical").ResetToDefault();
		CVar.GetCVar("sem_weight_Thermal").ResetToDefault();
		CVar.GetCVar("sem_weight_Electro").ResetToDefault();
		CVar.GetCVar("sem_weight_Gravity").ResetToDefault();
		CVar.GetCVar("sem_weight_Psi").ResetToDefault();
		CVar.GetCVar("sem_weight_Bloodsucker").ResetToDefault();
		CVar.GetCVar("sem_weight_Snork").ResetToDefault();
		CVar.GetCVar("sem_weight_Pseudogiant").ResetToDefault();
		CVar.GetCVar("sem_weight_AnomalyGrowth").ResetToDefault();
		CVar.GetCVar("sem_weight_PhaseShift").ResetToDefault();
		CVar.GetCVar("sem_weight_EmissionRage").ResetToDefault();
	}

	static void ApplyEmission()
	{
		CVar.GetCVar("sem_OverrideChance").SetInt(160);
		CVar.GetCVar("sem_SeverityChance").SetInt(48);
		CVar.GetCVar("sem_VisualFX").SetInt(1);
		CVar.GetCVar("sem_fx_visibility").SetInt(0);
		CVar.GetCVar("sem_performance_lite").SetInt(0);
		CVar.GetCVar("sem_Particles").SetInt(1);
		CVar.GetCVar("sem_cap_enabled").SetInt(0);
		CVar.GetCVar("sem_weight_Chemical").SetInt(10);
		CVar.GetCVar("sem_weight_Thermal").SetInt(10);
		CVar.GetCVar("sem_weight_Electro").SetInt(10);
		CVar.GetCVar("sem_weight_Gravity").SetInt(10);
		CVar.GetCVar("sem_weight_Psi").SetInt(10);
		CVar.GetCVar("sem_weight_Bloodsucker").SetInt(10);
		CVar.GetCVar("sem_weight_Snork").SetInt(10);
		CVar.GetCVar("sem_weight_Pseudogiant").SetInt(10);
		CVar.GetCVar("sem_weight_AnomalyGrowth").SetInt(8);
		CVar.GetCVar("sem_weight_PhaseShift").SetInt(8);
		CVar.GetCVar("sem_weight_EmissionRage").SetInt(8);
	}
}
