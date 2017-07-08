-- Developed by Pablo J. Martínez
ITEM.name = "Health"
--ITEM.desc = "Looks neat [Effectiveness: %s]"
ITEM.model = ""
ITEM.category = "Health"
ITEM.effectiveness = 0 -- Percentage
ITEM.functions.Use = {
	name = "Use",
	tip = "equipTip",
	icon = "icon16/heart_add.png",
    sound = "items/medshot4.wav",
	onRun = function(item)
        local player = item.player
        player:SetHealth(math.Clamp(player:Health() + item.effectiveness, 0, player:GetMaxHealth()))
    end
}

function ITEM:getDesc()
	return Format(self.desc, self.effectiveness)
end