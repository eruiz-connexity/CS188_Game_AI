----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     Maze2 Table Declaration                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

Maze2 = {
  type = "Maze2",                                   -- can be useful for scripting

  -- Directions in Maze2 (For example: Going north from current position means going up 1 in y axis)
    directions = {
        north = {x = 0, y = 1},
        east = {x = 1, y = 0},
        south = {x = 0, y = -1},
        west = {x = -1, y = 0},
    },
    
  -- Instance vars
  Width = 0,
  Height = 0,
  Map = "",
  Model_Width = 0,
  Model_Height = 0,
  Model = "",
  CorridorSize = 0,
  Foods = 0,
  Traps = 0,
  Snakes = 0,
  
  OriginXY = {x=0, y=0, z=0},
  
  myWalls = {},
  myMice = {},
  mySnakes = {},
  myFoods = {
      Cheese = {},
      Berry = {},
      Grains = {},
      Potato = {},
      PowerBall = {},
  },
  myTraps = {},
  
  -- Copied from BasicEntity.lua
  Properties = {
     bPlayer = 0,
     bUsable = 0,
     iM_Width = 20,
     iM_Height = 20,
     
     iM_Foods = 5,
     iM_Traps = 10,
     iM_Snakes = 15,
     
     object_Model = "objects/default/primitive_cube.cgf",
     
     file_map_txt = "Scripts\\Entities\\maps\\map_default.txt",
     bMap_Save_TXT = 0,
     iM_CorridorSize = 1,
     entType = "Maze2",
     
     --Copied from BasicEntity.lua
     Physics = {
        bPhysicalize = 1, -- True if object should be physicalized at all.
        bRigidBody = 1, -- True if rigid body, False if static.
        bPushableByPlayers = 1,
    
        Density = -1,
        Mass = -1,
     },
  },
  
  

  -- optional editor information taken from BasicEntity.lua
  Editor = {
    Icon = "physicsobject.bmp",
    IconOnTop=1,
  },
  
    -- Read in Maze2 File to lines:
  Lines = {},
  
  --two dimensional table containing information about each cell (not door) in the maze
  --actually maybe don't want to do that
  --obj = {},
};

-- I DUNNO WTF THIS IS I COPIED FROM BasicEntity.lua
local Physics_DX9MP_Simple = {
  bPhysicalize = 1, -- True if object should be physicalized at all.
  bPushableByPlayers = 0,
    
  Density = 0,
  Mass = 0,
    
}

-- I dunno, make it usable?
--MakeUsable(Maze2);

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     Entity State Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function Maze2:OnInit()
	--Log("test reload script from maze");
	--Script.ReloadScript( "SCRIPTS/Entities/userdef/LivingEntityBase.lua");
	--Script.ReloadScript( "SCRIPTS/Entities/userdef/mouse.lua");
	--Script.ReloadScript( "SCRIPTS/Entities/userdef/Snake.lua");
	
	--Log("Reload Entity script");
	--Script.ReloadEntityScript("Mouse");
	
	--Log("Reload all scripts");
	--Script.ReloadScripts();

    Log("OnInit is running");
    self.Width = self.Properties.iM_Width
    self.Height = self.Properties.iM_Height
    self.Map = self.Properties.file_map_txt
    self.Model = self.Properties.object_Model
    self.CorridorSize = self.Properties.iM_CorridorSize
    self.Foods = self.Properties.iM_Foods
    self.Traps = self.Properties.iM_Traps
    self.Snakes = self.Properties.iM_Snakes
    
	local pos = self:GetPos();
	rounded_pos = {x = math.floor(pos.x + 0.5), y = math.floor(pos.y + 0.5), z = pos.z};
	self:SetPos(rounded_pos);
    self.Origin = self:GetPos()
    --self:OnReset()
    
    --self:SetupModel()
    --self:New()    
    self:SetFromProperties()
    self:New()  
end

function Maze2:OnPropertyChange()
    Log("OnPropertyChange is running");
    
    self:SetFromProperties();
    --self:OnReset();
    --self:SetupModel()
    self:New()
end

function Maze2:OnReset()
    Log("OnReset is running");
    --self:SetupModel()
    --self:New()
end

function Maze2:OnDestroy()
    self:RemoveWalls()
    self:RemoveMice()
    self:RemoveSnakes()
    self:RemoveFoods()
    self:RemoveTraps()
end
----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Helper Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function Maze2:SetupModel()
        
    local Properties = self.Properties;

    if(Properties.object_Model ~= "") then          -- Make sure objectModel is specified
        self:LoadObject(0,Properties.object_Model)  -- Load model into main entity
        
           local v1, v2 = self:GetLocalBBox()
           self:GetModelDimensions(v1,v2);
        
        if (Properties.Physics.bPhysicalize == 1) then -- Physicalize it
            self:PhysicalizeThis();
        end
        
    end
    
end

function Maze2:PhysicalizeThis() -- Helper function to physicalize, Copied from BasicEntity.lua
    -- Init physics.
  local Physics = self.Properties.Physics;
  if (CryAction.IsImmersivenessEnabled() == 0) then
    Physics = Physics_DX9MP_Simple;
  end
  EntityCommon.PhysicalizeRigid( self,0,Physics,self.bRigidBodyActive );
end

function Maze2:SetFromProperties()
    Log("In SetFromProperties")
    
    local Properties = self.Properties;
    
    if (Properties.object_Model == "") then
        do return end;
    end
       
    -- Free Spawn 
    local width, height, map, model, corSize, foods, traps, snakes = Properties.iM_Width, Properties.iM_Height, Properties.file_map_txt, Properties.object_Model, Properties.iM_CorridorSize, Properties.iM_Foods, Properties.iM_Traps, Properties.iM_Snakes
    self:RemoveWalls()
    self:RemoveMice()
    self:RemoveSnakes()
    self:RemoveFoods()
    self:RemoveTraps()
    
    self.Width = width
    self.Height = height
    self.Map = map
    self.Model = model
    self.CorridorSize = corSize
    self.Foods = foods
    self.Traps = traps 
    self.Snakes = snakes
    
    self:SetupModel();

