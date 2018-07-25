require "prefabutil"

local assets=
{
	Asset("ANIM", "anim/industrymachine.zip"),
  Asset("SOUNDPACKAGE", "sound/industry.fev"),
  Asset("SOUND", "sound/industry.fsb"),
}

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
  if inst.components.prototyper.on then
    inst.AnimState:PushAnimation("active", true)
  end
end

local function onturnon(inst)
  inst.AnimState:PlayAnimation("active", true)
  inst.SoundEmitter:PlaySound("industry/sound/industrymachine_active","active")
end

local function onturnoff(inst)
  inst.AnimState:PushAnimation("idle", true)
  inst.SoundEmitter:KillSound("active")
end

-----------  special code -----------
local function craft(inst)
  print("Crafting")
end


local fn = function(Sim)
  local inst = CreateEntity()
  local trans = inst.entity:AddTransform()
  local anim = inst.entity:AddAnimState()
  inst.entity:AddMiniMapEntity()
  inst.entity:AddSoundEmitter()
  inst.entity:AddNetwork()
  
  inst.MiniMapEntity:SetPriority( 5 )
  inst.MiniMapEntity:SetIcon( "industrymachine.tex" )
  
  inst.Transform:SetScale(0.7, 0.7, 0.7)
    
  MakeObstaclePhysics(inst, .4)
    
  anim:SetBank("industrymachine")
  anim:SetBuild("industrymachine")
  anim:PlayAnimation("idle", true)

  inst:AddTag("structure")
  inst:AddTag("industry")
  
  inst.entity:SetPristine() -- everything above this is the same for clients and server
  
  if not TheWorld.ismastersim then -- stop here if you are a client
    return inst
  end
  
  inst:AddComponent("inspectable")
  
  inst:AddComponent("prototyper")
  inst.components.prototyper.onturnon = onturnon
  inst.components.prototyper.onturnoff = onturnoff  
  inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.INDUSTRY_ONE
  
  inst.components.prototyper.onactivate = function()
    inst.AnimState:PlayAnimation("run")
    inst.AnimState:PushAnimation("idle")
    inst.AnimState:PushAnimation("active", true)
    inst.SoundEmitter:PlaySound("industry/sound/industrymachine_run","run")

    inst:DoTaskInTime(1.5, function() 
      inst.SoundEmitter:KillSound("run")
      inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_lvl1_ding","ding")
    end)
  end
  
  inst:ListenForEvent( "onbuilt", function()
    inst.components.prototyper.on = true
    anim:PlayAnimation("place")
    anim:PushAnimation("idle")
    anim:PushAnimation("active", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_lvl1place")
    inst.SoundEmitter:PlaySound("industry/sound/industrymachine_active","active")				
  end)		

  inst:AddComponent("lootdropper")
  inst:AddComponent("workable")
  inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
  inst.components.workable:SetWorkLeft(4)
  inst.components.workable:SetOnFinishCallback(onhammered)
  inst.components.workable:SetOnWorkCallback(onhit)		
  MakeSnowCovered(inst, .01)
  return inst
end

return Prefab( "common/industrymachine", fn, assets),
  MakePlacer("common/industrymachine_placer", "industrymachine", "industrymachine", "idle")