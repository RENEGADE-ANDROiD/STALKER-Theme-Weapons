// Tactical weapon motion (strafe roll, lowering, wall dip, landing kick, optional lean).
// Ported from Project Brutality 2022 — PB_WeaponTacticalFeel.zc — adapted for this TC.
//
// SUPERSEDED: not #include'd. Live stack is Project Survival fold:
//   TiltPlusPlus.zs (camera) + WeaponRotTilt.zs (strafe PSP roll/dip) + STALKERPlayer yaw sway.
// Keep this file only as a reference for wall-proximity / lean if those are restored later.

class CS_LeanLeft : Inventory {}
class CS_LeanRight : Inventory {}
class CS_LeanToggle : Inventory {}

class CS_WeaponTilterInventory : Inventory
{
	double currentRoll;
	double loweringAmount;
	double landingKick;
	double reloadBlend;
	double motionEnableBlend;
	double leanRoll;
	double previousVelZ;
	bool previousOnFloor;
	int tickCounter;
	double appliedYOffset;
	Name lastWeaponClass;
	double neutralWeaponY;
	bool hasNeutralWeaponY;
	double smoothedWeaponRoll;
	double prevStrafeDot;
	int wallOnCount;
	int wallOffCount;
	bool wallDebouncedActive;

	double cvRollResistance;
	double cvRollVelocity;
	double cvRollCap;
	double cvLoweringScale;
	double cvWallLowering;
	double cvLeanAngle;
	double cvLeanSmoothing;
	double cvTiltSmoothing;
	double cvWallDistance;
	bool cvEnabled;
	bool cvWallDetect;
	bool cvEnableLean;
	bool cvEnableReadyOnly;
	bool cvEnableMoveOnly;
	bool cvCapRoll;

	static const Name NO_TACTICAL_WEAPONS[] =
	{
		'NR40',
		'RiotShield'
	};

	// PSprite layers that mirror PSP_WEAPON roll (dual overlays / segmented HUD weapons).
	private void ApplyWeaponTiltToAttachedOverlays(PlayerInfo pi, double roll)
	{
		if (!pi) return;
		let o10 = pi.FindPSprite(10); if (o10) o10.Rotation = roll;
		let o11 = pi.FindPSprite(11); if (o11) o11.Rotation = roll;
		let o60 = pi.FindPSprite(60); if (o60) o60.Rotation = roll;
		let o61 = pi.FindPSprite(61); if (o61) o61.Rotation = roll;
		let o63 = pi.FindPSprite(63); if (o63) o63.Rotation = roll;
		let o64 = pi.FindPSprite(64); if (o64) o64.Rotation = roll;
	}

	Default
	{
		Inventory.MaxAmount 1;
	}

	override void BeginPlay()
	{
		Super.BeginPlay();
		reloadBlend = 0.;
		motionEnableBlend = 1.;
		smoothedWeaponRoll = 0.;
		prevStrafeDot = 0.;
		wallOnCount = 0;
		wallOffCount = 0;
		wallDebouncedActive = false;
	}

	private bool IsOnFloor()
	{
		if (!owner) return false;
		let pp = PlayerPawn(owner);
		if (pp && pp.player)
		{
			return pp.player.OnGround || owner.bONMOBJ || owner.bMBFBOUNCER
				|| ((pp.player.Cheats & CF_NOCLIP2) != 0);
		}
		return owner.Pos.Z <= owner.FloorZ + 1.0;
	}

	private bool IsExcludedWeapon(Weapon weap)
	{
		if (!weap) return true;
		Name cls = weap.GetClassName();
		for (int i = 0; i < NO_TACTICAL_WEAPONS.Size(); i++)
			if (cls == NO_TACTICAL_WEAPONS[i]) return true;
		return false;
	}