end


----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     Maze2 Helper  Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function Maze2:RemoveWalls()
    Log("Removing All Walls")
    --self:PrintTable(self.myWalls)
    for k,v in pairs(self.myWalls) do

        --local EntID=System.GetEntityByName(v);
        --local EntID = System.GetEntityByName("WALLS");

        --System.RemoveEntity(EntID)
        System.RemoveEntity(v.id)
		self.myWalls[k] = nil;
        --v:DeleteThis()
        --v:TestDelete()
    end
    
end
function Maze2:RemoveMice()
    Log("Removing All Mice")
    --self:PrintTable(self.myMice)
    for k,v in pairs(self.myMice) do

        --local EntID=System.GetEntityByName(v);
        --local EntID = System.GetEntityByName("WALLS");

        --System.RemoveEntity(EntID)
        System.RemoveEntity(v.id)
        self.myMice[k] = nil;
        --v:DeleteThis()
        --v:TestDelete()
    end
    
end
function Maze2:RemoveSnakes()
    Log("Removing All Snakes")
    --self:PrintTable(self.mySnakes)
    for k,v in pairs(self.mySnakes) do

        --local EntID=System.GetEntityByName(v);
        --local EntID = System.GetEntityByName("WALLS");

        --System.RemoveEntity(EntID)
        System.RemoveEntity(v.id)
        self.mySnakes[k] = nil
        --v:DeleteThis()
        --v:TestDelete()
    end
    
end
function Maze2:RemoveFoods()
    Log("Removing All Foods")
    --self:PrintTable(self.myFoods)
    for key,value in pairs(self.myFoods) do  
        --Log("Key is: "..key)
        --Log("Printing Table value")
        --self:PrintTable(value)
        for key2,value2 in pairs(value) do
            --Log("Key2 is (Should be an int): "..key2)
            --Log("Printing Table value2, should be a food entity")
            System.RemoveEntity(value2.id)
            value[key2] = nil;
        end
    end
    
end
function Maze2:RemoveTraps()
    for k,v in pairs(self.myTraps) do

        System.RemoveEntity(v.id)
        self.myTraps[k] = nil

    end
end 

--Fills in border of Maze2 with blocks
function Maze2:Border()

    -- Get Height and Width
    local corridorSize = self:corridorSize();
    local height = 1+ (self:height()*(corridorSize+1));       
    local width = 1+ (self:width()*(corridorSize+1));
        
    --[[
        The reason its multiplied by 2 and 1 is added is to 
            1) Account for basic graph like version... meaning the lines become solid and take up non-infitesimal width 
            2) Keep size always OddxOdd (needed to ensure there is a border wall surrounding entire graph ...)
            
            Ex Graph: Three 3x3 grid, 9 rooms/cells, Each cell is separated by a wall ( wall is | or __ )
                Room 1 is at coordinates (1,1)
                Room 2 is at coordinates (2,1)
                Room 4 is at coordinates (1,2)
        y-axis _____________
             3 |_7_|_8_|_9_|
             2 |_4_|_5_|_6_|
             1 |_1_|_2_|_3_|
                 1   2   3   x-axis
                 
              Which is great on paper with lines to only be walls....
              But in a 3D env, the walls have thickness, they become blocks
              So to really make a 3room/cell x 3room/cell grid, the size actually has to be 3*2+1 by 3*2+1 => 7 by 7
              
              Ex: #'s are Walls, Open Cells/Rooms are numbered 1-9 like before
                  Room 1 is at coordinates (2,2)
                  Room 2 is at coordinates (4,2)
                  Room 4 is at coordinates (2,4)
          y-axis _____________________________
               7 |_#_|_#_|_#_|_#_|_#_|_#_|_#_|
               6 |_#_|_7_|_#_|_8_|_#_|_9_|_#_|
               5 |_#_|_#_|_#_|_#_|_#_|_#_|_#_|
               4 |_#_|_4_|_#_|_5_|_#_|_6_|_#_|
               3 |_#_|_#_|_#_|_#_|_#_|_#_|_#_|
               2 |_#_|_1_|_#_|_2_|_#_|_3_|_#_|
               1 |_#_|_#_|_#_|_#_|_#_|_#_|_#_|
                   1   2   3   4   5   6   7    x-axis
                   
               Overall this is a translation of (2x,2y) from orig (Room 1 used to be at (1,1) now it is at (2*1, 2*1) )
               
               Further each position in this graph will be referred to as a slot, the slot at coordinates (1,1) will be slot 1
               The slot at (2,1) will be slot 2 ... (7,1) will be slot 7. The slot at (1,2) will be 8...
               One can calculate the slot from the coordinates (x,y) with the formula: 
                    (y-1)*Width + x 
                        Ex: 
                            (1,1) -> (1-1)*7 + 1 = 1
                            (1,2) -> (2-1)*7 + 1 = 8
              
              Here is a graph with each slot labelled:
                    Keep in mind that the majority of these slots are walls
                        In fact, the only slots that are actually open rooms/cell are 
                            (2,2) is Room 1 -> Slot 9 -> this is open cell/room 1 in graph above 
                            (4,2) is Room 2 -> slot 11                        
                        
                   y-axis ____________________________________
                        7 |_43_|_44_|_45_|_46_|_47_|_48_|_49_|
                        6 |_36_|_37_|_38_|_39_|_40_|_41_|_42_|
                        5 |_29_|_30_|_31_|_32_|_33_|_34_|_35_|
                        4 |_22_|_23_|_24_|_25_|_26_|_27_|_28_|
                        3 |_15_|_16_|_17_|_18_|_19_|_20_|_21_|
                        2 |_8 _|_9 _|_10_|_11_|_12_|_13_|_14_|
                        1 |_1 _|_2 _|_3 _|_4 _|_5 _|_6 _|_7 _|
                            1     2   3    4    5    6    7    x-axis
              
              To Further specify the walls into categories, there are some that are a border (i.e. never broken down to create a path) and 
              others that can be broken down to create a path (Doors). 
              For the sake of simplicity, consider doors to be the walls North, East, South, and West of a room
              For example cells (2,7), (3,6), (2,5), and (1,6) will be considered doors (despite the fact that (1,6) and (2,7) cannot be opened)
                because they are North, East, South, and West of a Room 7
              The walls that are not adjacent to a room will be considered a border 
              This distinction doesn't really matter, it just explains that the for loop below that "create border" just fills in these border walls  
              
              Thus Create Border on the graph:
          y-axis _____________________________
               7 |_B_|_#_|_B_|_#_|_B_|_#_|_B_|
               6 |_#_|_7_|_#_|_8_|_#_|_9_|_#_|
               5 |_B_|_#_|_B_|_#_|_B_|_#_|_B_|
               4 |_#_|_4_|_#_|_5_|_#_|_6_|_#_|
               3 |_B_|_#_|_B_|_#_|_B_|_#_|_B_|
               2 |_#_|_1_|_#_|_2_|_#_|_3_|_#_|
               1 |_B_|_#_|_B_|_#_|_B_|_#_|_B_|
                   1   2   3   4   5   6   7    x-axis
               
               where B is what has been filled in with walls so far
    ]]
        
    local bGap = corridorSize+1
    -- Create Border
    for y=1, height, bGap do 
        for x=1, width, bGap do
            
            self:Wall(x,y); -- This function takes an x and y coord on the graph and fills in a wall
            
        end
    end
