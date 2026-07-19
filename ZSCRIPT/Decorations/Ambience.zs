// Ambient sounds
class ClearSkyAmbientSound1 : Actor
{
    Default
    {
        Radius 2;
        Height 2;
        +NOINTERACTION;
    }
    States
    {
    Spawn:
        TNT1 A random(10, 80);
        TNT1 A 15 A_PlaySound("Ambience/Screams", CHAN_AUTO, 6.0, false, ATTN_NONE);
        TNT1 A random(800, 1200);
        Loop;
    }
}

class ClearSkyAmbientSound2 : Actor
{
    Default
    {
        Radius 2;
        Height 2;
        +NOINTERACTION;
    }
    States
    {
    Spawn:
        TNT1 A random(10, 80);
        TNT1 A 15 A_PlaySound("Ambience/GunShots", CHAN_AUTO, 6.0, false, ATTN_NONE);
        TNT1 A random(800, 1200);
        Loop;
    }
}

class ClearSkyAmbientSound3 : Actor
{
    Default
    {
        Radius 2;
        Height 2;
        +NOINTERACTION;
    }
    States
    {
    Spawn:
        TNT1 A random(10, 80);
        TNT1 A 15 A_PlaySound("Ambience/Ghosts", CHAN_AUTO, 6.0, false, ATTN_NONE);
        TNT1 A random(800, 1200);
        Loop;
    }
}

class ClearSkyAmbientSound4 : Actor
{
    Default
    {
        Radius 2;
        Height 2;
        +NOINTERACTION;
    }
    States
    {
    Spawn:
        TNT1 A random(10, 80);
        TNT1 A 15 A_PlaySound("Ambience/Whispers", CHAN_AUTO, 6.0, false, ATTN_NONE);
        TNT1 A random(800, 1200);
        Loop;
    }
}

// Footstep actors
class HumanishStep : Actor
{
    Default
    {
        Radius 6;
        Height 6;
        +CLIENTSIDEONLY;
        +CORPSE;
        +NOCLIP;
        -DONTSPLASH;
    }
    States
    {
    Spawn:
        TNT1 A 8;
        Stop;
    Crash:
        TNT1 A 1 A_PlaySound("Humanish/Step");
        Stop;
    }
}

class BootStep : Actor
{
    Default
    {
        Radius 6;
        Height 6;
        +CLIENTSIDEONLY;
        +CORPSE;
        +NOCLIP;
        -DONTSPLASH;
    }
    States
    {
    Spawn:
        TNT1 A 8;
        Stop;
    Crash:
        TNT1 A 1 A_PlaySound("Boot/Step");
        Stop;
    }
}

class GiantStep : Actor
{
    Default
    {
        Radius 6;
        Height 6;
        +CLIENTSIDEONLY;
        +CORPSE;
        +NOCLIP;
        -DONTSPLASH;
    }
    States
    {
    Spawn:
        TNT1 A 8;
        Stop;
    Crash:
        TNT1 A 1 A_PlaySound("Giant/Step");
        Stop;
    }
}

// Vermin
class SwarmFly : Actor
{
    Default
    {
        +NOCLIP;
        +DONTSPLASH;
        Speed 5;
        Radius 1;
        Height 1;
        Scale 0.25;
        Projectile;
        ReactionTime 4;
    }
    States
    {
    Spawn:
        SFLY A 1 ThrustThingZ(0, random(-1, 1), random(1, 0), 1);
        TNT1 A 0 A_ChangeVelocity(frandom(-2, 2), frandom(-1, 1), frandom(-2, 2), CVF_RELATIVE);
        SFLY B 1 ThrustThingZ(0, random(-1, 1), random(1, 0), 1);
        TNT1 A 0 A_ChangeVelocity(frandom(-1, 1), frandom(-2, 2), frandom(-1, 1), CVF_RELATIVE);
        SFLY A 0 A_CountDown();
        SFLY C 1 ThrustThingZ(0, random(-1, 1), random(1, 0), 1);
        TNT1 A 0 A_ChangeVelocity(frandom(-2, 2), frandom(-1, 1), frandom(-2, 2), CVF_RELATIVE);
        SFLY B 1 ThrustThingZ(0, random(-1, 1), random(1, 0), 1);
        TNT1 A 0 A_ChangeVelocity(frandom(-1, 1), frandom(-2, 2), frandom(-1, 1), CVF_RELATIVE);
        SFLY A 0 A_CountDown();
        Loop;
    Death:
        SFLY A 1 A_CustomMissile("SwarmFly", 0, 0, frandom(-20, 20));
        Stop;
    }
}

