/*
	Weapon rotational tilt + pendulum lowering (Project Survival PS_WeaponTilter).
	Strafe-driven PSP_WEAPON roll/dip for Clear Sky / STALKER weapons.

	IMPORTANT: Do not require wf_weaponready / InStateSequence("RealReady").
	Fort-12 (and most guns) use a dual-branch RealReady; InStateSequence stops at
	the first Loop, so ready-flag gating left pistols with zero motion forever.
*/

class CS_WeaponRotTilterInventory : Inventory
{
	double currentRoll;
	double smoothedWeaponRoll;
	double prevStrafeInput;
	double motionEnableBlend;

	double outputRoll;
	double smoothedPendulumDip;
	double lastAppliedRoll;
	double lastAppliedDip;
	double baselineWeaponY;

	bool poseActive;
	bool cvEnabled;
	bool hasBaselineWeaponY;
	bool restoreDipThisTick;

	Name lastWeaponClass;
	int currentTickCount;
	int lastComputeGametic;

	float cvRollResistance;
	float cvRollVelocity;
	float cvRollCap;
	float cvLoweringIntensity;
	float cvTiltSmoothing;
	float profileRollMul;
	float profileDipMul;
	bool cvCapRoll;
	bool cvLowering;

	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
	}

	private float GetWeaponRollMul(Weapon weap)
	{
		if (!weap) return 1.0;
		Name cls = weap.GetClassName();
		if (cls == 'Fort12' || cls == 'TT33' || cls == 'NR40') return 1.35;
		if (cls == 'RiotShield') return 0.85;
		if (cls == 'SVD' || cls == 'MosinNagant' || cls == 'GM94' || cls == 'RPG7D') return 0.90;
		if (cls == 'PP19' || cls == 'PPSh41' || cls == 'ASVAL'
			|| cls == 'AK47' || cls == 'OTS14' || cls == 'SKS' || cls == 'RP46') return 1.0;
		return 1.0;
	}

	private float GetWeaponDipMul(Weapon weap)
	{
		if (!weap) return 1.0;
		Name cls = weap.GetClassName();
		if (cls == 'SVD' || cls == 'MosinNagant' || cls == 'GM94' || cls == 'RPG7D') return 1.25;
		if (cls == 'Fort12' || cls == 'TT33' || cls == 'NR40') return 1.0;
		if (cls == 'RiotShield') return 0.85;
		return 1.0;
	}

	private bool InWeaponStateSequence(Weapon weap, PSprite psp, statelabel label)
	{
		if (!weap || !psp || !psp.CurState) return false;
		State st = weap.FindState(label);
		return st && weap.InStateSequence(psp.CurState, st);
	}

	// Goto RealReady/Ready targets the label head — compare pointers, do NOT use
	// InStateSequence (Fire/Reload Goto RealReady, so idle frames falsely match).
	private bool IsIdleGotoTarget(Weapon weap, State s)
	{
		if (!weap || !s) return false;
		static const statelabel idles[] =
		{
			"RealReady", "Ready", "ReadyRaised", "ReadyLoop",
			"ScopedReady", "AfterUse", "CS_StimDone"
		};
		for (int i = 0; i < idles.Size(); ++i)
		{
			if (s == weap.FindState(idles[i]))
				return true;
		}
		return false;
	}

	// Like InStateSequence, but STOP before following Goto into Ready/RealReady.
	// Plain InStateSequence makes Fort-12 idle look like Fire/Reload forever
	// (those strips Goto RealReady) — tilt only "worked" intermittently.
	private bool InExclusiveCombatSequence(Weapon weap, PSprite psp, statelabel label)
	{
		if (!weap || !psp || !psp.CurState) return false;
		State base = weap.FindState(label);
		if (!base) return false;

		State cur = psp.CurState;
		State s = base;
		int guard = 0;
		while (s && guard++ < 300)
		{
			if (s == cur)
				return true;

			State next = s.NextState;
			if (!next)
				return false;
			if (next == base)
				return false;
			if (IsIdleGotoTarget(weap, next))
				return false;

			s = next;
		}
		return false;
	}

	private bool ShouldBlock(Weapon weap, PSprite psp)
	{
		if (!weap || !psp) return true;

		static const statelabel blockLabels[] =
		{
			"Select", "Deselect",
			"Fire", "Fire2", "AltFire", "Hold",
			"Reload", "ReloadLoop", "Reload2", "ProperReload", "Unload",
			"User1",
			"ZoomIn", "ZoomOut", "ScopedFire", "FireZoom",
			"ThrowF1", "ThrowMolotov", "HealInjector",
			"UseF1GrenadeState", "UseMolotovState", "UseInjectorState"
		};
		for (int i = 0; i < blockLabels.Size(); ++i)
		{
			if (InExclusiveCombatSequence(weap, psp, blockLabels[i]))
				return true;
		}

		if (owner)
		{
			if (owner.CountInv("SVDZoom") > 0) return true;
			if (owner.CountInv("UseF1Grenade") > 0) return true;
			if (owner.CountInv("UseMolotov") > 0) return true;
			if (owner.CountInv("UseStimInjector") > 0) return true;
		}
		return false;
	}

	private void ResetRollState()
	{
		currentRoll = 0;
		smoothedWeaponRoll = 0;
		prevStrafeInput = 0;
		outputRoll = 0;
		lastAppliedRoll = 0;
	}

	private void DiscardPendulumDipState()
	{
		lastAppliedDip = 0;
		smoothedPendulumDip = 0;
		hasBaselineWeaponY = false;
	}

	private void RestorePendulumDip(PSprite psp)
	{
		if (psp)
		{
			if (hasBaselineWeaponY)
				psp.Y = baselineWeaponY;
			else if (lastAppliedDip > 0)
				psp.Y -= lastAppliedDip;
		}
		DiscardPendulumDipState();
	}

	private void ApplyPendulumDip(PSprite psp, double dip)
	{
		if (!psp) return;

		if (hasBaselineWeaponY && lastAppliedDip > 0.05)
		{
			double expectedY = baselineWeaponY + lastAppliedDip;
			if (abs(psp.Y - expectedY) > 2.0)
			{
				baselineWeaponY = psp.Y;
				lastAppliedDip = 0;
			}
		}
		else if (!hasBaselineWeaponY)
		{
			baselineWeaponY = psp.Y - lastAppliedDip;
			hasBaselineWeaponY = true;
		}

		if (dip > 0.05)
		{
			psp.Y = baselineWeaponY + dip;
			lastAppliedDip = dip;
		}
		else
		{
			psp.Y = baselineWeaponY;
			lastAppliedDip = 0;
		}
	}

	private double ComputePendulumDipTarget(double displayRoll, double strafeInput, bool allowLowering)
	{
		if (!allowLowering || !cvLowering) return 0;

		double absRoll = abs(displayRoll);
		// Wait until roll has committed so dip doesn't lead with a wrong-side slam.
		if (absRoll < 0.55) return 0;
		if (abs(strafeInput) < 0.05) return 0;

		double scale = max(0.5, cvLoweringIntensity) * profileDipMul;
		double dip = (5.5 + absRoll * 7.5) * scale;
		// Keep left/right dip closer — old left-heavy bias exaggerated the wrong-start look.
		if (displayRoll < 0)
			dip += absRoll * 3.2 * scale;
		else
			dip += absRoll * 2.4 * scale;
		return min(dip, 26.0);
	}

	private void RefreshCvars(PlayerInfo pi)
	{
		// Default ON if CVAR lookup fails (addon load-order / missing CVARINFO).
		cvEnabled = true;
		cvRollResistance = 0.6;
		cvRollVelocity = 4.0;
		cvRollCap = 12.0;
		cvLoweringIntensity = 0.5;
		cvTiltSmoothing = 0.38;
		cvCapRoll = true;
		cvLowering = true;

		if (!pi) return;

		let cEnable = CVar.GetCVar("wt_enable", pi);
		let cRes = CVar.GetCVar("wt_rollresistance", pi);
		let cVel = CVar.GetCVar("wt_rollvelocity", pi);
		let cCapAmt = CVar.GetCVar("wt_rollcap", pi);
		let cLowInt = CVar.GetCVar("wt_lowering_intensity", pi);
		let cSmooth = CVar.GetCVar("wt_tilt_smoothing", pi);
		let cCap = CVar.GetCVar("wt_cap", pi);
		let cLow = CVar.GetCVar("wt_lowering", pi);

		if (cEnable) cvEnabled = cEnable.GetBool();
		if (cRes) cvRollResistance = cRes.GetFloat();
		if (cVel) cvRollVelocity = cVel.GetFloat();
		if (cCapAmt) cvRollCap = cCapAmt.GetFloat();
		if (cLowInt) cvLoweringIntensity = cLowInt.GetFloat();
		if (cSmooth) cvTiltSmoothing = cSmooth.GetFloat();
		if (cCap) cvCapRoll = cCap.GetBool();
		if (cLow) cvLowering = cLow.GetBool();

		cvRollResistance = clamp(cvRollResistance, 0.08, 0.70);
		cvLoweringIntensity = clamp(cvLoweringIntensity, 0.0, 2.5);
		cvTiltSmoothing = clamp(cvTiltSmoothing, 0.20, 0.95);
		if (cvRollCap < 3.0) cvRollCap = 3.0;
	}

	void ApplyPose(PlayerInfo pi)
	{
		if (!pi) return;
		let psp = pi.FindPSprite(PSP_WEAPON);
		if (!psp) return;

		// Must run ComputePose first this tic (EnsureAndApply does).
		if (lastComputeGametic != level.time)
			ComputePose(pi);

		if (restoreDipThisTick || !poseActive || !cvEnabled)
		{
			psp.Rotation = 0;
			lastAppliedRoll = 0;
			RestorePendulumDip(psp);
			restoreDipThisTick = false;
			return;
		}

		// Pivot near grip so small rolls read on pistols.
		psp.bPivotPercent = true;
		psp.Pivot = (0.5, 0.75);

		psp.Rotation = outputRoll;
		lastAppliedRoll = outputRoll;
		ApplyPendulumDip(psp, smoothedPendulumDip);
	}

	override void DoEffect()
	{
		Super.DoEffect();
		currentTickCount++;
	}

	// WorldTick entry — after weapon A_WeaponReady for this tic.
	// Safe to call from multiple handlers; only computes once per gametic.
	void ComputePose(PlayerInfo pi)
	{
		if (lastComputeGametic == level.time)
			return;
		lastComputeGametic = level.time;

		outputRoll = 0;
		poseActive = false;
		restoreDipThisTick = false;
		profileRollMul = 1.0;
		profileDipMul = 1.0;

		if (!owner || !pi) return;

		// Yield while Universal Kick / ledge grab owns weapon pose.
		let kickTok = MR_uKickToken(owner.FindInventory("MR_uKickToken"));
		if (kickTok && kickTok.Kickin) return;
		if (owner.CountInv("MR_Grabbing_A_Ledge") > 0) return;

		let psp = pi.FindPSprite(PSP_WEAPON);
		let wpn = pi.ReadyWeapon;
		if (!psp || !wpn) return;

		RefreshCvars(pi);

		Name weaponClass = wpn.GetClassName();
		if (weaponClass != lastWeaponClass)
		{
			ResetRollState();
			DiscardPendulumDipState();
			motionEnableBlend = 1.0;
			lastWeaponClass = weaponClass;
		}

		if (pi.PendingWeapon != WP_NOCHANGE && pi.PendingWeapon != null
			&& pi.PendingWeapon.GetClassName() != weaponClass)
		{
			ResetRollState();
			restoreDipThisTick = true;
			smoothedPendulumDip = 0;
			return;
		}

		if (!cvEnabled)
		{
			ResetRollState();
			restoreDipThisTick = true;
			smoothedPendulumDip = 0;
			return;
		}

		let weap = Weapon(wpn);
		profileRollMul = GetWeaponRollMul(weap);
		profileDipMul = GetWeaponDipMul(weap);

		bool blocked = ShouldBlock(weap, psp);

		// Positive cmd.sidemove = strafe right (Doom convention).
		double strafeInput = pi.cmd.sidemove / 10240.0;
		// Right-lateral axis (matches sidemove sign). Old code used left-axis
		// (-sin, cos), so velocity override fought input and rolled the wrong way
		// for a few tics until input dominated again.
		Vector2 rightDir = (sin(owner.angle), -cos(owner.angle));
		double strafeDot = owner.Vel.X * rightDir.X + owner.Vel.Y * rightDir.Y;

		// Input always wins while the stick/key is held. Velocity only fills in
		// when there’s no sidemove (ice, knockback, conveyors).
		double strafe = strafeInput;
		if (abs(strafeInput) < 0.08 && abs(strafeDot) > 1.0)
			strafe = clamp(strafeDot * 0.10, -1.5, 1.5);

		if (blocked)
		{
			currentRoll *= 0.7;
			smoothedWeaponRoll *= 0.7;
			motionEnableBlend += (0.0 - motionEnableBlend) * 0.45;
			restoreDipThisTick = true;
			smoothedPendulumDip *= 0.8;
			if (smoothedPendulumDip < 0.05) smoothedPendulumDip = 0;
			return;
		}

		motionEnableBlend += (1.0 - motionEnableBlend) * 0.45;

		if (prevStrafeInput * strafe < 0. && abs(strafe) > 0.02 && abs(prevStrafeInput) > 0.02)
			currentRoll *= 0.88;

		double rollVel = cvRollVelocity * profileRollMul;
		double rollCap = cvRollCap * profileRollMul;

		currentRoll += strafe * rollVel * motionEnableBlend;
		currentRoll *= cvRollResistance;
		if (cvCapRoll)
			currentRoll = clamp(currentRoll, -rollCap, rollCap);

		prevStrafeInput = strafe;

		double tiltS = cvTiltSmoothing;
		smoothedWeaponRoll = smoothedWeaponRoll * tiltS + currentRoll * (1.0 - tiltS);
		outputRoll = smoothedWeaponRoll;

		// Dip only after roll has a clear direction — avoids the early “slam opposite” look.
		double dipTarget = ComputePendulumDipTarget(outputRoll, strafe, true);
		double dipRate = dipTarget > smoothedPendulumDip ? 0.36 : 0.30;
		smoothedPendulumDip += (dipTarget - smoothedPendulumDip) * dipRate;
		if (smoothedPendulumDip <= 0.05) smoothedPendulumDip = 0;

		poseActive = abs(outputRoll) > 0.04 || smoothedPendulumDip > 0.05;
	}
}