end

-- fills in "doors" of Maze2 with blocks
    --Never actually used, made for testing purposes
function Maze2:DoorSpawn()
    
    local corridorSize = self:corridorSize();
    local height = 1+ (self:height()*(corridorSize+1));       
    local width = 1+ (self:width()*(corridorSize+1));
    
    --[[ 
        Same as the comment block in CreateBorder
        This time we fill in the walls for "Door"
        Effectively Making:
        
         y-axis  _____________________________
               7 |_B_|_D_|_B_|_D_|_B_|_D_|_B_|
               6 |_D_|_7_|_D_|_8_|_D_|_9_|_D_|
               5 |_B_|_D_|_B_|_D_|_B_|_D_|_B_|
               4 |_D_|_4_|_D_|_5_|_D_|_6_|_D_|
               3 |_B_|_D_|_B_|_D_|_B_|_D_|_B_|
               2 |_D_|_1_|_D_|_2_|_D_|_3_|_D_|
               1 |_B_|_D_|_B_|_D_|_B_|_D_|_B_|
                   1   2   3   4   5   6   7    x-axis
               
               Where all the every non room cell is now a wall 
               (B and D are both walls and are essentially the same. 
               B is what was filled in in the createBorder function, D is what was filled in here)
               
    ]]
    
    
    local dGap = corridorSize+1;
    -- For Each Room:
    for y = 1, height, dGap do
        for x=1, width, dGap do 
            -- Door Bottom & Left
                for i = 1, corridorSize do
                    --Log("Dooring (%d, %d)", x+i, y)
                    if(x+i <= width) then
                        self:Wall(x+i, y)
                    end
                   -- Log("Dooring (%d, %d)", x, y+i)
                    if(y+i <= height) then
                        self:Wall(x, y+i)
                    end
                end 
        end
    end 
end

function Maze2:wh_to_nslot(w, h) 
  local width = 1+ self:width()*(self:corridorSize()+1)
  return ((h-1)*width + w)
end

function Maze2:rowcol_to_nslot(row, col)
  local h = row;
  local w = col;
  local width = 1+ self:width()*(self:corridorSize()+1);
  return(h-1)*width + w;
end

function Maze2:wh_to_pos(w, h)
  return {x = self.Model_Width*(w-1) + self.Origin.x, 
    y = self.Model_Height*(h-1) + self.Origin.y};
end

function Maze2:rowcol_to_pos(row, col) 
  local h = row;
  local w = col;
  return {x = self.Model_Width*(w-1) + self.Origin.x, 
    y = self.Model_Height*(h-1) + self.Origin.y, z = self:GetPos().z};
end

function Maze2:pos_to_rowcol(pos) 

  local x = pos.x;
  local y = pos.y;

  local offset_x = x - self.Origin.x;
  local offset_y = y - self.Origin.y;

  local offset_blocks_x = offset_x/self.Model_Width;
  local offset_blocks_y = offset_y/self.Model_Height;

  local grid_dec_x = offset_blocks_x + 1;
  local grid_dec_y = offset_blocks_y + 1;

  return {col = math.floor(grid_dec_x+0.5), 
          row = math.floor(grid_dec_y+0.5)};

end

function Maze2:pos_to_cellrowcol(pos)
	local rowcol = self:pos_to_rowcol(pos);
	return self:rowcol_to_cellrowcol(rowcol.row, rowcol.col);
end

function Maze2:rowcol_to_cellrowcol(row, col) 
	--row = row - 1;
	--col = col - 1;
	local cell_row_dec = (row - 1) / (self:corridorSize() + 1);
	local cell_col_dec = (col - 1) / (self:corridorSize() + 1);
	local cell_row = math.floor(cell_row_dec + 1)
	local cell_col = math.floor(cell_col_dec + 1)
	Log("cell_row_dec" .. tostring(cell_row_dec) .. "," .. tostring(math.floor(cell_row_dec)));
	Log("cell_col_dec" .. tostring(cell_col_dec) .. "," .. tostring(math.floor(cell_col_dec)));

	if math.floor(cell_col_dec) == cell_col_dec or math.floor(cell_row_dec) == cell_row_dec then
		return {row = -1, col = -1};
	else
		return {row = cell_row, col = cell_col}
	end
end

function Maze2:cellrowcol_to_rowcol(cell_row_arg, cell_col_arg)
	local cell_row = cell_row_arg - 1;
	cell_row = cell_row * (self:corridorSize() + 1) + 1 + math.floor(self:corridorSize()/2 + 0.5);
	local cell_col = cell_col_arg - 1;
	cell_col = cell_col * (self:corridorSize() + 1) + 1 + math.floor(self:corridorSize()/2 + 0.5);
	return {row = cell_row, col = cell_col};
