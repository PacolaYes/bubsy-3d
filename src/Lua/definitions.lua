
local function copyTable(copy) end

--- copies a table
---@param copy table
---@return table
function copyTable(copy)
    local new = {}
    for key, value in pairs(copy) do
        if type(value) == "table" then
            new[key] = copyTable(value)
        else
            new[key] = value
        end
    end
    return new
end

---@class plyrMovies
local movieTemplate = {
    definition = nil, ---@type bubsyMovies?
    tics = 0, ---@type tic_t
}

---@class bubsyPlayer_t: player_t
local playerTable = {
    bubsy3d = {
        movie = copyTable(movieTemplate), ---@type plyrMovies?
        curState = "grounded",
        cmdHeld = {
            forwardmove = 0
        },
        jumptics = 0, ---@type tic_t
        speed = 0,

        -- grounded state stuff :D
        backpedalTime = 0,
        runTics = 0,
        camturn = 0, -- the angle the camera should turn at, always trying to go back to 0

        -- jump state stuff :þ
        cameramo = nil, ---@type mobj_t?
        jumpAngle = 0 ---@type angle_t
    }
}

-- initPlayerTable, resetPlayerTable
-- init, well, initializes the table, when its nil
-- reset is when it needs to be reset
return function()
    return copyTable(playerTable.bubsy3d)
end