	private bool IsReadyState(Weapon weap, PSprite psp)
	{
		State st;
		if (!weap || !psp || !psp.CurState) return false;

		// Idle loops only — not the authored "Ready" equip strip (A_WeaponOffset 100→34) most guns use before RealReady.
		st = weap.FindState("RealReady");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("RealReady_Reload");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("ScopedReady");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("ReadyLoop");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("Hold");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("Ready3");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("ReadyAim");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("Ready_ADS");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("BDReady3");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("BDReadyADS");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("ReadyRaised");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;

		// Riot shield / bare ClearSkyWeapon template: no RealReady, "Ready" is the idle loop.
		if (!weap.FindState("RealReady"))
		{
			st = weap.FindState("Ready");
			if (st && weap.InStateSequence(psp.CurState, st)) return true;
		}
		return false;
	}

	private bool IsScopedNow(Actor plr, Weapon weap, PSprite psp)
	{
		if (!plr || !weap || !psp || !psp.CurState) return false;
		if (weap.GetClassName() == 'SVD' && plr.CountInv("SVDZoom") > 0) return true;
		return false;
	}

	private bool ShouldBlockForSafety(Actor plr, Weapon weap, PSprite psp)
	{
		if (!plr || !weap || !psp || !plr.player) return true;
		if (IsScopedNow(plr, weap, psp)) return true;

		State st = weap.FindState("User1");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;

		let ov10 = plr.player.GetPSprite(10);
		let ov11 = plr.player.GetPSprite(11);
		bool hasOverlayActions = (ov10 && ov10.CurState) || (ov11 && ov11.CurState);
		if (hasOverlayActions && !IsReadyState(weap, psp)) return true;

		if (plr.CountInv("UseF1Grenade") > 0 || plr.CountInv("UseMolotov") > 0 || plr.CountInv("UseStimInjector") > 0)
			return true;

		return false;
	}

	private bool TraceHitsWall(double traceAngle, double dist)
	{
		FLineTraceData wallCheck;
		double zOff = owner.Height * 0.55;
		owner.LineTrace(traceAngle, dist, 0, TRF_THRUACTORS, offsetz: zOff, data: wallCheck);
		if (wallCheck.HitType == TRACE_HitWall) return true;
		owner.LineTrace(traceAngle, dist, owner.Pitch, TRF_THRUACTORS, offsetz: zOff, data: wallCheck);
		return wallCheck.HitType == TRACE_HitWall;
	}

	static const double TAC_WALL_YAW[] = { 0., 22.5, -22.5, 45., -45., 90., -90. };
	static const double TAC_WALL_DISTSCALE[] = { 1., 0.95, 0.95, 0.9, 0.9, 0.85, 0.85 };

	private bool FacingWall(double distance)
	{
		if (distance < 1.0) return false;
		for (int i = 0; i < 7; i++)
		{
			double ang = owner.Angle + TAC_WALL_YAW[i];
			double dist = distance * TAC_WALL_DISTSCALE[i];
			if (TraceHitsWall(ang, dist)) return true;
		}
		return false;
	}

	private bool IsFiringState(Weapon weap, PSprite psp)
	{
		State st;
		if (!weap || !psp || !psp.CurState) return false;
		st = weap.FindState("Fire");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("Fire_ADS");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("FireRight_Overlay");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("FireLeft_Overlay");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("FireGrenade");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("Scope_Fire");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("ScopedFire");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		return false;
	}

	private bool UsesExtraMoveLowering(Name weaponClass)
	{
		return weaponClass == 'GM94' || weaponClass == 'RPG7D';
	}

	private bool IsReloadState(Weapon weap, PSprite psp)
	{
		State st;
		if (!weap || !psp || !psp.CurState) return false;
		st = weap.FindState("Reload");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("Reload2");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("Reload3");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("ReloadLoop");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("Reloading");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("BDReload");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		st = weap.FindState("BDReloadADS");
		if (st && weap.InStateSequence(psp.CurState, st)) return true;
		return false;
	}

	private void ResetAppliedOffset(PSprite psp)
	{
		if (psp && appliedYOffset != 0)
			psp.Y -= appliedYOffset;
		appliedYOffset = 0;
	}

