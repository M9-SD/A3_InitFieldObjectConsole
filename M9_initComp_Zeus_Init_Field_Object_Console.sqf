comment "
A3_InitFieldObjectConsole

Arma 3 Steam Workshop
https://steamcommunity.com/sharedfiles/filedetails/?id=3039417719

MIT License
Copyright (c) 2023 M9-SD
https://github.com/M9-SD/A3_InitFieldObjectConsole/tree/main/LICENSE
";

comment "Determine if execution context is composition and delete the helipad."; 
if ((!isNull (findDisplay 312)) && (!isNil 'this')) then {
	if (!isNull this) then { 
		if (typeOf this == 'Land_HelipadEmpty_F') then { 
			deleteVehicle this; 
		}; 
	}; 
};
0 = [] spawn {
	waitUntil {isNull findDisplay 49};
	M9SD_fnc_removeCommentsFromCode = { 
		_input = _this select 0;

		private _strings = [];
		private _start = -1;

		while {_start = _input find "//"; _start > -1} do 
		{	
			_input select [0, _start] call
			{
				private _badQuotes = _this call 
				{
					private _qtsGood = [];
					private _qtsInfo = [];
					private _arr = toArray _this;

					{
						_qtsGood pushBack ((count _arr - count (_arr - [_x])) % 2 == 0);
						_qtsInfo pushBack [_this find toString [_x], _x];
					} 
					forEach [34, 39];

					if (_qtsGood isEqualTo [true, true]) exitWith {0};

					_qtsInfo sort true;
					_qtsInfo select 0 select 1
				};

				if (_badQuotes > 0) exitWith
				{ 
					_last = _input select [_start] find toString [_badQuotes];

					if (_last < 0) exitWith 
					{
						_strings = [_input];
						_input = "";
					};

					_last = _start + _last + 1;
					_strings pushBack (_input select [0, _last]);

					_input = _input select [_last];
				};

				_strings pushBack _this;

				_input = _input select [_start];

				private _end = _input find toString [10];

				if (_end < 0) exitWith {_input = ""};

				_input = _input select [_end + 1];
			};
		};

		_input = (_strings joinString "") + _input;
		_input
	};
	private _initREpack = [] spawn {
		if (!isNil 'M9SD_fnc_RE2_V3') exitWith {};
		comment "Initialize Remote-Execution Package";
		M9SD_fnc_initRE2_V3 = {
			M9SD_fnc_initRE2Functions_V3 = {
				comment "Prep RE2 functions.";
				M9SD_fnc_REinit2_V3 = {
					private _functionNameRE2 = '';
					if (isNil {_this}) exitWith {false};
					if !(_this isEqualType []) exitWith {false};
					if (count _this == 0) exitWith {false};
					private _functionNames = _this;
					private _aString = "";
					private _namespaces = [missionNamespace, uiNamespace];
					{
						if !(_x isEqualType _aString) then {continue};
						private _functionName = _x;
						_functionNameRE2 = format ["RE2_%1", _functionName];
						{
							private _namespace = _x;
							with _namespace do {
								if (!isNil _functionName) then {
									private _fnc = _namespace getVariable [_functionName, {}];
									private _fncStr = str _fnc;
									private _fncStr2 = "{" + 
										"removeMissionEventHandler ['EachFrame', _thisEventHandler];" + 
										"_thisArgs call " + _fncStr + 
									"}";
									private _fncStrArr = _fncStr2 splitString '';
									_fncStrArr deleteAt (count _fncStrArr - 1);
									_fncStrArr deleteAt 0;
									_namespace setVariable [_functionNameRE2, _fncStrArr, true];
								};
							};
						} forEach _namespaces;
					} forEach _functionNames;
					true;_functionNameRE2;
				};
				M9SD_fnc_RE2_V3 = {
					params [["_REarguments", []], ["_REfncName2", ""], ["_REtarget", player], ["_JIPparam", false]];
					if (!((missionnamespace getVariable [_REfncName2, []]) isEqualType []) && !((uiNamespace getVariable [_REfncName2, []]) isEqualType [])) exitWith {
						systemChat "::Error:: remoteExec failed (invalid _REfncName2 - not an array).";
					};
					if ((count (missionnamespace getVariable [_REfncName2, []]) == 0) && (count (uiNamespace getVariable [_REfncName2, []]) == 0)) exitWith {
						systemChat "::Error:: remoteExec failed (invalid _REfncName2 - empty array).";
						systemChat str _REfncName2;
					};
					[[_REfncName2, _REarguments],{ 
						addMissionEventHandler ["EachFrame", (missionNamespace getVariable [_this # 0, ['']]) joinString '', _this # 1]; 
					}] remoteExec ['call', _REtarget, _JIPparam];
				};
				comment "systemChat '[ RE2 Package ] : RE2 functions initialized.';";
			};
			M9SD_fnc_initRE2FunctionsGlobal_V2 = {
				comment "Prep RE2 functions on all clients+jip.";
				private _fncStr = format ["{
					removeMissionEventHandler ['EachFrame', _thisEventHandler];
					_thisArgs call %1
				}", M9SD_fnc_initRE2Functions_V3];
				_fncStr = _fncStr splitString '';
				_fncStr deleteAt (count _fncStr - 1);
				_fncStr deleteAt 0;
				missionNamespace setVariable ["RE2_M9SD_fnc_initRE2Functions_V2", _fncStr, true];
				[["RE2_M9SD_fnc_initRE2Functions_V2", []],{ 
					addMissionEventHandler ["EachFrame", (missionNamespace getVariable ["RE2_M9SD_fnc_initRE2Functions_V2", ['']]) joinString '', _this # 1]; 
				}] remoteExec ['call', 0, 'RE2_M9SD_JIP_initRE2Functions_V2'];
				comment "Delete from jip queue: remoteExec ['', 'RE2_M9SD_JIP_initRE2Functions_V2'];";
			};
			call M9SD_fnc_initRE2FunctionsGlobal_V2;
		};
		call M9SD_fnc_initRE2_V3;
		waitUntil {!isNil 'M9SD_fnc_RE2_V3'};
		if (true) exitWith {true};
	};
	waitUntil {scriptDone _initREpack};
	waitUntil {!isNil 'M9SD_fnc_REinit2_V3'};
	M9SD_fnc_objConsoleReturn = {
		_returnStr = _this joinString '';
		private _ctrl = uiNamespace getVariable ['objConsole_outputCtrl', controlNull];
		_ctrl ctrlSetText _returnStr;
		_ctrl ctrlCommit 0;
	};
	private _fncNameRE2 = ['M9SD_fnc_objConsoleReturn'] call M9SD_fnc_REinit2_V3;
	waitUntil {!isNil _fncNameRE2};
	M9SD_fnc_openObjectConsole = {
		_object = _this;
		findDisplay 49 closeDisplay 0;
		findDisplay 316000 closeDisplay 0;
		createDialog 'RscDisplayDebugPublic';
		_disp = findDisplay 316000;
		[_disp, _object] spawn {
			params ['_disp', '_object'];
			waitUntil {(isNull _disp) or (isNull _object)};
			if (isNull _object) then {
				systemChat 'ERROR | Object is MIA.';
				_disp closeDisplay 0;
			};
		};
		_ctrls = allControls _disp;
		{
			_x ctrlShow true;
			_x ctrlEnable true;
			_x ctrlSetFade 0;
			_x ctrlCommit 0;
		} forEach _ctrls;
		showChat true;
		13184; 'console entire';
		11891; 'console hyperlink';
		11884; 'console title text';
		12284; 'expression';
		11885; 'expression background';
		11892; 'expressiontext';
		13191; 'expression output background';
		13190; 'expression output';
		13484; 'local exec';
		13285; 'global exec';
		13286; 'server exec';
		13284; 'code performance';
		_protectedCtrlIDCs = [
			11891, 13184, 11884, 12284, 13190, 13191, 11892, 11885, 13484, 13285, 13286, 13284
		];
		_protectedCtrlClasses = [
			'ButtonExecuteServerBackground', [0,1,0,0.25098], 
			'ButtonExecuteAllBackground', [1,0,0,0.25098], 
			'ButtonExecuteLocalBackground', [0,0,1,0.25098]
		];_protectedCtrlClasses = [];
		{
			private _idc = ctrlIDC _x;
			private _className = ctrlClassName _x;
			if ((!(_idc in _protectedCtrlIDCs)) && (!(_className in _protectedCtrlClasses))) then {
				_x ctrlShow false;
				_x ctrlEnable false;
				_x ctrlCommit 0;
			};
		} forEach _ctrls;
		private _titleTextCtrl = (_disp displayCtrl 11884);
		_objType = typeOf _object;
		_objName = if (isPlayer _object) then {name _object} else {getText (configFile >> 'cfgVehicles' >> _objType >> 'displayName')};
		_objName = if (_objName == '') then {_objType} else {_objName};
		_titleTextCtrl ctrlSetText FORMAT ['OBJECT CONSOLE | %1', _objName];
		_titleTextCtrl ctrlCommit 0;

		private _consoleCtrlGroup = _disp displayCtrl 13184;

		private _localExecCtrl	= (_disp displayCtrl 13484);
		private _globalExecCtrl = (_disp displayCtrl 13285);
		private _serverExecCtrl = (_disp displayCtrl 13286);
		private _codePerfCtrl	= (_disp displayCtrl 13284);

		private _consoleCtrlGroup2 = ctrlParentControlsGroup _serverExecCtrl;
		

		_dPos_local = ctrlPosition _localExecCtrl;
		_dPos_global = ctrlPosition _globalExecCtrl;
		_dPos_server = ctrlPosition _serverExecCtrl;
		_dPos_perf = ctrlPosition _codePerfCtrl;

		_serverExecCtrl ctrlEnable false;
		_serverExecCtrl ctrlShow false;
		_globalExecCtrl ctrlEnable false;
		_globalExecCtrl ctrlShow false;
		_localExecCtrl ctrlEnable false;
		_localExecCtrl ctrlShow false;
		_codePerfCtrl ctrlEnable false;
		_codePerfCtrl ctrlShow false;

		_dPos_y = _dPos_local # 1;
		_dPos_h = _dPos_perf # 3;
		
		_bPosStart = _dPos_perf # 0;
		_bPosEnd = (_dPos_local # 2) + (_dPos_local # 0);
		_singleGapLength = 0.0034;
		_totalGapLength = _singleGapLength * 4;
		_totalWidth = (_bPosEnd - _bPosStart) - _totalGapLength;
		_uniWidth = (_totalWidth / 5);

		_bPos_1 = [_bPosStart, _dPos_y, _uniWidth, _dPos_h];
		_bPos_2 = [_bPosStart + (_uniWidth + _singleGapLength) * 1, _dPos_y, _uniWidth, _dPos_h];
		_bPos_3 = [_bPosStart + (_uniWidth + _singleGapLength) * 2, _dPos_y, _uniWidth, _dPos_h];
		_bPos_4 = [_bPosStart + (_uniWidth + _singleGapLength) * 3, _dPos_y, _uniWidth, _dPos_h];
		_bPos_5 = [_bPosStart + (_uniWidth + _singleGapLength) * 4, _dPos_y, _uniWidth, _dPos_h];

		_localExecCtrl ctrlRemoveAllEventHandlers 'ButtonClick';
		_globalExecCtrl ctrlRemoveAllEventHandlers 'ButtonClick';
		_serverExecCtrl ctrlRemoveAllEventHandlers 'ButtonClick';
		_codePerfCtrl ctrlRemoveAllEventHandlers 'ButtonClick';

		_localExecCtrl ctrlCommit 0;
		_globalExecCtrl ctrlCommit 0;
		_serverExecCtrl ctrlCommit 0;
		_codePerfCtrl ctrlCommit 0;

		_disp setVariable ['obj', _object];

		_ctrlExpression = _disp displayCtrl 12284;
		_disp setVariable ['expressionCtrl', _ctrlExpression];

		_ctrlOutput = _disp displayCtrl 13190;
		_disp setVariable ['outputCtrl', _ctrlOutput];
		uiNamespace setVariable ['objConsole_outputCtrl', _ctrlOutput];

		_ctrlOutputBackground = _disp displayCtrl 13191;
		_ctrlOutputBackground ctrlSetBackgroundColor [0.4,0.4,0.4,0.4];
		_ctrlOutputBackground ctrlCommit 0;

		_ctrlClose = _disp ctrlCreate ['RscButtonMenu', -1, _consoleCtrlGroup];
		_ctrlClose ctrlSetTooltip 'Close this console menu.';
		_ctrlClose ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.05)) + "'><img image='\a3\ui_f_curator\data\CfgCurator\waypoint_ca.paa'></img>CLOSE</t>");
		_ctrlClose ctrlSetPosition _bPos_1;
		_ctrlClose ctrlAddEventHandler ['ButtonClick', 
		{
			params ["_control"];
			_parentDisplay = ctrlParent _control;
			_parentDisplay closeDisplay 0;
		}];
		_ctrlClose ctrlSetBackgroundColor [0,0,0,0.9];
		_ctrlClose ctrlCommit 0;

		_ctrlServer = _disp ctrlCreate ['RscButtonMenu', -1, _consoleCtrlGroup];
		_ctrlServer ctrlSetTooltip 'Remote-execute the code on the server machine.';
		_ctrlServer ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.05)) + "'><img image='\a3\3den\data\displays\display3den\statusbar\server_ca.paa'></img>SERVER</t>");
		_ctrlServer ctrlSetPosition _bPos_2;
		_ctrlServer ctrlAddEventHandler ['ButtonClick', 
		{
			params ["_control"];
			_parentDisplay = ctrlParent _control;
			_object = _parentDisplay getVariable ['obj', objNull];
			_expressionCtrl = _parentDisplay getVariable ['expressionCtrl', controlNull];
			_outputCtrl = _parentDisplay getVariable ['outputCtrl', controlNull];
			if (isNull _expressionCtrl) exitWith {};
			_codeText = ctrlText _expressionCtrl;
			if (toLower _codeText == 'utils') exitWith {
				0 execVM '\A3\Functions_F\Debug\Utilities\lib\index.sqf';
			};
			if ((_codeText == "")) then {
				playsound "addItemFailed";
			} else {
				playsound "addItemOK";
				_codeText = [_codeText] call M9SD_fnc_removeCommentsFromCode;
				_codeText = "this = _this;" + _codeText;
				_codeText = format ["[(str ([nil] apply {(_this # 0) call {%1}} param [0, text '']) splitString ''), 'RE2_M9SD_fnc_objConsoleReturn', remoteExecutedOwner] call M9SD_fnc_RE2_V3;", _codeText];
				_code = compile _codeText;
				M9SD_fnc_objectConsole_serverExec = _code;
				[[_object], (['M9SD_fnc_objectConsole_serverExec'] call M9SD_fnc_REinit2_V3), 2] call M9SD_fnc_RE2_V3;
			};
		}];
		_ctrlServer ctrlSetBackgroundColor [0.01,0.1,0.01,0.9];
		_ctrlServer ctrlCommit 0;

		_ctrlGlobal = _disp ctrlCreate ['RscButtonMenu', -1, _consoleCtrlGroup];
		_ctrlGlobal ctrlSetTooltip 'Remote-execute the code on all clients connected to the server.';
		_ctrlGlobal ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.05)) + "'><img image='\A3\3den\data\Displays\Display3den\toolbar\widget_global_ca.paa'></img>GLOBAL</t>");
		_ctrlGlobal ctrlSetPosition _bPos_3;
		_ctrlGlobal ctrlAddEventHandler ['ButtonClick', 
		{
			params ["_control"];
			_parentDisplay = ctrlParent _control;
			_object = _parentDisplay getVariable ['obj', objNull];
			_expressionCtrl = _parentDisplay getVariable ['expressionCtrl', controlNull];
			_outputCtrl = _parentDisplay getVariable ['outputCtrl', controlNull];
			if (isNull _expressionCtrl) exitWith {};
			_codeText = ctrlText _expressionCtrl;
			if (toLower _codeText == 'utils') exitWith {
				0 execVM '\A3\Functions_F\Debug\Utilities\lib\index.sqf';
			};
			if ((_codeText == "")) then {
				playsound "addItemFailed";
			} else {
				playsound "addItemOK";
				_codeText = [_codeText] call M9SD_fnc_removeCommentsFromCode;
				_codeText = "this = _this;" + _codeText;
				_codeText = format ["[(str ([nil] apply {(_this # 0) call {%1}} param [0, text '']) splitString ''), 'RE2_M9SD_fnc_objConsoleReturn', remoteExecutedOwner] call M9SD_fnc_RE2_V3;", _codeText];
				_code = compile _codeText;
				M9SD_fnc_objectConsole_globalExec = _code;
				[[_object], (['M9SD_fnc_objectConsole_globalExec'] call M9SD_fnc_REinit2_V3), 0] call M9SD_fnc_RE2_V3;
			};
		}];
		_ctrlGlobal ctrlSetBackgroundColor [0.1,0.01,0.01,0.9];
		_ctrlGlobal ctrlCommit 0;

		_ctrlOwner = _disp ctrlCreate ['RscButtonMenu', -1, _consoleCtrlGroup];
		_ctrlOwner ctrlSetTooltip 'Remote-execute the code on the client that owns the object.';
		_ctrlOwner ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.05)) + "'><img image='\a3\ui_f\data\GUI\rsc\RscDisplayGarage\crew_ca.paa'></img>OWNER</t>");
		_ctrlOwner ctrlSetPosition _bPos_4;
		_ctrlOwner ctrlAddEventHandler ['ButtonClick', 
		{
			params ["_control"];
			_parentDisplay = ctrlParent _control;
			_object = _parentDisplay getVariable ['obj', objNull];
			_expressionCtrl = _parentDisplay getVariable ['expressionCtrl', controlNull];
			_outputCtrl = _parentDisplay getVariable ['outputCtrl', controlNull];
			if (isNull _expressionCtrl) exitWith {};
			_codeText = ctrlText _expressionCtrl;
			if (toLower _codeText == 'utils') exitWith {
				0 execVM '\A3\Functions_F\Debug\Utilities\lib\index.sqf';
			};
			if ((_codeText == "")) then {
				playsound "addItemFailed";
			} else {
				playsound "addItemOK";
				_codeText = [_codeText] call M9SD_fnc_removeCommentsFromCode;
				_codeText = "this = _this;" + _codeText;
				_codeText = format ["[(str ([nil] apply {(_this # 0) call {%1}} param [0, text '']) splitString ''), 'RE2_M9SD_fnc_objConsoleReturn', remoteExecutedOwner] call M9SD_fnc_RE2_V3;", _codeText];
				_code = compile _codeText;
				M9SD_fnc_objectConsole_ownerExec = _code;
				[[_object], (['M9SD_fnc_objectConsole_ownerExec'] call M9SD_fnc_REinit2_V3), _object] call M9SD_fnc_RE2_V3;
			};
		}];
		_ctrlOwner ctrlSetBackgroundColor [0.14,0.01,0.14,0.9];
		_ctrlOwner ctrlCommit 0;

		_ctrlLocal = _disp ctrlCreate ['RscButtonMenu', -1, _consoleCtrlGroup];
		_ctrlLocal ctrlSetTooltip 'Execute the code on your client.';
		_ctrlLocal ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.05)) + "'><img image='\A3\3den\data\Displays\Display3den\toolbar\widget_local_ca.paa'></img>LOCAL</t>");
		_ctrlLocal ctrlSetPosition _bPos_5;
		_ctrlLocal ctrlAddEventHandler ['ButtonClick', 
		{
			params ["_control"];
			_parentDisplay = ctrlParent _control;
			_object = _parentDisplay getVariable ['obj', objNull];
			_expressionCtrl = _parentDisplay getVariable ['expressionCtrl', controlNull];
			_outputCtrl = _parentDisplay getVariable ['outputCtrl', controlNull];
			if (isNull _expressionCtrl) exitWith {};
			_codeText = ctrlText _expressionCtrl;
			if (toLower _codeText == 'utils') exitWith {
				0 execVM '\A3\Functions_F\Debug\Utilities\lib\index.sqf';
			};
			if ((_codeText == "")) then {
				playsound "addItemFailed";
			} else {
				playsound "addItemOK";
				_codeText = [_codeText] call M9SD_fnc_removeCommentsFromCode;
				_codeText = "this = _this;" + _codeText;
				_code = compile _codeText;
				_returnStr = str ([nil] apply {_object call _code} param [0, text ""]);
				with uiNamespace do 
				{
					disableSerialization;
					_outputCtrl ctrlSetText _returnStr;
					_outputCtrl ctrlCommit 0;
				};
				comment "profileNamespace setVariable ['RscDebugConsole_expression', _codeText];";
			};
		}];
		_ctrlLocal ctrlSetBackgroundColor [0.01,0.01,0.1,0.9];
		_ctrlLocal ctrlCommit 0;
	};
	M9SD_fnc_moduleObjectConsole_composition = 
	{
		if (isNull findDisplay 312) exitWith {systemChat 'ERROR | Zeus is not open!';};
		private _targetObjArray = curatorMouseOver;
		_object = if ((_targetObjArray isEqualTo []) or (_targetObjArray isEqualTo [''])) then {objNull} else {_targetObjArray select 1};
		if (isNull _object) exitWith {systemChat "ERROR | No object! (Place the zeus module on top of an object’s 3D icon)";[_zeusLogic, 'NO OBJECT SELECTED'] call BIS_fnc_showCuratorFeedbackMessage;};
		_zeusLogic = objNull;
		_zeusLogic = getAssignedCuratorLogic player;
		if (isNull _zeusLogic) exitWith {systemChat 'ERROR | Zeus logic entity not found!';};
		_object spawn M9SD_fnc_openObjectConsole;
		_objType = typeOf _object;
		_objName = if (isPlayer _object) then {name _object} else {getText (configFile >> 'cfgVehicles' >> _objType >> 'displayName');};
		if (_objName == '') then 
		{
			_objName = _objType;
		};
		_feeback = format ["You are editing [ %1 ]...", _objName];
		[_zeusLogic, _feeback] call BIS_fnc_showCuratorFeedbackMessage;
	};
	[] call M9SD_fnc_moduleObjectConsole_composition;
};

comment "
A3_InitFieldObjectConsole

Arma 3 Steam Workshop
https://steamcommunity.com/sharedfiles/filedetails/?id=3039417719

MIT License
Copyright (c) 2023 M9-SD
https://github.com/M9-SD/A3_InitFieldObjectConsole/tree/main/LICENSE
";