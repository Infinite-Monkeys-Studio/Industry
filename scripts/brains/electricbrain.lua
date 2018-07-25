require "behaviours/standstill"

local AUTOCHEST_RANGE = 30

--[NEW] Here we create a new brain 
local electricbrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function FindNearestAutochest(inst)
  return GetClosestInstWithTag("autochest", inst, AUTOCHEST_RANGE)
end

local function InRangeOfAutochest( inst )
  return GetClosestInstWithTag("autochest", inst, AUTOCHEST_RANGE) ~= nil
end

local function CleanGroundAction(inst)
  local x, y, z = inst.Transform:GetWorldPosition()
  --local tags = inst.components.
  local ents = TheSim:FindEntities(x, y, z, AUTOCHEST_RANGE)
  --local taget = FindEntity(inst, SEE_FOOD_DIST, HasBerry, { "pickable" })
  --print("clear ground")
  for i, item in ipairs(ents) do
    if item.components.inventoryitem ~= nil and
      item.components.inventoryitem.canbepickedup and
      item:IsOnValidGround() and
      not item.components.inventoryitem:IsHeld() and
      inst.components.container:CanTakeItemInSlot(item, 1) and
      item.name == "Log" then
        -- check it's inrange of the autochest
        if InRangeOfAutochest(item) then
          --print("clear ground worked")
          local act = BufferedAction(inst, item, ACTIONS.PICKUP)
          print(act)
          return act
        end
    end
  end
  --print("clear ground failed")
  return nil 
end

local function FindTreeInRange(inst)
  return FindEntity(inst, AUTOCHEST_RANGE, nil, { "CHOP_workable" })
end

local function StartChoppingCondition( inst )
  return FindTreeInRange(inst) ~= nil
end

local function KeepChoppingAction( inst )
  return inst.tree_target ~= nil
end

local function FindTreeToChopAction(inst)
  local target = FindEntity(inst, AUTOCHEST_RANGE, {"DIG_workable"}, { "CHOP_workable" })

  if target ~= nil then
    inst.tree_target = target
    return BufferedAction(inst, target, ACTIONS.CHOP)
  end
  print("no tree in range")
end

function electricbrain:OnStart()

	--[NEW] Some behavior trees have multiple priority nodes.
    local root = PriorityNode(
    {
      IfNode(function() return StartChoppingCondition(self.inst) end, "chop", 
    	  WhileNode(function() return KeepChoppingAction(self.inst) end, "keep chopping", 
          LoopNode{
            DoAction(self.inst, FindTreeToChopAction )
          }
        )
      ),
      
      
      -- if nothing else stand there like an id10+.
      StandStill(self.inst),
    }, 1.0) --check every X seconds
    
    --[NEW] Now we attach the behaviour tree to our brain.
    self.bt = BT(self.inst, root)
end

--[NEW] Register our new brain so that it can later be attached to any creature we create.
return electricbrain
