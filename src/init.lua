
rawset(_G, "Bubsy3D", {})

--- approaches the angle :þ
---@param cur angle_t
---@param new angle_t
---@param factor number
---@return angle_t
function Bubsy3D.approachAngle(cur, new, factor) -- adapted from the directionchar code stuff :P
    local diff = new - cur
	factor = $ or 8

    if diff then
        if (diff > ANGLE_180) then
            diff = InvAngle(InvAngle(diff)/factor);
        else
            diff = $/factor;
        end
        cur = $ + diff;
    end
    return cur
end

local storedFiles = {}
--- stores loaded results, so ya can use them later :P
---@param file string
function Bubsy3D.dofile(file)
    if not storedFiles[file] then
        storedFiles[file] = dofile(file)
    end
    return storedFiles[file]
end

local dofile = Bubsy3D.dofile

dofile("Libs/lib_customhud.lua")

dofile("Functions/player.lua")

dofile("definitions.lua")

-- states!!
dofile("States/base.lua")
dofile("States/States/grounded.lua")
dofile("States/States/jumped.lua")

dofile("movies.lua")