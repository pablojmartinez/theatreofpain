-- Modified by Pablo J. Martínez
ITEM.name = "Weapon"
ITEM.desc = "A Weapon."
ITEM.category = "Weapons"
ITEM.model = "models/weapons/w_pistol.mdl"
ITEM.class = "weapon_pistol"
ITEM.width = 2
ITEM.height = 2
ITEM.isWeapon = true
ITEM.weaponCategory = "sidearm"

-- Inventory drawing
if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		if (item:getData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end
end

-- On item is dropped, Remove a weapon from the player and keep the ammo in the item.
ITEM:hook("drop", function(item)

    if(SERVER) then -- Pablo J. Martínez
        if(item.player:FlashlightIsOn() and item.uniqueID == "maglite") then
			item.player:Flashlight(false)
        end
    end

	if(item:getData("equip")) then -- Pablo J. Martínez: 'WARNING: Don't allow players to drop when the item is equipped'
        return false
    end

	item.player.carryWeapons = item.player.carryWeapons or {}

	local weapon = item.player.carryWeapons[item.weaponCategory]

	if (IsValid(weapon)) then
		item:setData("ammo", item.player:GetAmmoCount(weapon:GetPrimaryAmmoType())) -- Pablo J. Martínez
		item:setData("ammo1", weapon:Clip1())
		item:setData("ammo2", weapon:Clip2()) -- Pablo J. Martínez

		item.player:StripWeapon(item.class)
		item.player.carryWeapons[item.weaponCategory] = nil
		item.player:EmitSound("items/ammo_pickup.wav", 80)
	end
	item:setData("equip", nil)
end)

-- On player uneqipped the item, Removes a weapon from the player and keep the ammo in the item.
ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cross.png",
	onRun = function(item)
		item.player.carryWeapons = item.player.carryWeapons or {}

		local weapon = item.player.carryWeapons[item.weaponCategory]

		if (!weapon or !IsValid(weapon)) then
			weapon = item.player:GetWeapon(item.class)	
		end

        item.player:EmitSound("items/ammo_pickup.wav", 80)
		item.player.carryWeapons[item.weaponCategory] = nil

		item:setData("equip", nil)

		if (weapon and weapon:IsValid()) then

			item:setData("ammo", item.player:GetAmmoCount(weapon:GetPrimaryAmmoType())) -- Pablo J. Martínez
			item:setData("ammo1", weapon:Clip1())
			item:setData("ammo2", weapon:Clip2()) -- Pablo J. Martínez
		
			item.player:StripWeapon(item.class)
		else
            if(item.weaponCategory == "explosive" or item.weaponCategory == "infectioncure") then -- Pablo J. Martínez
                item.player.carryWeapons[item.weaponCategory] = nil
                return true
            end
			print(Format("[Nutscript] Weapon %s does not exist!", item.class))
		end
		
		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:getData("equip") == true)
	end
}

