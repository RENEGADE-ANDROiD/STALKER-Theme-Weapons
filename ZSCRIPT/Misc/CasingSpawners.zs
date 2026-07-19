// Folded in from legacy CasingSpawners.wad (DECORATE + CAS1/CAS2/CAS7 patches).
// Map thing 32010 = CasingSpawner (ZmapInfo DoomEdNums). Args: [0] = casing count, [1] = half-width of spawn square,
// [2] = type — 0 pistol, 1 shotgun, 2+ rifle (matches bundled DOCUMENT text).

class CasingSpawner : Actor
{
    int remainingCasings;

    Default
    {
        Radius 1;
        Height 1;
        +NOCLIP;
    }

    States
    {
    Spawn:
        TNT1 A 1
        {
            remainingCasings = args[0];
            if (remainingCasings < 0)
                remainingCasings = 0;
        }
        TNT1 A 0 A_JumpIf(args[2] == 1, "ShotgunSpawning");
        TNT1 A 0 A_JumpIf(args[2] > 1, "RifleSpawning");
    BulletSpawning:
        TNT1 A 1;
        TNT1 A 0 A_JumpIf(remainingCasings > 0, "BulletDump");
        Goto Death;
    BulletDump:
        TNT1 A 0 { remainingCasings--; }
        TNT1 A 0 A_SpawnItemEx("DeadBulletCasing",
            random(-args[1], args[1]), random(-args[1], args[1]), 0,
            0, 0, 0, random(0, 360), 128);
        Loop;
    ShotgunSpawning:
        TNT1 A 1;
        TNT1 A 0 A_JumpIf(remainingCasings > 0, "ShotgunDump");
        Goto Death;
    ShotgunDump:
        TNT1 A 0 { remainingCasings--; }
        TNT1 A 0 A_SpawnItemEx("DeadShotgunCasing",
            random(-args[1], args[1]), random(-args[1], args[1]), 0,
            0, 0, 0, random(0, 360), 128);
        Loop;
    RifleSpawning:
        TNT1 A 1;
        TNT1 A 0 A_JumpIf(remainingCasings > 0, "RifleDump");
        Goto Death;
    RifleDump:
        TNT1 A 0 { remainingCasings--; }
        TNT1 A 0 A_SpawnItemEx("DeadRifleCasing",
            random(-args[1], args[1]), random(-args[1], args[1]), 0,
            0, 0, 0, random(0, 360), 128);
        Loop;
    Death:
        TNT1 A 1;
        Stop;
    }
}

class DeadBulletCasing : Actor
{
    Default
    {
        Height 1;
        Radius 1;
        Scale 0.45;
        Mass 1;
    }

    States
    {
    Spawn:
        CAS2 A 0;
        CAS2 A 0 A_Jump(192, "DB_B", "DB_C", "DB_D");
        CAS2 A -1;
        Stop;
    DB_B:
        CAS2 B -1;
        Stop;
    DB_C:
        CAS2 C -1;
        Stop;
    DB_D:
        CAS2 D -1;
        Stop;
    }
}

class DeadShotgunCasing : Actor
{
    Default
    {
        Height 1;
        Radius 1;
        Scale 0.45;
        Mass 1;
    }

    States
    {
    Spawn:
        CAS1 A 0;
        CAS1 A 0 A_Jump(192, "DS_B", "DS_C", "DS_D", "DS_E", "DS_F", "DS_G", "DS_H");
        CAS1 A -1;
        Stop;
    DS_B:
        CAS1 B -1;
        Stop;
    DS_C:
        CAS1 C -1;
        Stop;
    DS_D:
        CAS1 D -1;
        Stop;
    DS_E:
        CAS1 E -1;
        Stop;
    DS_F:
        CAS1 F -1;
        Stop;
    DS_G:
        CAS1 G -1;
        Stop;
    DS_H:
        CAS1 H -1;
        Stop;
    }
}

class DeadRifleCasing : Actor
{
    Default
    {
        Height 1;
        Radius 1;
        Scale 0.45;
        Mass 1;
    }

    States
    {
    Spawn:
        CAS7 A 0;
        CAS7 A 0 A_Jump(192, "DR_B", "DR_C", "DR_D", "DR_E", "DR_F");
        CAS7 A -1;
        Stop;
    DR_B:
        CAS7 B -1;
        Stop;
    DR_C:
        CAS7 C -1;
        Stop;
    DR_D:
        CAS7 D -1;
        Stop;
    DR_E:
        CAS7 E -1;
        Stop;
    DR_F:
        CAS7 F -1;
        Stop;
    }
}
