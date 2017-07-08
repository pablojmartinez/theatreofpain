PLUGIN.name = "Hunger"
PLUGIN.author = "Pablo J. Martínez"
PLUGIN.desc = "Adds a simple hunger system."

local timeWhenMustBeWarned = 0

if (SERVER) then
	function PLUGIN:PostPlayerLoadout(client)
		local uniqueID = "Hunger"..client:SteamID()
		timer.Create(uniqueID, 8, 0, function()
            if(IsValid(client) and client:Alive()) then
                local character = client:getChar()
                if(character ~= nil) then
                    local currentHunger = math.Clamp(character:getData("hunger", 100) - 0.055, 0, 100) -- 4 hours
                    character:setData("hunger", currentHunger)
                    if(currentHunger <= 0) then
                        client:Kill()
                        character:setData("hunger", 100)
                        character:setData("banned", true)
                    elseif(currentHunger <= 25 and CurTime() > timeWhenMustBeWarned) then
                        client:notify("You are starving!")
                        timeWhenMustBeWarned = CurTime() + 300
                    end
                end
            end
        end)
    end
else
	nut.bar.add(function()
		return LocalPlayer():getChar():getData("hunger", 100) / 100
	end, Color(255, 255, 255), nil, "hunger")
end

--nut.config.add("Time until death", 30, "Maximum time until death (in minutes).", nil, {
--	category = "Hunger System"
--})