	private void ClearTacticalPSpriteMotion(PlayerInfo pi, PSprite psp)
	{
		ResetAppliedOffset(psp);
		psp.Rotation = 0;
		ApplyWeaponTiltToAttachedOverlays(pi, 0.);
		leanRoll = 0;
		smoothedWeaponRoll = 0;
		currentRoll = 0;
	}

	private void RefreshCvars(PlayerInfo pi)
	{
		cvEnabled = CVar.GetCVar("cs_tac_enable", pi).GetBool();
		cvRollResistance = CVar.GetCVar("cs_tac_roll_resistance", pi).GetFloat();
		cvRollVelocity = CVar.GetCVar("cs_tac_roll_velocity", pi).GetFloat();
		cvRollCap = CVar.GetCVar("cs_tac_roll_cap_value", pi).GetFloat();
		cvLoweringScale = CVar.GetCVar("cs_tac_lowering_scale", pi).GetFloat();
		cvWallDetect = CVar.GetCVar("cs_tac_wall_detect", pi).GetBool();
		cvWallDistance = CVar.GetCVar("cs_tac_wall_distance", pi).GetFloat();
		cvWallLowering = CVar.GetCVar("cs_tac_wall_lowering", pi).GetFloat();
		cvEnableLean = CVar.GetCVar("cs_tac_lean_enable", pi).GetBool();
		cvLeanAngle = CVar.GetCVar("cs_tac_lean_angle", pi).GetFloat();
		cvLeanSmoothing = CVar.GetCVar("cs_tac_lean_smoothing", pi).GetFloat();
		cvTiltSmoothing = clamp(CVar.GetCVar("cs_tac_tilt_smoothing", pi).GetFloat(), 0.5, 0.95);
		cvEnableReadyOnly = CVar.GetCVar("cs_tac_ready_only", pi).GetBool();
		cvEnableMoveOnly = CVar.GetCVar("cs_tac_move_only", pi).GetBool();
		cvCapRoll = CVar.GetCVar("cs_tac_roll_cap", pi).GetBool();
	}

