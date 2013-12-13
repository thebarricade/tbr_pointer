if(isDedicated) exitWith{};

waitUntil {!isNull player};

sleep 2;

// should come from config
TBR_pointer_lifetime = 10;								// lifetime of pointer
TBR_pointer_color = '#(argb,8,8,3)color(1,1,0,0.35)';

missionNamespace setVariable ["pointershown", false];
missionNamespace setVariable ["pointers", []];
missionNamespace setVariable ["light", objNull];
missionNamespace setVariable ["pointerhandle", ""];

missionNamespace setVariable ["actionSphere", -1];
missionNamespace setVariable ["actionCircle", -1];

TBR_PointerCountdown = {
	missionNamespace setVariable ["pointershown", true];

	sleep TBR_pointer_lifetime;

	[] call TBR_DeletePointer;

	missionNamespace setVariable ["pointershown", false];
};

TBR_DeletePointer = {
	private["_pointers","_light"];

	_pointers = missionNamespace getVariable "pointers";
	_light = missionNamespace getVariable "light";

	if(!(isNull _light)) then { deleteVehicle _light; };
	if((count _pointers) != 0) then { { deleteVehicle _x; } forEach _pointers; };

	missionNamespace setVariable ["pointers", []];
	missionNamespace setVariable ["light", objNull];
};

TBR_DisplayPointer = {
	private["_model","_stack_count","_stack_space","_ps","_ph","_pointers","_tmpPointer","_light","_screenPos","_pointerPos","_pointerStackPos","_objs","_first","_bbr","_p1","_p2","_maxHeight","_handle","_i"];

	_model = _this select 0;
	_stack_count = _this select 1;
	_stack_space = _this select 2;

	_ps = missionNamespace getVariable "pointershown";

	if( _ps ) then {
		_ph = missionNamespace getVariable "pointerhandle";
		if( !scriptDone _ph ) then {
			terminate _ph;
			missionNamespace setVariable ["pointershown", false];
			missionNamespace setVariable ["pointerhandle", ""];

			[] call TBR_DeletePointer;			
		};
	};

	_light = objNull;

	_screenPos = screenToWorld [0.5,0.5];
	_pointerPos = [_screenPos select 0, _screenPos select 1, 2];

	_objs = lineIntersectsWith [eyePos player, ATLtoASL _screenPos];

	if( count _objs != 0 ) then {
		// place the pointer at the center of the object
		_first = (_objs select 0);

		_pointerPos = getPos _first;
		_pointerPos set [2, 2];
	};

	// place a vertical column of pointer objects to increase the chance that people will actually notice it...
	// TODO: create custom object in shape of a high vertical block to decrease strain on engine

	_pointers = [];
	_pointerStackPos = _pointerPos;
	for [{_i=0},{_i<_stack_count},{_i=_i+1}] do {
		_tmpPointer = createVehicle [_model, _pointerStackPos, [], 0, "CAN_COLLIDE"];
		_tmpPointer setPos _pointerStackPos;
		_tmpPointer setDir (getDir player);
		_tmpPointer setObjectTexture [0, TBR_pointer_color];

		_pointers set [_i, _tmpPointer];
		_pointerStackPos set [2, (_pointerStackPos select 2) + _stack_space];
	};

	if( sunOrMoon < 0.5 ) then {
		// only place a light if it's at least slighty dark
		// only one light is created, at the foot of the "pillar" of pointer-objects
		_light = "#lightpoint" createVehicle _pointerPos;
		_light setLightBrightness 0.05;
		_light setLightAmbient[0.5, 0.5, 0.0];
		_light setLightColor[0.0, 0.0, 0.0];
		_light lightAttachObject [(_pointers select 0), [0,0,0]];
	};

	missionNamespace setVariable ["pointers", _pointers];
	missionNamespace setVariable ["light", _light];

	_handle = [] spawn TBR_PointerCountdown;
	missionNamespace setVariable ["pointerhandle", _handle];
};

AddPointerActions = {
	private["_a","_b"];

	_a = missionNamespace getVariable "actionSphere";
	_b = missionNamespace getVariable "actionCircle";

	if( _a != -1 ) then { player removeAction _a; };
	if( _b != -1 ) then { player removeAction _b; };

	_a = player addAction ["<t color='#99ffffff'><img image='\tbr_pointer\gr_end_point_ca.paa' /> - Point to... (spheres)</t>", "['Sign_Sphere100cm_F', 10, 3] call TBR_DisplayPointer", [], -10, false, true, "User15"];
	_b = player addAction ["<t color='#99ffffff'><img image='\tbr_pointer\gr_end_point_ca.paa' /> - Point to... (circle)</t>", "['Sign_Circle_F', 1, 2] call TBR_DisplayPointer", [], -11, false, true, "User16"];	

	missionNamespace setVariable ["actionSphere", _a];
	missionNamespace setVariable ["actionCircle", _b];
};

player addEventHandler ["respawn", "[] call AddPointerActions"];
[] call AddPointerActions;