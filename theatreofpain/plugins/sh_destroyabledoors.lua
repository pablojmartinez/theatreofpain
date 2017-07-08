PLUGIN.name = "Destroyable Doors"
PLUGIN.author = "Pablo J. Martínez"
PLUGIN.desc = "Allows to destroy doors within certain conditions. Now they can be destroyed with explosives and molotovs too :)"

hook.Add( "InitPostEntity", "InitializeDestroyableDoors", function()
    if(SERVER) then
	    timer.Simple(5, function()
		    for k, v in ipairs(ents.GetAll()) do
			    if(IsValid(v) and v:GetClass() == "prop_door_rotating") then
				    v:SetHealth(nut.config.get("DoorsHealth"))
			    end
		    end
	    end)--[[
        timer.Create("CheckingForExplosionsOnDoors", 1, 0, function()
            for k, v in pairs(ents.GetAll()) do
			    if(IsValid(v) and v:GetClass() == "prop_door_rotating") then
                    
			    end
		    end
        end)--]]
    end
end)

-- It seems that EntityTakeDamage doesn't work for doors so I had to make my own hook
-- You must run this Hook when an entity explodes (grenades, tnt, etc)
-- There is an exception for molotovs
-- hook.Run("OnEntityExplode", self.Entity, self.Owner, self.Entity:GetPos(), radv, 250)
function PLUGIN:OnEntityExplode(inflictor, attacker, damageOrigin, damageRadius, damage)
    if(SERVER) then
        for k, v in ipairs(ents.GetAll()) do
		    if(IsValid(v) and v:GetClass() == "prop_door_rotating" and v.HasBeenBusted == nil or v.HasBeenBusted == false) then
                local doorPos = v:GetPos()
                if(doorPos:DistToSqr(damageOrigin) <= damageRadius * damageRadius) then
                    local inflictorClass = inflictor:GetClass()
                    if(inflictorClass ~= "tfa_nmrih_molly_thrown") then
                        local dir = doorPos - damageOrigin
			            dir:Normalize()
			            local dummyDoor = v:blastDoor(dir * 400, nut.config.get("DoorsLifetime"), true)
                        dummyDoor:Ignite(30, 100)
                        if(IsValid(v.lock)) then
                            v.lock:Remove()
                            v.lock.SaveData()
                        end
                    else
                        v:Ignite(30, 100)
                    end
                end
		    end
	    end
    end
end

if(SERVER) then

 --WeaponsAllowedToDestroyDoors = {}

    hook.Add("EntityTakeDamage","ADoorIsTakingDamage", function(target, damageInfo)
	    if((IsValid(target) and target:isDoor() and target:GetClass() == "prop_door_rotating" and IsValid(target.lock) == false) and (target.HasBeenBusted == nil or target.HasBeenBusted == false)) then
		    local doorhealth = target:Health()
            local attacker = damageInfo:GetAttacker()
		    local dmgtaken = damageInfo:GetDamage()
		    target:SetHealth(doorhealth - dmgtaken)

            --if(!attacker:IsZombie()) then
		        if(target:Health() <= 0 and (!target.phys_door or !IsValid(target.phys_door))) then
                    local dir = target:GetPos() - attacker:GetPos()
			        dir:Normalize()
			        local dummyDoor = target:blastDoor(dir * 400, nut.config.get("DoorsLifetime"), true)
                    target:Fire("unlock", 0)
			        target:Fire("open", 0)
                    target:SetHealth(nut.config.get("DoorsHealth"))

                    if(target:IsOnFire()) then
                        target:Extinguish()
                        dummyDoor:Ignite(30, 100)
                    end

			        -- Who doesnt like a little pyrotechnics eh? (By Exho)
			        target:EmitSound("physics/wood/wood_crate_break3.wav")
			        local effectdata = EffectData()
			        effectdata:SetOrigin(target:GetPos() + target:OBBCenter())
			        effectdata:SetMagnitude(5)
			        effectdata:SetScale(2)
			        effectdata:SetRadius(5)
			        util.Effect("Sparks", effectdata)
		        end
            --end
	    end
    end)

end

nut.config.add("DoorsHealth", 300, "How much damage can the doors handle before being busted.", nil, {
                data = {min = 1, max = 300},
	            category = "Destroyable Doors"
            })

nut.config.add("DoorsLifetime", 3600, "How much time it takes for the door to get back to its original position (in seconds).", nil, {
    data = {min = 1, max = 3600},
	category = "Destroyable Doors"
})