-- On player eqipped the item, Gives a weapon to player and load the ammo data from the item.
ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/tick.png",
	onRun = function(item)
		local client = item.player
		local items = client:getChar():getInv():getItems()

		client.carryWeapons = client.carryWeapons or {}

        if(item.weaponCategory == "explosive" or item.weaponCategory == "infectioncure") then -- Pablo J. Martínez
            for k, v in ipairs(client:GetWeapons()) do
                if(v:GetClass() == item.class) then
		            client:notify("You're already equipping this kind of weapon")
		            return false
                end
            end
        end

		for k, v in pairs(items) do
			if (v.id != item.id) then
				local itemTable = nut.item.instances[v.id]

                if(itemTable.isWeapon and client.carryWeapons[item.weaponCategory] and itemTable:getData("equip")) then
					client:notify("You're already equipping this kind of weapon")

					return false
				end
			end
		end
		
		if (client:HasWeapon(item.class)) then
			client:StripWeapon(item.class)
		end

        nut.chat.send(client, nut.config.get("AutoDelayChatType"), nut.config.get("AutoDelayMessage"))
        timer.Simple(nut.config.get("AutoDelayTime"), function()

		    local weapon = client:Give(item.class)

		    if (IsValid(weapon)) then
                client.carryWeapons[item.weaponCategory] = weapon
			    client:SelectWeapon(weapon:GetClass())
			    client:SetActiveWeapon(weapon)
			    client:EmitSound("items/ammo_pickup.wav", 80)

			    -- Remove default given ammo.
			    if (client:GetAmmoCount(weapon:GetPrimaryAmmoType()) == weapon:Clip1() and item:getData("ammo1", 0) == 0) then
				    client:RemoveAmmo(weapon:Clip1(), weapon:GetPrimaryAmmoType())
			    end
                if (client:GetAmmoCount(weapon:GetPrimaryAmmoType()) == weapon:Clip2() and item:getData("ammo2", 0) == 0) then -- Pablo J. Martínez
				    client:RemoveAmmo(weapon:Clip2(), weapon:GetPrimaryAmmoType())
			    end

			    item:setData("equip", true)

                local ammo = 0
                if(item.weaponCategory == "explosive") then -- Pablo J. Martínez
			        ammo = 1
                else
			        ammo = item:getData("ammo", 0)
                end
                client:SetAmmo(ammo, weapon:GetPrimaryAmmoType()) -- Pablo J. Martínez
			    weapon:SetClip1(item:getData("ammo1", 0))
			    weapon:SetClip2(item:getData("ammo2", 0)) -- Pablo J. Martínez
		    else
			    print(Format("[Nutscript] Weapon %s does not exist!", item.class))
		    end

        end)

		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:getData("equip") != true)
	end
}

function ITEM:onCanBeTransfered(oldInventory, newInventory)
	if (newInventory and self:getData("equip")) then
		return newInventory:getID() == 0
	end

	return true
end

function ITEM:onLoadout()
	if (self:getData("equip")) then
		local client = self.player
		client.carryWeapons = client.carryWeapons or {}

		local weapon = client:Give(self.class)

		if (IsValid(weapon)) then
			client:RemoveAmmo(weapon:Clip1(), weapon:GetPrimaryAmmoType())
			client:RemoveAmmo(weapon:Clip2(), weapon:GetPrimaryAmmoType()) -- Pablo J. Martínez
			client.carryWeapons[self.weaponCategory] = weapon

            if(self.weaponCategory == "explosive") then -- Pablo J. Martínez
			    client:SetAmmo(1, weapon:GetPrimaryAmmoType()) -- Pablo J. Martínez
            else
			    client:SetAmmo(self:getData("ammo", 0), weapon:GetPrimaryAmmoType()) -- Pablo J. Martínez
            end
			weapon:SetClip1(self:getData("ammo1", 0))
			weapon:SetClip2(self:getData("ammo2", 0)) -- Pablo J. Martínez
		else
			print(Format("[Nutscript] Weapon %s does not exist!", self.class))
		end
	end
end

function ITEM:onSave()
	local weapon = self.player:GetWeapon(self.class)
	if (IsValid(weapon)) then
		self:setData("ammo", self.player:GetAmmoCount(weapon:GetPrimaryAmmoType())) -- Pablo J. Martínez
		self:setData("ammo1", weapon:Clip1())
		self:setData("ammo2", weapon:Clip2()) -- Pablo J. Martínez
    else
        if((self.weaponCategory == "explosive" or self.weaponCategory == "infectioncure") and self:getData("equip")) then -- Pablo J. Martínez
            self.player.carryWeapons[self.weaponCategory] = nil
            self.player:getChar():getInv():remove(self.id, true, true)
        end
	end
end

HOLSTER_DRAWINFO = {}

-- Called after the item is registered into the item tables.
function ITEM:onRegistered()
	if (self.holsterDrawInfo) then
		HOLSTER_DRAWINFO[self.class] = self.holsterDrawInfo
	end
end

hook.Add("PlayerDeath", "nutStripClip", function(client)
	client.carryWeapons = {}

	for k, v in pairs(client:getChar():getInv():getItems()) do
		if (v.isWeapon and v:getData("equip")) then
			--v:setData("ammo", nil)
			--v:setData("ammo1", nil)
			--v:setData("ammo2", nil)
			v:setData("equip", nil)
		end
	end
end)