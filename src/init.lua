
rawset(_G, "Bubsy3D", {})

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
dofile("Functions/auxiliary.lua")

dofile("definitions.lua")
dofile("death anims.lua")

-- states!!
dofile("States/base.lua")
dofile("States/States/grounded.lua")
dofile("States/States/jumped.lua")
dofile("States/States/dead.lua")

dofile("movies.lua")