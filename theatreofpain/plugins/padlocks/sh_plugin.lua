PLUGIN.name = "Padlocks"
PLUGIN.author = "Chessnut & Pablo J. Martínez"
PLUGIN.desc = "Adds padlocks to doors. [Requires Pablo J. Martínez's 'Character Groups' plugin]"

if (SERVER) then
	function PLUGIN:SaveData()
		local data = {}

		for k, v in ipairs(ents.FindByClass("nut_padlock")) do
			if (IsValid(v.door)) then
				data[#data + 1] = {v.door:MapCreationID(), v.door:WorldToLocal(v:GetPos()), v.door:WorldToLocalAngles(v:GetAngles()), v:GetLocked() == true and true or nil, v.PadlockOwner, v.CharacterGroup}
			end
		end

		self:setData(data)
	end

	function PLUGIN:LoadData()
		local data = self:getData() or {}

		for k, v in ipairs(data) do
			local door = ents.GetMapCreatedEntity(v[1])

			if (IsValid(door) and door:isDoor()) then
				local entity = ents.Create("nut_padlock")
				entity:SetPos(door:GetPos())
				entity:Spawn()
				entity:setDoor(door, door:LocalToWorld(v[2]), door:LocalToWorldAngles(v[3]))
				entity:SetLocked(v[4])

				if (v[4]) then
					entity:toggle(true)
				end
                entity.PadlockOwner = v[5]
                entity.CharacterGroup = v[6]
			end
		end
	end
end