// Actor that spawns nothing (scarcity filler — does not replace map HealthBonus).
class NothingItem : Actor
{
    Default
    {
        +NOINTERACTION;
        +NOBLOCKMAP;
        +NOSECTOR;
    }
    States
    {
    Spawn:
        TNT1 A 1;
        Stop;
    }
}

// Scarcity gate for RandomSpawners that use NothingItem.
// cs_item_spawn_chance: 1.0 = table weights unchanged; <1 empties more; >1 fills more empties (up to 2.0).
class CS_ItemScarcitySpawner : RandomSpawner
{
    override Name ChooseSpawn()
    {
        Name result = Super.ChooseSpawn();
        CVar cv = CVar.FindCVar("cs_item_spawn_chance");
        double mult = cv ? cv.GetFloat() : 1.0;
        if (mult < 0.0) mult = 0.0;
        if (mult > 2.0) mult = 2.0;

        if (mult >= 0.999 && mult <= 1.001)
            return result;

        bool empty = (result == 'None' || result == 'NothingItem');

        if (mult < 1.0)
        {
            if (!empty && frandom[cs_spawn](0.0, 1.0) > mult)
                return 'None';
            return result;
        }

        // mult > 1: reduce empty rolls by re-picking a non-empty drop.
        if (empty)
        {
            double fillBoost = min(mult - 1.0, 1.0);
            if (frandom[cs_spawn](0.0, 1.0) < fillBoost)
                return ChooseNonEmptySpawn();
        }
        return result;
    }

    Name ChooseNonEmptySpawn()
    {
        for (int i = 0; i < 8; i++)
        {
            Name n = Super.ChooseSpawn();
            if (n != 'None' && n != 'NothingItem')
                return n;
        }

        DropItem di = GetDropItems();
        while (di != null)
        {
            if (di.Name != 'NothingItem' && di.Name != 'None')
                return di.Name;
            di = di.Next;
        }
        return 'None';
    }
}

class StimpackSpawner : RandomSpawner replaces Stimpack
{
    Default
    {
        DropItem "StimInjectorItem", 255, 1;
    }
}

// HealthBonus → food / bandage / pills (scarcity via NothingItem + cs_item_spawn_chance)
class HealthBonusSpawner : CS_ItemScarcitySpawner replaces HealthBonus
{
    Default
    {
        DropItem "NothingItem", 255, 5;
        DropItem "CS_FoodRation", 255, 4;
        DropItem "CS_CannedFood", 255, 3;
        DropItem "CS_Bandage", 255, 3;
        DropItem "CS_PainPills", 255, 2;
    }
}

class MedikitSpawner : RandomSpawner replaces Medikit
{
    Default
    {
        DropItem "CS_FieldMedkit", 255, 1;
    }
}

// Backpack → Zone supply drop (RPGAB0): random ammo + grenade / molotov / stim
class BackpackSpawner : RandomSpawner replaces Backpack
{
    Default
    {
        DropItem "CS_AmmoSupplyCrate", 255, 1;
    }
}

// Ambience sound spawner (once per player — see StepEventHandler.PlayerEntered)
class ClearSkyAmbientToken : Inventory
{
    Default
    {
        Inventory.MaxAmount 1;
        +INVENTORY.UNDROPPABLE;
    }
}

class ClearSkySoundSpawner : SpecialSpot
{
    Default
    {
        +NOSECTOR;
        +NOBLOCKMAP;
    }
    States
    {
    Spawn:
        TNT1 A 1;
        TNT1 A -1 A_SpawnSingleItem("ClearSkySoundRandom");
        Stop;
    }
}

class ClearSkySoundRandom : RandomSpawner
{
    Default
    {
        DropItem "ClearSkyAmbientSound1", 255, 8;
        DropItem "ClearSkyAmbientSound2", 255, 8;
        DropItem "ClearSkyAmbientSound3", 255, 8;
        DropItem "ClearSkyAmbientSound4", 255, 8;
    }
}

// Lamps / columns
class ColumnSpawner : RandomSpawner replaces Column
{
    Default
    {
        DropItem "ClearSkyColumn", 255, 4;
        DropItem "BrokenColumn", 255, 8;
    }
}

