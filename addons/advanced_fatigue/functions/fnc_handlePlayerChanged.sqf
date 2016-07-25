/*
 * Author: BaerMitUmlaut
 * Handles switching units (once on init and afterwards via Zeus).
 *
 * Arguments:
 * 0: New Unit <OBJECT>
 * 1: Old Unit <OBJECT>
 *
 * Return Value:
 * None
 */
#include "script_component.hpp"
params ["_newUnit", "_oldUnit"];

if !(isNull _oldUnit) then {
    _oldUnit enableStamina true;
    _oldUnit removeEventHandler ["AnimChanged", GVAR(animHandler)];

    _oldUnit setVariable [QGVAR(ae1Reserve), GVAR(ae1Reserve)];
    _oldUnit setVariable [QGVAR(ae2Reserve), GVAR(ae2Reserve)];
    _oldUnit setVariable [QGVAR(anReserve), GVAR(anReserve)];
    _oldUnit setVariable [QGVAR(anFatigue), GVAR(anFatigue)];
    _oldUnit setVariable [QGVAR(muscleDamage), GVAR(muscleDamage)];
};

_newUnit enableStamina false;
GVAR(animHandler) = _newUnit addEventHandler ["AnimChanged", {
    GVAR(animDuty) = _this call FUNC(getAnimDuty);
}];

GVAR(ae1Reserve)      = _newUnit getVariable [QGVAR(ae1Reserve), AE1_MAXRESERVE];
GVAR(ae2Reserve)      = _newUnit getVariable [QGVAR(ae2Reserve), AE2_MAXRESERVE];
GVAR(anReserve)       = _newUnit getVariable [QGVAR(anReserve), AN_MAXRESERVE];
GVAR(anFatigue)       = _newUnit getVariable [QGVAR(anFatigue), 0];
GVAR(muscleDamage)    = _newUnit getVariable [QGVAR(muscleDamage), 0];

GVAR(VO2Max)          = 35 + 20 * (_newUnit getVariable [QGVAR(performanceFactor), GVAR(performanceFactor)]);
GVAR(VO2MaxPower)     = GVAR(VO2Max) * SIM_BODYMASS * 0.23 * JOULES_PER_ML_O2 / 60;
GVAR(peakPower)       = VO2MAX_STRENGTH * GVAR(VO2MaxPower);

GVAR(ae1PathwayPower) = GVAR(peakPower) / (13.3 + 16.7 + 113.3) * 13.3 * ANTPERCENT ^ 1.28 * 1.362;
GVAR(ae2PathwayPower) = GVAR(peakPower) / (13.3 + 16.7 + 113.3) * 16.7 * ANTPERCENT ^ 1.28 * 1.362;
GVAR(anPathwayPower)  = GVAR(peakPower) - _ae1PathwayPower - _ae2PathwayPower;

GVAR(ppeBlackoutLast) = 100;
GVAR(lastBreath)      = 0;
GVAR(animDuty)        = [_newUnit, animationState _newUnit] call FUNC(getAnimDuty);