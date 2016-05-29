#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ace_interact_menu"};
        author[] = {"joko // Jonas", "Emperias", "Zigomarvin"};
        authorUrl = "https://github.com/jokoho48";
        VERSION_CONFIG;
    };
};

#include "CBA_Settings.hpp"
#include "CfgMovesBasic.hpp"
#include "CfgEventHandlers.hpp"
#include "CfgVehicles.hpp"
