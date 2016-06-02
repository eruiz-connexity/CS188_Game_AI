
-- Globals

--Mitchel's file path
--MousePlayer_Data_Definition_File = "Scripts/Entities/Custom/MousePlayer_Data_Definition_File.xml"
--MousePlayer_Default_Data_File = "Scripts/Entities/Custom/DataFiles/MousePlayer_Data_File.xml"

--Amal's file path
MousePlayer_Data_Definition_File = "Scripts/Entities/userdef/MousePlayer_Data_Definition_File.xml"
MousePlayer_Default_Data_File = "Scripts/Entities/userdef/DataFiles/MousePlayer_Data_File.xml"

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    MousePlayer Player Table Declaration    ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

MousePlayer = {
	type = "Mouse",
	
	States = {
		"Player",
		"PlayerRecorder",
		"Eat",
		"Sleep",
		"Dead",
		"Power",
	},
	
	MousePlayerDataTable = {},
    
    angles = 0,
    pos = {},
    
    --moveQueue = {},
    nextPos,
	
    Properties = {
    	entType = "MousePlayer",
		bUsable = 0,
        object_Model = "Objects/characters/animals/rat/rat.cdf",
	    --object_Model = "objects/default/primitive_cube_small.cgf",
		fRotSpeed = 10, --[0.1, 20, 0.1, "Speed of rotation"]
		m_speed = 0.15;

		maze_ent_name = "",         --maze_ent_name = "Maze1",

        bActive = 1,

        MousePlayerDataTable = {},
        
        impulse_modifier = 50,
        
		Physics = {
			
            --Density = -1,
            mass = 10,
			flags = 0,
			stiffness_scale = 73,
			
			--Living:
			Living = {
				height = 0, -- vertical offset of collision geometry center
				--size = {x=1,z=0.5}, --collision cylinder dimensions, a vector WTF WONT WORK U PIECE OF SHIT
				size = {x=2.4,y=2.4,z=0.8},
				--height_eye = , --vertical offset of the camera
				--height_pivot = , -- offset from central ground position that is considered the entity center
				--height_head = , -- vertical offset of the head
				inertia = 5.0, -- inertia coefficient, higher means less inertia, 0 means no inertia
				inertiaAccel = 8.0, -- Same as inertia, but used when the player accel
				air_resistance = 0.2, -- air control coefficient, 0.0-1.0, where 1 is special (total control of movement)
				gravity = 9.81, -- vertical gravity magnitude
				mass = 10, -- in kg
				min_slide_angle = 30, --  if surface slope is more than this angle (in radians), player starts sliding
				max_climb_angle =30 , -- player cannot climb surface with slope steeper than this angle, in radians
				--max_jump_angle = , -- player cannot jump towards ground if this angle is exceeded
				min_fall_angle = 70, -- player starts falling when slope is steeper than this, in radians
				max_vel_ground = 100, -- player cannot stand on surfaces that are moving faster than this
				--colliderMat = "mat_player_collider",
				--useCapsule=0,
			},
			
			-- Area:
			Area = {
				type = AREA_BOX, -- type of the area, AREA_BOX, AREA_SPHERE, AREA_GEOMETRY, AREA_SHAPE, AREA_CYLINDER, AREA_SPLINE
				--radius = , radius of the area sphere, required if the area type is AREA_SPHERE
				box_min = {x=0,y=0,z=0}, --min vector of the bounding box, rquired if the area type is AREA_BOX
				box_max = {x=0,y=0,z=0}, -- max vector of the bounding box, rquired if the area type is AREA_BOX
				--points = {}, -- table containing collection of vectors in local entity space defining the 2D shape of the area, if the area type is AREA_SHAPE
				--height = 0, -- height of the 2D area, relative to the minimal Z in the points table, if the area type is AREA_SHAPE
				--uniform = , -- same direction in every point or always point to the center
				--falloff = , --ellipsoidal falloff dimensions, a vector. zero vector if no falloff
				gravity = 9.81, --gravity vector inside the physical area
			},
			
				PlayerDim = {
					cyl_r = 1, --float - radius of collider cylinder default -

					cyl_pos =0.5 , --float - vertical position of collider cylinder default -
				},
        },
    },

    Editor = { 
		Icon = "Checkpoint.bmp", 
	},	
	
	
	eatCount = {
		Cheese = 0,
		Berry = 0,
		Potato = 0,
		Grains = 0,
	},
	
	ToEat = {},
    
    Snake = {
        pos,
		entity,
    },
    
    Food = {
        type = "",
        pos,
		entity,
    },
    
    Trap = {
        type = "",
        pos,
		entity,
    },
    
};

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    MousePlayer States                 --------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
MousePlayer.PlayerRecorder = 
{
	OnBeginState = function(self)
		Log("MousePlayer: Record state")
		
  	end,
	
	OnUpdate = function(self, time)

        -- Recording
        self:UpdateTable()

        -- See anything new?
        if self:Observe() == false then 
			self:GotoState("Player")
		end 
        
        -- Movement
        self:Move()
        
	end,
	
	OnCollision = function(self, hitdata)
		Log("A COLLISION!")
		local target = hitdata.target
		Log("Target.type is "..target.type)
		
		if target.type == "Food" then
			Log("Eating Food")
			--self:GotoState("Eat")
			target:DeleteThis()
		elseif target.type == "Snake" or target.type == "Trap1" or target.type == "Trap2" then 
			self:GotoState("Dead")
		end 
		
	end, 
	
	OnEndState = function(self)
		Log("MousePlayer: Exiting Record State")
        self:SaveXMLData()
		self.Snake.pos = nil 
		self.Snake.entity = nil 
		self.Food.type = nil 
		self.Food.pos = nil
		self.Food.entity = nil 
		self.Trap.type = nil 
		self.Trap.pos = nil 
		self.Trap.entity = nil 
	end,
}

