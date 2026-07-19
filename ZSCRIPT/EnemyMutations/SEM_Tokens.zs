// Inventory markers for Zone afflictions / severity overlays.

class SEM_Token : Inventory
{
	Default
	{
		+INVENTORY.UNDROPPABLE;
		+INVENTORY.UNTOSSABLE;
		Inventory.MaxAmount 1;
	}
}

class SEM_ChemicalToken : SEM_Token {}
class SEM_ThermalToken : SEM_Token {}
class SEM_ElectroToken : SEM_Token {}
class SEM_GravityToken : SEM_Token {}
class SEM_PsiToken : SEM_Token {}
class SEM_BloodsuckerToken : SEM_Token {}
class SEM_SnorkToken : SEM_Token {}
class SEM_PseudogiantToken : SEM_Token {}

class SEM_AnomalyGrowthToken : SEM_Token {}
class SEM_PhaseShiftToken : SEM_Token {}
class SEM_EmissionRageToken : SEM_Token {}

// Opt-out for scripted / unique enemies.
class SEM_NullToken : Inventory
{
	Default
	{
		+INVENTORY.UNDROPPABLE;
		+INVENTORY.UNTOSSABLE;
		Inventory.MaxAmount 1;
	}
}

class SEM_PersistentInfo : Inventory
{
	class<Thinker> c;
	int i;
	int m;

	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE;
		+INVENTORY.HUBPOWER;
		+INVENTORY.UNTOSSABLE;
	}
}