	override void DoEffect()
	{
		Super.DoEffect();
		tickCounter++;

		if (!owner || !owner.player || owner.player.health <= 0) return;

		PlayerInfo pi = owner.player;
		Weapon weap = pi.ReadyWeapon;
		let psp = pi.FindPSprite(PSP_WEAPON);
		if (!weap || !psp) return;
		Name weaponClass = weap.GetClassName();
		if (weaponClass != lastWeaponClass)
		{
			ClearTacticalPSpriteMotion(pi, psp);
			prevStrafeDot = 0;
			wallOnCount = 0;
			wallOffCount = 0;
			wallDebouncedActive = false;
			loweringAmount = 0;
			landingKick = 0;
			reloadBlend = 0;
			motionEnableBlend = 1.;
			hasNeutralWeaponY = false;
			lastWeaponClass = weaponClass;
		}

		if (tickCounter % 8 == 0) RefreshCvars(pi);
		if (!cvEnabled)
		{
			ClearTacticalPSpriteMotion(pi, psp);
			return;
		}

		bool blocked = ShouldBlockForSafety(owner, weap, psp);
		bool ready = IsReadyState(weap, psp);
		bool excluded = IsExcludedWeapon(weap);

		// Never stack tactical Y/roll on equip strips, quick melee, knife/shield, or other non-idle states.
		if (excluded || blocked || !ready)
		{
			ClearTacticalPSpriteMotion(pi, psp);
			hasNeutralWeaponY = false;
			return;
		}
		bool moving = owner.Vel.XY.Length() > 0.75;
		bool reloading = IsReloadState(weap, psp);
		if (reloading)
			reloadBlend += (1.0 - reloadBlend) * 0.18;
		else
			reloadBlend += (0.0 - reloadBlend) * 0.18;

		bool authoredFireOffset = false;

		bool allowMotion = !blocked && !excluded;
		if (cvEnableReadyOnly) allowMotion = allowMotion && ready;
		if (cvEnableMoveOnly) allowMotion = allowMotion && moving;
		bool allowLowering = allowMotion && !authoredFireOffset;

		if (allowMotion)
			motionEnableBlend += (1.0 - motionEnableBlend) * 0.15;
		else
			motionEnableBlend += (0.0 - motionEnableBlend) * 0.15;

		Vector2 strafeDir = (sin(-owner.angle), cos(-owner.angle));
		double strafeDot = (owner.Vel.X * strafeDir.X) + (owner.Vel.Y * strafeDir.Y);
		if (allowMotion)
		{
			if (prevStrafeDot * strafeDot < 0. && abs(strafeDot) > 0.02 && abs(prevStrafeDot) > 0.02)
				currentRoll *= 0.55;
			currentRoll += strafeDot * cvRollVelocity * motionEnableBlend;
			currentRoll *= cvRollResistance;
			if (cvCapRoll)
				currentRoll = clamp(currentRoll, -cvRollCap, cvRollCap);
		}
		else
		{
			currentRoll *= 0.75;
		}
		prevStrafeDot = strafeDot;

		double targetLower = 0;
		if (allowLowering)
		{
			double speedXY = owner.Vel.XY.Length();
			double sidewaysInput = abs(pi.cmd.sidemove);
			if (sidewaysInput < 64.0) sidewaysInput = 0.;
			double baseLower = (abs(strafeDot) * 0.9) + (speedXY * 0.225) + (sidewaysInput * 0.015);
			double lowerCap = 30.0;
			if (UsesExtraMoveLowering(weaponClass))
			{
				baseLower *= 1.14;
				baseLower += abs(currentRoll) * 0.11;
				lowerCap = 38.0;
			}
			targetLower = min(lowerCap, baseLower) * cvLoweringScale;
			targetLower = min(targetLower, 7.0);
		}
		bool allowWallDetect = !blocked && !excluded;
		if (cvEnableReadyOnly) allowWallDetect = allowWallDetect && ready;
		bool rawWall = cvWallDetect && allowWallDetect && !authoredFireOffset && FacingWall(cvWallDistance);
		if (rawWall)
		{
			wallOnCount = min(wallOnCount + 1, 10);
			wallOffCount = 0;
		}
		else
		{
			wallOffCount = min(wallOffCount + 1, 10);
			wallOnCount = 0;
		}
		if (wallOnCount >= 6) wallDebouncedActive = true;
		else if (wallOffCount >= 6) wallDebouncedActive = false;
		if (wallDebouncedActive)
			targetLower = min(32.0, targetLower + cvWallLowering);
		loweringAmount += (targetLower - loweringAmount) * 0.20;

		bool onFloor = IsOnFloor();
		if (previousOnFloor == false && onFloor == true && previousVelZ < -1.0)
			landingKick += min(12.0, abs(previousVelZ) * 0.5) * 1.5;
		if (abs(landingKick) > 1.0)
			landingKick *= 0.78;
		else
			landingKick *= 0.92;
		previousOnFloor = onFloor;
		previousVelZ = owner.Vel.Z;

		double targetLean = 0;
		if (cvEnableLean && !blocked && ready && !excluded && !authoredFireOffset)
		{
			bool toggleLean = owner.CountInv("CS_LeanToggle") > 0;
			bool moveLeft = (pi.cmd.buttons & BT_MOVELEFT) != 0;
			bool moveRight = (pi.cmd.buttons & BT_MOVERIGHT) != 0;
			if (toggleLean)
			{
				if (moveLeft && !moveRight) targetLean = -cvLeanAngle;
				else if (moveRight && !moveLeft) targetLean = cvLeanAngle;
				else if (pi.cmd.sidemove < 0) targetLean = -cvLeanAngle;
				else if (pi.cmd.sidemove > 0) targetLean = cvLeanAngle;
			}
			else
			{
				bool left = owner.CountInv("CS_LeanLeft") > 0;
				bool right = owner.CountInv("CS_LeanRight") > 0;
				if (left && !right) targetLean = -cvLeanAngle;
				else if (right && !left) targetLean = cvLeanAngle;
			}
		}
		leanRoll += (targetLean - leanRoll) * cvLeanSmoothing;

		double tiltS = cvTiltSmoothing;
		smoothedWeaponRoll = smoothedWeaponRoll * tiltS + currentRoll * (1.0 - tiltS);
		// PB leaves leanRoll for Tilt++ to read; this TC uses CS_* names so combine here for visible lean.
		double displayRoll = smoothedWeaponRoll + leanRoll;

		if (authoredFireOffset)
		{
			psp.Rotation = displayRoll;
			ApplyWeaponTiltToAttachedOverlays(pi, displayRoll);
			appliedYOffset = 0;
			neutralWeaponY = psp.Y;
			hasNeutralWeaponY = true;
			return;
		}
		psp.Rotation = displayRoll;
		ApplyWeaponTiltToAttachedOverlays(pi, displayRoll);
		if (hasNeutralWeaponY && appliedYOffset != 0)
		{
			double expectedY = neutralWeaponY + appliedYOffset;
			if (abs(psp.Y - expectedY) > 2.0 && abs(psp.Y - neutralWeaponY) < abs(psp.Y - expectedY))
				appliedYOffset = 0;
		}
		double baseY = psp.Y - appliedYOffset;
		if (!hasNeutralWeaponY)
		{
			neutralWeaponY = baseY;
			hasNeutralWeaponY = true;
		}
		if (ready && !blocked)
			neutralWeaponY += (baseY - neutralWeaponY) * 0.12;

		double extraLowerPixels = UsesExtraMoveLowering(weaponClass) ? 4.5 : 3.0;
		double targetYOffset = - (loweringAmount + (landingKick * 0.45) + (0.8 * reloadBlend) + extraLowerPixels);
		double yLowerCap = UsesExtraMoveLowering(weaponClass) ? -30.0 : -22.0;
		targetYOffset = clamp(targetYOffset, yLowerCap, 0.0);
		double newYOffset = appliedYOffset + (targetYOffset - appliedYOffset) * 0.20;
		double finalY = baseY + newYOffset;
		double maxRaisePixels = 1.0;
		if (finalY < neutralWeaponY - maxRaisePixels)
			finalY = neutralWeaponY - maxRaisePixels;
		psp.Y = finalY;
		appliedYOffset = finalY - baseY;
	}
}

