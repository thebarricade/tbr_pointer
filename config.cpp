#define _ARMA_

class CfgPatches
{
	class tbr_pointer
	{
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {"Extended_EventHandlers"};
	};
};

class Extended_PostInit_EventHandlers
{
	TBR_Pointer_Init = "[] execVM '\tbr_pointer\scripts\pointer.sqf'";
};