// PB2022-style ejected magazines (see zscript/Effects/Casings.txt — EmptyClipMP40 / EmptyMagMP40).
// Knife-pushable via CS_MagazineEjecta → STAT_CS_EJECTA (PB kick impulse, no kick key).
// Sprite note: PB uses CLP4 / C1P4 patches; this TC ships PCLP / AKCL already, so these actors use
// those frames until CLP4/C1P4 (any image extension) are added under Sprites/ — GZDoom matches by 4-char prefix.

class EmptyClipMP40 : CS_MagazineEjecta
{
    Default
    {
        Height 12;
        Radius 9;
        Speed 4;
        Scale 0.125;
        BounceType "Doom";
        -NOGRAVITY;
        +WINDTHRUST;
        +CLIENTSIDEONLY;
        +MOVEWITHSECTOR;
        +MISSILE;
        +NOBLOCKMAP;
        -DROPOFF;
        +NOTELEPORT;
        +FORCEXYBILLBOARD;
        +NOTDMATCH;
        +GHOST;
        Mass 1;
        SeeSound "weapons/smallmagdrop";
    }

    States
    {
    Spawn:
        PCLP A 1;
    Exist:
        PCLP ABCDEFGH 4;
        Loop;
    Death:
        PCLP G 900;
        Loop;
    }
}

class EmptyMagMP40 : CS_MagazineEjecta
{
    Default
    {
        Height 12;
        Radius 9;
        Speed 4;
        Scale 0.125;
        BounceType "Doom";
        -NOGRAVITY;
        +WINDTHRUST;
        +CLIENTSIDEONLY;
        +MOVEWITHSECTOR;
        +MISSILE;
        +NOBLOCKMAP;
        -DROPOFF;
        +NOTELEPORT;
        +FORCEXYBILLBOARD;
        +NOTDMATCH;
        +GHOST;
        +ROLLSPRITE;
        +ROLLCENTER;
        Mass 1;
        SeeSound "weapons/largemagdrop";
    }

    States
    {
    Spawn:
        AKCL A 1 A_SetRoll(roll + 90);
    Exist:
        AKCL ABCDEFGH 1 A_SetRoll(roll + 10, SPF_INTERPOLATE);
        Loop;
    Death:
        AKCL G 900 A_SetRoll(0);
        Loop;
    }
}
