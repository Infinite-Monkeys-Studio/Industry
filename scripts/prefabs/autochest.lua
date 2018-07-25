require "prefabutil"

local assets=
{
	Asset("ANIM", "anim/autochest.zip"),
	Asset("ANIM", "anim/ui_chest_3x2.zip"),
}

local prefabs =
{
  "collapse_small",
}

local function onopen(inst) 
	inst.AnimState:PlayAnimation("open") 
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end 

local function onclose(inst) 
	inst.AnimState:PlayAnimation("close") 
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")		
end 

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
  if inst.components.container ~= nil then
    inst.components.container:DropEverything()
  end
  local fx = SpawnPrefab("collapse_small")
  fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
  fx:SetMaterial("wood")
  inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
  inst.AnimState:PushAnimation("closed", false)
	if inst.components.container ~= nil then
    inst.components.container:DropEverything()
    inst.components.container:Close()
  end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
	inst.SoundEmitter:PlaySound("dontstarve/common/chest_craft")
end

local function fn(Sim)
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddSoundEmitter()
  inst.entity:AddMiniMapEntity()
  inst.entity:AddNetwork()
  
  inst.Transform:SetScale(1.4, 1.4, 1.4)
  
  inst.MiniMapEntity:SetPriority( 4 )
  inst.MiniMapEntity:SetIcon("autochest.tex")
  
  MakeObstaclePhysics(inst, .4)

  inst:AddTag("structure")
  inst:AddTag("autochest")
  
  inst.AnimState:SetBank("autochest")
  inst.AnimState:SetBuild("autochest")
  inst.AnimState:PlayAnimation("closed")
  
  inst.entity:SetPristine()
  
  if not TheWorld.ismastersim then
    return inst
  end
  
  inst:AddComponent("inspectable")
  
  local chestwidget = {
    slotpos = {},
    animbank = "ui_chest_3x2",
    animbuild = "ui_chest_3x2",
    pos = Vector3(0, 150, 0),
    side_align_tip = 160,
  }

  for x = 0, 2 do
      table.insert(chestwidget.slotpos, Vector3(-75 + 75 * x, 40, 0))
      table.insert(chestwidget.slotpos, Vector3(-75 + 75 * x, 40 - 75, 0))
  end
  
  local chestdata =
  {
    numslots = #chestwidget.slotpos,
    type = "chest",
    widget = chestwidget,
  }
  
  inst:AddComponent("container")
  inst.components.container:WidgetSetup("autochest", chestdata)
  inst.components.container.onopenfn = onopen
  inst.components.container.onclosefn = onclose
  
  inst:AddComponent("lootdropper")
  inst:AddComponent("workable")
  inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
  inst.components.workable:SetWorkLeft(2)
  inst.components.workable:SetOnFinishCallback(onhammered)
  inst.components.workable:SetOnWorkCallback(onhit) 
  
  inst:ListenForEvent( "onbuilt", onbuilt)
  MakeSnowCovered(inst, .01)
  return inst
end

return Prefab( "common/autochest", fn, assets),
  MakePlacer("common/autochest_placer", "autochest", "autochest", "closed")