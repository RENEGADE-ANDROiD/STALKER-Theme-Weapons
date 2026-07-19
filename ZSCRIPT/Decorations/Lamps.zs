class ClearSkyTechLamp : Actor
{
    Default
    {
        +LOOKALLAROUND;
        +SHOOTABLE;
        +NOBLOOD;
        +FORCEYBILLBOARD;
        +SOLID;
        Radius 16;
        Height 80;
        Mass 99999;
        Health 15;
        DeathHeight 80;
    }
    States
    {
    Spawn:
        TLMP A 0 NoDelay A_PlaySound("Lamps/Hum", CHAN_5, 0.5, true);
        TLMP ABCD 2 Bright A_SpawnItem("WhiteLampLensFlare", 0, 70);
        Loop;
    Death:
        TLMP E 1 A_StopSound(CHAN_5);
        TLMP A 0 A_PlaySound("LampGlassBreak");
        TLMP AAAAAAAAAAAAAAA 0 A_SpawnItemEx("LampGlassShard", 0, 0, 55, random(-2, 2), random(-2, 2), random(3, 9), random(0, 359), 32);
        TLMP E -1;
        Stop;
    }
}

class BrokenTechLamp : Actor
{
    Default
    {
        Radius 16;
        Height 80;
        ProjectilePassHeight -16;
        +SOLID;
    }
    States
    {
    Spawn:
        TLMP E -1;
        Stop;
    }
}

class ClearSkyTechLamp2 : Actor
{
    Default
    {
        +LOOKALLAROUND;
        +SHOOTABLE;
        +NOBLOOD;
        +FORCEYBILLBOARD;
        +SOLID;
        Radius 16;
        Height 60;
        Mass 99999;
        Health 15;
        DeathHeight 60;
    }
    States
    {
    Spawn:
        TLP2 A 0 NoDelay A_PlaySound("Lamps/Hum", CHAN_5, 0.5, true);
        TLP2 ABCD 2 Bright A_SpawnItem("WhiteLampLensFlare", 0, 50);
        Loop;
    Death:
        TLP2 E 1 A_StopSound(CHAN_5);
        TLMP A 0 A_PlaySound("LampGlassBreak");
        TLMP AAAAAAAAAAAAAAA 0 A_SpawnItemEx("LampGlassShard", 0, 0, 40, random(-2, 2), random(-2, 2), random(3, 9), random(0, 359), 32);
        TLP2 E -1;
        Stop;
    }
}

class BrokenTechLamp2 : Actor
{
    Default
    {
        Radius 16;
        Height 60;
        ProjectilePassHeight -16;
        +SOLID;
    }
    States
    {
    Spawn:
        TLP2 E -1;
        Stop;
    }
}

class ClearSkyColumn : Actor
{
    Default
    {
        +LOOKALLAROUND;
        +SHOOTABLE;
        +NOBLOOD;
        +FORCEYBILLBOARD;
        +SOLID;
        Radius 16;
        Height 48;
        Mass 99999;
        Health 15;
        DeathHeight 48;
    }
    States
    {
    Spawn:
        COLU A 0 NoDelay A_PlaySound("Lamps/Hum", CHAN_5, 0.5, true);
        COLU A 2 Bright A_SpawnItem("YellowLampLensFlare", 0, 41);
        Loop;
    Death:
        COLU B 1 A_StopSound(CHAN_5);
        TLMP A 0 A_PlaySound("LampGlassBreak");
        TLMP AAAAAAAAAAAAAAA 0 A_SpawnItemEx("LampGlassShard", 0, 0, 35, random(-2, 2), random(-2, 2), random(3, 9), random(0, 359), 32);
        COLU B -1;
        Stop;
    }
}

class BrokenColumn : Actor
{
    Default
    {
        Radius 16;
        Height 60;
        ProjectilePassHeight -16;
        +SOLID;
    }
    States
    {
    Spawn:
        COLU B -1;
        Stop;
    }
}