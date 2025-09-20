
-- handles states :D

local stateList = {}

addHook("NetVars", function(net)
    stateList = net($)
end)

Bubsy3D.state = {}

---@class B3DState
---@field name string
---@field enter function?
---@field exit function?
---@field preThink function?
---@field think function?
---@field postThink function?
---@field playerThink function?

---@param t B3DState
--- adds the specified state to the list
function Bubsy3D.state.addState(t)
    if t == nil then return end

    if stateList[t.name] ~= nil then
        error("Oops! It seems like you've tried to add a state that already exists!", 2)
        return
    end

    stateList[t.name] = t -- so usefuls :P
end

---@param name string
---@return B3DState?
--- gets a state definition from the specified name; case-sensitive.
function Bubsy3D.state.getState(name)
    for key, val in pairs(stateList) do -- such usefuls
        if key == tostring(name) then
            return val
        end
    end
end

---@param p bubsyPlayer_t | player_t
---@param name string
---@return boolean
--- changes the current state to "name", triggering both enter and exit functions
function Bubsy3D.state.changeState(p, name)
    local newState = Bubsy3D.state.getState(name)
    local curState = Bubsy3D.state.getState(p.bubsy3d.curState)

    if not newState
    or not curState then return false end

    if curState.exit ~= nil then
        curState.exit(p, newState)
    end
    if newState.enter ~= nil then
        newState.enter(p, curState)
    end
    p.bubsy3d.curState = name
    return true
end

---@param p bubsyPlayer_t | player_t
---@param hook string
local function executeState(p, hook)
    if p.bubsy3d
    and p.bubsy3d.curState then
        local statedef = Bubsy3D.state.getState(p.bubsy3d.curState)

        if statedef ~= nil
        and type(statedef[hook]) == "function" then
            local funcResult = statedef[hook](p)

            if funcResult != nil
            and Bubsy3D.state.getState(funcResult) then
                Bubsy3D.state.changeState(p, funcResult)
            end
        end
    end
end

addHook("PreThinkFrame", function()
    for p in players.iterate do
        executeState(p, "preThink")
    end
end)

addHook("ThinkFrame", function()
    for p in players.iterate do
        executeState(p, "think")
    end
end)

addHook("PostThinkFrame", function()
    for p in players.iterate do
        if p.realmo.skin == "3dbubsy" then
            p.drawangle = p.cmd.angleturn << 16
        end

        executeState(p, "postThink")
    end
end)

local initTable = Bubsy3D.dofile("definitions.lua")

---@param p bubsyPlayer_t
addHook("PlayerThink", function(p)
    if p.realmo.skin ~= "3dbubsy" then
        p.bubsy3d = nil ---@diagnostic disable-line: inject-field
        return
    end

    if p.bubsy3d == nil then
        p.bubsy3d = initTable() ---@diagnostic disable-line: inject-field
        stateList.grounded.enter(p)
    end

    p.bubsy3d.jumptics = (p.pflags & PF_JUMPED) and $+1 or 0

    executeState(p, "playerThink")
end)