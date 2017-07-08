PLUGIN.name = "Zombies Health"
PLUGIN.author = "Pablo J. Martínez"
PLUGIN.desc = "Allows to manage the zombies' health."

if(SERVER) then

    function SetZombiesHealth()
        local health = nut.config.get("ZombiesHealth")
	    for k, v in pairs(ents.FindByClass("v_zombie")) do
	        v:SetHealth(health)
        end
        if(nut.config.save ~= nil) then
            nut.config.save()
        end
    end

end

nut.config.add("ZombiesHealth", 2, "The amount of health that zombies have.", nil, {
            data = {min = 1, max = 200},
	        category = "Zombies"
        })