MousePlayer.Player = 
{
	OnBeginState = function(self)
		Log("MousePlayer: Player state")
		
  	end,
	
	OnUpdate = function(self, time)
		 
		-- Ray trace and check for food, traps, snakes
		 if(self:Observe()) then 
		 	self:GotoState("PlayerRecorder");
		 end 
		          
         -- Movement
         self:Move()
         
	end,
	
	OnCollision = function(self, hitdata)
		Log("A COLLISION!")
        local target = hitdata.target
        Log("Target.type is "..target.type)
		
        if target.type == "Food" then
			Log("Eating Food")
            --self:GotoState("Eat")
			target:DeleteThis()
        elseif target.type == "Snake" or target.type == "Trap1" or target.type == "Trap2" then 
			self:GotoState("Dead")
		end 
		
	end, 
	
	OnEndState = function(self)
		Log("MousePlayer: Exiting Player State")

	end,
}


MousePlayer.Eat =
{

	OnBeginState = function(self)
		Log("MousePlayer: Entering Eat State")

  	end,

 	OnUpdate = function(self,time)
  		local continue_chase = self:chase("Food", time);

  		if continue_chase == false then
  			self:GotoState("Search");
  		else end;	 	
	end,

  	OnEndState = function(self)
		Log("MousePlayer: Exiting Eat State")
		self:SaveXMLData(self.Properties.MousePlayerDataTable, MousePlayer_Default_Data_File)
		-- Record Food Locs knowledge
  	end,
	
}

MousePlayer.Sleep =
{

	OnBeginState = function(self)
		Log("MousePlayer: Entering SLeep State")
		-- Mark as winner

  	end,

 	OnUpdate = function(self,time)
  	

	end,

  	OnEndState = function(self)

  	end,
	
}

MousePlayer.Dead =
{
	
	OnBeginState = function(self)
		Log("MousePlayer: Entering Dead State")
			--self:SaveXMLData()

			self:DeleteThis()

		-- Mark as Loser
		-- Record learned dangers
  	end,

 	OnUpdate = function(self,time)
  	

	end,

  	OnEndState = function(self)
		--self:SaveXMLData()
  	end,
}

MousePlayer.Power = 
{
	
	OnBeginState = function(self)
		Log("MousePlayer: Entering Power State")
  	end,

 	OnUpdate = function(self,time)
  		--[[
			  if timePassed > powerTime then
			  	self:GotoState("Search")
			  end
			  
			  self:PowerMode();
		  ]]

	end,

  	OnEndState = function(self)
	  	Log("MousePlayer: Exiting Power State")
  	end,
}
---------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Functions                        --------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

function MousePlayer:OnInit() 
    self:OnReset();
end

function MousePlayer:OnPropertyChange() 
    self:OnReset();
end

function MousePlayer:OnReset()

    self:SetFromProperties() 
    self.MousePlayerPlayerDataTable = self:LoadXMLData() 
    self:GotoState("Player")

