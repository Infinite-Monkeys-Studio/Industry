local assets=
{
	Asset("ANIM", "anim/electric.zip"),
}

local brain = require "brains/electricbrain"

local function OnPickup(inst, data)
  print("onpickup")
  print(data)
end
  
--[[
local function OnPickup(inst, data)
    local item = data.item
    print("0")
    if item ~= nil then
        --Need to wait until PICKUP has called "GiveItem" before equipping item.
        print("1")
        if not inst.components.container:IsFull() then
        print("2")
          inst:DoTaskInTime(.1, function()
                                  if item:IsValid() and
                                      item.components.inventoryitem ~= nil and
                                      item.components.inventoryitem.owner == inst then
                                      print("3")
                                      print(inst.components.inventory
                                      --local outItem = inst.components.inventory:RemoveItem(item, true)
                                      --inst.components.container:GiveItem(outItem)
                                  end
                                end)
        end
    end
end
]]--

local function init_prefab()
	local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddSoundEmitter()
  inst.entity:AddDynamicShadow()
  inst.entity:AddMiniMapEntity()
  inst.entity:AddNetwork()
  
  MakeCharacterPhysics(inst, 50, 0)
  
  inst.DynamicShadow:SetSize(1.5, .75)
  
  inst.MiniMapEntity:SetPriority( 4 )
  inst.MiniMapEntity:SetIcon("electric.tex")
  
  inst.Transform:SetFourFaced() -- will now call '*animation*_up', '*_down' and '*_side'
  
  inst.AnimState:SetBank("electric")
  inst.AnimState:SetBuild("electric")
  inst.AnimState:PlayAnimation("idle", true)
  
  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
      return inst
  end
  
  inst:AddComponent("inspectable")
  
  inst:AddComponent("inventory")
  inst:ListenForEvent("onpickupitem", OnPickup)

  inst:AddComponent("locomotor")
  inst.components.locomotor.runspeed = 4

  inst:SetStateGraph("SGelectric")
  
  inst:SetBrain(brain)
  
  return inst
end

--[NEW] Here we register our new prefab so that it can be used in game.
return Prefab( "common/electric", init_prefab, assets, nil),
    MakePlacer("common/electric_placer", "electric", "electric", "idle")