class CS_WeaponRotTilterHandler : EventHandler
{
	static void EnsureAndApply(PlayerPawn mo)
	{
		if (!mo || !mo.player) return;
		if (!mo.FindInventory("CS_WeaponRotTilterInventory"))
			mo.A_GiveInventory("CS_WeaponRotTilterInventory", 1);

		let inv = CS_WeaponRotTilterInventory(mo.FindInventory("CS_WeaponRotTilterInventory"));
		if (!inv) return;
		inv.ComputePose(mo.player);
		inv.ApplyPose(mo.player);
	}

	override void PlayerEntered(PlayerEvent e)
	{
		let mo = players[e.PlayerNumber].mo;
		if (mo && mo.player && !mo.FindInventory("CS_WeaponRotTilterInventory"))
			mo.A_GiveInventory("CS_WeaponRotTilterInventory", 1);
	}

	override void PlayerRespawned(PlayerEvent e)
	{
		PlayerEntered(e);
	}

	override void WorldLoaded(WorldEvent e)
	{
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playerInGame[i] || !players[i].mo) continue;
			if (!players[i].mo.FindInventory("CS_WeaponRotTilterInventory"))
				players[i].mo.A_GiveInventory("CS_WeaponRotTilterInventory", 1);
		}
	}

	override void WorldTick()
	{
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playerInGame[i] || !players[i].mo) continue;
			EnsureAndApply(players[i].mo);
		}
	}
}
