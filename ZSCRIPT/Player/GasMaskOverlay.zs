// Dynamic gas-mask HUD layer (inertial sway + fade-in) without the helmet visor shell.
// Matched to Callsign: Zero CSZ_MFD_GasMaskOverlayHandler (ProSurv Essentials lineage).
// Asset: Graphics/ps_hf/gasmask/pb_gasmask.png

class CS_GasMaskOverlayHandler : EventHandler
{
	const CS_GASMASK_OVERHANG = 0.08; // 108% of screen.

	bool showMask;
	double maskAlpha;

	double m0to1Float;

	double prevYaw;
	double prevPitch;
	double tiltX;
	double tiltY;
	bool tiltInited;

	override void OnRegister()
	{
		showMask = false;
		maskAlpha = 1.0;
		m0to1Float = 0.0;
		prevYaw = 0;
		prevPitch = 0;
		tiltX = 0;
		tiltY = 0;
		tiltInited = false;
	}

	override void PlayerEntered(PlayerEvent e)
	{
		m0to1Float = 0.0;
		tiltInited = false;
	}

	override void WorldTick()
	{
		if (gamestate != GS_LEVEL)
			return;

		PlayerInfo plr = players[consoleplayer];
		if (!plr || !plr.mo)
			return;

		let cvShow = CVar.GetCVar("cs_gasmask", plr);
		let cvAlpha = CVar.GetCVar("cs_gasmask_alpha", plr);
		showMask = cvShow ? cvShow.GetBool() : false;
		maskAlpha = cvAlpha ? cvAlpha.GetFloat() : 1.0;

		if (plr.mo.health > 0 && m0to1Float < 1.0)
			m0to1Float = min(m0to1Float + 0.1, 1.0);

		if (showMask)
			UpdateGasmaskTilt(plr);
		else
			tiltInited = false;
	}

	void UpdateGasmaskTilt(PlayerInfo plr)
	{
		if (!plr || !plr.mo)
		{
			tiltInited = false;
			return;
		}

		double curYaw = plr.mo.angle;
		double curPitch = plr.mo.pitch;

		if (!tiltInited)
		{
			prevYaw = curYaw;
			prevPitch = curPitch;
			tiltInited = true;
		}

		double dyaw = Actor.DeltaAngle(prevYaw, curYaw);
		double dpitch = Actor.DeltaAngle(prevPitch, curPitch);

		double targetX = clamp(-dyaw * 2.2, -12.0, 12.0);
		double targetY = clamp(-dpitch * 1.8, -9.0, 9.0);

		tiltX = (tiltX * 0.70 + targetX * 0.30) * 0.88;
		tiltY = (tiltY * 0.70 + targetY * 0.30) * 0.88;

		prevYaw = curYaw;
		prevPitch = curPitch;
	}

	override void RenderUnderlay(RenderEvent e)
	{
		if (!showMask || m0to1Float <= 0)
			return;

		PlayerInfo plr = players[consoleplayer];
		if (!plr || !plr.mo)
			return;

		DrawGasmask();
	}

	ui void DrawGasmask()
	{
		TextureID tex = TexMan.CheckForTexture(
			"graphics/ps_hf/gasmask/pb_gasmask.png", TexMan.Type_Any);
		if (!tex.IsValid())
			return;

		double scrW = Screen.GetWidth();
		double scrH = Screen.GetHeight();
		double hudScale = scrH / 200.0;
		let sb = statusbar;
		if (sb)
		{
			Vector2 hsv = sb.GetHUDScale();
			if (hsv.y > 0.5)
				hudScale = hsv.y;
		}

		double offX = tiltX * hudScale;
		double offY = tiltY * hudScale;
		double a = clamp(m0to1Float * maskAlpha, 0.0, maskAlpha);
		double dw = scrW * (1.0 + CS_GASMASK_OVERHANG);
		double dh = scrH * (1.0 + CS_GASMASK_OVERHANG);

		Screen.DrawTexture(tex, false,
			scrW * 0.5 + offX, scrH * 0.5 + offY,
			DTA_DestWidth, int(dw), DTA_DestHeight, int(dh),
			DTA_Alpha, a,
			DTA_CenterOffset, true);
	}
}