class PripyatRoach : Actor
{
    Default
    {
        Obituary "%o was infected by a Prypiat Roach";
        Health 1;
        Radius 8;
        Height 8;
        Mass 1000;
        Speed 8;
        Scale 0.3;
        PainChance 256;
        DeathSound "Roach/Squish";
        ActiveSound "Roach/Active";
        Monster;
        +FLOORCLIP;
        +FRIGHTENED;
        +NOTARGET;
        +CANTSEEK;
        +CANNOTPUSH;
        -CANUSEWALLS;
        +THRUSPECIES;
        +AMBUSH;
        +LOOKALLAROUND;
        -COUNTKILL;
        +ISMONSTER;
        +NOBLOOD;
        +NEVERTARGET;
        +TOUCHY;
    }
    States
    {
    Spawn:
        ROCH AB 2 A_Wander();
        ROCH A 0 A_Look();
        Loop;
    See:
        ROCH AB 2 A_Chase();
        Loop;
    Death:
    XDeath:
        ROCH A 1 A_Scream();
        ROCH A 1 A_NoBlocking();
        ROCH C 20 A_SetScale(0.4);
        ROCH C -1;
        Stop;
    }
}

// Gore bodies
class DeadBodyNoFlies : DeadMarine
{
    States
    {
    Spawn:
        DEAD A 0 NoDelay A_Jump(256, "Corpse1", "Corpse2", "Corpse3", "Corpse4", "Corpse5", "Corpse6", "Corpse7", "Corpse8", "Corpse9", "Corpse10");
        Goto Corpse1;
    Corpse1:
        DEAD A 0 A_SpawnItem("GreatBloodSpot");
        DEAD A -1;
        Stop;
    Corpse2:
        DEAD B 0 A_SpawnItem("GreatBloodSpot");
        DEAD B 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD B -1;
        Stop;
    Corpse3:
        DEAD C 0 A_SpawnItem("GreatBloodSpot");
        DEAD C -1;
        Stop;
    Corpse4:
        DEAD D 0 A_SpawnItem("GreatBloodSpot");
        DEAD D 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD D -1;
        Stop;
    Corpse5:
        DEAD E 0 A_SpawnItem("GreatBloodSpot");
        DEAD E -1;
        Stop;
    Corpse6:
        DEAD F 0 A_SpawnItem("GreatBloodSpot");
        DEAD F 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD F -1;
        Stop;
    Corpse7:
        DEAD G 0 A_SpawnItem("GreatBloodSpot");
        DEAD G -1;
        Stop;
    Corpse8:
        DEAD H 0 A_SpawnItem("GreatBloodSpot");
        DEAD H 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD H -1;
        Stop;
    Corpse9:
        DEAD I 0 A_SpawnItem("GreatBloodSpot");
        DEAD I -1;
        Stop;
    Corpse10:
        DEAD J 0 A_SpawnItem("GreatBloodSpot");
        DEAD J 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD J -1;
        Stop;
    }
}