// Gore spawners
class DeadDutySpawner : RandomSpawner replaces GibbedMarineExtra
{
    Default
    {
        DropItem "DeadDutyNoFlies", 255, 8;
        DropItem "DeadDutyWithFlies", 255, 8;
    }
}

class DeadMarineSpawner : RandomSpawner replaces DeadMarine
{
    Default
    {
        DropItem "DeadBodyNoFlies", 255, 8;
        DropItem "DeadBodyWithFlies", 255, 8;
        DropItem "DeadDutySpawner", 255, 2;
    }
}

class GibbedMarineSpawner : RandomSpawner replaces GibbedMarine
{
    Default
    {
        DropItem "GibbedBodyNoFlies", 255, 8;
        DropItem "GibbedBodyWithFlies", 255, 8;
        DropItem "DeadDutySpawner", 255, 2;
    }
}

// Ammo spawners — F-1 / molotov at weight 1 (uncommon; ~5–7% each at default tables).
class ClipSpawner : CS_ItemScarcitySpawner replaces Clip
{
    Default
    {
        DropItem "NothingItem", 255, 9;
        DropItem "MakarovClip", 255, 4;
        DropItem "TokarevClip", 255, 3;
        DropItem "F1GrenadeItem", 255, 1;
        DropItem "MolotovItem", 255, 1;
    }
}

class ClipBoxSpawner : CS_ItemScarcitySpawner replaces ClipBox
{
    Default
    {
        DropItem "NothingItem", 255, 9;
        DropItem "MakarovBox", 255, 4;
        DropItem "TokarevBox", 255, 3;
        DropItem "F1GrenadeItem", 255, 1;
        DropItem "MolotovItem", 255, 1;
    }
}

class ShellSpawner : CS_ItemScarcitySpawner replaces Shell
{
    Default
    {
        DropItem "NothingItem", 255, 9;
        DropItem "_12GaugeShell", 255, 4;
        DropItem "F1GrenadeItem", 255, 1;
        DropItem "MolotovItem", 255, 1;
    }
}

class ShellBoxSpawner : CS_ItemScarcitySpawner replaces ShellBox
{
    Default
    {
        DropItem "NothingItem", 255, 9;
        DropItem "_12GaugeBox", 255, 4;
        DropItem "F1GrenadeItem", 255, 1;
        DropItem "MolotovItem", 255, 1;
    }
}

class RocketAmmoSpawner : CS_ItemScarcitySpawner replaces RocketAmmo
{
    Default
    {
        DropItem "NothingItem", 255, 9;
        DropItem "KalashnikovClip", 255, 3;
        DropItem "SP6Clip", 255, 1;
        DropItem "F1GrenadeItem", 255, 1;
        DropItem "MolotovItem", 255, 1;
    }
}

class RocketBoxSpawner : CS_ItemScarcitySpawner replaces RocketBox
{
    Default
    {
        DropItem "NothingItem", 255, 9;
        DropItem "KalashnikovBox", 255, 3;
        DropItem "SP6Box", 255, 1;
        DropItem "F1GrenadeItem", 255, 1;
        DropItem "MolotovItem", 255, 1;
    }
}

class CellSpawner : CS_ItemScarcitySpawner replaces Cell
{
    Default
    {
        DropItem "NothingItem", 255, 9;
        DropItem "_762RAmmo", 255, 3;
        DropItem "F1GrenadeItem", 255, 1;
        DropItem "MolotovItem", 255, 1;
    }
}

class CellPackSpawner : CS_ItemScarcitySpawner replaces CellPack
{
    Default
    {
        DropItem "NothingItem", 255, 8;
        DropItem "_762RAmmoBox", 255, 3;
        DropItem "CS_AmmoSupplyCrate", 255, 1;
        DropItem "F1GrenadeItem", 255, 1;
        DropItem "MolotovItem", 255, 1;
    }
}

// Weapon spawners 
class ChainsawSpawner : RandomSpawner replaces Chainsaw
{
    Default
    {
        DropItem "RiotShieldPickup", 255, 1;
    }
}

class PistolSpawner : CS_ItemScarcitySpawner replaces Pistol
{
    Default
    {
        DropItem "Fort12", 255, 8;
        DropItem "TT33", 255, 4;
        DropItem "NothingItem", 255, 2;   // sometimes nothing
    }
}

