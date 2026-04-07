local Action = {
    name = "",
    duration = 0,
    label = "",
    useWhileDead = false,
    canCancel = true,
    disarm = true,
    controlDisables = {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = false,
    },
    animation = {
        animDict = nil,
        anim = nil,
        flags = 0,
        task = nil,
    },
    prop = {
        model = nil,
        bone = nil,
        coords = { x = 0.0, y = 0.0, z = 0.0 },
        rotation = { x = 0.0, y = 0.0, z = 0.0 },
    },
    propTwo = {
        model = nil,
        bone = nil,
        coords = { x = 0.0, y = 0.0, z = 0.0 },
        rotation = { x = 0.0, y = 0.0, z = 0.0 },
    },
}

local isDoingAction = false
local wasCancelled = false
local isAnim = false
local isProp = false
local isPropTwo = false
local prop_net = nil
local propTwo_net = nil

local function ActionCleanup()
    local ped = PlayerPedId()
    
    if Action.animation ~= nil then
        if Action.animation.task ~= nil or (Action.animation.animDict ~= nil and Action.animation.anim ~= nil) then
            ClearPedTasks(ped)
            StopAnimTask(ped, Action.animation.animDict, Action.animation.anim, 1.0)
        end
    end

    if prop_net ~= nil then
        DetachEntity(NetToObj(prop_net), 1, 1)
        DeleteEntity(NetToObj(prop_net))
        prop_net = nil
    end

    if propTwo_net ~= nil then
        DetachEntity(NetToObj(propTwo_net), 1, 1)
        DeleteEntity(NetToObj(propTwo_net))
        propTwo_net = nil
    end

    isDoingAction = false
    wasCancelled = false
    isAnim = false
    isProp = false
    isPropTwo = false
end

local function DisableActions()
    if Action.controlDisables.disableMouse then
        DisableControlAction(0, 1, true)
        DisableControlAction(0, 2, true)
        DisableControlAction(0, 106, true)
    end

    if Action.controlDisables.disableMovement then
        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
        DisableControlAction(0, 36, true)
        DisableControlAction(0, 21, true)
    end

    if Action.controlDisables.disableCarMovement then
        DisableControlAction(0, 63, true)
        DisableControlAction(0, 64, true)
        DisableControlAction(0, 71, true)
        DisableControlAction(0, 72, true)
        DisableControlAction(0, 75, true)
    end

    if Action.controlDisables.disableCombat then
        DisablePlayerFiring(PlayerId(), true)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(1, 37, true)
        DisableControlAction(0, 47, true)
        DisableControlAction(0, 58, true)
        DisableControlAction(0, 140, true)
        DisableControlAction(0, 141, true)
        DisableControlAction(0, 142, true)
        DisableControlAction(0, 143, true)
        DisableControlAction(0, 263, true)
        DisableControlAction(0, 264, true)
        DisableControlAction(0, 257, true)
    end
end

local function Cancel()
    isDoingAction = false
    wasCancelled = true
    ActionCleanup()
    SendNUIMessage({
        action = "cancel"
    })
end

