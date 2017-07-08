--[[
	© 2015 Novabox.org do not share, re-distribute or modify
	without permission of its author (dragonfabledonnny@gmail.com).
--]]

-- The 'nice' name of the faction.
FACTION.name = "Survivor"
-- This faction is default by the server.
-- This faction does not requires a whitelist.
FACTION.isDefault = true
-- A description used in tooltips in various menus.
FACTION.desc = "An average citizen that managed to survive the initial outbreak of the disease."
-- A color to distinguish factions from others, used for stuff such as
-- name color in OOC chat.
FACTION.color = Color(20, 150, 15)
-- The list of models of the citizens.
-- Only default citizen can wear Advanced Citizen Wears and new facemaps.
FACTION.models = {
	"models/humans/group02/tale_01.mdl",
	"models/humans/group02/tale_03.mdl",
	"models/humans/group02/tale_04.mdl",
	"models/humans/group02/tale_05.mdl",
	"models/humans/group02/tale_06.mdl",
	"models/humans/group02/tale_07.mdl",
	"models/humans/group02/tale_08.mdl",
	"models/humans/group02/tale_09.mdl",
    --[["models/half-dead/civilians/male_01.mdl",
    "models/half-dead/civilians/male_02.mdl",
    "models/half-dead/civilians/male_03.mdl",
    "models/half-dead/civilians/male_04.mdl",
    "models/half-dead/civilians/male_05.mdl",
    "models/half-dead/civilians/male_06.mdl",
    "models/half-dead/civilians/male_07.mdl",
    "models/half-dead/civilians/male_08.mdl",
    "models/half-dead/civilians/male_09.mdl",--]]
    "models/humans/office1/male_01.mdl",
    "models/humans/office1/male_02.mdl",
    "models/humans/office1/male_03.mdl",
    "models/humans/office1/male_04.mdl",
    "models/humans/office1/male_05.mdl",
    "models/humans/office1/male_06.mdl",
    "models/humans/office1/male_07.mdl",
    "models/humans/office1/male_08.mdl",
    "models/humans/office1/male_09.mdl",
    "models/half-dead/metrollfix/a1b1.mdl",
    "models/half-dead/metrollfix/a2b1.mdl",
    "models/half-dead/metrollfix/a3b1.mdl",
    "models/half-dead/metrollfix/a4b1.mdl",
    "models/half-dead/metrollfix/a5b1.mdl",
    "models/half-dead/metrollfix/a6b1.mdl",
    "models/half-dead/metrollfix/m1b1.mdl",
    "models/half-dead/metrollfix/m2b1.mdl",
    "models/half-dead/metrollfix/m3b1.mdl",
    "models/half-dead/metrollfix/m4b1.mdl",
    "models/half-dead/metrollfix/m5b1.mdl",
    "models/half-dead/metrollfix/m6b1.mdl",
    "models/half-dead/metrollfix/m7b1.mdl",
    "models/half-dead/metrollfix/m8b1.mdl",
    "models/half-dead/metrollfix/m9b1.mdl",
	"models/humans/group02/temale_01.mdl",
	"models/humans/group02/temale_02.mdl",
	"models/humans/group02/temale_07.mdl",
    --[["models/half-dead/civilians/female_01.mdl",
    "models/half-dead/civilians/female_02.mdl",
    "models/half-dead/civilians/female_03.mdl",
    "models/half-dead/civilians/female_04.mdl",
    "models/half-dead/civilians/female_06.mdl",
    "models/half-dead/civilians/female_07.mdl",--]]
    "models/humans/office1/female_01.mdl",
    "models/humans/office1/female_02.mdl",
    "models/humans/office1/female_03.mdl",
    "models/humans/office1/female_04.mdl",
    "models/humans/office1/female_06.mdl",
    "models/humans/office1/female_07.mdl",
    "models/half-dead/metrollfix/f1b1.mdl",
    "models/half-dead/metrollfix/f2b1.mdl",
    "models/half-dead/metrollfix/f3b1.mdl",
    "models/half-dead/metrollfix/f4b1.mdl",
    "models/half-dead/metrollfix/f6b1.mdl",
    "models/half-dead/metrollfix/f7b1.mdl"
}
-- The amount of money citizens get.
-- FACTION.index is defined when the faction is registered and is just a numeric ID.
-- Here, we create a global variable for easier reference to the ID.
FACTION_SURVIVOR = FACTION.index