class PP19PackSpawner : Actor
{
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_SpawnItem("PP19");
        TNT1 AAA 0 A_DropItem("MakarovClip", 8, 256);
        TNT1 A 0 A_DropItem("MakarovBox", 25, 64);
        Stop;
    }
}

class PP19Spawner : RandomSpawner
{
    Default
    {
        DropItem "PP19", 255, 6;
        DropItem "PP19PackSpawner", 255, 2;
    }
}

class PPSh41PackSpawner : Actor
{
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_SpawnItem("PPSh41");
        TNT1 AAA 0 A_DropItem("TokarevClip", 8, 256);
        TNT1 A 0 A_DropItem("TokarevBox", 25, 64);
        Stop;
    }
}

class PPSh41Spawner : RandomSpawner
{
    Default
    {
        DropItem "PPSh41", 255, 6;
        DropItem "PPSh41PackSpawner", 255, 2;
    }
}

class ChaingunSpawner : CS_ItemScarcitySpawner replaces Chaingun
{
    Default
    {
        DropItem "NothingItem", 255, 9;
        DropItem "PP19Spawner", 255, 5;
        DropItem "PPSh41Spawner", 255, 3;
    }
}

class Vepr12PackSpawner : Actor
{
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_SpawnItem("Vepr12");
        TNT1 AAA 0 A_DropItem("_12GaugeShell", 4, 256);
        TNT1 A 0 A_DropItem("_12GaugeBox", 25, 128);
        Stop;
    }
}

class TOZ34PackSpawner : Actor
{
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_SpawnItem("TOZ34");
        TNT1 AAA 0 A_DropItem("_12GaugeShell", 4, 256);
        TNT1 A 0 A_DropItem("_12GaugeBox", 25, 128);
        Stop;
    }
}

class Vepr12Spawner : RandomSpawner
{
    Default
    {
        DropItem "Vepr12", 255, 6;
        DropItem "Vepr12PackSpawner", 255, 2;
    }
}

class TOZ34Spawner : RandomSpawner
{
    Default
    {
        DropItem "TOZ34", 255, 6;
        DropItem "TOZ34PackSpawner", 255, 2;
    }
}

class SSGSpawner : CS_ItemScarcitySpawner replaces SuperShotgun
{
    Default
    {
        DropItem "NothingItem", 255, 9;
        DropItem "Vepr12Spawner", 255, 3;
        DropItem "TOZ34Spawner", 255, 3;
    }
}

class KS23PackSpawner : Actor
{
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_SpawnItem("KS23");
        TNT1 AAA 0 A_DropItem("_23RAmmo", 4, 256);
        Stop;
    }
}

class KS23Spawner : RandomSpawner
{
    Default
    {
        DropItem "KS23", 255, 6;
        DropItem "KS23PackSpawner", 255, 2;
    }
}

class ShotgunSpawner : CS_ItemScarcitySpawner replaces Shotgun
{
    Default
    {
        DropItem "NothingItem", 255, 9;
        DropItem "KS23Spawner", 255, 2;
    }
}

class SKSPackSpawner : Actor
{
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_SpawnItem("SKS");
        TNT1 AAA 0 A_DropItem("KalashnikovClip", 6, 256);
        TNT1 A 0 A_DropItem("KalashnikovBox", 25, 64);
        Stop;
    }
}

class AK47PackSpawner : Actor
{
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_SpawnItem("AK47");
        TNT1 AAA 0 A_DropItem("KalashnikovClip", 6, 256);
        TNT1 A 0 A_DropItem("KalashnikovBox", 25, 64);
        Stop;
    }
}

class SKSSpawner : RandomSpawner
{
    Default
    {
        DropItem "SKS", 255, 6;
        DropItem "SKSPackSpawner", 255, 2;
    }
}

class AK47Spawner : RandomSpawner
{
    Default
    {
        DropItem "AK47", 255, 6;
        DropItem "AK47PackSpawner", 255, 2;
    }
}

class KalashnikovRifleSpawner : RandomSpawner
{
    Default
    {
        DropItem "SKSSpawner", 255, 4;
        DropItem "AK47Spawner", 255, 4;
    }
}

class ASVALPackSpawner : Actor
{
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_SpawnItem("ASVAL");
        TNT1 AAA 0 A_DropItem("SP6Clip", 6, 256);
        TNT1 A 0 A_DropItem("SP6Box", 25, 64);
        Stop;
    }
}

