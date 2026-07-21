class ClearSkyWeapon : CS_WeaponBase
{
    // PB-style lingering barrel smoke — heat from muzzle SmokeSpawner*, cools in DoEffect.
    int barrelHeat;

    Default
    {
        Weapon.BobStyle "Smooth";
        Weapon.BobSpeed 1.5;
        Weapon.BobRangeX 0.10;
        Weapon.BobRangeY 0.10;
    }

    void CS_AddBarrelHeat(int amount)
    {
        if (amount <= 0) return;
        barrelHeat = min(barrelHeat + amount, 120);
    }

    // Trails thin smoke from the muzzle for a few seconds after firing (PB CoolDownBarrel).
    void CS_CoolDownBarrel()
    {
        if (barrelHeat < 1) return;
        barrelHeat--;

        // Spawn every 3rd tic so the trail reads as continuous without flooding particles.
        if (level.maptime % 3 != 0) return;

        let p = PlayerPawn(owner);
        if (!p) return;

        double endingScale = clamp(double(barrelHeat) / 20.0, 0.5, 1.0);
        double cosp = cos(p.pitch);
        Vector3 dir = (cos(p.angle) * cosp, sin(p.angle) * cosp, -sin(p.pitch));
        Vector3 eye = p.pos + (0, 0, p.viewheight * 0.72);
        Vector3 spawnPos = eye + dir * 10.0;

        let sm = CS_GunBarrelSmoke(Spawn("CS_GunBarrelSmoke", spawnPos));
        if (!sm) return;

        sm.target = p;
        sm.angle = p.angle;
        sm.pitch = p.pitch;
        sm.scale.x *= endingScale;
        sm.scale.y *= endingScale;
        sm.alpha *= (0.55 + 0.45 * endingScale);
        sm.vel = dir * (1.2 + frandom(0.0, 0.6))
            + (frandom(-0.25, 0.25), frandom(-0.25, 0.25), frandom(0.35, 0.85) * endingScale);
    }

    override void DoEffect()
    {
        Super.DoEffect();
        if (barrelHeat <= 0) return;
        if (!owner || !owner.player || owner.player.ReadyWeapon != self) return;
        CS_CoolDownBarrel();
    }

    // ------------------------------------------------------------------------
    // Instant mag fill / equipment helpers continue below.
    // (Knife feel + A_KnifeLunge live on CS_WeaponBase so NR-40 inherits too.)
    // ------------------------------------------------------------------------
    action void A_ReadyWithMelee()
    {
        A_WeaponReady(WRF_ALLOWUSER1);
    }

    action void A_ReadyWithReloadAndMelee()
    {
        A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWUSER1);
    }

    // Instant mag fill used by ReloadLoop (avoids multi-second invisible TNT1 waits).
    action void A_CS_FillMagazine(class<Inventory> magType, class<Inventory> reserveType, int magMax)
    {
        if (!player || !player.mo || magMax <= 0)
            return;

        int have = CountInv(magType);
        int need = magMax - have;
        if (need <= 0)
            return;

        int reserve = CountInv(reserveType);
        int take = min(need, reserve);
        if (take <= 0)
            return;

        TakeInventory(reserveType, take, TIF_NOTAKEINFINITE);
        GiveInventory(magType, take);
    }

    // Goto on ClearSkyWeapon is STATIC — it always lands on this class's TNT1
    // RealReady/Ready, ignoring child firearm labels. ResolveState is dynamic.
    action state A_CS_GotoRealReady()
    {
        State st = ResolveState("RealReady");
        if (st) return st;
        return ResolveState("Ready");
    }

    action state A_CS_GotoAfterUse()
    {
        return ResolveState("AfterUse");
    }

    // Remember ReadyWeapon before stim so AfterUse can re-select / re-raise it.
    action void A_CS_SaveReadyWeapon()
    {
        let p = player;
        if (!p || !p.mo || !p.ReadyWeapon)
            return;

        if (!p.mo.FindInventory("CS_SavedWeapon"))
            p.mo.GiveInventory("CS_SavedWeapon", 1);

        let tok = CS_SavedWeapon(p.mo.FindInventory("CS_SavedWeapon"));
        if (tok)
            tok.Saved = p.ReadyWeapon.GetClass();
    }

    action void A_CS_RestoreReadyWeapon()
    {
        let p = player;
        if (!p || !p.mo)
            return;

        let tok = CS_SavedWeapon(p.mo.FindInventory("CS_SavedWeapon"));
        if (!tok || tok.Saved == null)
            return;

        class<Weapon> want = tok.Saved;
        tok.Saved = null;
        p.mo.TakeInventory("CS_SavedWeapon", 1);

        if (!p.mo.FindInventory(want))
            return;

        // Already on that gun — AfterUse raise strip handles bring-up.
        if (p.ReadyWeapon && p.ReadyWeapon.GetClass() == want)
            return;

        A_SelectWeapon(want);
    }

    States
    {
    // Fallback for inherited AfterUse / User1 (firearms define their own Ready strips).
    Ready:
        TNT1 A 1 A_WeaponReady(WRF_ALLOWUSER1);
        Loop;

    RealReady:
        TNT1 A 1 A_WeaponReady(WRF_ALLOWUSER1 | WRF_ALLOWRELOAD);
        Loop;

    // Require both use token and inventory item before throw/heal (stale tokens / pickup+use same tic).
    CS_CheckMolUse:
        TNT1 A 0 A_JumpIfInventory("MolotovItem", 1, "UseMolotovState");
        TNT1 A 0 A_TakeInventory("UseMolotov", 1);
        TNT1 A 0 A_CS_GotoRealReady();

    CS_CheckF1Use:
        TNT1 A 0 A_JumpIfInventory("F1GrenadeItem", 1, "UseF1GrenadeState");
        TNT1 A 0 A_TakeInventory("UseF1Grenade", 1);
        TNT1 A 0 A_CS_GotoRealReady();

    CS_CheckStimUse:
        TNT1 A 0 A_JumpIfInventory("StimInjectorItem", 1, "CS_CheckStimHealth");
        TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_CS_GotoRealReady();

    CS_CheckStimHealth:
        TNT1 A 0 A_JumpIf(health >= GetMaxHealth(), "CS_StimFull");
        TNT1 A 0 A_CS_SaveReadyWeapon();
        Goto UseInjectorState;

    CS_StimFull:
        TNT1 A 0 A_Print("Your health is full", 1);
        TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_CS_GotoRealReady();

    CS_StimDone:
        TNT1 A 0 A_CS_RestoreReadyWeapon();
        TNT1 A 0 A_CS_GotoAfterUse();

    Select:
        TNT1 A 0 A_Raise();
        Wait;

    Deselect:
        TNT1 A 0 A_Lower();
        Wait;

    Fire:
        TNT1 A 1;
        TNT1 A 0 A_CS_GotoRealReady();

    User1:
        TNT1 A 0 A_PlaySound("NR40/Swing", CHAN_WEAPON);
        NR40 A 1 A_CS_KnifeFeelWind();
        NR40 H 1 A_CS_KnifeFeelStep(0.970);
        NR40 B 1 A_CS_KnifeFeelStep(0.965);
        NR40 C 1 A_CS_KnifeFeelStep(0.955);
        NR40 D 1 A_CS_KnifeFeelCommit();
        NR40 E 1 A_KnifeLunge();
        NR40 F 1 A_CS_KnifeFeelReturn(0.975);
        NR40 G 1 A_CS_KnifeFeelReturn(0.990);
        NR40 H 1 A_CS_KnifeFeelEnd();
        // Dynamic jump — static Goto RealReady stays on ClearSkyWeapon's blank TNT1.
        TNT1 A 0 A_CS_GotoRealReady();

    // F-1 Grenade
    UseF1GrenadeState:
        TNT1 A 0 A_JumpIfInventory("F1GrenadeItem", 1, "UseF1GrenadeState.Go");
        TNT1 A 0 A_TakeInventory("UseF1Grenade", 1);
        TNT1 A 0 A_CS_GotoRealReady();

    UseF1GrenadeState.Go:
        TNT1 A 0 A_PlaySound("weapon/down", 8);
        Goto ThrowF1;

    ThrowF1:
        TNT1 A 2 A_WeaponOffset(0, 32, WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing", 4);
        HNGR D 0 A_TakeInventory("UseF1Grenade", 1);
        HNGR D 0 A_TakeInventory("F1GrenadeItem", 1);
        HNGR C 1 A_FireCustomMissile("F1Grenade", random(-2,2), 0, 0, 0, 0, 0);
        HNGR DF 1;
        TNT1 A 4;
        TNT1 A 0 A_CS_GotoAfterUse();

    // Molotov Cocktail
    UseMolotovState:
        TNT1 A 0 A_JumpIfInventory("MolotovItem", 1, "UseMolotovState.Go");
        TNT1 A 0 A_TakeInventory("UseMolotov", 1);
        TNT1 A 0 A_CS_GotoRealReady();

    UseMolotovState.Go:
        TNT1 A 0 A_PlaySound("weapon/down", 8);
        Goto ThrowMolotov;

    ThrowMolotov:
        TNT1 A 2 A_WeaponOffset(0, 32, WOF_INTERPOLATE);
        HNGR AB 1 A_PlaySound("Item/Swing", 4);
        HNGR D 0 A_TakeInventory("UseMolotov", 1);
        HNGR D 0 A_TakeInventory("MolotovItem", 1);
        HNGR C 1 A_FireCustomMissile("MolotovCocktail", random(-2,2), 0, 0, 0, 0, 0);
        HNGR DF 1;
        TNT1 A 4;
        TNT1 A 0 A_CS_GotoAfterUse();

    // Stim Injector
    UseInjectorState:
        TNT1 A 0 A_PlaySound("weapon/down", 8);
        Goto HealInjector;

    HealInjector:
        TNT1 A 2 A_WeaponOffset(0, 32, WOF_INTERPOLATE);
        HLN1 ABCDEFH 1;
        HLN1 I 9;
        HLN1 JKL 1;
        TNT1 A 0 A_TakeInventory("UseStimInjector", 1);
        TNT1 A 0 A_TakeInventory("StimInjectorItem", 1);
        TNT1 A 0 A_PlaySound("Items/UseStimInjector", 5);
        TNT1 A 0 A_PlaySound("*pain100", 6);
        TNT1 A 0 A_SetBlend("White", 0.5, 35);
        // Direct heal — PowerRegeneration giver was unreliable / easy to miss.
        TNT1 A 0 { GiveBody(40); }
        TNT1 A 0 A_SpawnItemEx("StimInjectorBurst", 0, 0, 32, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        HLN1 MNMNOPOP 1;
        HLN1 P 14;
        HLN1 QRSTUVW 1;
        Goto CS_StimDone;

    AfterUse:
        TNT1 A 0 A_PlaySound("weapon/up", 9);
        TNT1 A 0 A_CS_GotoRealReady();
    }
}