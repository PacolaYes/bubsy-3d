---@diagnostic disable: inject-field

-- handles movement
-- for bubsy from bubsy
-- -pac

local initTable = Bubsy3D.dofile("definitions.lua")

---@param p bubsyPlayer_t
local function groundedMovement(p)
    if (p.cmd.forwardmove) < -15 then
        P_SetObjectMomZ(p.mo, 3*FU)
        P_InstaThrust(p.mo, p.mo.angle, -3*FU)
    end
end

---@param p bubsyPlayer_t
---@param cmd ticcmd_t
addHook("PlayerCmd", function(p, cmd)
    if not (p.mo and p.mo.valid)
    or p.mo.skin ~= "3dbubsy"
    or (p.pflags & PF_STASIS) then return end

    if P_IsObjectOnGround(p.mo)
    and abs(cmd.sidemove) > 15 then
        local sign = max(min(cmd.sidemove, 1), -1)

        cmd.angleturn = $ + (FixedAngle(4 * FU * -sign) >> 16)
    end
end)

addHook("PreThinkFrame", function()
    for p in players.iterate do
        ---@cast p bubsyPlayer_t

        if p.realmo.skin ~= "3dbubsy" then
            p.bubsy3d = nil
            continue
        end

        if not (p.mo and p.mo.valid) then continue end
        p.drawangle = p.mo.angle

        if p.bubsy3d == nil then
            p.bubsy3d = initTable()
        end

        if (p.pflags & PF_JUMPED) then
            p.bubsy3d.jumptics = $+1
        else
            p.bubsy3d.jumptics = 0
        end

        if (p.pflags & PF_STASIS) then
            p.bubsy3d.cmdHeld.forwardmove = 0
            continue
        end

        if abs(p.cmd.forwardmove) > 15 then
            p.bubsy3d.cmdHeld.forwardmove = $+1
        else
            p.bubsy3d.cmdHeld.forwardmove = 0
        end

        if P_IsObjectOnGround(p.mo) then
            groundedMovement(p)
        end
    end
end)