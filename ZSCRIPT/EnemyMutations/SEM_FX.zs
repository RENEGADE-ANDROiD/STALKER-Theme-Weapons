// Lightweight FX / DoT helpers (particle-first; no Champions sprites).

class SEM_ChemicalCreep : Actor
{
	Default
	{
		Radius 16;
		Height 4;
		+NOBLOCKMAP;
		+NOTELEPORT;
		+DONTSPLASH;
		RenderStyle "Stencil";
		StencilColor "00AA00";
		Alpha 0.35;
	}

	States
	{
	Spawn:
		TNT1 A 0 NoDelay
		{
			A_SetScale(frandom(0.6, 1.1));
		}
		TNT1 AAAAAAAAAAAAAAAAAAAA 3 A_Explode(2, 40, XF_HURTSOURCE, false, 40);
		Stop;
	}
}

class SEM_ThermalBurst : Actor
{
	Default
	{
		+NOBLOCKMAP;
		+NOTELEPORT;
		+NOGRAVITY;
	}

	States
	{
	Spawn:
		TNT1 A 0 NoDelay
		{
			A_StartSound("weapons/rocklx", CHAN_AUTO, CHANF_OVERLAP, 0.7);
			A_Explode(96, 112, XF_HURTSOURCE);
			for (int i = 0; i < 10; i++)
			{
				A_SpawnParticle("ff6600",
					flags: SPF_FULLBRIGHT | SPF_RELPOS,
					lifetime: 28,
					size: frandom(4.0, 8.0),
					angle: frandom(0, 360),
					zoff: frandom(0, 40),
					velz: frandom(0.5, 2.0));
			}
		}
		Stop;
	}
}

class SEM_ChemicalPoisonBase : Powerup
{
	override void InitEffect()
	{
		Super.InitEffect();
		if (Owner)
			Owner.A_SetBlend("66AA00", 0.28, 35 * 3);
	}

	override void DoEffect()
	{
		Super.DoEffect();
		Actor own = Owner;
		if (!own || own.health <= 0 || level.time % 35 != 0)
			return;
		if (SEM_Static.OwnerResistsChemical(own))
			return;
		own.A_DamageSelf(2, "sem_Chemical", flags: 0);
	}
}

class SEM_ChemicalPoison : PowerupGiver
{
	Default
	{
		Powerup.Type "SEM_ChemicalPoisonBase";
		Powerup.Duration -3;
		+INVENTORY.AUTOACTIVATE;
		+INVENTORY.ALWAYSPICKUP;
	}
}

class SEM_PsiShockBase : Powerup
{
	override void InitEffect()
	{
		Super.InitEffect();
		if (Owner)
			Owner.A_SetBlend("8844CC", 0.35, 20);
	}

	override void DoEffect()
	{
		Super.DoEffect();
		// Local copy + shake before damage: A_DamageSelf can kill the pawn and
		// clear Owner mid-DoEffect (null deref on Angle/Pitch under BiasedDoom).
		Actor own = Owner;
		if (!own || own.health <= 0 || level.time % 8 != 0)
			return;
		own.Angle += frandom(-1.5, 1.5);
		own.Pitch = clamp(own.Pitch + frandom(-0.8, 0.8), -60, 60);
		if (own.health > 0)
			own.A_DamageSelf(1, "sem_Psi", flags: 0);
	}
}

class SEM_PsiShock : PowerupGiver
{
	Default
	{
		Powerup.Type "SEM_PsiShockBase";
		Powerup.Duration -2;
		+INVENTORY.AUTOACTIVATE;
		+INVENTORY.ALWAYSPICKUP;
	}
}
