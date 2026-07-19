class MakarovClip : Ammo
{
    Default
    {
        Inventory.PickupMessage "Picked up a clip of 9x18mm Makarov ammo";
        Inventory.Amount 8;
        Inventory.MaxAmount 250;
        Ammo.BackpackAmount 10;
        Ammo.BackpackMaxAmount 500;
        Inventory.Icon "MAKAA0";
        Inventory.PickupSound "Tokarev/Clip";
    }
    States
    {
    Spawn:
        MAKA A -1;
        Stop;
    }
}

class MakarovBox : MakarovClip
{
    Default
    {
        Inventory.PickupMessage "Picked up a box of 9x18mm Makarov ammo";
        Inventory.Amount 25;
        Inventory.PickupSound "Tokarev/Box";
    }
    States
    {
    Spawn:
        MAKA B -1;
        Stop;
    }
}

class TokarevClip : Ammo
{
    Default
    {
        Inventory.PickupMessage "Picked up a clip of 7,62x25mm Tokarev ammo";
        Inventory.Amount 8;
        Inventory.MaxAmount 200;
        Ammo.BackpackAmount 10;
        Ammo.BackpackMaxAmount 400;
        Inventory.Icon "TOKAA0";
        Inventory.PickupSound "Tokarev/Clip";
    }
    States
    {
    Spawn:
        TOKA A -1;
        Stop;
    }
}

class TokarevBox : TokarevClip
{
    Default
    {
        Inventory.PickupMessage "Picked up a box of 7,62x25mm Tokarev ammo";
        Inventory.Amount 25;
        Inventory.PickupSound "Tokarev/Box";
    }
    States
    {
    Spawn:
        TOKA B -1;
        Stop;
    }
}

class KalashnikovClip : Ammo
{
    Default
    {
        Inventory.PickupMessage "Picked up a clip of 7,62x39mm ammo";
        Inventory.Amount 6;
        Inventory.MaxAmount 150;
        Ammo.BackpackAmount 10;
        Ammo.BackpackMaxAmount 300;
        Inventory.Icon "AKAMA0";
        Inventory.PickupSound "AK/Clip";
    }
    States
    {
    Spawn:
        AKAM A -1;
        Stop;
    }
}

class KalashnikovBox : KalashnikovClip
{
    Default
    {
        Inventory.PickupMessage "Picked up a 7,62x39mm ammo box";
        Inventory.Amount 25;
        Inventory.PickupSound "AK/Box";
    }
    States
    {
    Spawn:
        AKAM B -1;
        Stop;
    }
}

class _12GaugeShell : Ammo
{
    Default
    {
        Inventory.PickupMessage "Picked up some 12 Gauge shotgun shells";
        Inventory.Amount 4;
        Inventory.MaxAmount 50;
        Ammo.BackpackAmount 8;
        Ammo.BackpackMaxAmount 100;
        Inventory.Icon "12GAA0";
        Inventory.PickupSound "12Gauge/Clip";
    }
    States
    {
    Spawn:
        12GA A -1;
        Stop;
    }
}

class _12GaugeBox : _12GaugeShell
{
    Default
    {
        Inventory.PickupMessage "Picked up a box of 12 Gauge shotgun shells";
        Inventory.Amount 15;
        Inventory.PickupSound "12Gauge/Box";
    }
    States
    {
    Spawn:
        12GA B -1;
        Stop;
    }
}

class _23RAmmo : Ammo
{
    Default
    {
        Inventory.PickupMessage "Picked up some 23x75mmR shells";
        Inventory.Amount 4;
        Inventory.MaxAmount 25;
        Ammo.BackpackAmount 8;
        Ammo.BackpackMaxAmount 50;
        Inventory.Icon "KSAMA0";
        Inventory.PickupSound "12Gauge/Clip";
    }
    States
    {
    Spawn:
        KSAM A -1;
        Stop;
    }
}

class _762RAmmo : Ammo
{
    Default
    {
        Inventory.PickupMessage "Picked up some 7,62 x 54R ammo";
        Inventory.Amount 4;
        Inventory.MaxAmount 100;
        Ammo.BackpackAmount 8;
        Ammo.BackpackMaxAmount 200;
        Inventory.Icon "762RA0";
        Inventory.PickupSound "762R/Clip";
    }
    States
    {
    Spawn:
        762R A -1;
        Stop;
    }
}

class _762RAmmoBox : _762RAmmo
{
    Default
    {
        Inventory.PickupMessage "Picked up a 7,62 x 54R ammo box";
        Inventory.Amount 50;
        Inventory.PickupSound "762R/Box";
        Scale 0.6;
    }
    States
    {
    Spawn:
        762R B -1;
        Stop;
    }
}

class SP6Clip : Ammo
{
    Default
    {
        Inventory.PickupMessage "Picked up a clip of 9x39mm SP-6 ammo";
        Inventory.Amount 4;
        Inventory.MaxAmount 50;
        Ammo.BackpackAmount 8;
        Ammo.BackpackMaxAmount 100;
        Inventory.Icon "SP6AA0";
        Inventory.PickupSound "AK/Clip";
    }
    States
    {
    Spawn:
        SP6A A -1;
        Stop;
    }
}

class SP6Box : SP6Clip
{
    Default
    {
        Inventory.PickupMessage "Picked up a 9x39mm SP-6 ammo box";
        Inventory.Amount 25;
        Inventory.PickupSound "AK/Box";
    }
    States
    {
    Spawn:
        SP6A B -1;
        Stop;
    }
}

class VGM93Ammo : Ammo
{
    Default
    {
        Inventory.PickupMessage "Picked up a VGM-93 Grenade";
        Inventory.Amount 1;
        Inventory.MaxAmount 50;
        Ammo.BackpackAmount 2;
        Ammo.BackpackMaxAmount 100;
        Inventory.Icon "V93AA0";
        Inventory.PickupSound "Grenade/Clip";
    }
    States
    {
    Spawn:
        V93A A -1;
        Stop;
    }
}

class VGM93AmmoBox : VGM93Ammo
{
    Default
    {
        Inventory.PickupMessage "Picked up a VGM-93 Grenade box";
        Inventory.Amount 25;
        Inventory.PickupSound "Explosive/Box";
    }
    States
    {
    Spawn:
        V93A B -1;
        Stop;
    }
}

class RPGAmmo : Ammo
{
    Default
    {
        Inventory.PickupMessage "Picked up a RPG-7 rocket";
        Inventory.Amount 1;
        Inventory.MaxAmount 25;
        Ammo.BackpackAmount 2;
        Ammo.BackpackMaxAmount 50;
        Inventory.Icon "RPGAA0";
        Inventory.PickupSound "RPG/Clip";
    }
    States
    {
    Spawn:
        RPGA A -1;
        Stop;
    }
}