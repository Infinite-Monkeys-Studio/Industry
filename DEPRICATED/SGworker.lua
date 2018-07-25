require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.CHOP, "chop"),
    --ActionHandler(ACTIONS.PICKUP, "act"),
}

local events =
{
    CommonHandlers.OnStep(),
    --CommonHandlers.OnLocomote(true, true),
    --CommonHandlers.OnSleep(),
    --CommonHandlers.OnFreeze(),
    --CommonHandlers.OnAttack(),
    --CommonHandlers.OnAttacked(true),
    --CommonHandlers.OnDeath(),
    EventHandler("doaction", function(inst, data)
        if data.action == ACTIONS.CHOP and not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.tree_target = data.target
            inst.sg:GoToState("chop", data.target)
        end
    end),

    EventHandler("locomote", function(inst)
        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running")
        local is_idling = inst.sg:HasStateTag("idle")

        local should_move = inst.components.locomotor:WantsToMoveForward()
        local should_run = inst.components.locomotor:WantsToRun()

        if is_moving and not should_move then
            inst.sg:GoToState("run_stop")
        --elseif (is_idling and should_move) or (is_moving and should_move and is_running ~= should_run and can_run and can_walk) then
        elseif (is_idling and should_move) then
            inst.sg:GoToState("run")
        end
    end),
}

local states=
{
	--[NEW] This handles the idle state.
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst, playanim)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            inst.AnimState:PlayAnimation("idle", true)
        end,
    },

    State{

        name = "run",
        tags = {"running", "canrotate", "moving" },

        onenter = function(inst, playanim)
            inst.AnimState:PlayAnimation("idle", true)
    		inst.components.locomotor:RunForward()            
        end,
    },

    State{
        name = "run_stop",
        tags = {"idle"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
        end
    },

    State {
        name = "chop",
        tags = {"chopping"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle")
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                print("cut tree: over")
                inst.tree_target = nil
                inst.sg:GoToState("idle")
            end),
        },

    },
}

--CommonStates.AddSimpleActionState(states, "chop", "idle", 5 * FRAMES, {"busy", "chopping"})
CommonStates.AddSimpleActionState(states, "pickup", "pig_pickup", 10 * FRAMES, { "busy" })
--[NEW] Register our new stategraph and set the default state to 'idle'.
return StateGraph("electric", states, events, "idle", actionhandlers)