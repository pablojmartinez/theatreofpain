--[[ *************************************************************************************************************************************************************************** --]]
--[[	Developed by Pablo J. Martínez (2016). You are free to use this and my plugins as long as you credit me. Thanks ^_^                                                                                      
--[[ *************************************************************************************************************************************************************************** --]]

hook.Add( "InitPostEntity", "InitializeDestroyableDoors", function()
	timer.Simple(5, function()
        local oldAngles = {}
		for k, v in pairs(ents.GetAll()) do
			if(IsValid(v) and v:GetClass() == "prop_door_rotating") then
                oldAngles[k] = v:GetAngles()
                v:Fire("close", "", 0)
			end
		end
        timer.Simple(5, function()
            for k, v in pairs(ents.GetAll()) do
			    if(IsValid(v) and v:GetClass() == "prop_door_rotating") then
                    if(oldAngles[k] ~= v:GetAngles()) then
                        v.IsDoorOpen = true
                        v:Fire("open", "", 0)
                    else
                        v.IsDoorOpen = false
                    end
			    end
            end
        end)
	end)
end)