end

function Maze2:cellrowcol_to_pos(cell_row, cell_col) 
	local rowcol = self:cellrowcol_to_rowcol(cell_row, cell_col);
	return self:rowcol_to_pos(rowcol.row, rowcol.col); 
end

-- Spawn a wall at coordinates (w,h)
function Maze2:Wall(w, h)
        
        local Properties = self.Properties;
        local width = 1+ self:width()*(self:corridorSize()+1)
        local nSlot = (h-1)*width + w;
        
        local objX = self.Model_Width;
        local objY = self.Model_Height;

        if self.Origin.x == 0 then 
            self.Origin = self:GetPos()
        end 
        local xOffset = self.Origin.x;
        local yOffset = self.Origin.y;
        local sx = objX*(w-1) + xOffset
        local sy = objY*(h-1) + yOffset

        --Log("Spawning at (%d, %d)", sx, sy);
        local spawnPos = {x=sx,y=sy,z=32}
        local dVec = self:GetDirectionVector()
        --LogVec("Maze orientation: ", dVec)
        local params = {
            class = "Maze_Wall";
            name = "WALLS";
            position = spawnPos;
            orientation = dVec;
            properties = {
                object_Model = self.Model;
            };
        };
        
        local newWall = System.SpawnEntity(params);
        --newWall:test()
        self.myWalls[nSlot] = newWall;
           
        --[[
            This is because the block object model we use is actually 2x2
            thus, we have to multiply by 2 so the blocks don't overlap
            I subtract 1, because the position actually starts at (0,0), and our graph/(lua tables) starts at 1
            Hence what we actually have for reals looks something like:
                Ex:
                
           y-axis ___________________________________________
            12,13 |_ # _|_ # _|_ # _|_ # _|_ # _|_ # _|_ # _|
            10,11 |_ # _|_ 7 _|_ # _|_ 8 _|_ # _|_ 9 _|_ # _|
              8,9 |_ # _|_ # _|_ # _|_ # _|_ # _|_ # _|_ # _|
              6,7 |_ # _|_ 4 _|_ # _|_ 5 _|_ # _|_ 6 _|_ # _|
              4,5 |_ # _|_ # _|_ # _|_ # _|_ # _|_ # _|_ # _|
              2,3 |_ # _|_ 1 _|_ # _|_ 2 _|_ # _|_ 3 _|_ # _|
              0,1 |_ # _|_ # _|_ # _|_ # _|_ # _|_ # _|_ # _|
                    0,1   2,3   4,5   6,7   8,9  10,11 12,13   x-axis                
        ]]

end

-- Alright, main Maze2 gen code that calls other helper function
function Maze2:New()
    Log("In New");
    
    local Properties = self.Properties;
  local success = false;
  if (Properties.file_map_txt ~= "") then
        Log("Map property isn't empty");
        success = self:ReadMaze2();
        --Properties.file_map_txt = "";
  end
    
    if (not success) then
        Log("Map property was empty");
        obj = obj or {}         -- Our 2d array that is the graph version of the Maze2 with infinitesimally thin walls... so (1,1) is actually Room 1, which is really at (2,2) in the world
        setmetatable(obj, self)
        self.__index = self
        
        local width = self:width()   -- Returns width of graph with infinitesimally thin walls, so essentially its #rooms wide, not actual width which would be width*2+1
        local height = self:height() -- #rooms tall
        
        self:Border(); -- Fill in border cells with walls
        self:DoorSpawn();
        -- Setup Maze2
            -- For each room in 2d array, record that there is a closed door (i.e. wall) in each direction
            -- Effectively doing what DoorSpawn() does, filling in remaining walls
        for y = 1, height do
            obj[y] = {}
            for x = 1, width do
                obj[y][x] = { east = obj:CreateDoor(true), north = obj:CreateDoor(true)}
                --CreateDoor records that there is a wall there via bool value in 2d array that is obj[y][x], and fills wall in in actual 3D real world graph
                                            
            -- Doors are shared beetween the cells to avoid out of sync conditions and data dublication
            if x ~= 1 then obj[y][x].west = obj[y][x - 1].east
            else obj[y][x].west = obj:CreateDoor(true) end
            
            if y ~= 1 then obj[y][x].south = obj[y -1 ][x].north
            else obj[y][x].south = obj:CreateDoor(true) end
            end
        end
        
        --[[
            At this point we have setup the following in the world:

            y-axis  _____________________________
                7 |_B_|_D_|_B_|_D_|_B_|_D_|_B_|
                6 |_D_|_7_|_D_|_8_|_D_|_9_|_D_|
                5 |_B_|_D_|_B_|_D_|_B_|_D_|_B_|
                4 |_D_|_4_|_D_|_5_|_D_|_6_|_D_|
                3 |_B_|_D_|_B_|_D_|_B_|_D_|_B_|
                2 |_D_|_1_|_D_|_2_|_D_|_3_|_D_|
                1 |_B_|_D_|_B_|_D_|_B_|_D_|_B_|
                    1   2   3   4   5   6   7    x-axis
                
                Where all the every non room cell is now a wall 
                (B and D are both walls and are essentially the same. 
                B is what was filled in in the createBorder function, D is what was filled in here)
            
            The obj 2d array representation we are using in the code actually would look someting like:
                    c stands for a closed door
                    # are implicit walls, not actually stated anywhere, just to make illustration more understandable...
                    
            y-axis   # c # c # c #
                    3   c 7 c 8 c 9 c
                    2   c 4 c 5 c 6 c
                    1   c 1 c 2 c 3 c
                        # c # c # c #
                        1   2   3   x-axis
        ]]
        
        obj:GrowingTree(); -- This function calls the growing tree algorithm to start opening doors to create a Maze2 

       -- obj:PhysicalizeWallSlots(); -- The Maze2 has been complete, make the walls of the Maze2 actually physical (i.e. cant go walk them)
   end
   
   self:SpawnMice()
   self:SpawnSnakes(self.Snakes)
   self:SpawnFood(self.Foods)
   self:SpawnTraps(self.Traps)
  