class CS_TacticalFeelHandler : EventHandler
{
	override void PlayerEntered(PlayerEvent e)
	{
		if (!e) return;
		if (e.PlayerNumber < 0 || e.PlayerNumber >= MAXPLAYERS) return;
		if (!playeringame[e.PlayerNumber]) return;
		let mo = players[e.PlayerNumber].mo;
		if (!mo) return;
		mo.GiveInventory("CS_WeaponTilterInventory", 1);
		// One ambient spawner per player (Spawn state only fires once; do not stack on Pain).
		if (mo.CountInv("ClearSkyAmbientToken") < 1)
		{
			mo.GiveInventory("ClearSkyAmbientToken", 1);
			mo.A_SpawnItem("ClearSkySoundSpawner");
		}
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (!e) return;
		if (e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player] || !players[e.Player].mo) return;
		let mo = players[e.Player].mo;
		if (e.Name ~== "cs_lean_toggle")
		{
			if (mo.CountInv("CS_LeanToggle") > 0) mo.TakeInventory("CS_LeanToggle", 1);
			else mo.GiveInventory("CS_LeanToggle", 1);
		}
		else if (e.Name ~== "cs_lean_left") mo.GiveInventory("CS_LeanLeft", 1);
		else if (e.Name ~== "cs_unlean_left") mo.TakeInventory("CS_LeanLeft", 1);
		else if (e.Name ~== "cs_lean_right") mo.GiveInventory("CS_LeanRight", 1);
		else if (e.Name ~== "cs_unlean_right") mo.TakeInventory("CS_LeanRight", 1);
	}
}
