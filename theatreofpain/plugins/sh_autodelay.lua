PLUGIN.name = "Auto Delay"
PLUGIN.author = "Pablo J. Martínez"
PLUGIN.desc = "Auto delay when you try to equip or use a weapon."

local weaponMeta = FindMetaTable("Weapon")

if(SERVER) then

    netstream.Hook("SendChatMessageFromClientToServer", function(player, data)
        nut.chat.send(player, data.chatType, data.message)
    end)

end

function weaponMeta:HasToBeDelayed(player)
    local weapon = self
    local weaponClass = weapon:GetClass()
    local activeWeapon = player:GetActiveWeapon()
    if(weapon ~= activeWeapon and
       weaponClass ~= "weapon_physcannon" and 
       weaponClass ~= "weapon_physgun" and
       weaponClass ~= "gmod_tool" and
       weaponClass ~= "tfa_nmrih_maglite" and
       weaponClass ~= "nut_hands") then
       netstream.Start("SendChatMessageFromClientToServer", {
           chatType = nut.config.get("AutoDelayChatType"),
           message = nut.config.get("AutoDelayMessage")
       })
       return true
    else return false end
end

nut.config.add("AutoDelayTime", 4, "The auto delayed time for the weapons (in seconds).", nil, {
            data = {min = 1, max = 10},
	        category = "Auto Delay"
        })

nut.config.add("AutoDelayChatType", "me", "The chat type you want to show the auto delay message to the players.", nil, {
	category = "Auto Delay"
})

nut.config.add("AutoDelayMessage", "is taking out a weapon...", "The message you want to show when someone is gonna use a weapon.", SetZombiesHealth, {
	category = "Auto Delay"
})