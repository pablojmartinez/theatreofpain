-- Developed by Pablo J. Martínez
ITEM.name = "Food"
--ITEM.desc = "Tasty [Satiety: %s]"
ITEM.model = ""
ITEM.category = "Food"
ITEM.satiety = 0 -- Percentage
ITEM.functions.Eat = {
	name = "Eat",
	tip = "equipTip",
	icon = "icon16/tick.png",
    sound = "npc/barnacle/barnacle_gulp2.wav",
	onRun = function(item)
        local character = item.player:getChar()
        character:setData("hunger", math.Clamp(character:getData("hunger", 100) + item.satiety, 0, 100))
    end
}

function ITEM:getDesc()
	return Format(self.desc, self.satiety)
end