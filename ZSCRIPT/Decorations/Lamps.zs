// Tall / short columns (gravity anomaly hosts). Tech lamps removed — maps use vanilla TechLamp.

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
        COLU A 0 A_PlaySound("LampGlassBreak");
        COLU AAAAAAAAAAAAAAA 0 A_SpawnItemEx("LampGlassShard", 0, 0, 35, random(-2, 2), random(-2, 2), random(3, 9), random(0, 359), 32);
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
