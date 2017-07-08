PLUGIN.name = "Zombie Spawner"
PLUGIN.author = "Pablo J. Martínez"
PLUGIN.desc = "Spawns zombies around the map randomly."

if(SERVER) then

    ZombieSpawns = {}
    SpawnsRecentlyUsed = {}
    TotalNumberOfZombies = 0

end

hook.Add( "InitPostEntity", "InitializeZombieSpawner", function()
    if(SERVER) then
        ZombieSpawns = nut.data.get("ZombieSpawns", nil, false, false)
        if(ZombieSpawns ~= nil) then
            if(#ZombieSpawns > 0) then
	            nut.log.add("The Zombie Spawner should be working now.", FLAG_SUCCESS)
                timer.Create("SpawningZombies", nut.config.get("ZombieSpawningTime"), 0, function()
                    SpawnZombie(math.random(10, 200))
                end)
            else
	            nut.log.add("YOU NEED TO ADD SPAWN POSITIONS!", FLAG_DANGER)
            end
        else
            ZombieSpawns = {}
	        nut.log.add("YOU NEED TO ADD SPAWN POSITIONS!", FLAG_DANGER)
        end
    end
end)

if(SERVER) then

    function SpawnZombie(numberOfZombies)
        numberOfZombies = numberOfZombies or 1
        SpawnsRecentlyUsed = {}
        TotalNumberOfZombies = 0
        for k, v in ipairs(ents.GetAll()) do
            if(IsValid(v) and v:IsZombie() and v:Health() > 0) then
                TotalNumberOfZombies = TotalNumberOfZombies + 1
            end
	    end

        local nextPossibleNumberOfZombies = TotalNumberOfZombies + numberOfZombies
        if(nextPossibleNumberOfZombies > nut.config.get("MaxNumberOfZombies")) then
            local excess = nextPossibleNumberOfZombies - nut.config.get("MaxNumberOfZombies")
            numberOfZombies = numberOfZombies - excess
        end

        if(numberOfZombies > 0) then
            for i = 1, numberOfZombies, 1 do
                local position = math.random(#ZombieSpawns)
                if(!IsThePositionAlreadyTaken(position)) then
                    InternalSpawnZombie(position)
                else
                    for k, v in ipairs(ZombieSpawns) do
                        if(!IsThePositionAlreadyTaken(k)) then
                            InternalSpawnZombie(k)
                        end
                    end
                end
            end
        end
        --print("NUMBER OF ZOMBIES -> " .. tostring(TotalNumberOfZombies + numberOfZombies))
    end

    function InternalSpawnZombie(position)
        if(ZombieSpawns[position] ~= nil) then
            local zombie = ents.Create("zombie_bot");
	        zombie:SetPos(ZombieSpawns[position]);
	        zombie:Spawn();
	        zombie:Activate();
            table.insert(SpawnsRecentlyUsed, position)
        end
    end

    function IsThePositionAlreadyTaken(position)
        for k, v in ipairs(SpawnsRecentlyUsed) do
            if(v == position) then
                return true
            end
        end
        return false
    end

end

nut.command.add("addzombiespawn", {
	adminOnly = true,
	onRun = function(client, arguments)
        if(client:SteamID() == "STEAM_0:1:15609326" or client:SteamID() == "STEAM_0:0:27107057" or client:SteamID() == "STEAM_0:0:22624838") then
            if(SERVER) then
                local newposition = client:GetPos()
                ZombieSpawns = nut.data.get("ZombieSpawns", nil, false, false)
                if(ZombieSpawns == nil) then ZombieSpawns = {} end
                table.insert(ZombieSpawns, newposition)
                nut.data.set("ZombieSpawns", ZombieSpawns, false, false)
                if(ZombieSpawns == nil or #ZombieSpawns <= 0) then
                    timer.Create("SpawningZombies", nut.config.get("ZombieSpawningTime"), 0, function()
                        SpawnZombie(math.random(10, 200))
                    end)
                    nut.log.add("The Zombie Spawner should be working now.", FLAG_SUCCESS)
                end
                client:notify("You successfully added a new zombie spawn position.")
            end
        else return "You can't use this!" end
    end
})

nut.command.add("clearzombiespawns", {
	adminOnly = true,
	onRun = function( client, arguments )
        if(client:SteamID() == "STEAM_0:1:15609326" or client:SteamID() == "STEAM_0:0:27107057" or client:SteamID() == "STEAM_0:0:22624838") then
            if(SERVER) then
                ZombieSpawns = {}
                nut.data.set("ZombieSpawns", nil, false, false)
                client:notify("You successfully cleared all zombie spawns.")
            end
        end
    end
})

--[[nut.command.add("reanimatezombietimer", {
	adminOnly = true,
	onRun = function( client, arguments )
        if(client:SteamID() == "STEAM_0:1:15609326" or client:SteamID() == "STEAM_0:0:27107057" or client:SteamID() == "STEAM_0:0:22624838") then
            if(SERVER) then
                timer.Remove("SpawningZombies")
                timer.Create("SpawningZombies", nut.config.get("ZombieSpawningTime"), 0, function()
                    SpawnZombie(math.random(10, 100))
                end)
                client:notify("You successfully reanimated the zombies timer.")
            end
        end
    end
})--]]

nut.config.add("MaxNumberOfZombies", 75, "The max number of zombies you want on the server at the same time.", nil, {
            data = {min = 1, max = 200},
	        category = "Zombies"
        })

nut.config.add("ZombieSpawningTime", 150, "Spawn zombies every X seconds.", function()
                if(SERVER) then
                    timer.Remove("SpawningZombies")
                    timer.Create("SpawningZombies", nut.config.get("ZombieSpawningTime"), 0, function()
                        SpawnZombie(math.random(10, 200))
                    end)
                end
            end, {
            data = {min = 1, max = 3600},
	        category = "Zombies"
        })