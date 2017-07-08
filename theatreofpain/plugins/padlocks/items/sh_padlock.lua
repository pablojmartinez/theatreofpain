ITEM.name = "Padlock"
ITEM.desc = "A padlock that is placed on doors."
ITEM.price = 250
ITEM.model = "models/props_wasteland/prison_padlock001a.mdl"
ITEM.category = "Security"
ITEM.functions.Place = {
	onRun = function(item)
		local data = {}
		data.start = item.player:GetShootPos()
		data.endpos = data.start + item.player:GetAimVector()*128
		data.filter = item.player
        entity = scripted_ents.Get("nut_padlock"):SpawnFunction(item.player, util.TraceLine(data))
		
		if (IsValid(entity)) then
			item.player:EmitSound("buttons/lever7.wav", 100, 90)
            local character = item.player:getChar()
            local characterName = character:getName()
            local group = character:getData("CharacterGroup", nil)
            entity.PadlockOwner = characterName
            if(group  == nil) then
                entity.CharacterGroup = characterName
            else
                entity.CharacterGroup = group
            end
            entity.SaveData()
		else
			return false
		end
	end
}