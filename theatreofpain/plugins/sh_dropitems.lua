PLUGIN.name = "Drop Items"
PLUGIN.author = "Pablo J. Martínez"
PLUGIN.desc = "Drop every item in the inventory when someone dies."

if(SERVER) then

    hook.Add("PlayerDeath", "DropItemsWhenSomeoneDies", function(victim, inflictor, attacker)
        character = victim:getChar()
        for k, v in pairs(character:getInv():getItems()) do
            --nut.item.spawn(v.uniqueID, victim:GetPos() + Vector(0, 0, 16))
		    v:transfer()
	    end
        hook.Run("SaveData")
    end)

end