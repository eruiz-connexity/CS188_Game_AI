--CryEngine
--Script.ReloadScript( "SCRIPTS/Entities/userdef/LivingEntityBase.lua");
--Lumberyard
Script.ReloadScript( "SCRIPTS/Entities/Custom/LivingEntityBase.lua");

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    Snake Table Declaration                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

Snake = {
	
	type = "Snake",
	
	-- Instance Vars
	max_patrol = 5,
    cur_patrol = 0,
    cur_direction = "NorthEast",
	
	States = {
		"Patrol",
		"Eat",
	},
	
    Properties = {
        --object_Model = "objects/characters/animals/reptiles/snake/snake.cdf",
        object_Model = "objects/default/primitive_cube_small.cgf",
		fRotSpeed = 3, --[0.1, 20, 0.1, "Speed of rotation"]
		m_speed = 0.1;
        --maze_ent_name = "Maze1",f
		maze_ent_name = "",
        bActive = 0,
		
		--Copied from BasicEntity.lua
        Physics = {
            bPhysicalize = 1, -- True if object should be physicalized at all.
            bRigidBody = 1, -- True if rigid body, False if static.
            bPushableByPlayers = 1,
        
            Density = -1,
            Mass = -1,
        },
    },
	
	Food_Properties = {
		ent_type = "Food",
		
	},
	
	Mouse_Properties = {
		ent_type = "Mouse",
	},
	
	Trap_Properties = {
		ent_type = "Trap",
	},
	
    Editor = { 
		Icon = "Checkpoint.bmp", 
	},
	
};

MakeDerivedEntityOverride(Snake, LivingEntityBase);

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    Snake States                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
Snake.Patrol =
 {

  OnBeginState = function(self)

    self:Patrol();

  end,

  OnUpdate = function(self,time)
  	
	self:Patrol()
    --if (--[[ SEE MOUSE ]]) then
      --self:GotoState("Eat");
    --end

  end,

  OnEndState = function(self)

  end,

 }

Snake.Eat =
{
	OnBeginState = function(self)

    --self:Eat();

  end,

  OnUpdate = function(self,time)
  	
	--self:Eat()
    --if (--[[ Lose Sight ]]) then
      --self:GotoState("Patrol");
    --end

  end,

  OnEndState = function(self)

  end,
	
}
---------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Functions                        --------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--sets the Mouse's properties
function Snake:abstractReset()
	Log("In OnReset");
	self:GotoState("Patrol");
		
end

--[[
function Snake:OnUpdate(frameTime)
	--Log("In OnUpdate");
	--Log("Frame at time" .. tostring(frameTime))
	
	if (self.state == "patrol") then
		self:Patrol();
	elseif (self.state == "eat") then
		--self:EatMice();
	else 
	
	end
	-
end
]]
----------------------------------------------------------------------------------------------------------------------------------
-------------------------                      Functions                             ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function Snake:Patrol()
	if (self.cur_patrol ~= self.max_patrol and self.cur_direction == "NorthEast") then
		self:MoveNorthEast();
		self.cur_patrol = self.cur_patrol + 1;
	elseif (self.cur_patrol ~= self.max_patrol and self.cur_direction == "SouthWest") then
		self:MoveSouthWest();
		self.cur_patrol = self.cur_patrol + 1;
	elseif (self.cur_patrol == self.max_patrol and self.cur_direction == "NorthEast") then
		self.cur_direction = "SouthWest";
		self.cur_patrol = 0;
	else
		self.cur_direction = "NorthEast";
		self.cur_patrol = 0;
	end
		
end

function Snake:MoveNorthEast() 

	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self:GetPos());

	-- Check if snake can move north, then east, then west, then south
	if (self.Maze_Properties.grid[row-1][col].occupied == false) then		-- North
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row-1, col);
		self:Move_to_Pos(frameTime, pos);
	elseif (self.Maze_Properties.grid[row][col+1].occupied == false) then	-- East
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row, col+1);
		self:Move_to_Pos(frameTime, pos);
	elseif (self.Maze_Properties.grid[row][col-1].occupied == false) then	-- West
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row, col-1);
		self:Move_to_Pos(frameTime, pos);
	elseif (self.Maze_Properties.grid[row+1][col].occupied == false) then	-- South
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row+1, col);
		self:Move_to_Pos(frameTime, pos);
	end
	--Log(tostring(self:GetPos().x) .. tostring(self.pos.x));
	
end

function Snake:MoveSouthWest() 

	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self:GetPos());

	-- Check if snake can move south, then west, then east, then north
	if (self.Maze_Properties.grid[row+1][col].occupied == false) then		-- South
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row+1, col);
		self:Move_to_Pos(frameTime, pos);
	elseif (self.Maze_Properties.grid[row][col-1].occupied == false) then	-- West
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row, col-1);
		self:Move_to_Pos(frameTime, pos);
	elseif (self.Maze_Properties.grid[row][col+1].occupied == false) then	-- East
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row, col+1);
		self:Move_to_Pos(frameTime, pos);
	elseif (self.Maze_Properties.grid[row-1][col].occupied == false) then	-- North
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row-1, col);
		self:Move_to_Pos(frameTime, pos);
	end
	--Log(tostring(self:GetPos().x) .. tostring(self.pos.x));
	
end
