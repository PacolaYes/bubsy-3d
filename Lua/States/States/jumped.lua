---@diagnostic disable: inject-field

-- handles the jump movement
-- i think the title's self-explanatory
-- -pac

Bubsy3D.state.addState({
    name = "airbourne!",

    ---@param p bubsyPlayer_t
    enter = function(p)
        if (p.bubsy3d.cameramo and p.bubsy3d.cameramo.valid) then
            P_RemoveMobj(p.bubsy3d.cameramo)
        end
    end,

    ---@param p bubsyPlayer_t
    preThink = function(p)
        if not (p.pflags & PF_JUMPED) then
            return "grounded"
        end

        if (p.cmd.forwardmove or p.cmd.sidemove) then
            P_InstaThrust(p.mo, p.mo.angle + R_PointToAngle2(0, 0, p.cmd.forwardmove*FU, -p.cmd.sidemove*FU), 7*FU)
        end
    end,

    ---@param p bubsyPlayer_t
    postThink = function(p)
        if (p == consoleplayer or (splitscreen and p == secondarydisplayplayer)) then
            local cam = p == consoleplayer and camera or camera2
            local cammo = p.bubsy3d.cameramo
            if (cammo and cammo.valid) then

                local camAngle = p.cmd.angleturn << 16
                local camDist = 96 * p.mo.scale
                local desiredX, desiredY, desiredZ = p.mo.x - P_ReturnThrustX(cammo, camAngle, camDist), p.mo.y - P_ReturnThrustY(cammo, camAngle, camDist), p.mo.z + p.mo.height + 128 * p.mo.scale

                local time = FixedDiv(min(p.bubsy3d.jumptics, TICRATE/2), TICRATE/2) ---@diagnostic disable-line: param-type-mismatch
                local curX, curY, curZ = ease.outsine(time, cammo.ogcampos.x, desiredX), ease.outsine(time, cammo.ogcampos.y, desiredY), ease.outsine(time, cammo.ogcampos.z, desiredZ) ---@diagnostic disable-line: param-type-mismatch

                P_SetOrigin(cammo, p.mo.x, p.mo.y, curZ)
                if P_TryMove(cammo, curX, curY, true) then
                    local fh, ch = P_FloorzAtPos(curX, curY, cammo.z, cammo.height), P_CeilingzAtPos(curX, curY, cammo.z, cammo.height)
                    cammo.z = max(min($, ch), fh) ---@diagnostic disable-line: assign-type-mismatch
                end
                cammo.angle = camAngle

                if not (p.awayviewmobj and p.awayviewmobj.valid) then
                    p.awayviewmobj = cammo
                    p.awayviewtics = 8
                    p.awayviewaiming = camera.aiming
                elseif p.awayviewmobj == cammo then
                    p.awayviewtics = 2
                    p.awayviewaiming = Bubsy3D.approachAngle($, FixedAngle((270 + 30)*FU), 10)
                end
            else
                p.bubsy3d.cameramo = P_SpawnMobj(cam.x, cam.y, cam.z, MT_THOK)

                local cammo = p.bubsy3d.cameramo
                if (cammo and cammo.valid) then

                    cammo.ogcampos = {x = cam.x, y = cam.y, z = cam.z}
                    cammo.radius, cammo.height = cam.radius, cam.height
                    cammo.flags = MF_NOGRAVITY|MF_SLIDEME
                    cammo.state = S_INVISIBLE
                end
            end
        end
    end
})