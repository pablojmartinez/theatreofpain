PLUGIN.name = "Items Cleanup"
PLUGIN.author = "Pablo J. Martínez"
PLUGIN.desc = "Allows cleaning items from the map."

nut.command.add("cleanallitemsfromthemap", {
	adminOnly = true,
	syntax = "",
	onRun = function(client, arguments)
		for k, v in pairs(ents.FindByClass("nut_item")) do
            if(v.nutItemID) then
			    v:Remove()
            end
		end
	end
})