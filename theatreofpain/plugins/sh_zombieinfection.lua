PLUGIN.name = "Zombie Infection"
PLUGIN.author = "Pablo J. Martínez"
PLUGIN.desc = "Adds a zombie infection system."

local timeWhenMustBeWarned = 0

if (SERVER) then
	function PLUGIN:PostPlayerLoadout(client)
		local uniqueID = "Infection"..client:SteamID()
		timer.Create(uniqueID, 2, 0, function()
            if(IsValid(client) and client:Alive()) then
                local character = client:getChar()
                if(character ~= nil and character:getData("infected", false) == true) then
                    local currentInfection = math.Clamp(character:getData("infection", 100) - 0.055, 0, 100) -- 1 hour
                    character:setData("infection", currentInfection)
                    if(currentInfection <= 0) then
                        local zombie = ents.Create("zombie_bot");
	                    zombie:SetPos(client:GetPos());
	                    zombie:Spawn();
	                    zombie:Activate();
                        client:Kill()
                        character:setData("infection", 100)
                        character:setData("infected", false)
                        character:setData("banned", true)
                    elseif(currentInfection <= 100 and CurTime() > timeWhenMustBeWarned) then
                        client:notify("You are dying because of the infection!")
                        timeWhenMustBeWarned = CurTime() + 300
                    end
                end
            end
        end)
    end

    hook.Add("EntityTakeDamage", "MayGetInfectedFromAZombieAttack", function(target, damageInfo)
        if(IsValid(target) and target:IsPlayer()) then
            local attacker = damageInfo:GetAttacker()
            if(IsValid(attacker) and target:getChar() ~= nil) then
                if(attacker:IsZombie() and math.random() <= 0.1 and (target:getChar():getData("infected", false) == nil or target:getChar():getData("infected", false) == false)) then
                    target:notify("Oh shit, you are infected!")
                    target:getChar():setData("infection", 100)
                    target:getChar():setData("infected", true)
                end
            end
        end
    end)
else
	nut.bar.add(function()
		return LocalPlayer():getChar():getData("infection", 100) / 100
	end, Color(180, 140, 200), nil, "infection")
end

hook.Add("KeyPress", "UsedTheCureFromTheAdrenalineInjection", function(player, key)
    local weapon = player:GetActiveWeapon()
    if(IsValid(weapon)) then
        if(key == IN_ATTACK and weapon:GetClass() == "sg_adrenaline") then
            if(SERVER) then
                timer.Simple(4, function()
                    character = player:getChar()
                    if(character:getData("infected", false) == true) then
                        character:setData("infection", 100)
                        character:setData("infected", false)
                        player:notify("Nice! You are recovering from the infection!")
                        if(IsValid(weapon)) then
                            player:StripWeapon("sg_adrenaline")
                        end
                    end
                end)
            end
        end
    end
end)

--nut.config.add("Time until death", 30, "Maximum time until death (in minutes).", nil, {
--	category = "Hunger System"
--})