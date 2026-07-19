// Merged from legacy HexenSmoke.wad (DECORATE + HSM2/HSMX/HSPX). Map thing 32011 = FX_TeleSmoke (see ZmapInfo DoomEdNums).

class FX_TeleSmoke : SwitchableDecoration
{
    Default
    {
        Radius 6;
        Height 10;
        +FIXMAPTHINGPOS;
    }

    States
    {
    Active:
        TNT1 A 0;
        Goto Spawn;
    Spawn:
        TNT1 A 0 A_SpawnItemEx("FXRedGlitter", random(-25, 25), random(-25, 25), 0, 0, 0, 4, 0, 0);
        TNT1 A 1 A_SpawnItemEx("FXRedSmoke", random(-5, 5), random(-5, 5), 0, 0, 0, random(6, 7), 0, 128);
        TNT1 A 1 A_SpawnItemEx("FXRedSmoke2", random(-5, 5), random(-5, 5), 0, 0, 0, random(6, 7), 0, 128);
        TNT1 A 1 A_SpawnItemEx("FXRedSmoke", random(-5, 5), random(-5, 5), 0, 0, 0, random(6, 7), 0, 128);
        TNT1 A 0 A_SpawnItemEx("FXRedGlitter2", random(-15, 15), random(-15, 15), 0, 0, 0, 4, 0, 0);
        TNT1 A 1 A_SpawnItemEx("FXRedSmoke2", random(-5, 5), random(-5, 5), 0, 0, 0, random(6, 7), 0, 128);
        TNT1 A 1 A_SpawnItemEx("FXRedSmoke", random(-5, 5), random(-5, 5), 0, 0, 0, random(6, 7), 0, 128);
        TNT1 A 1 A_SpawnItemEx("FXRedSmoke2", random(-5, 5), random(-5, 5), 0, 0, 0, random(6, 7), 0, 128);
        Loop;
    Inactive:
        TNT2 A 1;
        Loop;
    }
}

class FXRedSmoke : Actor
{
    Default
    {
        +NOGRAVITY;
        +NOINTERACTION;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +FORCEXYBILLBOARD;
        +BRIGHT;
        RenderStyle "Translucent";
        Alpha 0.6;
        Scale 0.46;
    }

    States
    {
    Spawn:
        TNT1 A 0 A_Jump(256, "Spawn2");
        HSMX A 1;
        HSMX B 1 A_SetScale(0.44);
        HSMX C 1 A_SetScale(0.42);
        HSMX D 1 A_SetScale(0.40);
        HSMX E 1 A_SetScale(0.38);
        HSMX F 1 A_SetScale(0.36);
        HSMX G 1 A_SetScale(0.34);
        HSMX H 1 A_SetScale(0.32);
        TNT1 A 0 A_FadeOut(0.07);
        HSMX I 1 A_SetScale(0.30);
        TNT1 A 0 A_FadeOut(0.07);
        HSMX J 1 A_SetScale(0.28);
        TNT1 A 0 A_FadeOut(0.07);
        HSMX K 1 A_SetScale(0.26);
        TNT1 A 0 A_FadeOut(0.07);
        HSMX L 1 A_SetScale(0.24);
        TNT1 A 0 A_FadeOut(0.07);
        HSMX A 1 A_SetScale(0.22);
        TNT1 A 0 A_FadeOut(0.07);
        HSMX B 1 A_SetScale(0.20);
        TNT1 A 0 A_FadeOut(0.07);
        HSMX C 1 A_SetScale(0.18);
        TNT1 A 0 A_FadeOut(0.07);
        HSMX D 1 A_SetScale(0.16);
        TNT1 A 0 A_FadeOut(0.07);
        Stop;
    Spawn2:
        HSMX A 1;
        HSMX L 1 A_SetScale(0.44);
        HSMX K 1 A_SetScale(0.42);
        HSMX J 1 A_SetScale(0.40);
        HSMX I 1 A_SetScale(0.38);
        HSMX H 1 A_SetScale(0.36);
        HSMX G 1 A_SetScale(0.34);
        HSMX F 1 A_SetScale(0.32);
        TNT1 A 0 A_FadeOut(0.07);
        HSMX E 1 A_SetScale(0.30);
        TNT1 A 0 A_FadeOut(0.07);
        HSMX D 1 A_SetScale(0.28);
        TNT1 A 0 A_FadeOut(0.07);
        HSMX C 1 A_SetScale(0.26);
        TNT1 A 0 A_FadeOut(0.07);
        HSMX D 1 A_SetScale(0.24);
        TNT1 A 0 A_FadeOut(0.07);
        HSMX A 1 A_SetScale(0.22);
        TNT1 A 0 A_FadeOut(0.07);
        HSMX L 1 A_SetScale(0.20);
        TNT1 A 0 A_FadeOut(0.07);
        HSMX K 1 A_SetScale(0.18);
        TNT1 A 0 A_FadeOut(0.07);
        HSMX J 1 A_SetScale(0.16);
        TNT1 A 0 A_FadeOut(0.07);
        Stop;
    }
}