class DeadBodyWithFlies : DeadMarine
{
    States
    {
    Spawn:
        DEAD A 0 NoDelay A_Jump(256, "Corpse1", "Corpse2", "Corpse3", "Corpse4", "Corpse5", "Corpse6", "Corpse7", "Corpse8", "Corpse9", "Corpse10");
        Goto Corpse1;
    Corpse1:
        DEAD A 0 A_SpawnItem("GreatBloodSpot");
        DEAD A 0 A_PlaySound("SFX/Buzz", CHAN_BODY, 1.0);
        DEAD AAAAA 1 A_SpawnItemEx("SwarmFly", frandom(-16, 16), frandom(-16, 16), frandom(-16, 16), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD A -1;
        Stop;
    Corpse2:
        DEAD B 0 A_SpawnItem("GreatBloodSpot");
        DEAD B 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD B 0 A_PlaySound("SFX/Buzz", CHAN_BODY, 1.0);
        DEAD BBBBB 1 A_SpawnItemEx("SwarmFly", frandom(-16, 16), frandom(-16, 16), frandom(-16, 16), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD B -1;
        Stop;
    Corpse3:
        DEAD C 0 A_SpawnItem("GreatBloodSpot");
        DEAD C 0 A_PlaySound("SFX/Buzz", CHAN_BODY, 1.0);
        DEAD CCCCC 1 A_SpawnItemEx("SwarmFly", frandom(-16, 16), frandom(-16, 16), frandom(-16, 16), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD C -1;
        Stop;
    Corpse4:
        DEAD D 0 A_SpawnItem("GreatBloodSpot");
        DEAD D 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD D 0 A_PlaySound("SFX/Buzz", CHAN_BODY, 1.0);
        DEAD DDDDD 1 A_SpawnItemEx("SwarmFly", frandom(-16, 16), frandom(-16, 16), frandom(-16, 16), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD D -1;
        Stop;
    Corpse5:
        DEAD E 0 A_SpawnItem("GreatBloodSpot");
        DEAD E 0 A_PlaySound("SFX/Buzz", CHAN_BODY, 1.0);
        DEAD EEEEE 1 A_SpawnItemEx("SwarmFly", frandom(-16, 16), frandom(-16, 16), frandom(-16, 16), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD E -1;
        Stop;
    Corpse6:
        DEAD F 0 A_SpawnItem("GreatBloodSpot");
        DEAD F 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD F 0 A_PlaySound("SFX/Buzz", CHAN_BODY, 1.0);
        DEAD FFFFF 1 A_SpawnItemEx("SwarmFly", frandom(-16, 16), frandom(-16, 16), frandom(-16, 16), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD F -1;
        Stop;
    Corpse7:
        DEAD G 0 A_SpawnItem("GreatBloodSpot");
        DEAD G 0 A_PlaySound("SFX/Buzz", CHAN_BODY, 1.0);
        DEAD GGGGG 1 A_SpawnItemEx("SwarmFly", frandom(-16, 16), frandom(-16, 16), frandom(-16, 16), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD G -1;
        Stop;
    Corpse8:
        DEAD H 0 A_SpawnItem("GreatBloodSpot");
        DEAD H 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD H 0 A_PlaySound("SFX/Buzz", CHAN_BODY, 1.0);
        DEAD HHHHH 1 A_SpawnItemEx("SwarmFly", frandom(-16, 16), frandom(-16, 16), frandom(-16, 16), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD H -1;
        Stop;
    Corpse9:
        DEAD I 0 A_SpawnItem("GreatBloodSpot");
        DEAD I 0 A_PlaySound("SFX/Buzz", CHAN_BODY, 1.0);
        DEAD IIIII 1 A_SpawnItemEx("SwarmFly", frandom(-16, 16), frandom(-16, 16), frandom(-16, 16), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD I -1;
        Stop;
    Corpse10:
        DEAD J 0 A_SpawnItem("GreatBloodSpot");
        DEAD J 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD J 0 A_PlaySound("SFX/Buzz", CHAN_BODY, 1.0);
        DEAD JJJJJ 1 A_SpawnItemEx("SwarmFly", frandom(-16, 16), frandom(-16, 16), frandom(-16, 16), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEAD J -1;
        Stop;
    }
}

class GibbedBodyNoFlies : DeadMarine
{
    States
    {
    Spawn:
        DEA2 A 0 NoDelay A_Jump(256, "Corpse1", "Corpse2", "Corpse3", "Corpse4");
        Goto Corpse1;
    Corpse1:
        DEA2 A 0 A_SpawnItem("GreatBloodSpot");
        DEA2 A -1;
        Stop;
    Corpse2:
        DEA2 B 0 A_SpawnItem("GreatBloodSpot");
        DEA2 B 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEA2 B -1;
        Stop;
    Corpse3:
        DEA2 C 0 A_SpawnItem("GreatBloodSpot");
        DEA2 C -1;
        Stop;
    Corpse4:
        DEA2 D 0 A_SpawnItem("GreatBloodSpot");
        DEA2 D 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEA2 D -1;
        Stop;
    }
}

class GibbedBodyWithFlies : DeadMarine
{
    States
    {
    Spawn:
        DEA2 A 0 NoDelay A_Jump(256, "Corpse1", "Corpse2", "Corpse3", "Corpse4");
        Goto Corpse1;
    Corpse1:
        DEA2 A 0 A_SpawnItem("GreatBloodSpot");
        DEA2 A 0 A_PlaySound("SFX/Buzz", CHAN_BODY, 1.0);
        DEA2 AAAAAA 1 A_SpawnItemEx("SwarmFly", frandom(-16, 16), frandom(-16, 16), frandom(-16, 16), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEA2 A -1;
        Stop;
    Corpse2:
        DEA2 B 0 A_SpawnItem("GreatBloodSpot");
        DEA2 B 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEA2 B 0 A_PlaySound("SFX/Buzz", CHAN_BODY, 1.0);
        DEA2 BBBBBB 1 A_SpawnItemEx("SwarmFly", frandom(-16, 16), frandom(-16, 16), frandom(-16, 16), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEA2 B -1;
        Stop;
    Corpse3:
        DEA2 C 0 A_SpawnItem("GreatBloodSpot");
        DEA2 C 0 A_PlaySound("SFX/Buzz", CHAN_BODY, 1.0);
        DEA2 CCCCCC 1 A_SpawnItemEx("SwarmFly", frandom(-16, 16), frandom(-16, 16), frandom(-16, 16), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEA2 C -1;
        Stop;
    Corpse4:
        DEA2 D 0 A_SpawnItem("GreatBloodSpot");
        DEA2 D 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEA2 D 0 A_PlaySound("SFX/Buzz", CHAN_BODY, 1.0);
        DEA2 DDDDDD 1 A_SpawnItemEx("SwarmFly", frandom(-16, 16), frandom(-16, 16), frandom(-16, 16), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DEA2 D -1;
        Stop;
    }
}

class DeadDutyNoFlies : DeadMarine
{
    States
    {
    Spawn:
        DTY1 N 0 NoDelay A_Jump(256, "Corpse1", "Corpse2");
        Goto Corpse1;
    Corpse1:
        DTY1 N 0 A_SpawnItem("GreatBloodSpot");
        DTY1 N 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DTY1 N 0 A_DropItem("DutyPDA", 1, 32);
        DTY1 N -1;
        Stop;
    Corpse2:
        DTY2 N 0 A_SpawnItem("GreatBloodSpot");
        DTY2 N 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DTY2 N 0 A_DropItem("DutyPDA", 1, 32);
        DTY2 N -1;
        Stop;
    }
}

class DeadDutyWithFlies : DeadMarine
{
    States
    {
    Spawn:
        DTY1 A 0 NoDelay A_Jump(256, "Corpse1", "Corpse2");
        Goto Corpse1;
    Corpse1:
        DTY1 N 0 A_SpawnItem("GreatBloodSpot");
        DTY1 N 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DTY1 N 0 A_DropItem("DutyPDA", 1, 32);
        DTY1 A 0 A_PlaySound("SFX/Buzz", CHAN_BODY, 1.0);
        DTY1 NNNNNN 1 A_SpawnItemEx("SwarmFly", frandom(-16, 16), frandom(-16, 16), frandom(-16, 16), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DTY1 N -1;
        Stop;
    Corpse2:
        DTY2 N 0 A_SpawnItem("GreatBloodSpot");
        DTY2 N 0 A_SpawnItemEx("PripyatRoach", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DTY2 N 0 A_DropItem("DutyPDA", 1, 32);
        DTY2 N 0 A_PlaySound("SFX/Buzz", CHAN_BODY, 1.0);
        DTY2 NNNNNN 1 A_SpawnItemEx("SwarmFly", frandom(-16, 16), frandom(-16, 16), frandom(-16, 16), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
        DTY2 N -1;
        Stop;
    }
}

// Terrain
class MudChunk : Actor
{
    Default
    {
        Radius 2;
        Height 4;
        +NOBLOCKMAP;
        +MISSILE;
        +DROPOFF;
        +NOTELEPORT;
        +CANNOTPUSH;
        +DONTSPLASH;
    }
    States
    {
    Spawn:
        MUDS ABCD 8;
        Stop;
    Death:
        MUDS D 6;
        Stop;
    }
}

class MudSplash : Actor
{
    Default
    {
        +NOBLOCKMAP;
        +NOCLIP;
        +NOGRAVITY;
        +DONTSPLASH;
    }
    States
    {
    Spawn:
        MUDS EFGH 6;
        Stop;
    }
}