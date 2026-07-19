//===========================================================================
// Tilt++ — camera roll (strafe / move / turn / underwater / death)
// Nash Muhandes — folded from Project Survival / TiltPlusPlus.zc
//===========================================================================

// Give during animations that must freeze camera roll (optional).
class CS_LockScreenTilt : Inventory
{
	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
	}
}

class TiltPlusPlusHandler : EventHandler
{
	override void PlayerEntered(PlayerEvent e)
	{
		let mo = players[e.PlayerNumber].mo;
		if (mo)
			mo.A_GiveInventory("Z_TiltMe", 1);
	}
}

class Z_TiltMe : Inventory
{
	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.AUTOACTIVATE
	}

	double strafeInput;
	double moveTiltOsc, underwaterTiltOsc;
	double deathTiltOsc;
	double deathTiltAngle;
	double lastRoll;

	bool bIsOnFloor()
	{
		return (Owner.Pos.Z == Owner.FloorZ) || Owner.bOnMObj;
	}

	double GetVelocity()
	{
		return Owner.Vel.Length();
	}

	int GetWaterLevel()
	{
		return Owner.WaterLevel;
	}

	bool bIsPlayerAlive()
	{
		return Owner.Health > 0;
	}

	void Tilt_CalcViewRoll()
	{
		bool strafeTiltEnabled = sv_strafetilt;
		bool moveTiltEnabled = sv_movetilt;
		bool turnTiltEnabled = sv_turntilt;
		bool underwaterTiltEnabled = sv_underwatertilt;
		bool deathTiltEnabled = sv_deathtilt;

		double strafeTiltSpeed = sv_strafetiltspeed;
		double strafeTiltAngle = sv_strafetiltangle;
		bool strafeTiltReversed = sv_strafetiltinvert;

		double moveTiltScalar = sv_movetiltscalar;
		double moveTiltAngle = sv_movetiltangle;
		double moveTiltSpeed = sv_movetiltspeed;

		double turnTiltScalar = sv_turntiltscalar;
		bool turnTiltReversed = sv_turntiltinvert;

		double underwaterTiltSpeed = sv_underwatertiltspeed;
		double underwaterTiltAngle = sv_underwatertiltangle;
		double underwaterTiltScalar = sv_underwatertiltscalar;

		double r = 0;

		//===========================================================================
		// Strafe Tilting
		//===========================================================================
		strafeInput = 0;
		if (strafeTiltEnabled && bIsOnFloor() && bIsPlayerAlive())
		{
			int dir = strafeTiltReversed ? -1 : 1;
			strafeInput = strafeTiltSpeed * (Owner.GetPlayerInput(MODINPUT_SIDEMOVE) / 10240.0);
			strafeInput *= strafeTiltAngle;
			strafeInput *= dir;
		}
		lastRoll += strafeInput;

		//===========================================================================
		// Movement Tilting
		//===========================================================================
		r = 0;
		if (moveTiltEnabled && bIsOnFloor() && bIsPlayerAlive())
		{
			double v = GetVelocity() * moveTiltScalar;
			moveTiltOsc += moveTiltSpeed;
			if (moveTiltOsc >= 360. || moveTiltOsc < 0.)
				moveTiltOsc = 0.;
			r = Sin(moveTiltOsc) * moveTiltAngle * v;
		}
		lastRoll += r;

		//===========================================================================
		// Turn Tilting
		//===========================================================================
		r = 0;
		if (turnTiltEnabled && bIsPlayerAlive())
		{
			double xinput = PlayerPawn(Owner).GetPlayerInput(MODINPUT_YAW) * (turnTiltReversed ? -1 : 1);
			r = turnTiltScalar * xinput / 32767.0;
		}
		lastRoll += r;

		//===========================================================================
		// Underwater Tilting
		//===========================================================================
		r = 0;
		if (GetWaterLevel() >= 3 && underwaterTiltEnabled)
		{
			double v = 15. * underwaterTiltScalar;
			underwaterTiltOsc += underwaterTiltSpeed;
			if (underwaterTiltOsc >= 360. || underwaterTiltOsc < 0.)
				underwaterTiltOsc = 0.;
			r = Sin(underwaterTiltOsc) * underwaterTiltAngle * v;
		}
		lastRoll += r;

		//===========================================================================
		// Death Tilting
		//===========================================================================
		r = 0;
		if (!bIsPlayerAlive() && deathTiltEnabled)
		{
			if (deathTiltAngle == 0)
			{
				deathTiltAngle = -90.;
				deathTiltAngle += FRandom(-45., 45.);
				deathTiltAngle *= RandomPick(-1, 1);
			}
			if (deathTiltOsc < 22.5)
				deathTiltOsc += 1.0;
			r = Sin(deathTiltOsc) * deathTiltAngle;
		}
		else
		{
			deathTiltOsc = 0;
			deathTiltAngle = 0;
		}
		lastRoll += r;

		//===========================================================================
		// Stabilize + apply
		//===========================================================================
		if (abs(lastRoll) > 0.000001)
			lastRoll *= 0.75;

		Owner.A_SetRoll((Owner.Roll + lastRoll) * 0.5, SPF_INTERPOLATE);
	}

	override void Tick()
	{
		if (Owner && Owner is "PlayerPawn" && !Owner.CountInv("CS_LockScreenTilt"))
			Tilt_CalcViewRoll();
		Super.Tick();
	}
}