class FXRedSmoke2 : FXRedSmoke
{
    States
    {
    Spawn:
        TNT1 A 0 A_Jump(256, "Spawn2");
        HSM2 A 1;
        HSM2 B 1 A_SetScale(0.44);
        HSM2 C 1 A_SetScale(0.42);
        HSM2 D 1 A_SetScale(0.40);
        HSM2 E 1 A_SetScale(0.38);
        HSM2 F 1 A_SetScale(0.36);
        HSM2 G 1 A_SetScale(0.34);
        HSM2 H 1 A_SetScale(0.32);
        TNT1 A 0 A_FadeOut(0.07);
        HSM2 I 1 A_SetScale(0.30);
        TNT1 A 0 A_FadeOut(0.07);
        HSM2 J 1 A_SetScale(0.28);
        TNT1 A 0 A_FadeOut(0.07);
        HSM2 K 1 A_SetScale(0.26);
        TNT1 A 0 A_FadeOut(0.07);
        HSM2 L 1 A_SetScale(0.24);
        TNT1 A 0 A_FadeOut(0.07);
        HSM2 A 1 A_SetScale(0.22);
        TNT1 A 0 A_FadeOut(0.07);
        HSM2 B 1 A_SetScale(0.20);
        TNT1 A 0 A_FadeOut(0.07);
        HSM2 C 1 A_SetScale(0.18);
        TNT1 A 0 A_FadeOut(0.07);
        HSM2 D 1 A_SetScale(0.16);
        TNT1 A 0 A_FadeOut(0.07);
        Stop;
    Spawn2:
        HSM2 A 1;
        HSM2 L 1 A_SetScale(0.44);
        HSM2 K 1 A_SetScale(0.42);
        HSM2 J 1 A_SetScale(0.40);
        HSM2 I 1 A_SetScale(0.38);
        HSM2 H 1 A_SetScale(0.36);
        HSM2 G 1 A_SetScale(0.34);
        HSM2 F 1 A_SetScale(0.32);
        TNT1 A 0 A_FadeOut(0.07);
        HSM2 E 1 A_SetScale(0.30);
        TNT1 A 0 A_FadeOut(0.07);
        HSM2 D 1 A_SetScale(0.28);
        TNT1 A 0 A_FadeOut(0.07);
        HSM2 C 1 A_SetScale(0.26);
        TNT1 A 0 A_FadeOut(0.07);
        HSM2 B 1 A_SetScale(0.24);
        TNT1 A 0 A_FadeOut(0.07);
        HSM2 A 1 A_SetScale(0.22);
        TNT1 A 0 A_FadeOut(0.07);
        HSM2 L 1 A_SetScale(0.20);
        TNT1 A 0 A_FadeOut(0.07);
        HSM2 K 1 A_SetScale(0.18);
        TNT1 A 0 A_FadeOut(0.07);
        HSM2 J 1 A_SetScale(0.16);
        TNT1 A 0 A_FadeOut(0.07);
        Stop;
    }
}

class FXRedGlitter : Actor
{
    Default
    {
        +NOGRAVITY;
        +NOINTERACTION;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +FORCEXYBILLBOARD;
        +BRIGHT;
        RenderStyle "Add";
        Scale 0.02;
    }

    States
    {
    Spawn:
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        HSPX A 1 A_FadeOut(0.03);
        Stop;
    }
}

class FXRedGlitter2 : FXRedGlitter
{
    Default
    {
        Scale 0.06;
    }
}
