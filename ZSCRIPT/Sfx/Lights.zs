class FlareBase : Actor
{
    Default
    {
        +NOINTERACTION;
        +NOGRAVITY;
        +CLIENTSIDEONLY;
        RenderStyle "Add";
        Radius 1;
        Height 1;
        Alpha 0.4;
        Scale 0.4;
    }
}

class WhiteLampLensFlare : FlareBase
{
    Default
    {
        Alpha 0.45;
        Scale 0.5;
    }
    States
    {
    Spawn:
        LENS A 5 Bright;
        Stop;
    }
}

class YellowLampLensFlare : FlareBase
{
    Default
    {
        Alpha 0.35;
        Scale 0.3;
    }
    States
    {
    Spawn:
        LEYS A 5 Bright;
        Stop;
    }
}

class GreenBarrelLensFlare : FlareBase
{
    Default
    {
        Alpha 0.15;
        Scale 0.15;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_Jump(128, 2);
        LENG A 2 Bright;
        Stop;
        TNT1 A 0;
        LENG B 2 Bright;
        Stop;
    }
}

class YellowBarrelLensFlare : FlareBase
{
    Default
    {
        Alpha 0.15;
        Scale 0.15;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_Jump(128, 2);
        LENY A 2 Bright;
        Stop;
        TNT1 A 0;
        LENY B 2 Bright;
        Stop;
    }
}

class WeaponRedFlareSpawn : Actor
{
    Default
    {
        Speed 20;
        Projectile;
        +NOCLIP;
    }
    States
    {
    Spawn:
        TNT1 AA 1 A_CustomMissile("WeaponRedFlare", -5, 0, -85, 0, random(-10, 10));
        Stop;
    }
}

class WeaponRedFlare : FlareBase
{
    Default
    {
        Scale 0.10;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_Jump(128, 2);
        LENR A 2 Bright;
        Stop;
        TNT1 A 0;
        LENR B 2 Bright;
        Stop;
    }
}

class BigWeaponRedFlareSpawn : Actor
{
    Default
    {
        Speed 20;
        Projectile;
        +NOCLIP;
    }
    States
    {
    Spawn:
        TNT1 AA 1 A_CustomMissile("BigWeaponRedFlare", -5, 0, -85, 0, random(-10, 10));
        Stop;
    }
}

class BigWeaponRedFlare : WeaponRedFlare
{
    Default
    {
        Scale 0.15;
    }
}

class ASVALRedFlareSpawn : Actor
{
    Default
    {
        Speed 20;
        Projectile;
        +NOCLIP;
    }
    States
    {
    Spawn:
        TNT1 AA 1 A_CustomMissile("ASVALRedFlare", -5, 0, -85, 0, random(-10, 10));
        Stop;
    }
}

class ASVALRedFlare : FlareBase
{
    Default
    {
        Scale 0.08;
    }
    States
    {
    Spawn:
        TNT1 A 0;
        TNT1 A 0 A_Jump(128, 2);
        LENR A 2 Bright;
        Stop;
        TNT1 A 0;
        LENR B 2 Bright;
        Stop;
    }
}