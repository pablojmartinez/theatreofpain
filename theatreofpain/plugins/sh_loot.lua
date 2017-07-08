PLUGIN.name = "Loot"
PLUGIN.author = "Pablo J. Martínez"
PLUGIN.desc = "A loot system which keeps spawning certain items around the map randomly."

if(SERVER) then

    Food = {}
    HealthItems = {}
    MeleeWeapons = {}
    Firearms = {}
    Ammunition = {}
    Explosives = {}
    Padlock = nil
    InfectionCure = nil
    Unique = {}
    LootPositions = {}
    CurrentNumberOfLootItems = 0
    HasTheLootJustStarted = true

end

hook.Add( "InitPostEntity", "InitializeLootSystem", function()
    if(SERVER) then
        HasTheLootJustStarted = true
        for k, v in pairs(nut.item.list) do
            if(v.category == "Food") then
                table.insert(Food, v)
                print("Food: " .. v.name)
            elseif(v.category == "Health") then
                table.insert(HealthItems, v)
                print("Health Item: " .. v.name)
            elseif(v.weaponCategory == "melee") then
                if(v.isUnique == nil) then
                    table.insert(MeleeWeapons, v)
                    print("Melee: " .. v.name)
                end
            elseif(v.weaponCategory == "firearm") then
                table.insert(Firearms, v)
                print("Firearm: " .. v.name)
            elseif(v.weaponCategory == "explosive") then
                table.insert(Explosives, v)
                print("Explosive: " .. v.name)
            elseif(v.category == "Ammunition") then
                table.insert(Ammunition, v)
                print("Ammunition: " .. v.name)
            elseif(v.isUnique == true) then
                table.insert(Unique, v)
                print("Unique: " .. v.name)
            elseif(v.name == "Padlock") then
                Padlock = v
                print(v.name)
            elseif(v.name == "Infection Cure") then
                InfectionCure = v
                print(v.name)
            end
        end
        timer.Simple(10, function()
            LootPositions = nut.data.get("LootPositions", nil, false, false)
            if(LootPositions ~= nil) then
                if(#LootPositions > 0) then
	                nut.log.add("Loot should be working now.", FLAG_SUCCESS)
                    for i = 1, nut.config.get("AmountOfInitialLootSpawns"), 1 do
                        SpawnLootItem()
                    end
                    HasTheLootJustStarted = false
                    timer.Create("SpawningLootItems", nut.config.get("LootSpawningTime"), 0, SpawnLootItem)
                else
	                nut.log.add("YOU NEED TO ADD LOOT SPAWNS IF YOU WANT WORKING LOOTING!", FLAG_DANGER)
                end
            else
                LootPositions = {}
                nut.log.add("YOU NEED TO ADD LOOT SPAWNS IF YOU WANT WORKING LOOTING!", FLAG_DANGER)
            end
        end)
    end
end)



function SpawnLootItem()
    if(SERVER) then
        --print("CURRENT NUMBER OF PLAYERS ONLINE -> " .. tostring(#player.GetHumans()))
        CurrentNumberOfLootItems = 0
        for k, v in ipairs(ents.FindByClass("nut_item")) do
            if(v.nutItemID) then
                local isLoot = nut.item.instances[v.nutItemID]:getData("IsLoot", false)
		        if(isLoot) then
			        CurrentNumberOfLootItems = CurrentNumberOfLootItems + 1
		        end
            end
	    end
        if(#player.GetHumans() > 0 or HasTheLootJustStarted == true) then
            if(CurrentNumberOfLootItems < nut.config.get("MaxNumberOfLootItems")) then
                if(math.random() <= (1 / nut.config.get("FoodChance"))) then
                    local item = Food[math.random(#Food)]
                    if(item ~= nil) then
                        InternalSpawnLootItem(item.uniqueID)
                    end
                end
                if(math.random() <= (1 / nut.config.get("HealthItemsChance"))) then
                    local item = HealthItems[math.random(#HealthItems)]
                    if(item ~= nil) then
                        InternalSpawnLootItem(item.uniqueID)
                    end
                end
                if(math.random() <= (1 / nut.config.get("InfectionCureChance"))) then
                    if(InfectionCure ~= nil) then
                        InternalSpawnLootItem(InfectionCure.uniqueID)
                    end
                end
                if(math.random() <= (1 / nut.config.get("PadlockChance"))) then
                    if(Padlock ~= nil) then
                        InternalSpawnLootItem(Padlock.uniqueID)
                    end
                end
                if(math.random() <= (1 / nut.config.get("FirearmsChance"))) then
                    local item = Firearms[math.random(#Firearms)]
                    if(item ~= nil) then
                        InternalSpawnLootItem(item.uniqueID)
                    end
                end
                if(math.random() <= (1 / nut.config.get("MeleeWeaponsChance"))) then
                    local item = MeleeWeapons[math.random(#MeleeWeapons)]
                    if(item ~= nil) then
                        InternalSpawnLootItem(item.uniqueID)
                    end
                end
                if(math.random() <= (1 / nut.config.get("AmmunitionChance"))) then
                    local item = Ammunition[math.random(#Ammunition)]
                    if(item ~= nil) then
                        InternalSpawnLootItem(item.uniqueID)
                    end
                end
                if(math.random() <= (1 / nut.config.get("UniqueChance"))) then
                    local item = Unique[math.random(#Unique)]
                    if(item ~= nil) then
                        InternalSpawnLootItem(item.uniqueID)
                    end
                end
                if(math.random() <= (1 / nut.config.get("ExplosivesChance"))) then
                    local item = Explosives[math.random(#Explosives)]
                    if(item ~= nil) then
                        InternalSpawnLootItem(item.uniqueID)
                    end
                end
            end
        end
        --print("NUMBER OF LOOT ITEMS: " .. CurrentNumberOfLootItems)
    end
end

function InternalSpawnLootItem(itemUniqueID)
    local position = LootPositions[math.random(#LootPositions)] + Vector(0, 0, 16)
    nut.item.spawn(itemUniqueID, position, function(thisItem, entity)
        thisItem:setData("IsLoot", true)
    end)
    CurrentNumberOfLootItems = CurrentNumberOfLootItems + 1
end

function FindItemIdByName(itemName)
    local uniqueID = itemName:lower()

	if(!nut.item.list[uniqueID]) then
	    for k, v in SortedPairs(nut.item.list) do
			if (nut.util.stringMatches(v.name, uniqueID)) then
				uniqueID = k
				break
			end
		end
	end
    return uniqueID
end

nut.command.add("addlootposition", {
	adminOnly = true,
	onRun = function(client, arguments)
        if(client:SteamID() == "STEAM_0:1:15609326" or client:SteamID() == "STEAM_0:0:27107057" or client:SteamID() == "STEAM_0:0:22624838") then
            if(SERVER) then
                local newposition = client:GetPos()
                LootPositions = nut.data.get("LootPositions", nil, false, false)
                if(LootPositions == nil) then LootPositions = {} end
                table.insert(LootPositions, newposition)
                nut.data.set("LootPositions", LootPositions, false, false)
                if(LootPositions == nil or #LootPositions <= 0) then
                    timer.Create("SpawningLootItems", nut.config.get("LootSpawningTime"), 0, SpawnLootItem)
                    nut.log.add("Loot should be working now.", FLAG_SUCCESS)
                end
                client:notify("You successfully added a new loot position.")
            end
        else return "You can't use this!" end
    end
})


nut.command.add("clearlootpositions", {
	adminOnly = true,
	onRun = function( client, arguments )
        if(client:SteamID() == "STEAM_0:1:15609326" or client:SteamID() == "STEAM_0:0:27107057" or client:SteamID() == "STEAM_0:0:22624838") then
            if(SERVER) then
                LootPositions = {}
                nut.data.set("LootPositions", nil, false, false)
                client:notify("You successfully cleared all loot positions.")
            end
        end
    end
})

nut.command.add("reanimateloottimer", {
	adminOnly = true,
	onRun = function( client, arguments )
        if(client:SteamID() == "STEAM_0:1:15609326" or client:SteamID() == "STEAM_0:0:27107057" or client:SteamID() == "STEAM_0:0:22624838") then
            if(SERVER) then
                Food = {}
                HealthItems = {}
                MeleeWeapons = {}
                Firearms = {}
                Ammunition = {}
                Explosives = {}
                Padlock = nil
                InfectionCure = nil
                Unique = {}
                LootPositions = nut.data.get("LootPositions", nil, false, false)
                for k, v in pairs(nut.item.list) do
                    if(v.category == "Food") then
                        table.insert(Food, v)
                        print("Food: " .. v.name)
                    elseif(v.category == "Health") then
                        table.insert(HealthItems, v)
                        print("Health Item: " .. v.name)
                    elseif(v.weaponCategory == "melee") then
                        if(v.isUnique == nil) then
                            table.insert(MeleeWeapons, v)
                            print("Melee: " .. v.name)
                        end
                    elseif(v.weaponCategory == "firearm") then
                        table.insert(Firearms, v)
                        print("Firearm: " .. v.name)
                    elseif(v.weaponCategory == "explosive") then
                        table.insert(Explosives, v)
                        print("Explosive: " .. v.name)
                    elseif(v.category == "Ammunition") then
                        table.insert(Ammunition, v)
                        print("Ammunition: " .. v.name)
                    elseif(v.isUnique == true) then
                        table.insert(Unique, v)
                        print("Unique: " .. v.name)
                    elseif(v.name == "Padlock") then
                        Padlock = v
                        print(v.name)
                    elseif(v.name == "Infection Cure") then
                        InfectionCure = v
                        print(v.name)
                    end
                end
                client:notify("You successfully reanimated the loot timer.")
            end
        end
    end
})

nut.config.add("MaxNumberOfLootItems", 25, "The max number of loot items that you want on the map at the same time.", nil, {
            data = {min = 1, max = 200},
	        category = "Loot System"
        })

nut.config.add("AmountOfInitialLootSpawns", 10, "The amount of loot spawns you want to trigger when the server starts.", nil, {
            data = {min = 1, max = 25},
	        category = "Loot System"
        })

nut.config.add("LootSpawningTime", 150, "Spawn loot items every X seconds.", function()
                if(SERVER) then
                    timer.Remove("SpawningLootItems")
                    timer.Create("SpawningLootItems", nut.config.get("LootSpawningTime"), 0, SpawnLootItem)
                end
            end, {
            data = {min = 1, max = 3600},
	        category = "Loot System"
        })

nut.config.add("FoodChance", 1, "For example: if you set this to 100, it means that it'll spawn approximately one of this kind of item every 100 spawns.", nil, {
            data = {min = 1, max = 1000000},
	        category = "Loot System"
        })

nut.config.add("HealthItemsChance", 20, "For example: if you set this to 100, it means that it'll spawn approximately one of this kind of item every 100 spawns.", nil, {
            data = {min = 1, max = 1000000},
	        category = "Loot System"
        })

nut.config.add("InfectionCureChance", 20, "For example: if you set this to 100, it means that it'll spawn approximately one of this kind of item every 100 spawns.", nil, {
            data = {min = 1, max = 1000000},
	        category = "Loot System"
        })

nut.config.add("PadlockChance", 100, "For example: if you set this to 100, it means that it'll spawn approximately one of this kind of item every 100 spawns.", nil, {
            data = {min = 1, max = 1000000},
	        category = "Loot System"
        })

nut.config.add("MeleeWeaponsChance", 30, "For example: if you set this to 100, it means that it'll spawn approximately one of this kind of item every 100 spawns.", nil, {
            data = {min = 1, max = 1000000},
	        category = "Loot System"
        })

nut.config.add("FirearmsChance", 50, "For example: if you set this to 100, it means that it'll spawn approximately one of this kind of item every 100 spawns.", nil, {
            data = {min = 1, max = 1000000},
	        category = "Loot System"
        })

nut.config.add("AmmunitionChance", 60, "For example: if you set this to 100, it means that it'll spawn approximately one of this kind of item every 100 spawns.", nil, {
            data = {min = 1, max = 1000000},
	        category = "Loot System"
        })

nut.config.add("UniqueChance", 500, "For example: if you set this to 100, it means that it'll spawn approximately one of this kind of item every 100 spawns.", nil, {
            data = {min = 1, max = 1000000},
	        category = "Loot System"
        })

nut.config.add("ExplosivesChance", 500, "For example: if you set this to 100, it means that it'll spawn approximately one of this kind of item every 100 spawns.", nil, {
            data = {min = 1, max = 1000000},
	        category = "Loot System"
        })