end

function MousePlayer:SetupModel()
    local Properties = self.Properties;

    if(Properties.object_Model ~= "") then          -- Make sure objectModel is specified
        self:LoadObject(0,Properties.object_Model)  -- Load model into main entity

		local v1, v2 = self:GetLocalBBox()
		
		self.Properties.Physics.Area.box_min = v1
		self.Properties.Physics.Area.box_max = v2

		self.Properties.Physics.PlayerDim.cyl_r = v2.x
		self.Properties.Physics.PlayerDim.cyl_pos = v2.y 
        self:PhysicalizeThis();
        
    end
	
end

function MousePlayer:PhysicalizeThis() -- Helper function to physicalize, Copied from BasicEntity.lua
   
   self:Physicalize(0, PE_LIVING, self.Properties.Physics);
   self:SetPhysicParams(PHYSICPARAM_PLAYERDIM, self.Properties.Physics.PlayerDim)
   self:AwakePhysics(1)
   
end

function MousePlayer:SetFromProperties()
	--Log("LivingEntityBase: SetFromProperties()")

    self:SetupModel();
	self.angles = self:GetAngles(); --gets the current angles of Rotating
    self.pos = self:GetPos(); --gets the current position of Rotating
    --self.pos.z = 32
    --self:SetPos({self.pos.x, self.pos.y, self.pos.z})

	local Properties = self.Properties;
	if (Properties.object_Model == "") then
		do return end;
	end

    self:Activate(1); --set OnUpdate() on/off

end

function MousePlayer:OnEat(userId, index)
	Log("RIP MousePlayer")
	--self.Properties.MousePlayerDataTable = self:LoadXMLData(MousePlayer_Default_Data_File);
	
	for i = 1, #self.Properties.MousePlayerDataTable.defaultTable.KnownDangerEnts do 
		if self.Properties.MousePlayerDataTable.defaultTable.KnownDangerEnts[i] == tostring(userId.type) then
			Log(tostring(userID.type) .. " already in data table");
			self:GotoState("Dead")
		end
	end
	Log("Adding " .. tostring(userID.type) .. " to data table");
	self.Properties.MousePlayerDataTable.defaultTable.KnownDangerEnts[#self.Properties.MousePlayerDataTable.defaultTable.KnownDangerEnts + 1] = userID.type;
	self:SaveXMLData(self.Properties.MousePlayerDataTable, MousePlayer_Default_Data_File);
	self:GotoState("Dead")
end



-- Loads a XML data file and returns it as a script table
function MousePlayer:LoadXMLData(dataFile)
	dataFile = dataFile	or MousePlayer_Default_Data_File
	return CryAction.LoadXML(MousePlayer_Data_Definition_File, dataFile);
end

-- Saves XML data from dataTable to dataFile
function MousePlayer:SaveXMLData(dataTable, dataFile)
	dataFile = dataFile or MousePlayer_Default_Data_File
	dataTable = dataTable or self.Properties.MousePlayerDataTable
	
	CryAction.SaveXML(MousePlayer_Data_Definition_File, dataFile, dataTable);
end


function MousePlayer:OnUpdate(frameTime)
	self:SetScale(5);

end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                      Functions                             ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function MousePlayer:ray_cast(target_class)

	local target = System.GetNearestEntityByClass({self.pos.x, self.pos.y, self.pos.z},
 			 20, target_class);

	if target == nil then
		return nil;
	end

 	--Log(tostring(target));

 	System.DrawLine(self.pos, target.pos, 1, 0, 0, 1);

 	local diff = {x = target.pos.x - self.pos.x, y = target.pos.y - self.pos.y, z = 0};

 	local fucker = {};

 	Physics.RayWorldIntersection(self.pos, diff, 1, ent_all, self.id, target.id, fucker);--, self:GetRawId(), target_mouse:GetRawId());

	
	local n_hits = 0;

	for key, value in pairs(fucker) do
		n_hits = n_hits + 1
	end

	if (n_hits > 0) then
		--Log("Raycast intersect");
		return nil;
	end
	
	
	return target;
end

function MousePlayer:Move(ft)

--[[
    if #self.moveQueue > 1 then 
        local loc = table.remove(self.moveQueue, 1)
        self:MoveTo(loc)

    end 
    ]]
    
    if self.nextPos ~= nil then 
       -- self:MoveTo(self.nextPos, ft)
       self:PhysicsMoveTo(self.nextPos)
       self.nextPos = nil
    end 
    
