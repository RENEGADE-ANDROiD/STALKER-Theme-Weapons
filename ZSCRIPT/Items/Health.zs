// Sync CustomInventory amounts into ammo mirrors so SBARINFO DrawNumber works.
class CS_ConsumableHUD play
{
    static void SyncAmmo(Actor owner, class<Inventory> ammoType, int want)
    {
        if (!owner || !ammoType)
            return;
        int have = owner.CountInv(ammoType);
        if (have < want)
            owner.GiveInventory(ammoType, want - have);
        else if (have > want)
            owner.TakeInventory(ammoType, have - want);
    }
}

class StimInjectorAmmo : Ammo
{
    Default
    {
        Inventory.Amount 0;
        Inventory.MaxAmount 5;
        +INVENTORY.IGNORESKILL;
        +INVENTORY.UNDROPPABLE;
        +INVENTORY.UNTOSSABLE;
    }
}

class StimInjectorItem : CustomInventory
{
    Default
    {
        +INVENTORY.INVBAR;
        -INVENTORY.KEEPDEPLETED;
        Inventory.Icon "HUDStim";
        Inventory.Amount 1;
        Inventory.MaxAmount 5;
        Inventory.PickupSound "Items/StimInjector";
        Inventory.PickupMessage "Picked up a stim injector";
        Tag "Stim Injector";
        Scale 0.9;
    }

    override void DoEffect()
    {
        Super.DoEffect();
        CS_ConsumableHUD.SyncAmmo(Owner, "StimInjectorAmmo", Amount);
    }

    override void DetachFromOwner()
    {
        if (Owner)
            Owner.TakeInventory("StimInjectorAmmo", Owner.CountInv("StimInjectorAmmo"));
        Super.DetachFromOwner();
    }

    States
    {
    Spawn:
        WSTM A -1;
        Stop;
    Use:
        NULL A 0 A_JumpIf(Health >= 100, "NoPickup");
        NULL A 0 A_GiveInventory("UseStimInjector", 1);
        Stop;
    NoPickup:
        NULL A 0 A_Print("Your health is full", 1);
        Fail;
    }
}

class StimInjectorHealthGiver : PowerupGiver
{
    Default
    {
        Inventory.PickupMessage "You have gotten healed!";
        Inventory.MaxAmount 0;
        Powerup.Duration -25;
        Powerup.Type "PowerRegeneration";
        Powerup.Strength 1;
        +COUNTITEM;
        +INVENTORY.ADDITIVETIME;
        +INVENTORY.AUTOACTIVATE;
        +INVENTORY.ALWAYSPICKUP;
        +INVENTORY.PERSISTENTPOWER;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        Loop;
    }
}

class StimInjectorMote : Actor
{
    Default
    {
        +NOGRAVITY;
        +NOINTERACTION;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +FORCEXYBILLBOARD;
        +CLIENTSIDEONLY;
        RenderStyle "Add";
        Alpha 0.8;
        Scale 0.08;
    }
    States
    {
    Spawn:
        PUF6 A 1 Bright;
        PUF6 B 1 Bright A_FadeOut(0.18);
        PUF6 C 1 Bright A_FadeOut(0.24);
        Stop;
    }
}

class StimInjectorBurst : Actor
{
    Default
    {
        +NOGRAVITY;
        +NOINTERACTION;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +FORCEXYBILLBOARD;
        +CLIENTSIDEONLY;
        RenderStyle "Add";
        Alpha 0.95;
        Scale 0.16;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_SpawnItemEx("StimInjectorMote", random(-6, 6), random(-6, 6), random(6, 22), random(-1, 1), random(-1, 1), random(1, 3), 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        TNT1 A 0 A_SpawnItemEx("StimInjectorMote", random(-6, 6), random(-6, 6), random(6, 22), random(-1, 1), random(-1, 1), random(1, 3), 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        TNT1 A 0 A_SpawnItemEx("StimInjectorMote", random(-6, 6), random(-6, 6), random(6, 22), random(-1, 1), random(-1, 1), random(1, 3), 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        TNT1 A 0 A_SpawnItemEx("StimInjectorMote", random(-6, 6), random(-6, 6), random(6, 22), random(-1, 1), random(-1, 1), random(1, 3), 0, SXF_NOCHECKPOSITION | SXF_CLIENTSIDE);
        PUF6 A 1 Bright;
        PUF6 B 1 Bright A_FadeOut(0.18);
        PUF6 C 1 Bright A_FadeOut(0.28);
        Stop;
    }
}

class UseStimInjector : Inventory
{
    Default
    {
        Inventory.MaxAmount 1;
    }
}

// Remembers ReadyWeapon across stim injector animation.
class CS_SavedWeapon : Inventory
{
    class<Weapon> Saved;

    Default
    {
        Inventory.MaxAmount 1;
        +INVENTORY.UNDROPPABLE;
        +INVENTORY.UNTOSSABLE;
        +INVENTORY.HUBPOWER;
    }
}