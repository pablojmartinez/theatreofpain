--[[ *************************************************************************************************************************************************************************** --]]
--[[	Developed by Pablo J. Martínez (2016). You are free to use this and my plugins as long as you credit me. Thanks ^_^                                                                                      
--[[ *************************************************************************************************************************************************************************** --]]

HasThePlayerDiedRecently = {}



function SCHEMA:PlayerSpawnSENT(player, class)
	if (player:getChar() and player:getChar():hasFlags("E")) then
		return true
	end

	return false
end

function SCHEMA:PlayerGiveSWEP(player, weapon, swep)
	if (player:getChar() and player:getChar():hasFlags("w")) then
		return true
	end

	return false
end

function SCHEMA:PlayerSpawnSWEP(player, weapon, swep)
	if (player:getChar() and player:getChar():hasFlags("w")) then
		return true
	end

	return false
end

function SCHEMA:OnCharCreated(client, character)
	local inventory = character:getInv()
	if(inventory) then
		inventory:add("Reich Identity", 1, {
			name = character:getName(),
			id = math.random(10000, 99999)
		})
	end
end

function SCHEMA:PlayerDeath(victim, inflictor, attacker)
    local character = victim:getChar()
    if(character ~= nil) then
        victim:GetRagdollEntity():Remove()
        local entity = ents.Create("prop_ragdoll")
		entity:SetPos(victim:GetPos())
		entity:SetAngles(victim:EyeAngles())
		entity:SetModel(victim:GetModel())
		entity:SetSkin(victim:GetSkin())
		entity:Spawn()
		entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		entity:Activate()
        --character:setData("banned", true)
        character:save()
        character:setData("pos", nil)
        for k, v in pairs(character:getInv():getItems()) do
            for key, value in ipairs(victim:GetWeapons()) do
                if(v.class == value:GetClass()) then
                    v:setData("ammo", victim:GetAmmoCount(value:GetPrimaryAmmoType()))
		            v:setData("ammo1", value:Clip1())
		            v:setData("ammo2", value:Clip2())
                end
            end
	    end
        timer.Simple(10, function()
            character:kick()              
        end)
    end
end

hook.Add("AcceptInput","IsDoorBeingUsed", function(entity, input, activator, caller, value)
    if(IsValid(entity) and input == "Use") then
        local entityClass = entity:GetClass()
        if(entityClass == "prop_door_rotating") then
            if(entity.IsDoorOpen == nil) then
                entity.IsDoorOpen = true -- Presumes that the doors are closed by default, this is called after it has been opened
                entity.InitialAngle = entity:GetAngles()
            end
            if(entity.InitialAngle == entity:GetAngles()) then
                entity.IsDoorOpen = true
            else
                entity.IsDoorOpen = false
            end
            entity.LastPlayerThatOpenedTheDoor = activator
            --print("Is Door Open? "..tostring(entity.IsDoorOpen).. " ACTIVATOR -> "..tostring(activator).. " CALLER -> "..tostring(caller).. " VALUE -> "..tostring(value))
        end
    end
end)

hook.Add( "Think", "OpeningCombineDoors", function()
	for k, v in pairs(player.GetHumans()) do
		if(v:KeyPressed(IN_USE)) then
			local trace = v:GetEyeTrace()
			if(trace.Entity and trace.Entity:IsValid() and (trace.Entity:GetClass() == "func_door" or trace.Entity:GetClass() == "func_door_rotating")) then
                if(v:getChar():hasFlags("d")) then
				    trace.Entity:Fire("Open")
                end
			end
		end
	end
end)


--[[function SpawnRagdollForEntity(entity)
    if(IsValid(entity) and entity:IsPlayer() or entity:IsNPC()) then
        local ragdoll = ents.Create("prop_ragdoll")
	    ragdoll:SetPos(entity:GetPos())
	    ragdoll:SetAngles(entity:EyeAngles())
	    ragdoll:SetModel(entity:GetModel())
	    ragdoll:SetSkin(entity:GetSkin())
	    ragdoll:Spawn()
	    ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	    ragdoll:Activate()
    end
end--]]


-- By Pablo J. Martínez. Overrides charChoose hook for the Schema
-- Networking information here.
--[[do
	if (SERVER) then
		netstream.Hook("charChoose", function(client, id)
			if (client:getChar() and client:getChar():getID() == id) then
				netstream.Start(client, "charLoaded")
				
				return client:notifyLocalized("usingChar")
			end

			local character = nut.char.loaded[id]

			if (character and character:getPlayer() == client) then
				local status, result = hook.Run("CanPlayerUseChar", client, character)

				if (status == false) then
					if (result) then
						if (result:sub(1, 1) == "@") then
							client:notifyLocalized(result:sub(2))
						else
							client:notify(result)
						end
					end

					netstream.Start(client, "charMenu")

					return
				end

				local currentChar = client:getChar()

				if (currentChar) then
					currentChar:save()
				end
                
                nut.log.add(string.format("SE HA ELEGIDO A UN PUTO CHARACTER JAJAJAJA DIOSSS -> %s", tostring(client)))
				character:setup()
				client:Spawn()

                if(HasThePlayerDiedRecently[client] == true) then
                    -- This prevents the bug of the camera being frozen after dying
                    --client.nutRagdoll.nutIgnoreDelete = true
	                client.nutRagdoll:Remove()
		            client:setLocalVar("blur", nil)
                    HasThePlayerDiedRecently[client] = nil
                end

				hook.Run("PlayerLoadedChar", client, character, currentChar)
			else
				ErrorNoHalt("[NutScript] Attempt to load invalid character '"..id.."'\n")
			end
		end)
    end
end--]]