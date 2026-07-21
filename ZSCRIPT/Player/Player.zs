class STALKERPlayer : DoomPlayer
{
	// Yaw weapon sway (ZMove / Project Survival math — applied on top of engine bob).
	double ViewAngleDelta;
	double XBobOffset;

    Default
    {
        Speed 0.80;
        Health 100;
        Radius 16;
        Height 56;
        Mass 300;
		Player.JumpZ 10;
		Player.ForwardMove 1.0,1.0;		//Player.ForwardMove 2.2,1.1;
		Player.Sidemove 0.8,0.8;		//Player.Sidemove 2.2,1.1;
		Player.AttackZOffset 16; //14
		Player.viewheight 48; //41
		MaxStepHeight 38;
        PainChance 255;
        Player.RunHealth 15;
        Player.CrouchSprite "MNK1";
        Player.DisplayName "STALKER";
        Player.StartItem "Fort12";
        Player.StartItem "NR40";
        Player.StartItem "Fort12Loaded", 12;
        Player.StartItem "MakarovClip", 100;
        Player.StartItem "StimInjectorItem", 1;
        Player.StartItem "F1GrenadeItem", 1;
		Player.StartItem "DutyPDA", 1;
        Player.WeaponSlot 1, "NR40", "RiotShield";
        Player.WeaponSlot 2, "Fort12", "TT33";
        Player.WeaponSlot 3, "Vepr12", "TOZ34", "KS23";
        Player.WeaponSlot 4, "PP19", "PPSh41", "ASVAL";
        Player.WeaponSlot 5, "SKS", "MosinNagant", "SVD";
        Player.WeaponSlot 6, "AK47", "OTS14", "RP46";
        Player.WeaponSlot 7, "GM94", "RPG7D";
        DamageFactor "Duty", 0.0;
    }

	private bool WeaponAllowsYawSway()
	{
		// All raised weapons (including riot shield / knife).
		return player && player.ReadyWeapon;
	}

	override void Tick()
	{
		// Capture yaw BEFORE Super.Tick — MODINPUT_YAW is often consumed afterward.
		if (player)
			ViewAngleDelta = GetPlayerInput(MODINPUT_YAW) * (360.0 / 65536.0);

		Super.Tick();
		if (!player)
			return;

		let swayOn = CVar.GetCVar("zm_yawsway", player);
		bool sway = !swayOn || swayOn.GetBool();
		if (sway && WeaponAllowsYawSway())
		{
			double dir = 1.0;
			let cDir = CVar.GetCVar("zm_yawswaydirection", player);
			if (cDir && cDir.GetBool()) dir = -1.0;

			double speed = 2.0;
			let cSpd = CVar.GetCVar("zm_yawswayspeed", player);
			if (cSpd) speed = cSpd.GetFloat();

			// Strafe weapon rot-tilt owns horizontal motion; yaw X-bob fights it.
			// Fade look-sway drive (and bleed residual) while sidestepping.
			double side = abs(GetPlayerInput(MODINPUT_SIDEMOVE));
			double strafeMul = 1.0;
			if (side > 2048.0)
				strafeMul = clamp(1.0 - (side - 2048.0) / 8192.0, 0.12, 1.0);

			XBobOffset += dir * ViewAngleDelta * speed / 35.0 * strafeMul;

			double friction = 1.0;
			let cFric = CVar.GetCVar("zm_yawswayfriction", player);
			if (cFric) friction = cFric.GetFloat() / 10.0;

			if (abs(XBobOffset) > 0.2)
				XBobOffset -= XBobOffset / ((1.5 - friction) * 100.0);
			else if (ViewAngleDelta == 0)
				XBobOffset = 0;

			if (strafeMul < 0.999)
				XBobOffset *= (0.80 + 0.20 * strafeMul);
		}
		else
		{
			XBobOffset = 0;
		}
	}

	override Vector2 BobWeapon(double ticfrac)
	{
		Vector2 r = Super.BobWeapon(ticfrac);
		if (!player)
			return r;

		let swayOn = CVar.GetCVar("zm_yawsway", player);
		bool sway = !swayOn || swayOn.GetBool();
		if (sway && WeaponAllowsYawSway() && abs(XBobOffset) > 0.001)
		{
			double range = 20.0;
			let cRange = CVar.GetCVar("zm_yawswayrange", player);
			if (cRange) range = cRange.GetFloat() * 10.0;
			r.X += clamp(XBobOffset, -range, range);
		}
		return r;
	}

    States
    {
    Spawn:
        goto RealSpawn;
    RealSpawn:
        MNK1 A 1;
        Loop;
    See:
        MNK1 ABCD 6;
        goto RealSpawn;
    Missile:
        MNK1 E 12;
        goto RealSpawn;
    Melee:
        MNK1 F 6 Bright;
        goto Missile;
    Pain:
        MNK1 G 3 A_Pain;
        goto RealSpawn;
    Death:
        MNK1 H 5;
        MNK1 I 5 A_PlayerScream;
        MNK1 J 5 A_NoBlocking;
        MNK1 KLM 5;
        MNK1 M 0 A_CustomMissile("GrowingBloodPool", 0, 0, random(0, 360), 2, random(0, 90));
        MNK1 N -1;
        Stop;
    XDeath:
        TNT1 AA 0 A_CustomMissile("FlyingBloodParticleFast", 60, 0, random(0, 360), 2, random(0, 90));
        TNT1 AA 0 A_CustomMissile("FlyingBloodParticleBig", 50, 0, random(0, 360), 2, random(30, 90));
        TNT1 AAAA 0 A_CustomMissile("FlyingBloodParticleBig", 30, 0, random(0, 360), 2, random(10, 45));
        TNT1 AA 0 A_CustomMissile("XDeath1b", 40, 0, random(0, 360), 2, random(45, 50));
        TNT1 AAA 0 A_CustomMissile("XDeath2", 50, 0, random(0, 360), 2, random(10, 45));
        TNT1 AAA 0 A_CustomMissile("XDeath3", 50, 0, random(0, 360), 2, random(10, 45));
        TNT1 AA 0 A_CustomMissile("XDeath4", 50, 0, random(0, 360), 2, random(40, 60));
        TNT1 AAA 0 A_CustomMissile("XDeath5", 50, 0, random(0, 360), 2, random(10, 45));
        TNT1 AA 0 A_CustomMissile("XDeath7", 50, 0, random(0, 360), 2, random(40, 60));
        TNT1 AA 0 A_CustomMissile("XDeath7b", 50, 0, random(0, 360), 2, random(40, 60));
        MNK1 O 5 A_XScream;
        MNK1 P 5 A_NoBlocking;
        MNK1 QRSTUV 5;
        MNK1 V 0 A_CustomMissile("XDeath1", 40, 0, random(0, 360), 2, random(10, 45));
        MNK1 W -1;
        Stop;
    Death.Fire:
        BURN A 0 A_NoBlocking;
        BURN A 0 A_PlaySound("Human/Burn");
        BURN A 1 BRIGHT A_Wander;
        BURN A 0 A_Wander;
        BURN AABBCCDDEE 3 BRIGHT A_CustomMissile("BurnParticles", 36, 0, random(0, 180), 2, random(0, 180));
        BURN A 0 A_Wander;
        BURN FFGGHH 3 BRIGHT A_CustomMissile("BurnParticles", 36, 0, random(0, 180), 2, random(0, 180));
        BURN A 0 A_Wander;
        BURN IIJJKKLL 3 BRIGHT A_CustomMissile("BurnParticles", 28, 0, random(0, 180), 2, random(0, 180));
        BURN A 0 A_Wander;
        BURN MMN 3 BRIGHT A_CustomMissile("BurnParticles", 32, 0, random(0, 180), 2, random(0, 180));
        BURN NOOPP 3 BRIGHT A_CustomMissile("BurnParticles", 22, 0, random(0, 180), 2, random(0, 180));
        BURN QQ 3 BRIGHT A_CustomMissile("BurnParticles", 18, 0, random(0, 180), 2, random(0, 180));
        BURN A 0 A_PlaySound("Human/Burn");
        BURN RRSSTTRRSSTTSSRRSSTTSSRRSSTTSSTT 3 BRIGHT A_CustomMissile("BurnParticles", 12, 0, random(0, 180), 2, random(0, 180));
        BURN UU 3 BRIGHT A_CustomMissile("SmallBurnParticles", 8, 0, random(0, 180), 2, random(0, 180));
        BURN VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV 9 A_CustomMissile("BurnedSmoke", 8, 0, random(0, 360), 2, random(90, 110));
        BURN V -1;
        Stop;
    Crush:
        TNT1 AAAAAAAAAA 0 A_CustomMissile("FlyingBloodParticleCrushed", 0, 0, random(0, 360), 2, random(0, 90));
        TNT1 AA 0 A_CustomMissile("XDeath2", 50, 0, random(0, 360), 2, random(10, 45));
        TNT1 AA 0 A_CustomMissile("XDeath3", 50, 0, random(0, 360), 2, random(10, 45));
        CRSH A -1;
        Stop;
    }
}