end

--Door class/ called to create doors
    -- Records there is a door adjacent to room in obj (The 2d graph with infinitesimally small walls)
    -- Fills in the real world coordinates with a wall
function Maze2:CreateDoor(closed, h, w)

    local door = {}
    door.closed = closed and true or false -- records that door is closed  (e.g. door=true)
    
    --self:Wall(w,h)  -- Fills in block object in world at real world coordinates (w,h)
    
    -- Never used
    function door:IsClosed()
        return self.closed
    end

    -- Never used
    function door:IsOpened()
        return not self.closed
    end

    -- Never used
    function door:Close()
        self.closed = true
    end

    -- Mark that the door is open, to avoid opening repeatedly
    function door:Open()
        self.closed = false

    end

    -- Never used
    function door:SetOpened(opened)
        if opened then
            self:Open()
        else
            self:Close()
        end
    end

    -- Never used
    function door:SetClosed(closed)
        self:SetOpened(not closed)
    end

    return door -- Returns door object
end

-- Removes the wall at the slot number s
function Maze2:OpenDoor(s)
    --Log("Freeing Slot: %d", s)
    self.myWalls[s]:DeleteThis();
  self.myWalls[s] = nil;
    --Log("Freed")
end

-- Returns a list of adjacent rooms to the room at coordinates (x,y) that have not yet been visited
-- Validator is a function that can be passed in to determine if room has been visited
    -- different validator functions could produce interesting effects...
function Maze2:DirectionsFrom(x, y, validator)
    local directions = {} -- List of unvisted adjacent rooms to (x,y)
    validator = validator or function() return true end
    
    --  calculate the coordinates to the adjacent room in each direction (North, East, South, West)
        -- Name is thus either North, East, South, or West
        -- Shift becomes the coordinate adj to get there
            -- E.g. name = North, Shift = {x=0, y=-1}
    for name, shift in pairs(self.directions) do
        local x,y = x + shift.x, y + shift.y    -- x = x+ ajustX,   y = y+ adjstY (Ex: north -> x= x+0, y= y-1)
        
        -- If its a valid coordinate (within graph bounds) and not visited (validator function)
        if self[y] and self[y][x] and validator(self[y][x], x, y) then
            -- add coordinates to that adjacent room to list of unvisted adjacent rooms
            directions[#directions+1] = {name = name, x = x, y = y}
        end
    end
    
    return directions  -- Return list of coordinates for unvisted adjacent rooms.
end



-- Returns number of open room (no walls/walls inf thin) wide
function Maze2:width()
    local Properties = self.Properties;
    local width = Properties.iM_Width
    return width
end

-- Returns number of open room high
function Maze2:height()
    local Properties = self.Properties;
    local height = Properties.iM_Height
    return height
end

function Maze2:corridorSize()
    local Properties = self.Properties;
    local cSize = Properties.iM_CorridorSize
    return cSize
    --return self.CorridorSize
end

-- OOO Buddy, the fun part, picking the doors to unlock to make a Maze2
    -- This is the growing tree algorithm...
        --[[
            "
            1) Let C be a list of cells, initially empty. Add one cell to C, at random.
            2) Choose a cell from C, and open door to any unvisited adjacent room of that cell, adding that neighbor to C as well. If there are no unvisited neighbors, remove the cell from C.
            3) Repeat #2 until C is empty.
            
            fun lies in how you choose the cells from C, in step #2. If you always choose the newest cell (the one most recently added), you�ll get the recursive backtracker. 
            If you always choose a cell at random, you get Prim�s. It�s remarkably fun to experiment with other ways to choose cells from C.
            " 
                - The Buck Blog
                
             Thus in this implementation, you can change, how C is selected in step 2 by specifying a selector function
             The default is a random Cell, which gives us Prim's algorithm
        ]]