end

function MousePlayer:MoveTo(loc, ft)
    local a = self:GetPos()
    local b = loc
    
    if a == b then self.nextPos = nil; return; end 
    
    self:FaceAt(loc, ft)
    
    local diff = {x = b.x-a.x, y=b.y-a.y}
    local diff_mag = math.sqrt(diff.x^2 + diff.y^2);
    local speed_mag = self.Properties.m_speed/diff_mag;
    
    local x = a.x + diff.x*speed_mag 
    local y = a.y+diff.y*speed_mag 
    
    self:SetPos({x, y, a.z})
    
end

function MousePlayer:PhysicsMoveTo(loc)

    self:FaceAt(loc)
    
    local distance = DifferenceVectors(loc, self:GetPos())
    local distance_mag = math.sqrt(distance.x^2 + distance.y^2)
    local impulse_mag = distance_mag * self.Properties.impulse_modifier
    self:AddImpulse(-1, self:GetCenterOfMassPos(), self:GetDirectionVector(), impulse_mag, 1)
    
 end

function MousePlayer:FaceAt(pos)
    local a = self:GetPos()
    local b = pos
	 local vector=DifferenceVectors(b, a);  -- Vector from player to target

     vector=NormalizeVector(vector);  -- Ensure vector is normalised (unit length)

     self:SetDirectionVector(vector); -- Orient player to the vector
end

function MousePlayer:Observe()
         -- See anything
        local trap;
		local enemy;
		local food;
		
		local hitData = {};
		local dir = self:GetDirectionVector();
		
		dir = vecScale(dir, 50); --See up to 50 away
		local hits = Physics.RayWorldIntersection(self:GetPos(), dir, 1, ent_all, self.id, nil, hitData )
		if(hits > 0) then 

			if(hitData[1].entity) then
			
				if(hitData[1].entity.class == "Trap1" or hitData[1].entity.class == "Trap2") then 
					trap = hitData[1].entity
				end
				--[[if(hitData[1].entity.class == "Snake") then 
					enemy = hitData[1].entity
				end 
				if(hitData[1].entity.class == "Food") then 
					food = hitData[1].entity 
				end 
				]]
			end 
			
		end 
		
		food = self:ray_cast("Food");

		if(trap ~=nil and trap.class == "Trap1") then 
		   Log("Mouse: Sees trap")
		   local child = trap:GetChild(0)
		   --self:PrintTable(child)
		   food = child;	
		end 
		
		if(trap ~= nil) then 
			self.Trap.type = trap.type
			self.Trap.pos = trap:GetPos()
			self.Trap.entity = trap;
		end 
	  
		enemy = self:ray_cast("Snake");
		
		if(food ~= nil) then 
			self.Food.type = food.type
			self.Food.pos = food:GetPos()
			self.Food.entity = food;
		end 
		if(enemy ~= nil) then 
			self.Snake.pos = enemy:GetPos()
			self.Snake.entity = enemy;
		end 
		
		if(enemy ~= nil or trap ~= nil or food ~= nil) then 
			return true;
		else
			return false;
		end 
		
		return false;
end 

function MousePlayer:UpdateTable()
    -- Locations 
    local locations = self.Properties.MousePlayerDataTable.defaultTable.Locations
    -- New Index 
    local index = #locations+1
    locations[index].MouseLocCur = self:GetPos()
    locations[index].MouseLocTo = self.nextPos
    locations[index].SnakeLoc = self.Snake.pos
    locations[index].TrapLoc = self.Trap.pos
	locations[index].TrapType = self.Trap.type
    locations[index].FoodLoc = self.Food.pos
	locations[index].FoodType = self.Food.type

end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    MousePlayer FlowGraph Utilities         ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
--[[
  function MousePlayer:QueueMoveTo(loc)
    self.moveQueue[#self.moveQueue+1] = loc 
    
end
]]

function MousePlayer:NextMove(sender, pos)
    self.nextPos = pos;
    self.nextPos.z = 32;

end 

MousePlayer.FlowEvents = 
{
    Inputs = 
	{	
		--Coordinates = {MousePlayer.QueueMoveTo, "Vec3"},
        Coordinates = {MousePlayer.NextMove, "Vec3"},

	},

	Outputs = 
	{
		-- 
	},
}