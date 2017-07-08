PLUGIN.name = "Flashlight"
PLUGIN.author = "Pablo J. Martínez"
PLUGIN.desc = "Allows to use a flashlight. Hands are not allowed to turn on the flashlight, you must use a weapon or the flashlight itself."

if(SERVER) then
    function PLUGIN:PlayerSwitchFlashlight(client, enabled)
        if(enabled) then
            local activeWeaponClass = client:GetActiveWeapon():GetClass()
            if((activeWeaponClass ~= "tfa_nmrih_maglite" and !client:getChar():getInv():hasItem("maglite")) or (activeWeaponClass == "nut_hands")) then
                return false
            end
        end
        return true
    end
end