class OTS14PackSpawner : Actor
{
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_SpawnItem("OTS14");
        TNT1 AAA 0 A_DropItem("SP6Clip", 6, 256);
        TNT1 A 0 A_DropItem("SP6Box", 25, 64);
        Stop;
    }
}

class ASVALSpawner : RandomSpawner
{
    Default
    {
        DropItem "ASVAL", 255, 6;
        DropItem "ASVALPackSpawner", 255, 2;
    }
}

class OTS14Spawner : RandomSpawner
{
    Default
    {
        DropItem "OTS14", 255, 6;
        DropItem "OTS14PackSpawner", 255, 2;
    }
}

class SP6RifleSpawner : RandomSpawner
{
    Default
    {
        DropItem "ASVALSpawner", 255, 4;
        DropItem "OTS14Spawner", 255, 4;
    }
}

class RocketLauncherSpawner : CS_ItemScarcitySpawner replaces RocketLauncher
{
    Default
    {
        DropItem "NothingItem", 255, 9;
        DropItem "KalashnikovRifleSpawner", 255, 4;
        DropItem "SP6RifleSpawner", 255, 2;
    }
}

class MosinPackSpawner : Actor
{
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_SpawnItem("MosinNagant");
        TNT1 AAA 0 A_DropItem("_762RAmmo", 10, 256);
        TNT1 A 0 A_DropItem("_762RAmmoBox", 50, 64);
        Stop;
    }
}

class SVDPackSpawner : Actor
{
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_SpawnItem("SVD");
        TNT1 AAA 0 A_DropItem("_762RAmmo", 10, 256);
        TNT1 A 0 A_DropItem("_762RAmmoBox", 50, 64);
        Stop;
    }
}

class RP46PackSpawner : Actor
{
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_SpawnItem("RP46");
        TNT1 AAA 0 A_DropItem("_762RAmmo", 10, 256);
        TNT1 A 0 A_DropItem("_762RAmmoBox", 50, 64);
        Stop;
    }
}

class MosinNagantSpawner : RandomSpawner
{
    Default
    {
        DropItem "MosinNagant", 255, 6;
        DropItem "MosinPackSpawner", 255, 2;
    }
}

class SVDSpawner : RandomSpawner
{
    Default
    {
        DropItem "SVD", 255, 6;
        DropItem "SVDPackSpawner", 255, 2;
    }
}

class RP46Spawner : RandomSpawner
{
    Default
    {
        DropItem "RP46", 255, 6;
        DropItem "RP46PackSpawner", 255, 2;
    }
}

class _762RSpawner : RandomSpawner
{
    Default
    {
        DropItem "MosinNagantSpawner", 255, 4;
        DropItem "SVDSpawner", 255, 4;
        DropItem "RP46Spawner", 255, 2;
    }
}

class PlasmaRifleSpawner : CS_ItemScarcitySpawner replaces PlasmaRifle
{
    Default
    {
        DropItem "NothingItem", 255, 9;
        DropItem "_762RSpawner", 255, 5;
    }
}

class GM94PackSpawner : Actor
{
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_SpawnItem("GM94");
        TNT1 AAA 0 A_DropItem("VGM93Ammo", 10, 256);
        TNT1 A 0 A_DropItem("VGM93AmmoBox", 25, 64);
        Stop;
    }
}

class GM94Spawner : RandomSpawner
{
    Default
    {
        DropItem "GM94", 255, 6;
        DropItem "GM94PackSpawner", 255, 2;
    }
}

class RPG7PackSpawner : Actor
{
    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_SpawnItem("RPG7D");
        TNT1 AAA 0 A_DropItem("RPGAmmo", 1, 256);
        Stop;
    }
}

class RPGSpawner : RandomSpawner
{
    Default
    {
        DropItem "RPG7D", 255, 6;
        DropItem "RPG7PackSpawner", 255, 2;
    }
}

class BFGSpawner : CS_ItemScarcitySpawner replaces BFG9000
{
    Default
    {
        DropItem "NothingItem", 255, 9;
        DropItem "GM94Spawner", 255, 3;
        DropItem "RPGSpawner", 255, 3;
    }
}