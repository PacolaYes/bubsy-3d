
-- handles all of bubsy's death animation stuff
-- except the state thing
-- that's in States/States :P

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
    
    Bubsy3D.startMovie(p, "EXPLODE")
    --p.playerstate = PST_DEAD
    Bubsy3D.state.changeState(p, "you are dead, no big surprise")
end, MT_PLAYER)