local function ActionStart()
    local ped = PlayerPedId()
    
    if Action.animation ~= nil then
        if Action.animation.task ~= nil then
            TaskStartScenarioInPlace(ped, Action.animation.task, 0, true)
        elseif Action.animation.animDict ~= nil and Action.animation.anim ~= nil then
            if Action.animation.flags == nil then
                Action.animation.flags = 1
            end

            RequestAnimDict(Action.animation.animDict)
            while not HasAnimDictLoaded(Action.animation.animDict) do
                Citizen.Wait(0)
            end
            
            TaskPlayAnim(ped, Action.animation.animDict, Action.animation.anim, 3.0, 3.0, -1, Action.animation.flags, 0, false, false, false)
        else
            -- If task and anim are both nil but dict is somehow requested, this prevents softlock.
            -- Using a default task if animation array was passed improperly
            -- TaskStartScenarioInPlace(ped, 'PROP_HUMAN_BUM_BIN', 0, true) 
        end
        isAnim = true
    end

    if Action.prop ~= nil and Action.prop.model ~= nil then
        RequestModel(Action.prop.model)
        while not HasModelLoaded(GetHashKey(Action.prop.model)) do
            Citizen.Wait(0)
        end
        
        local pCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 0.0)
        local modelSpawn = CreateObject(GetHashKey(Action.prop.model), pCoords.x, pCoords.y, pCoords.z, true, true, true)

        local netId = ObjToNet(modelSpawn)
        SetNetworkIdExistsOnAllMachines(netId, true)
        NetworkSetNetworkIdDynamic(netId, true)
        SetNetworkIdCanMigrate(netId, false)
        local boneIndex = GetPedBoneIndex(ped, Action.prop.bone or 60309)
        local c = Action.prop.coords or {x=0.0, y=0.0, z=0.0}
        local r = Action.prop.rotation or {x=0.0, y=0.0, z=0.0}
        AttachEntityToEntity(modelSpawn, ped, boneIndex, c.x, c.y, c.z, r.x, r.y, r.z, true, true, false, true, 1, true)
        prop_net = netId
        isProp = true
    end

    if Action.propTwo ~= nil and Action.propTwo.model ~= nil then
        RequestModel(Action.propTwo.model)
        while not HasModelLoaded(GetHashKey(Action.propTwo.model)) do
            Citizen.Wait(0)
        end
        
        local pCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 0.0)
        local modelSpawn = CreateObject(GetHashKey(Action.propTwo.model), pCoords.x, pCoords.y, pCoords.z, true, true, true)

        local netId = ObjToNet(modelSpawn)
        SetNetworkIdExistsOnAllMachines(netId, true)
        NetworkSetNetworkIdDynamic(netId, true)
        SetNetworkIdCanMigrate(netId, false)
        local boneIndex = GetPedBoneIndex(ped, Action.propTwo.bone or 60309)
        local c = Action.propTwo.coords or {x=0.0, y=0.0, z=0.0}
        local r = Action.propTwo.rotation or {x=0.0, y=0.0, z=0.0}
        AttachEntityToEntity(modelSpawn, ped, boneIndex, c.x, c.y, c.z, r.x, r.y, r.z, true, true, false, true, 1, true)
        propTwo_net = netId
        isPropTwo = true
    end
end

function Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    if type(name) == 'table' then
        print("[Progressbar] Received configuration table correctly. Label: " .. tostring(name.label) .. ", Duration: " .. tostring(name.duration))
        local action = name
        local finishFunc = label
        local cancelFunc = duration
        
        onFinish = finishFunc
        onCancel = cancelFunc
        if (type(finishFunc) == 'function' or type(finishFunc) == 'table') and cancelFunc == nil then
            onFinish = function() if type(finishFunc) == 'function' or type(finishFunc) == 'table' then finishFunc(false) end end
            onCancel = function() if type(finishFunc) == 'function' or type(finishFunc) == 'table' then finishFunc(true) end end
        end

        name = action.name or "Action"
        label = action.label or action.text or action.message or "Loading..."
        duration = tonumber(action.duration) or tonumber(action.time) or tonumber(action.length) or 5000
        useWhileDead = action.useWhileDead
        canCancel = action.canCancel
        -- Framework cross-compatibility assignments
        local inDisable = action.controlDisables or action.disableControls or action.disable
        if type(inDisable) == 'table' then
            disableControls = {
                disableMovement = inDisable.disableMovement or inDisable.move or false,
                disableCarMovement = inDisable.disableCarMovement or inDisable.car or false,
                disableMouse = inDisable.disableMouse or inDisable.mouse or false,
                disableCombat = inDisable.disableCombat or inDisable.combat or false,
            }
        elseif type(inDisable) == 'boolean' then
            disableControls = {
                disableMovement = inDisable,
                disableCarMovement = inDisable,
                disableMouse = false,
                disableCombat = inDisable,
            }
        else
            disableControls = inDisable
        end

        local inAnim = action.animation or action.anim
        if type(inAnim) == 'table' then
            animation = {
                animDict = inAnim.animDict or inAnim.dict,
                anim = inAnim.anim or inAnim.clip,
                flags = inAnim.flags or inAnim.flag,
                task = inAnim.task or inAnim.scenario
            }
        else
            animation = inAnim
        end

        local inProp = action.prop
        if type(inProp) == 'table' then
            prop = {
                model = inProp.model,
                bone = inProp.bone,
                coords = inProp.coords or inProp.pos,
                rotation = inProp.rotation or inProp.rot,
            }
        else
            prop = inProp
        end
        propTwo = action.propTwo
    elseif type(name) == 'string' and type(label) == 'number' then
        -- Handle ESX style: Progressbar(message, length, options)
        print("[Progressbar] Received ESX-style arguments. Message: " .. tostring(name) .. ", Length: " .. tostring(label))
        local esxMessage = name
        local esxLength = label
        local esxOptions = type(duration) == 'table' and duration or {}
        
        name = "esx_action"
        label = esxMessage
        duration = tonumber(esxLength) or 5000
        useWhileDead = esxOptions.useWhileDead or esxOptions.UseWhileDead or false
        canCancel = esxOptions.canCancel or esxOptions.can_cancel or true
        
        local freeze = esxOptions.freeze or esxOptions.FreezePlayer or false
        disableControls = {
            disableMovement = freeze,
            disableCarMovement = freeze,
            disableMouse = false,
            disableCombat = freeze,
        }
        
        animation = (type(esxOptions.animation) == 'table' and esxOptions.animation) or (type(esxOptions.anim) == 'table' and esxOptions.anim) or nil
        if animation then
            animation.animDict = animation.animDict or animation.dict
            animation.anim = animation.anim or animation.clip
        end
        
        prop = type(esxOptions.prop) == 'table' and esxOptions.prop or nil
        propTwo = type(esxOptions.propTwo) == 'table' and esxOptions.propTwo or nil
        
        local finishCb = esxOptions.onFinish
        local cancelCb = esxOptions.onCancel
        onFinish = function() if finishCb then finishCb() end end
        onCancel = function() if cancelCb then cancelCb() end end
    else
        print("[Progressbar] Received positional arguments correctly. Label: " .. tostring(label) .. ", Duration: " .. tostring(duration))
        duration = tonumber(duration) or 5000
    end

    if not isDoingAction then
        isDoingAction = true
        wasCancelled = false
        isAnim = false
        isProp = false
        isPropTwo = false

        if type(disableControls) ~= 'table' then
            disableControls = { disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = false }
        end

        Action.name = name
        Action.label = label
        Action.duration = duration
        Action.useWhileDead = useWhileDead
        Action.canCancel = canCancel
        Action.controlDisables = disableControls
        Action.animation = type(animation) == 'table' and animation or nil
        Action.prop = type(prop) == 'table' and prop or nil
        Action.propTwo = type(propTwo) == 'table' and propTwo or nil

        SendNUIMessage({
            action = "start",
            duration = Action.duration,
            label = Action.label
        })

        Citizen.CreateThread(function()
            local startTime = GetGameTimer()
            ActionStart()

            while isDoingAction do
                Citizen.Wait(0)
                
                if not Action.useWhileDead and IsEntityDead(PlayerPedId()) then
                    Cancel()
                end

                if Action.canCancel then
                    if IsControlJustPressed(0, 73) or IsControlJustPressed(0, 200) then -- X or ESC
                        Cancel()
                    end
                end
                
                DisableActions()

                if GetGameTimer() - startTime >= Action.duration then
                    isDoingAction = false
                end
            end

            ActionCleanup()

            if not wasCancelled then
                if onFinish ~= nil then
                    onFinish()
                end
            else
                if onCancel ~= nil then
                    onCancel()
                end
            end
        end)
    else
        print('Action Already in Progress')
    end
end

exports('Progressbar', Progressbar)
exports('Progress', Progressbar)

-- Event Handlers for Framework Independence
RegisterNetEvent('progressbar:client:progress', function(action, finish, cancel)
    Progressbar(action.name, action.label, action.duration, action.useWhileDead, action.canCancel, action.controlDisables, action.animation, action.prop, action.propTwo, finish, cancel)
end)

RegisterNetEvent('progressbar:client:cancel', function() Cancel() end)

RegisterNetEvent('mythic_progbar:client:progress', function(action, finish, cancel)
    Progressbar(action, finish, cancel)
end)

RegisterNetEvent('mythic_progbar:client:cancel', function() Cancel() end)

RegisterNetEvent('esx_progressbar:start', function(action, finishCb, cancelCb)
    -- Often ESX users might trigger this event with just the options table
    Progressbar(action, finishCb, cancelCb)
end)

RegisterNetEvent('esx_progressbar:cancel', function() Cancel() end)

exports('isDoingSomething', function() return isDoingAction end)

-- [DEV] Test Command
RegisterCommand('testprog', function()
    Progressbar({
        name = "test_progress",
        duration = 5000,
        label = "Testing Progressbar UI...",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
    }, function(cancelled)
        if not cancelled then
            print("Test Progressbar Completed Successfully!")
        else
            print("Test Progressbar Cancelled!")
        end
    end)
end, false)