function Maze2:GrowingTree(selector)
    Log("In GrowingTree");
    selector = selector or function (list) return random(#list) end
    local cell = { x = random(self:width()), y = random(self:height()) } -- Select a random cell (Step 1)
    self[cell.y][cell.x].visited = true -- Mark as visited
    local list = { cell } -- Add random cell to list (also step 1)
    
    local width = self:width()
    local corridorSize = self:corridorSize()
    local realWidth = 1+ width*(self:corridorSize()+1)
    
    -- Until all neighboring cells have been visited
    while #list ~= 0 do
        local rnd_i = selector(list)
        cell = list[rnd_i]  -- Step 2, choose random cell from list (Prim's alg)

        -- Step 2, Get list of unvisted adjacent cells.
        local directions = self:DirectionsFrom(cell.x, cell.y, function (cell) return not cell.visited end)

        -- If only 1 way left to go
        if #directions < 2 then
            list[rnd_i] = list[#list]
            list[#list] = nil
        end
        
        -- If multiple ways to go
        if #directions ~= 0 then 
        
            --Log("Visiting (%d, %d)", 2*cell.x, 2*cell.y);
            --Log("This is slot: %d", (2*cell.y-1)*(2*width+1) + 2*cell.x);
            
            -- local var that tells us which direction we went (North, East, South, or West)
            local dirn = directions[random(#directions)]
                       
            --Log("Going direction " .. dirn.name .. "To the cell (%d, %d), which is slot: %d", dx*2, dy*2, (2*dy-1)*(2*width+1) + 2*dx);
            
            local incX = self.directions[dirn.name].x;
            local incY = self.directions[dirn.name].y;
             
            local nX, nY = self:CoordTransform(cell.x, cell.y)
            
            if (incX > 0) then 
                incX = incX*corridorSize
            elseif (incY > 0) then 
                incY = incY*corridorSize
            end 
            
            local s = ((nY-1)+incY)*(realWidth) +nX+incX; -- Slot of first door
            self:OpenDoor(s);
            
            for d=2, corridorSize do
                -- Free East or West doors...
                if (incX ~= 0) then 
                    s = s+realWidth
                elseif (incY ~= 0) then -- Free North or south doors
                    s = s+1
                end
               
                self:OpenDoor(s);                       -- Remove wall in world that represented the door
            end
            
            self[cell.y][cell.x][dirn.name]:Open()  -- Mark door as opened
            self[dirn.y][dirn.x].visited = true     -- Mark cell as visited
            list[#list + 1] = { x = dirn.x, y = dirn.y }  -- Add the new room just visted to list of cells that we can start branching out from
        end

    end
        
   -- Save generated map in maps folder
   if self.Properties.bMap_Save_TXT == 1 then
        Log("Saving...");
        self:PrintMaze2();
   end

end

--[[
function Maze2:PhysicalizeWallSlots()  
    local width, height = self:width()*2 + 1, self:height()*2+1
 
    for i = 1, width*height do 
            if(self:IsSlotValid(i)) then
                self:PhysicalizeSlot(i,  {mass=0});
            end
    end 
 
end
]]

    -- Takes what is in obj and prints it out to a txt file
function Maze2:PrintMaze2(txtName) -- Optional parameter to name map
    Log("In PrintMaze2");
    local width = self:width()--*2+1;
    local height = self:height()--*2+1;
    
    local realWidth = 1+width*(self:corridorSize()+1)
    local start_path = "C:\\Amazon\\Lumberyard\\1.1.0.0\\dev\\GameSDK\\Scripts\\Entities\\maps\\";

    --local all_maps = self:Scandir(start_path);
    --local num_maps = #all_maps;
    
    local txt = txtName or "map_".."temp"

    Log("txt is: "..txt);
    local path = start_path..txt..".txt";
    Log("path is: "..path);
    local file = io.open(path, "w");
    
    io.output(file)
    local corSize = self.CorridorSize;
    local corridorSizeSetting = "S= "..corSize.."\n"
    file:write(corridorSizeSetting)     
     
   -- Top border
    for x = 1, realWidth do
        file:write("X");
    end
    file:write("\n");
    
    local curLine = ""
    -- Insides
    for y = height, 1, -1 do 
        curLine = ""
        for x = 1, width do
        
            -- Fill in walls by checking if there is a door to the west
            if(self[y][x].west.closed) then 
                --file:write("XO")
                curLine = curLine.."XO"
            else
                --file:write("OO")
                curLine = curLine.."OO"
            end
            -- Add additional corridor Width Size 
            for d=2, corSize do
                --file:write("O")
                curLine = curLine.."O"
            end
            
            -- Edge case (Must fill in right vertical border)
            if(x == width) then
                --file:write("X")
                curLine = curLine.."X"
            end 
            
        end
        curLine = curLine.."\n"
        for d=1, corSize do
            file:write(curLine)
        end
        
        curLine = "X"
        -- Next Line, vertical border left side
        --file:write("\n");
       -- file:write("X");
        
        for x = 1, width do 
            
            if(self[y][x].south:IsClosed()) then 
                --file:write("XX")
                for d=1, corSize+1 do
                    curLine = curLine.."X"
                end
            else 
                --file:write("OX")
                for d=1, corSize do
                    curLine = curLine.."O"
                end
                curLine = curLine.."X"
            end 
            
        end 
        
        curLine = curLine.."\n"
        
        file:write(curLine);
        
    end
    
    io.close(file)
    
    local Properties = self.Properties;
    Properties.file_map_txt = "Scripts\\Entities\\maps\\"..txt..".txt";
    
end

-- Reads in a txt file Maze2 and creates it in the world
function Maze2:ReadMaze2(my_Maze2_file)
    Log("In ReadMaze2");
    
    local file_str;
    local Properties = self.Properties;
    
    -- Open a file for read and test that it worked
    local file_str = my_Maze2_file or self.Properties.file_map_txt;
    --Log(file_str);
    
    local path = "C:\\Amazon\\Lumberyard\\1.1.0.0\\dev\\GameSDK\\"..file_str;--..".txt";
    local file, err = io.open(path, "r");
    if err then Log("Maze2 file does not exist");  return false; end
    
    Log("Opened Map.txt");
    
    io.input(file);
    -- Line by line
    local lines = {}
    for line in io.lines() do 
        lines[#lines + 1] = line
    end
    
    if #lines > 0 then
        Maze2.Lines = lines
    end 
        
    --file:close();
    io.close(file);
    
    -- Get CorSize if it exists
    local corSize = 1
    local h, w = 0,0
    local cSizeSetting = lines[1]
    if (cSizeSetting.sub(1, 3) == "S= ") then
        h = 1
        corSize = tonumber(cSizeSetting.sub(3, -1))
    end
    
    -- Set iWidth and iHeight
    Properties.iM_Height =   ((#lines - h)-1)/(corSize+1)
    Properties.iM_Width = (#lines[2]-1)/(corSize+1)
    Properties.iM_CorridorSize = corSize
    
    -- Call setFromProperties
    self:SetFromProperties();
    
    self:LinesToWorld(lines);
    
    return true;
end

-- takes a 2D array Maze2 and creates it in world
function Maze2:LinesToWorld(map_lines)
    
    Log("In LinesToWorld");
    
    local corridorSize = self:corridorSize()
    local lines = map_lines or Maze2.Lines;
    local width = #lines[1]
    local height = #lines
    
    for k,v in pairs(lines) do
        --print('line[' .. k .. ']', v)
        for i = 1, #v do
            local c = v:sub(i,i)
            
            if (c == "X" ) then
                self:Wall(i, height+1-k);
            end
            
        end
    end
    
   -- self:PhysicalizeWallSlots();
    
end

function Maze2:GetModelDimensions(v1, v2)
    local v = { x=0, y=0, z=0}
    SubVectors(v, v2, v1)
    self.Model_Width = v.x
    self.Model_Height = v.y;
    --Log("Model_Width = %d, Model_Height = %d", v.x, v.y);
end

-- Determine Map numbers 
-- Lua implementation of PHP scandir function
function Maze2:Scandir(directory)
    Log("In ScanDir")
    local i, t, popen = 0, {}, io.popen                 -- POPEN NOT SUPPORT ARRRRGH
    local pfile = popen('ls -a "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function Maze2:CoordTransform(x,y)
    local Properties = self.Properties;
    local corridorSize =  Properties.iM_CorridorSize;
    
    local nX = 2*x + ((corridorSize-1)*(x-1))
    local nY = 2*y + ((corridorSize-1)*(y-1))
    return nX, nY
end

function Maze2:SpawnMice()

        if( self.Properties.bPlayer == 1) then return end;
        Log("Spawning Mice")
        local w, h = 2,4
        local Properties = self.Properties;
        local width = 1+ self:width()*(self:corridorSize()+1)
        local nSlot = (h-1)*width + w;
        
        local objX = self.Model_Width;
        local objY = self.Model_Height;

        if self.Origin.x == 0 then 
            self.Origin = self:GetPos()
        end 
        local xOffset = self.Origin.x;
        local yOffset = self.Origin.y;
        local sx = objX*(w-1) + xOffset
        local sy = objY*(h-1) + yOffset

        --Log("Spawning at (%d, %d)", sx, sy);
        local spawnPos = {x=sx,y=sy,z=33}
        local dVec = self:GetDirectionVector()
        local spawnClass = "Mouse"
        if(self.Properties.bPlayer == 1) then 
            spawnClass = "MousePlayer"
        end 
        --LogVec("Maze orientation: ", dVec)
        local params = {
            class = spawnClass;
            name = "M";
            position = spawnPos;
            orientation = dVec;
           -- scale = 3;
            properties = {
                bActive = 1;
              --  object_Model = self.Model;
            };
        };
        
        local mouse = System.SpawnEntity(params);
       -- mouse:SetScale(3)
          self.myMice[#self.myMice+1] = mouse;

end

function Maze2:SpawnSnakes(num)
        local Properties = self.Properties;
        local width = 1+ self:width()*(self:corridorSize()+1)
        local height = 1+ (self:height()*(self:corridorSize()+1));     
        
        local nSlot
        
        for i =1, num do
            -- Get random open coord
            local h = random(2, height)
            if h < 1 then h = h+1 end
            --if h%2 ~= 0 and h > 0 then h = h-1 end
            
            local w = random(2, width)
            if w < 1 then w = w+1 end
            --if w%2 ~= 0 and w > 0 then w = w-1 end 
            
            -- Make sure its not Mouse position 
            if w == 2 then w = w+1+self:corridorSize() end 
            
            -- Check if wall there 
            nSlot = (h-1)*width + w;
            if(self.myWalls[nSlot] ~= nil) then 
                w = w-1;
                nSlot = (h-1)*width + w;
                if(self.myWalls[nSlot] ~= nil) then 
                    h = h-1
                end 
            end 
            
            -- Spawn Logic
            local objX = self.Model_Width;
            local objY = self.Model_Height;

            if self.Origin.x == 0 then 
                self.Origin = self:GetPos()
            end 
            local xOffset = self.Origin.x;
            local yOffset = self.Origin.y;
            local sx = objX*(w-1) + xOffset
            local sy = objY*(h-1) + yOffset

            --Log("Spawning at (%d, %d)", sx, sy);
            local spawnPos = {x=sx,y=sy,z=32}
            --local dVec = self:GetDirectionVector()
            --LogVec("Maze orientation: ", dVec)
            local params = {
                class = "Snake";
                name = "S";
                position = spawnPos;
                --orientation = dVec;
                properties = {
                    bActive = 1;

                    --initial_direction = "up",
                --  object_Model = self.Model;
                };
            };

            local snake = System.SpawnEntity(params);
            snake.direction = snake.directions[up];

            self.mySnakes[#self.mySnakes+1] = snake;
        end
                    
end

function Maze2:SpawnFood(nCheese, nBerry, nPotato, nGrains, powerBallProb)
        
        local numCheese = nCheese or 3
        local numBerry = nBerry or numCheese
        local numPotato = nPotato or numCheese
        local numGrains = nGrains or numCheese
        local PB_Prob = powerBallProb or self:corridorSize()
        
        local width = 1+ self:width()*(self:corridorSize()+1)
        local height = 1+ (self:height()*(self:corridorSize()+1));  
        local nSlot = 0   
        local w = 2
        local h = 2
        
        -- Spawn Cheese
        while #self.myFoods.Cheese < numCheese do
            -- NorthEast
            w = random(math.ceil(width/2), width)
            --if w%2 ~= 0 then w = w-1 end
            h = random(math.ceil(height/2), height)
            --if h%2 ~= 0 then h = h-1 end
            
            -- Check if wall there 
            nSlot = (h-1)*width + w;
            if(self.myWalls[nSlot] ~= nil) then 
                w = w-1;
                nSlot = (h-1)*width + w;
                if(self.myWalls[nSlot] ~= nil) then 
                    h = h-1
                end 
            end 
            
            self.myFoods.Cheese[#self.myFoods.Cheese+1] = self:FoodSpawnHelper(w,h,"Cheese")
            --Log("Cheese Added, Should not be empty...")
            --self:PrintTable(self.myFoods)
        end
        
        -- Spawn Berry 
        while #self.myFoods.Berry < numBerry do
            -- NorthWest
            w = random(2, math.floor(width/2))
            --if w%2 ~= 0 then w = w-1 end
            h = random(math.ceil(height/2), height)
            --if h%2 ~= 0 then h = h-1 end
            
            -- Check if wall there 
            nSlot = (h-1)*width + w;
            if(self.myWalls[nSlot] ~= nil) then 
                w = w-1;
                nSlot = (h-1)*width + w;
                if(self.myWalls[nSlot] ~= nil) then 
                    h = h-1
                end 
            end 
            
            self.myFoods.Berry[#self.myFoods.Berry+1] = self:FoodSpawnHelper(w,h,"Berry")
            
        end
        
        -- Spawn Potato
        while #self.myFoods.Potato < numPotato do
            -- South East
            w = random(math.ceil(width/2), width)
            --if w%2 ~= 0 then w = w-1 end
            h = random(2, math.floor(height/2))
            --if h%2 ~= 0 then h = h-1 end
            
            -- Check if wall there 
            nSlot = (h-1)*width + w;
            if(self.myWalls[nSlot] ~= nil) then 
                w = w-1;
                nSlot = (h-1)*width + w;
                if(self.myWalls[nSlot] ~= nil) then 
                    h = h-1
                end 
            end 
            
            self.myFoods.Potato[#self.myFoods.Potato+1] = self:FoodSpawnHelper(w,h,"Potato")
        end
        
        -- Spawn Grains
        while #self.myFoods.Grains < numGrains do 
            -- South West
            w = random(2, math.floor(width/2))
            --if w%2 ~= 0 and w > 0 then w = w-1 end
            h = random(2, math.floor(height/2))
            --if h%2 ~= 0 then h = h-1 end
            
            -- Check if wall there 
            nSlot = (h-1)*width + w;
            if(self.myWalls[nSlot] ~= nil) then 
                w = w-1;
                nSlot = (h-1)*width + w;
                if(self.myWalls[nSlot] ~= nil) then 
                    h = h-1
                end 
            end 
            
            self.myFoods.Grains[#self.myFoods.Grains+1] = self:FoodSpawnHelper(w,h,"Grains")
        end
        
        -- Spawn PowerBalls
        local i = 0
        while i < PB_Prob do 
            
            if(PB_Prob > random(10)) then 
                w = random(2, width) 
                --if w%2 ~= 0  then w = w-1 end
            
                h = random(2, height)
                --if h%2 ~= 0  then h = h-1 end
                
                -- Check if wall there 
                nSlot = (h-1)*width + w;
                if(self.myWalls[nSlot] ~= nil) then 
                    w = w-1;
                    nSlot = (h-1)*width + w;
                    if(self.myWalls[nSlot] ~= nil) then 
                        h = h-1
                    end 
                end 
                
                self.myFoods.PowerBall[#self.myFoods.PowerBall+1] = self:FoodSpawnHelper(w,h,"PowerBall")
            end
           
           i = i+1
           
        end
    
      
end

function Maze2:FoodSpawnHelper(w,h, foodType)
        local Properties = self.Properties;
        local width = 1+ self:width()*(self:corridorSize()+1)

        local objX = self.Model_Width;
        local objY = self.Model_Height;

        if self.Origin.x == 0 then 
            self.Origin = self:GetPos()
        end 

        local xOffset = self.Origin.x;
        local yOffset = self.Origin.y;
        
        local sx = objX*(w-1) + xOffset
        local sy = objY*(h-1) + yOffset

        local spawnPos = {x=sx,y=sy,z=32}
       -- local dVec = self:GetDirectionVector()

--[[
        local foodType = ""

        if w > self:width() and h > self:height() then
            -- North Easst
            foodType = "Berry"
        elseif w > self:width() and h <= self:height() then
            --North Wesst
            foodType = "Cheese"
        elseif w <=  self:width() and h > self:height() then
            -- South Easst
            foodType = "Potato"
        elseif w <= self:width() and h <= self:height() then
            -- South Wesst
            foodType = "Grains"
        end
]]

        local params = {
            class = "Food";
            name = "F";
            position = spawnPos;
            --orientation = dVec;
            properties = {
                esFoodType = foodType
              --  object_Model = self.Model;
            };
        };

        local food = System.SpawnEntity(params);
        return food
end

function Maze2:SpawnTraps(num)
        Log("Spawning Traps")
            
        local w, h = 2, 16
        local Properties = self.Properties;
        
        local width = 1+ self:width()*(self:corridorSize()+1)
        local height = 1+ (self:height()*(self:corridorSize()+1));     
             
        local objX = self.Model_Width;
        local objY = self.Model_Height;

        if self.Origin.x == 0 then 
            self.Origin = self:GetPos()
        end 
        local xOffset = self.Origin.x;
        local yOffset = self.Origin.y;
       
        local i = 0;
        while i < num do
        
            local tClass = "Trap1"
            local tName = "Spring"
            local tModel = "objects/default/primitive_box.cgf"
            
            local trapType = random(2)
            if(trapType > 1) then 
                tClass = "Trap2"
                tName = "Thwomp"
                tModel = "objects/default/primitive_cube.cgf"
            end
            
            i = i +1
            local w = random(2, width) 
            --if w%2 ~= 0  then w = w-1 end
            local h = random(2, height)
            --if h%2 ~= 0  then h = h-1 end
            
            -- Check if wall there 
            nSlot = (h-1)*width + w;
            if(self.myWalls[nSlot] ~= nil) then 
                w = w-1;
                nSlot = (h-1)*width + w;
                if(self.myWalls[nSlot] ~= nil) then 
                    h = h-1
                end 
            end 
           
            local sx = objX*(w-1) + xOffset
            local sy = objY*(h-1) + yOffset

            --Log("Spawning at (%d, %d)", sx, sy);
            local spawnPos = {x=sx,y=sy,z=32}
            local dVec = self:GetDirectionVector()
            --LogVec("Maze orientation: ", dVec)
            local params = {
                class = tClass or "Trap1";
                name = tName or "Spring";
                position = spawnPos;
                --orientation = dVec;
                properties = {
                    bActive = 1;
                    object_Model = tModel or "objects/default/primitive_box.cgf";
                --  object_Model = self.Model;
                };
            };
            
            local Trap = System.SpawnEntity(params);
            
            self.myTraps[#self.myTraps+1] = Trap;
        end    
end

function Maze2:PrintTable(t)

    local print_r_cache={}

    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            Log(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        Log(indent.."["..pos.."] => "..tostring(t).." {")

                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))

                        Log(indent..string.rep(" ",string.len(pos)+6).."}")

                    elseif (type(val)=="string") then

                        Log(indent.."["..pos..'] => "'..val..'"')

                    else

                        Log(indent.."["..pos.."] => "..tostring(val))

                    end

                end

            else
                Log(indent..tostring(t))
            end
        end
    end

    if (type(t)=="table") then
        Log(tostring(t).." {")
        sub_print_r(t,"  ")
        Log("}")
    else
        sub_print_r(t,"  ")
    end
end