---@diagnostic disable: inject-field

-- handles grounded movement
-- for bubsy from bubsy
-- -pac

local RUN_TIME = TICRATE + TICRATE/2
local WALKSPEED = 7*FU ---@type fixed_t
local RUNSPEED = 18*FU

--- should the player actually do this ????
---@param p bubsyPlayer_t
local function shouldMove(p)
    return not (
        (p.pflags & PF_STASIS)
        or p.exiting
        or P_PlayerInPain(p)
    )
end

---@param p bubsyPlayer_t
---@param cmd ticcmd_t
addHook("PlayerCmd", function(p, cmd)
    if not (p.mo and p.mo.valid)
    or p.mo.skin ~= "3dbubsy"
    or not shouldMove(p) then return end

    if p.bubsy3d
    and p.bubsy3d.curState == "grounded"
    and p.bubsy3d.camturn != 0 then
    /*and abs(cmd.sidemove) > 15 then
        local sign = max(min(cmd.sidemove, 1), -1)

        cmd.angleturn = $ + (FixedAngle(2 * FU * -sign) >> 16)
    */
        cmd.angleturn = $ + (p.bubsy3d.camturn >> 16)
    end
end)

Bubsy3D.state.addState({
    name = "grounded",

    ---@param p bubsyPlayer_t
    enter = function(p)
        p.bubsy3d.backpedalTime = 0
        p.bubsy3d.runTics = 6

    end,

    ---@param p bubsyPlayer_t
    preThink = function(p)
        if (p.pflags & PF_JUMPED) then
            return "airbourne!" -- im so good at typing :D
        end

        if not shouldMove(p) then
            p.bubsy3d.cmdHeld.forwardmove = 0
            p.bubsy3d.cmdHeld.sidemove = 0
            p.bubsy3d.backpedalTime = 0
            p.bubsy3d.runTics = 0
            return
        end

        if (p.cmd.forwardmove) <= -15
        and not p.bubsy3d.cmdHeld.forwardmove
        and P_IsObjectOnGround(p.mo) then
            p.bubsy3d.backpedalTime = TICRATE/2
        end

        local camAngle = p.cmd.angleturn << 16
        if p.bubsy3d.backpedalTime then
            p.bubsy3d.backpedalTime = abs($-1)

            if p.bubsy3d.backpedalTime <= TICRATE/3
            and p.cmd.forwardmove > -15 then
                P_SetObjectMomZ(p.mo, 3*FU)
                P_InstaThrust(p.mo, camAngle, -3*FU)
                p.mo.state = S_PLAY_WALK
                p.bubsy3d.backpedalTime = 0
            end
        elseif p.bubsy3d.cmdHeld.forwardmove
        and p.cmd.forwardmove <= -15 then
            P_InstaThrust(p.mo, camAngle + ANGLE_180, WALKSPEED)
            if p.mo.state ~= S_PLAY_WALK then
                p.mo.state = S_PLAY_WALK
            end
        end

        --print(AngleFixed(camera.aiming)/FU)
        if (p.cmd.buttons & BT_CUSTOM1) then
            p.bubsy3d.runTics = max($, RUN_TIME-1)
        end

        if p.cmd.forwardmove >= 15 then
            p.bubsy3d.runTics = $+1

            if p.bubsy3d.runTics > 4 then
                if p.bubsy3d.runTics == 5
                or p.bubsy3d.runTics == RUN_TIME then
                    P_SpawnSkidDust(p, 0)
                end
                
                local speed = p.bubsy3d.runTics > RUN_TIME and RUNSPEED or WALKSPEED
                P_InstaThrust(p.mo, p.mo.angle, speed)
            end
        else
            p.bubsy3d.runTics = 0
        end

        -- camera thing
        if abs(p.cmd.sidemove) > 15 then
            local sign = max(min(p.cmd.sidemove, 1), -1)

            p.bubsy3d.camturn = Bubsy3D.approachAngle($, FixedAngle(6*FU * -sign), TICRATE / 3)
        else
            p.bubsy3d.camturn = Bubsy3D.approachAngle($, 0, 4)
        end

        p.bubsy3d.cmdHeld.forwardmove = abs(p.cmd.forwardmove) > 15 and $+1 or 0
        p.bubsy3d.cmdHeld.sidemove = abs(p.cmd.sidemove) > 15 and $+1 or 0
        p.cmd.sidemove = 0
    end
})

addHook("MobjMoveBlocked", function(pmo)
    if not (pmo and pmo.valid)
    or pmo.skin ~= "3dbubsy"
    or not (pmo.player and pmo.player.valid) then return end

    local p = pmo.player
    if p.bubsy3d
    and p.bubsy3d.curState == "grounded" then
        p.bubsy3d.runtics = 0
    end
end, MT_PLAYER)