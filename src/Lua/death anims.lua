
-- handles all of bubsy's death animation stuff
-- except the state thing
-- that's in States/States :P

local movieList = {
    [DMG_WATER] = "DROWN",
    ["default"] = "EXPLODE",
    ["uwDeath"] = {
        "UWDEATH1",
        "UWDEATH2",
        "UWDEATH3"
    }
}

---@param pmo mobj_t
---@param inf mobj_t
---@param src mobj_t
---@param dmgtype integer
addHook("MobjDeath", function(pmo, inf, src, dmgtype)
    if not (pmo and pmo.valid)
    or pmo.skin ~= "3dbubsy"
    or not (pmo.player and pmo.player.valid)
    or not pmo.player.bubsy3d then return end

    local p = pmo.player ---@cast p bubsyPlayer_t
    
    local selectedMovie = movieList[dmgtype] or movieList.default

    if (pmo.eflags & MFE_UNDERWATER)
    and selectedMovie == movieList.default then
        selectedMovie = movieList.uwDeath
    end

    if type(selectedMovie) == "table" then
        selectedMovie = selectedMovie[P_RandomRange(1, #selectedMovie)]
    end

    Bubsy3D.startMovie(p, selectedMovie)
    Bubsy3D.state.changeState(p, "you are dead, no big surprise")
end, MT_PLAYER)

-- add 'em up!

Bubsy3D.addMovie({
    name = "EXPLODE",
    fps = 15,
    sfx = freeslot("sfx_b3dexp"),
    numframes = 91
})

Bubsy3D.addMovie({
    name = "DROWN",
    fps = 15,
    sfx = freeslot("sfx_b3ddrw"),
    numframes = 111
})

Bubsy3D.addMovie({
    name = "UWDEATH1",
    fps = 15,
    sfx = freeslot("sfx_b3duw1"),
    numframes = 104
})

Bubsy3D.addMovie({
    name = "UWDEATH2",
    fps = 15,
    sfx = freeslot("sfx_b3duw2"),
    numframes = 83
})

Bubsy3D.addMovie({
    name = "UWDEATH3",
    fps = 15,
    sfx = freeslot("sfx_b3duw3"),
    numframes = 100
})

sfxinfo[sfx_b3dexp].caption = "Look at what you did."
sfxinfo[sfx_b3ddrw].caption = "Bubsy's Vice Pawsity ;)" -- this joke sucks
sfxinfo[sfx_b3duw1].caption = "Hey Bubsy! chest."
sfxinfo[sfx_b3duw2].caption = "bubel"
sfxinfo[sfx_b3duw3].caption = "Jones' bobcat."