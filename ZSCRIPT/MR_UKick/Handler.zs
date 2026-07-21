// Universal Kick — folded into STALKER Theme Weapons (Mickromash).
// Features always on: kick, crouch+kick or run/sprint+kick slide (momentum extends), FP legs, taunt gesture.
// (Ledge grab disabled — BiasedDoom null-deref.)

class MR_uKickHandler : EventHandler
{
	override void NetworkProcess(ConsoleEvent e)
	{
		let plr = players[e.Player].mo;
		if (!plr || plr.health < 1) return;

		if (e.name ~== "MR_uKick")
		{
			if (!plr.CountInv("MR_uKickToken"))
				plr.A_GiveInventory("MR_uKickToken");
			plr.UseInventory(plr.FindInventory("MR_uKickToken"));
		}
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (PlayerPawn(players[i].mo))
				PlayerPawn(players[i].mo).A_TakeInventory("MR_uKickToken");
		}
	}

	override void PlayerEntered(PlayerEvent e)
	{
		let plr = players[e.PlayerNumber].mo;
		if (!plr) return;
		plr.A_GiveInventory("MR_uKickToken");
		plr.A_GiveInventory("MR_uLegsToken");
		// Ledge grab disabled — Mr_uLedgeToken + LineTrace crashes under BiasedDoom (null VM read on E1M1).
		// plr.A_GiveInventory("Mr_uLedgeToken");
		plr.A_GiveInventory("MR_FukToken");
		plr.Roll = 0;
	}
}
