---@diagnostic disable: inject-field

-- hey all, pac here
-- make sure your movies are 1 indexed :D

---@class bubsyMovies
---@field name string the name the movie's graphics use
---@field numframes number how many frames the movie has
---@field fps number the frames per second the movie uses.

local movieMetatable = {
    __newindex = function(_, _, value)
        Bubsy3D.addMovie(value)
    end,
    __usedindex = function()
    end
}

registerMetatable(movieMetatable)

--- list of all movies added.
Bubsy3D.movies = {}
setmetatable(Bubsy3D.movies, movieMetatable)

local cachedPatches = {}
local function getPatch(v, name)
    if not cachedPatches[name] then
        cachedPatches[name] = v.cachePatch(name)
    end
    return cachedPatches[name]
end

local requiredIndexes = {"name", "numframes", "fps"}
--- adds a movie :P
---@param t bubsyMovies
function Bubsy3D.addMovie(t)
    if type(t) ~= "table" then return end

    for _, val in ipairs(requiredIndexes) do
        if not t[val] then
            error("Oops! Looks like you've forgotten to specify your movie's " + val + " index!", 2)
            return
        end
    end

    rawset(Bubsy3D.movies, #Bubsy3D.movies+1, t)
end

--- gets a movie definition from name; case-sensitive
---@param name string
---@return bubsyMovies?
function Bubsy3D.getMovieDef(name)
    if name == nil then return end

    for _, val in ipairs(Bubsy3D.movies) do
        if not val.name
        or val.name ~= name then continue end

        return val
    end
end

-- starts a movie based off of name; returns if the movie was successfully initiated.
---@param p bubsyPlayer_t?
---@param name string
---@return boolean
function Bubsy3D.startMovie(p, name)
    if name == nil then return false end

    local movieDef = Bubsy3D.getMovieDef(name)
    if not movieDef then return false end

    local started = false -- did it start for someone?
    if (p and p.valid) then
        if not p.bubsy3d then return false end

        p.bubsy3d.movie = {
            definition = movieDef, -- you wouldn't modify this, right?
            tics = 0
        }
    else
        ---@param p bubsyPlayer_t
        for p in players.iterate do
            if not p.bubsy3d then continue end

            p.bubsy3d.movie = {
                definition = movieDef,
                tics = 0
            }
            started = true
        end
    end
    return started
end

---@param v videolib
customhud.SetupItem("bubsyMovies", "bubsy3d", function(v)
    ---@param p bubsyPlayer_t
    Bubsy3D.scoresSplitscreen(v, function(nv, p)
        if skins[p.skin].name ~= "3dbubsy"
        or not p.bubsy3d
        or not p.bubsy3d.movie
        or p.bubsy3d.movie.definition == nil then return end

        local bubMovie = p.bubsy3d.movie
        local curFrame = max(
            ease.linear(FixedDiv(bubMovie.tics, TICRATE), 0, bubMovie.definition.fps * FU), ---@diagnostic disable-line: param-type-mismatch, need-check-nil
            FU
        )

        local patch = getPatch(v, bubMovie.definition.name + (FixedRound(curFrame) / FU)) ---@diagnostic disable-line: param-type-mismatch, need-check-nil
        nv.drawFill()
        nv.draw(0, 100 - (patch.height / 2), patch)
    end)
end, "gameandscores") ---@diagnostic disable-line: param-type-mismatch

Bubsy3D.addMovie({
    name = "EXPLODE",
    fps = 15,
    numframes = 91
})

---@param p bubsyPlayer_t
addHook("PlayerThink", function(p)
    if not (p.mo and p.mo.valid)
    or p.mo.skin ~= "3dbubsy"
    or not p.bubsy3d
    or not p.bubsy3d.movie then return end

    if p.bubsy3d.movie.definition then
        p.bubsy3d.movie.tics = $+1

        local def = p.bubsy3d.movie.definition
        if p.bubsy3d.movie.tics > def.numframes * TICRATE / def.fps then ---@diagnostic disable-line: need-check-nil
            p.bubsy3d.movie.definition = nil
            p.bubsy3d.movie.tics = 0
        end
    end
end)