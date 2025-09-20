
Bubsy3D.state.addState({
    name = "you are dead, no big surprise",

    ---@param p bubsyPlayer_t
    enter = function(p)
        local def = p.bubsy3d.movie.definition
        if def then -- how are you here if you're not playing a movie already??
            p.deadtimer = 70 - (def.numframes * TICRATE / def.fps - 1)
        end
    end,

    ---@param p bubsyPlayer_t
    preThink = function(p)
        if p.playerstate ~= PST_DEAD then
            return "grounded"
        end

        --print(p.deadtimer)
    end
})