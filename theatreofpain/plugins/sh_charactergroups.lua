PLUGIN.name = "Character Groups"
PLUGIN.author = "Pablo J. Martínez"
PLUGIN.desc = "Allows to create and join groups in-game without needing the permission of an admin."

nut.command.add("creategroup", {
	adminOnly = false,
	syntax = "",
	onRun = function(client, arguments)
		local character = client:getChar()
        local characterName = character:getName()
        local group = character:getData("CharacterGroup", nil)
        if(group == nil) then
            character:setData("CharacterGroup", characterName)
            character:save()
            client:notify("You have successfully created a group.")
        else
            return "You are already in ".. group .."'s group!"
        end
	end
})

nut.command.add("invitetomygroup", {
	adminOnly = false,
	syntax = "<string name>",
	onRun = function(client, arguments)
		if (!arguments[1]) then
			return L("invalidArg", client, 1)
		end
        local character = client:getChar()
        local characterName = character:getName()
        local group = character:getData("CharacterGroup", nil)
        if(group == nil) then
            return "You are not in a group!"
        elseif(group != characterName) then
            return "You are not the leader of the group!"
        end
        local invitedPlayer = nut.command.findPlayer(client, arguments[1])
        if(IsValid(invitedPlayer)) then
            local invitedPlayerCharacter = invitedPlayer:getChar()
            local invitedPlayerCharacterName = invitedPlayerCharacter:getName()
            local invitedPlayerGroup = invitedPlayerCharacter:getData("CharacterGroup", nil)
            local acceptsGroupInvitations = invitedPlayerCharacter:getData("AcceptsGroupInvitations", false)
            if(invitedPlayerGroup == nil)  then
                if(acceptsGroupInvitations == true) then
                    invitedPlayerCharacter:setData("CharacterGroup", group)
                    invitedPlayerCharacter:save()
                    client:notify(invitedPlayerCharacterName .. " has successfully joined your group.")
                    invitedPlayer:notify("You has successfully joined ".. group .."'s group.")
                else
                    return "The invited player isn't accepting group invitations! He must use /acceptgroupinvitations."
                end
            else
                return "The invited player is already in a group!"
            end
        end
	end
})

nut.command.add("acceptgroupinvitations", {
	adminOnly = false,
	syntax = "",
	onRun = function(client, arguments)
        local character = client:getChar()
        local group = character:getData("CharacterGroup", nil)
        if(group == nil) then
            character:setData("AcceptsGroupInvitations", true)
            character:save()
            client:notify("You are now accepting group invitations.")
            timer.Simple(15, function()
                character:setData("AcceptsGroupInvitations", false)
                character:save()
                client:notify("You are now rejecting group invitations.")
            end)
        else
            return "You are already in ".. group .."'s group!"
        end
	end
})

nut.command.add("leavegroup", {
	adminOnly = false,
	syntax = "",
	onRun = function(client, arguments)
        local character = client:getChar()
        local group = character:getData("CharacterGroup", nil)
        if(group ~= nil) then
            character:setData("CharacterGroup", nil)
            character:save()
            client:notify("You have left ".. group .."'s group.")
        else
            return "You aren't in any group!"
        end
	end
})

nut.command.add("removefromgroup", {
	adminOnly = false,
	syntax = "<string name>",
	onRun = function(client, arguments)
		if (!arguments[1]) then
			return L("invalidArg", client, 1)
		end
        local removedPlayer = nut.command.findPlayer(client, arguments[1])
        if(IsValid(removedPlayer)) then
            local removedPlayerCharacter = removedPlayer:getChar()
            local removedPlayerCharacterName = removedPlayerCharacter:getName()
            local removedPlayerGroup = removedPlayerCharacter:getData("CharacterGroup", nil)
            local character = client:getChar()
            local characterName = character:getName()
            local group = character:getData("CharacterGroup", nil)
            if(client:IsAdmin() == false) then
                if(group == nil) then
                    return "You are not in a group!"
                elseif(characterName != removedPlayerGroup) then
                    return "You are not the leader of his group!"
                end
            end
            removedPlayerCharacter:setData("CharacterGroup", nil)
            removedPlayerCharacter:save()
            removedPlayer:notify("You have been removed from ".. group .."'s group.")
            character:notify("You have successfully removed ".. removedPlayerCharacterName .. " from ".. group .."'s group.")
        end
	end
})