--[[ *************************************************************************************************************************************************************************** --]]
--[[	Developed by Pablo J. Martínez using Vein's zombies (2016). You are free to use this and my plugins as long as you credit me. Thanks ^_^                                                                                      
--[[ *************************************************************************************************************************************************************************** --]]

AddCSLuaFile()
AddCSLuaFile("cl_init.lua");
include("shared.lua");
include("schedules.lua");

ENT.HitSounds = {
	Sound("npc/vort/foot_hit.wav"),
	Sound("weapons/crossbow/hitbod1.wav"),
	Sound("weapons/crossbow/hitbod2.wav")
}

function ENT:Initialize()
	
	self:SetModel(table.Random(SCHEMA.ZombieModels));

    --self:SetHullType(HULL_HUMAN);
    --self:SetHullSizeNormal();
	
    self:SetSolid(SOLID_BBOX);
    --self:SetMoveType(MOVETYPE_STEP);
	
	--self:SetCustomCollisionCheck(true);
	
   	--self:CapabilitiesAdd(CAP_MOVE_GROUND);
   	
    --self:SetMaxYawSpeed(20);

    self:SetCollisionBounds(Vector(-4, -4, 0), Vector(4, 4, 64)) 
	
	self.NextMoan = 0;
	
	self.LastSeenEnemy = 0;
	--self:AddRelationship("player D_HT 99");

	self:SetHealth(nut.config.get("ZombiesHealth"));
	
	self.NextDoorAttack = 0;
	
	self.Alive = true;

    self.DoorBeingAttacked = nil
    self.PositionOfDoorBeingAttacked = nil
    self.EnemyBeforeAttackingDoor = nil

    self.LoseTargetDist	= 2000	-- How far the enemy has to be before we lose them
	self.SearchRadius 	= 1000	-- How far to search for enemies

    --for k, v in ipairs(self:GetSequenceList()) do
    --    print("ZOMBIE SEQUENCE " .. k .. " : " .. tostring(v))
    --end

    --[[util.PrecacheSound("vein/zombies/femzom_idle1.wav")
	util.PrecacheSound("vein/zombies/femzom_idle2.wav")
	util.PrecacheSound("vein/zombies/femzom_idle3.wav")
	util.PrecacheSound("vein/zombies/femzom_idle4.wav")
	util.PrecacheSound("vein/zombies/femzom_idle5.wav")
	util.PrecacheSound("vein/zombies/femzom_idle6.wav")
	util.PrecacheSound("vein/zombies/femzom_idle7.wav")
	util.PrecacheSound("vein/zombies/femzom_idle8.wav")
	util.PrecacheSound("vein/zombies/femzom_idle9.wav")
	util.PrecacheSound("vein/zombies/femzom_idle10.wav")
	util.PrecacheSound("vein/zombies/femzom_idle11.wav")

    util.PrecacheSound("vein/zombies/idle1.wav")
	util.PrecacheSound("vein/zombies/idle2.wav")
	util.PrecacheSound("vein/zombies/idle3.wav")
	util.PrecacheSound("vein/zombies/idle4.wav")
	util.PrecacheSound("vein/zombies/idle5.wav")
	util.PrecacheSound("vein/zombies/idle6.wav")
	util.PrecacheSound("vein/zombies/idle7.wav")
	util.PrecacheSound("vein/zombies/idle8.wav")
	util.PrecacheSound("vein/zombies/idle9.wav")
	util.PrecacheSound("vein/zombies/idle10.wav")
	util.PrecacheSound("vein/zombies/idle11.wav")
	util.PrecacheSound("vein/zombies/idle12.wav")
	util.PrecacheSound("vein/zombies/idle13.wav")
	util.PrecacheSound("vein/zombies/idle14.wav")
	util.PrecacheSound("vein/zombies/idle15.wav")--]]
	
end

function ENT:SetEnemy(ent)
	self.Enemy = ent
end

function ENT:GetEnemy()
	return self.Enemy
end

function ENT:IsAValidEnemy(enemy)
    if(!IsValid(enemy)) then return false end
    if(!enemy:IsPlayer()) then return false end
	if(enemy:IsEFlagSet(EFL_NOCLIP_ACTIVE)) then return false end
	if(enemy:getChar() == nil) then return false end
	if(!enemy:Alive()) then return false end
    return true
end

function ENT:HaveEnemy()
	if(self:GetEnemy() and self:IsAValidEnemy(self:GetEnemy())) then
        if(!self:IsThereANewEnemy()) then
		    if(self:GetPos():DistToSqr(self:GetEnemy():GetPos()) > self.LoseTargetDist * self.LoseTargetDist) then
			    return self:FindEnemy()
		    elseif(self:GetEnemy():IsPlayer() and !self:GetEnemy():Alive()) then
			    return self:FindEnemy()
		    end
        end
		return true
	else
		return self:FindEnemy()
	end
end

function ENT:IsThereANewEnemy()
    for k, v in ipairs(player.GetHumans()) do
        if(self:IsAValidEnemy(v)) then
            local zombiePosition = self:GetPos()
		    if(v ~= self:GetEnemy() and (zombiePosition:DistToSqr(v:GetPos()) + 50 * 50) < (zombiePosition:DistToSqr(self:GetEnemy():GetPos()))) then
		        self:SetEnemy(v)
		        return true
            end
        end
	end
    return false
end

function ENT:FindEnemy()
	for k, v in ipairs(player.GetHumans()) do
        if(self:IsAValidEnemy(v)) then
		    if(self:GetPos():DistToSqr(v:GetPos()) < self.SearchRadius * self.SearchRadius) then
		        self:SetEnemy(v)
		        return true
            end
        end
	end
	self:SetEnemy(nil)
	return false
end

function ENT:ChaseEnemy(options)

	local options = options or {}

	local path = Path("Follow")
	path:SetMinLookAheadDistance(options.lookahead or 300)
	path:SetGoalTolerance(options.tolerance or 20)
	path:Compute(self, self:GetEnemy():GetPos())

	if(!path:IsValid()) then return "failed" end

	while(path:IsValid() and self:HaveEnemy()) do

        enemyPosition = self:GetEnemy():GetPos()

		if(path:GetAge() > 0.1) then
			path:Compute(self, enemyPosition)
		end
		path:Update(self)

		if (options.draw) then path:Draw() end

		--[[if (self.loco:IsStuck()) then
			self:HandleStuck()
			return "stuck"
		end--]]

        if(self:GetPos():DistToSqr(enemyPosition) < 50 * 50) then break end

		coroutine.yield()

	end

	return "ok"

end

function ENT:CustomMoveToPos(pos, options)

    local options = options or {}

	local path = Path("Follow")
	path:SetMinLookAheadDistance(options.lookahead or 300)
	path:SetGoalTolerance(options.tolerance or 20)
	path:Compute(self, pos)

	if(!path:IsValid()) then return "failed" end

	while(path:IsValid() and !self:HaveEnemy()) do

        local zombiePosition = self:GetPos()
        if(zombiePosition:DistToSqr(pos) < 50 * 50 or path:GetAge() > 60) then
            pos = zombiePosition + Vector(math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400
			path:Compute(self, pos)
		end
		path:Update(self)

		if (options.draw) then path:Draw() end

		--[[if (self.loco:IsStuck()) then
			self:HandleStuck()
			return "stuck"
		end--]]

		coroutine.yield()

	end

	return "ok"

end

function ENT:RunBehaviour()
	while (true) do
		if(self:HaveEnemy()) then
			self.loco:FaceTowards(self:GetEnemy():GetPos())
			self:StartActivity(ACT_WALK)
			self.loco:SetDesiredSpeed(15)
			self:ChaseEnemy()
            self:Attack()
		else
			self:StartActivity(ACT_WALK)
			self.loco:SetDesiredSpeed(15)
            self:CustomMoveToPos(self:GetPos() + Vector(math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400) -- Walk to a random place within about 400 units (yielding)
			--self:MoveToPos(self:GetPos() + Vector(math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400) -- Walk to a random place within about 400 units (yielding)
		end
		coroutine.yield()
	end
end

function ENT:Think()
    self:MoanSometimes()
end

function ENT:OnKilled(damageInfo)
    self:BecomeRagdoll(damageInfo)
    self.Alive = false
end

function ENT:SpawnBlood( pos )
	
	local ed = EffectData();
	ed:SetOrigin( pos );
	util.Effect( "BloodImpact", ed );
	
end

function ENT:Damage( ply, bite )
	
	if(!self.Alive) then return end
	
	if( bite ) then
		ply:TakeDamage( math.random( 35, 45 ), self, self );
	else
		ply:TakeDamage( math.random( 6, 14 ), self, self );
	end
	
end

function ENT:Attack()
	
	if(!self.Alive or self.Biting or self.Attacking) then return end

        self.Attacking = true;
		self:Claw()
	
	--[[if( math.random(1, 4) == 1) then
		
		self.Biting = true;
		self:Bite()
		
	else
		
		self.Attacking = true;
		self:Claw()
		
	end--]]
	
end

function ENT:AttackDoor()
	
	if(!self.Alive) then return end
	
	self.Attacking = true;
	self:StartSchedule( self.ClawDoor );
	
end

function ENT:TraceAttack()
	
	if(!self.Alive) then return end
	
	if(self.BiteTarg) then
		
		self:Damage( self.BiteTarg, true );
		
	else
		
		local hit = false;
		
		for _, v in pairs( player.GetAll() ) do
			
			local epos = v:GetPos();
			local spos = self:GetPos();
			local dist = epos:DistToSqr( spos );
			local dir = ( epos - spos );
			dir:Normalize();
			
			if( dist < 60 * 60 and dir:Dot( self:GetForward() ) > 0.75 and v:Alive() ) then
				
				hit = true;
				self:Damage( v, false );
				
			end
			
		end
		
		if( hit ) then
			
			self:EmitSound( table.Random( self.HitSounds ) );
			
		end
		
	end
	
end

function ENT:TraceAttackDoor()
	
	if(!self.Alive) then return end
	
	local hit = false;
	
	for k, v in pairs(ents.FindByClass( "prop_door_rotating")) do
		
		local epos = v:GetPos();
		local spos = self:GetPos();
		local dist = epos:DistToSqr( spos );
		local dir = ( epos - spos );
		dir:Normalize();
		
		if( dist < 60 * 60 and dir:Dot( self:GetForward() ) > 0.75 ) then
			
			hit = true;
			SCHEMA.ME.ZombieDamageDoor( v )
			
		end
		
	end
	
	if( hit ) then
		
		self:EmitSound( table.Random( self.HitSounds ) );
		
	end
	
end

--[[function ENT:OnTakeDamage( dmg )
	
    print("is taking damage")
	if(!self.Alive) then return end
	
	local atk = dmg:GetAttacker();
	local inf = dmg:GetInflictor();
	local pos = dmg:GetDamagePosition();
	local type = dmg:GetDamageType();
	
	if( inf:GetClass() == "prop_physics" or inf:GetClass() == "prop_physics_multiplayer" ) then return end
	
	if( type == DMG_CRUSH and table.HasValue( SCHEMA.InstantCrushDeath, inf:GetClass() ) ) then
		
		self:SetHealth( 0 );
		self:EmitSound( Sound( "physics/body/body_medium_break" .. math.random( 2, 4 ) .. ".wav" ) );
		
	end
	
	if( type == DMG_BURN ) then
		
		if( !self:IsOnFire() ) then
			
			self:Ignite( 60, 0 );
			self:SetMaterial( "models/vein/burned" );
			
			self.StartFire = CurTime();
			self.FireTime = math.random( 20, 40 );
			
		end
		
		return
		
	end
	
	if( type == DMG_DIRECT ) then
		
		return
		
	end
	
	if( type == DMG_SLASH or dmg:IsBulletDamage() ) then
		
		self:SpawnBlood( pos );
		
	end
	
	if( ( pos - self:GetPos() ).z > 55 ) then
		
		if( dmg:IsBulletDamage() ) then
			
			self:SetHealth( 0 );
			
		else
			
			self:SetHealth( self:Health() - 1 );
			
		end
		
	end
	
	if( self:Health() <= 0 ) then
	
		--local rag = SCHEMA:GibMod_DeathRagdoll( self, dmg )
        -- By Pablo J. Martínez
		--self:Fire( "kill", "", 0 )
        --SpawnRagdollForEntity(self)
		self:Die();
		
	end
	
end--]]

function ENT:IsFemale()
	
	if( self:GetModel() == "models/nmr_zombie/julie.mdl" or
		self:GetModel() == "models/nmr_zombie/zombiekid_girl.mdl" ) then
		
		return true;
		
	end
	
	return false;
	
end

function ENT:Moan()

	if(self:IsFemale()) then

        self:EmitSound("vein/zombies/femzom_idle" .. tostring(math.random(1, 11)) .. ".wav");
		
	else
		
        self:EmitSound("vein/zombies/idle" .. tostring(math.random( 1, 15)) .. ".wav");
		
	end
	
end

function ENT:MoanSometimes()
    if(CurTime() > self.NextMoan) then
		self:Moan();
		self.NextMoan = CurTime() + math.random(3, 6);
	end
end

--[[function ENT:SeeEnemy()

    --self:UpdateEnemyMemory( self:GetEnemy(), self:GetEnemy():GetPos() )
    --self:SetLastPosition(self:GetEnemy():GetPos())
	--self.LastSeenEnemy = CurTime()
    --]]
    --[[local enemy = self:GetEnemy()
    self:ClearEnemyMemory()
	self:SetEnemy(enemy)
    --self:SetTarget(enemy)
	self:UpdateEnemyMemory(enemy, enemy:GetPos())
    self:NavSetGoal(enemy:GetPos())
    --self:NavSetGoalTarget(enemy,  enemy:GetPos())
    self:AddRelationship("player D_HT 99")
	self.LastSeenEnemy = CurTime()--]]--[[
end

function ENT:CanTarget( ply )

    if(!ply:IsPlayer()) then return false end
	if(ply:IsEFlagSet(EFL_NOCLIP_ACTIVE)) then return false end
	if(ply.CharCreate) then return false end
	--if(ply.Sitting) then return false end
	if(!ply:Alive()) then return false end
    
    return true
	
end

function ENT:MaxEnemyLOSDistance()
	
	local d = SCHEMA.Config.ZombieSeeDistance;
	
	return d;
	
end

function ENT:MaxEnemySoundDistance()
	
	local d = SCHEMA.Config.ZombieHearDistance;
	
	return d;
	
end
--]]
--[[function ENT:FindEnemy()
	
	local best;
	local bdist = math.huge;
	
	for _, v in pairs( player.GetAll() ) do
		
		local epos = v:GetPos();
		local spos = self:GetPos();
		local dist = epos:DistToSqr( spos );
		local dir = ( spos - epos );
		dir:Normalize();
		
		local trace = { };
		trace.start = self:EyePos();
		trace.endpos = v:EyePos();
		trace.filter = self;
		local tr = util.TraceLine( trace );
		
		if((tr.Entity and tr.Entity:IsValid() and tr.Entity == v and ((dist < self:MaxEnemyLOSDistance() * self:MaxEnemyLOSDistance() and dir:Dot( self:GetForward()) > 0.5)) or (dist < self:MaxEnemySoundDistance() * self:MaxEnemySoundDistance()) and self:CanTarget(tr.Entity))) then
			
			if( dist < bdist * bdist ) then
				
				best = v;
				bdist = dist;
				
			end
			
		end
		
	end
	
	if( best and self:CanTarget( best ) ) then
		
		self:SetEnemy(best)
        self:SeeEnemy()
        self:SetSchedule(SCHED_CHASE_ENEMY)

        timer.Create("timerforfuckingzombiesshittt", 0.5, 0, function()
            self:UpdateEnemyMemory(best, best:GetPos())
        end)
		
	end
	
end--]]--[[

function ENT:LosingPlayer()
	
	return ( CurTime() - self.LastSeenEnemy > 20 );
	
end

function ENT:LostPlayer()
	
	return ( CurTime() - self.LastSeenEnemy > SCHEMA.Config.ZombieBoredTime );
	
end

function ENT:HearPlayer( ply, d )
	
	if( ply:EyePos():DistToSqr( self:EyePos() ) > d * d ) then return end
	if( !self:CanTarget( ply ) ) then return end
	
	if( !self:GetEnemy() or ( self:GetEnemy() and self:LosingPlayer() ) ) then
		
		self:StopMoving();
		self:SetEnemy( ply );
		self:SeeEnemy();
		
	end
	
	if( ply == self:GetEnemy() ) then
		
		self:SeeEnemy();
		
	end
	
end--]]

--[[function ENT:Think()
	
	if(!self.Alive) then return end
	
	if( self:GetNPCState() == NPC_STATE_SCRIPT ) then return end
	
	self:SetMovementActivity( ACT_WALK );

    if(self.DoorBeingAttacked == nil) then

	    if(self:GetEnemy()) then
		
		    if( self:LostPlayer() or !self:CanTarget( self:GetEnemy() ) ) then
			
			    --self:SetEnemy()
			    --self:ResetAIVariables()
			    --self:SetSchedule( SCHED_IDLE_WANDER )
                print("lost enemy...")
			    return
			
		    end
		
		    local epos = self:GetEnemy():GetPos();
		    local spos = self:GetPos();
		    local dist = epos:DistToSqr( spos );
		
		    for _, v in pairs( player.GetAll() ) do
			
			    local bdist = v:GetPos():DistToSqr( spos )
			
			    if( self:CanTarget( v ) and bdist < 50 * 50 ) then
				
				    dist = bdist
				    self:SetEnemy( v )
                    print("hola amigo!")
				
			    end
			
		    end
		
		    local trace = { };
		    trace.start = self:EyePos();
		    trace.endpos = self:GetEnemy():EyePos();
		    trace.filter = SCHEMA.Z.GetZombies();
		    trace.mask = MASK_VISIBLE;
		    for _, v in pairs( player.GetAll() ) do
			    table.insert( trace.filter, v );
		    end
		    local tr = util.TraceLine( trace );
		
		    if( tr.Fraction == 1.0 ) then
			
			    self:SeeEnemy();

		    end
		
		    if( !self.Attacking and !self.Biting and dist < 50 * 50 ) then
			
			    self:Attack()

		    end

	    else
		
		    self:FindEnemy();

            print("finding enemy...")
		
	    end
    end
	
    if(self.DoorBeingAttacked == nil) then

	    if(!self.Attacking and !self.Biting and self:GetEnemy()) then
		    local trace = { };
		    trace.start = self:EyePos();
		    trace.endpos = trace.start + self:GetForward() * 100;
		    trace.filter = self;
		    local traceResult = util.TraceLine( trace );
            local traceResultNormal = traceResult.HitNormal:Angle()

		    if(traceResult.Entity and traceResult.Entity:IsValid() and traceResult.Entity:GetClass() == "prop_door_rotating") then
                if(traceResult.Entity.IsDoorOpen == false) then
                    if(traceResult.Entity.HasBeenBusted == nil or traceResult.Entity.HasBeenBusted == false) then
                        self.DoorBeingAttacked = traceResult.Entity
                        self:ResetAIVariables()
                        self.PositionOfDoorBeingAttacked = self.DoorBeingAttacked:LocalToWorld(self.DoorBeingAttacked:OBBCenter())
                        self.PositionOfDoorBeingAttacked = Vector(self.PositionOfDoorBeingAttacked.x, self.PositionOfDoorBeingAttacked.y, self:GetPos().z)
                        self:SetLastPosition(self.PositionOfDoorBeingAttacked)
		                self:SetSchedule(SCHED_CHASE_ENEMY)
                        self.EnemyBeforeAttackingDoor = self:GetEnemy()
                        self:SetEnemy(self.DoorBeingAttacked)
                    end
                end
		    end

	    end
    else
        if(self.DoorBeingAttacked.IsDoorOpen == true) then
			self:ResetAIVariables()
			self:SetSchedule(SCHED_CHASE_ENEMY)
            if(self.DoorBeingAttacked.LastPlayerThatOpenedTheDoor ~= nil and self.DoorBeingAttacked.LastPlayerThatOpenedTheDoor:IsPlayer()) then
                self:SetEnemy(self.DoorBeingAttacked.LastPlayerThatOpenedTheDoor)
            else
                self:SetEnemy()
            end
            self.EnemyBeforeAttackingDoor = nil
            self.DoorBeingAttacked.LastPlayerThatOpenedTheDoor = nil
            self.DoorBeingAttacked = nil
            self.PositionOfDoorBeingAttacked = nil
            return
        end
        self.PositionOfDoorBeingAttacked = self.DoorBeingAttacked:LocalToWorld(self.DoorBeingAttacked:OBBCenter())
        self.PositionOfDoorBeingAttacked = Vector(self.PositionOfDoorBeingAttacked.x, self.PositionOfDoorBeingAttacked.y, self:GetPos().z)
        local distanceBetweenZombieAndDoor = self:GetPos():DistToSqr(self.PositionOfDoorBeingAttacked)
        if(distanceBetweenZombieAndDoor < 30 * 30) then
            if(CurTime() > self.NextDoorAttack) then
			    self.NextDoorAttack = CurTime() + 2; -- Don't want zombies to get stuck.
			    self:AttackDoor();
                self.DoorBeingAttacked:EmitSound("physics/wood/wood_box_impact_hard"..math.random(1, 3)..".wav", 80)
			    self.DoorBeingAttacked:TakeDamage(math.random(10, 50), self, self)
                if(self.DoorBeingAttacked.HasBeenBusted == true) then
			        self:ResetAIVariables()
			        self:SetSchedule(SCHED_CHASE_ENEMY)
                    if(self.EnemyBeforeAttackingDoor:IsPlayer()) then
                        self:SetEnemy(self.EnemyBeforeAttackingDoor)
                    else
                        self:SetEnemy()
                    end
                    self.EnemyBeforeAttackingDoor = nil
                    self.DoorBeingAttacked = nil
                    self.PositionOfDoorBeingAttacked = nil
                    return
                end
		    end
            self:UpdateEnemyMemory(self.DoorBeingAttacked, self.PositionOfDoorBeingAttacked)
        end
    end
	
	if( self.StartFire and CurTime() - self.StartFire >= self.FireTime ) then
		
		self:SetHealth( 0 );
		self:Die();
		
	end
	
	if( CurTime() > self.NextMoan ) then
		
		self:Moan();
		self.NextMoan = CurTime() + math.random( 3, 6 );
		
	end
	
end

function ENT:Die()
	
	self:ResetAIVariables();
	self:SetSchedule( SCHED_NPC_FREEZE );
	self.Alive = false;
	
	self:SetRenderFX( 23 );
	
	timer.Simple( 5, function()
		if( self and self:IsValid() ) then
			self:Remove();
		end
	end );
	
end--]]