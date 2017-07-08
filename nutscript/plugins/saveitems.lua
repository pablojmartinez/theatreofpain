PLUGIN.name = "Save Items"
PLUGIN.author = "Chessnut - Modified by Pablo J. Martínez"
PLUGIN.desc = "Saves items that were dropped."

local PLUGIN = PLUGIN

hook.Add( "InitPostEntity", "LoadDroppedItems", function()
    if(SERVER) then
        timer.Simple(5, function()
            PLUGIN:LoadItems()
            print("Items loaded")
        end)
    end
end)

if(SERVER) then -- Pablo J. Martínez

    function PLUGIN:ShouldCleanDataItems()
	    -- We will handle the cleansing of items ourselves.
	    return false
    end

    function PLUGIN:LoadItems()
	    local items = self:getData()

	    if (items) then
		    local idRange = {}
		    local positions = {}

		    for k, v in ipairs(items) do
			    idRange[#idRange + 1] = v[1]
			    positions[v[1]] = v[2]
		    end

		    if (#idRange > 0) then
			    local range = "("..table.concat(idRange, ", ")..")"

			    nut.db.query("SELECT _itemID, _uniqueID, _data FROM nut_items WHERE _itemID IN "..range, function(data)
				    if (data) then
					    for k, v in ipairs(data) do
						    local itemID = tonumber(v._itemID)
						    local data = util.JSONToTable(v._data or "[]")
						    local uniqueID = v._uniqueID
						    local itemTable = nut.item.list[uniqueID]
						    local position = positions[itemID]

						    if (itemTable and itemID) then
							    local position = positions[itemID]
							    local item = nut.item.new(uniqueID, itemID)
							    item.data = data or {}
							    local spawnedItem = item:spawn(position)
                                spawnedItem.nutItemID = itemID
                                spawnedItem:SetPos(position + Vector(0, 0, 16))
                                print("IS ON GROUND? -> " .. tostring(spawnedItem:IsOnGround()))
							    item.invID = 0
						    end
					    end
				    end
			    end)
		    end
	    end
    end

    function PLUGIN:SaveData()
	    local items = {}

	    for k, v in ipairs(ents.FindByClass("nut_item")) do
            if(v.nutItemID) then
                local isLoot = nut.item.instances[v.nutItemID]:getData("IsLoot", false)
		        if(isLoot == false) then
			        items[#items + 1] = {v.nutItemID, v:GetPos()}
		        end
            end
	    end

	    self:setData(items)
    end

end