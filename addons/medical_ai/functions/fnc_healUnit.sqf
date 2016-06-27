/*
 * Author: BaerMitUmlaut
 * Makes a medic heal the next unit that needs treatment.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Nothing
 *
 * Public: No
 */
#include "script_component.hpp"

// Can't heal other units when unconscious
if (_this getVariable ["ACE_isUnconscious", false]) exitWith {};
// Check if we're still treating
if ((_this getVariable [QGVAR(treatmentOverAt), CBA_missionTime]) > CBA_missionTime) exitWith {};

// Find next unit to treat
private _healQueue = _this getVariable [QGVAR(healQueue), []];
private _target = _healQueue select 0;

// If unit died or was healed, be lazy and wait for the next tick
if (isNull _target || {!alive _target} || {!(_target call FUNC(isInjured))}) exitWith {
    _target forceSpeed -1;
    _healQueue deleteAt 0;
    _this getVariable [QGVAR(healQueue), _healQueue];
    _this forceSpeed -1;
    // return to formation instead of going where the injured unit was if it healed itself in the mean time
    _this moveTo getPosATL _this;

    #ifdef DEBUG_MODE_FULL
        systemChat systemChat format ["%1 finished healing %2", _this, _target];
    #endif
};

// Move to target...
if (_this distance _target > 1.5) exitWith {
    // This is necessary to force the unit to move ._.
    _this forceSpeed 0;
    _this forceSpeed -1;
    _this doMove getPosATL _target;
};
// ...and make sure medic and target don't move
_this forceSpeed 0;
_target forceSpeed 0;

private _needsBandaging   = ([_target] call EFUNC(medical,getBloodLoss)) > 0;
private _needsMorphine    = (_target getVariable [QEGVAR(medical,pain), 0]) > 0.2;

switch (true) do {
    case _needsBandaging: {
        // Find injured body part and bandage it
        private _bodyPartStatus = _target getVariable [QEGVAR(medical,bodyPartStatus), [0,0,0,0,0,0]];
        private _partIndex = {
            if (_x > 0) exitWith {_forEachIndex};
        } forEach _bodyPartStatus;
        private _selection = ["head","body","hand_l","hand_r","leg_l","leg_r"] select _partIndex;
        [_target, _selection] call EFUNC(medical,treatmentBasic_bandageLocal);

        #ifdef DEBUG_MODE_FULL
            systemChat systemChat format ["%1 is bandaging selection %2 on %3", _this, _selection, _target];
        #endif

        // Play animation
        [_this, true, false] call FUNC(playTreatmentAnim);
        _this setVariable [QGVAR(treatmentOverAt), CBA_missionTime + 5];
    };
    case _needsMorphine: {
        [_target] call EFUNC(medical,treatmentBasic_morphineLocal);
        [_this, false, false] call FUNC(playTreatmentAnim);
        _this setVariable [QGVAR(treatmentOverAt), CBA_missionTime + 2];

        #ifdef DEBUG_MODE_FULL
            systemChat systemChat format ["%1 is giving %2 morphine", _this, _target];
        #endif
    };
};
