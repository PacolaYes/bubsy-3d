---@diagnostic disable: inject-field, need-check-nil

-- does the scary camera stuff
-- oooooooooo ghost sfx
-- -pac

-- first time doin' camera stuff
-- so it's not really the best, i think
-- -pac

local cam_dist = CV_FindVar("cam_dist")
local cam2_dist = CV_FindVar("cam2_dist")
local cam_simpledist = CV_FindVar("cam_simpledist")
local cam2_simpledist = CV_FindVar("cam2_simpledist")

--- approaches the angle :þ
---@param cur angle_t
---@param new angle_t
---@param factor number
---@return angle_t
local function approachAngle(cur, new, factor) -- adapted from the directionchar code stuff :P
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

---@class cameraMobj: mobj_t
---@field aiming angle_t

---@param p bubsyPlayer_t
---@param cam camera_t
---@param camdist fixed_t
local function doDaCameraStuff(p, cam, camdist)
    if not Bubsy3D.playerCheck(p)
    or (p.awayviewmobj and p.awayviewmobj.valid) and p.awayviewtics then return end

    local b3d = p.bubsy3d

    --print(AngleFixed(cam.aiming)/FU)
    if (p.pflags & PF_JUMPED) then
        camdist = $ + b3d.cameraOffset.dist
        camdist = FixedMul(FixedMul($, b3d.cameraOffset.dist), p.mo.scale) ---@diagnostic disable-line: param-type-mismatch
        
        local x, y = cos(cam.angle), sin(cam.angle)
        while not P_TryCameraMove(cam, p.mo.x - FixedMul(camdist, x), p.mo.y - FixedMul(camdist, y)) do
            camdist = $-FU

            if camdist < 0 then break end
        end
        
        if b3d.cameraOffset.height < 0 then b3d.cameraOffset.height = 0 end
        if b3d.cameraOffset.dist < 0 then b3d.cameraOffset.dist = FU end

        local flip = P_MobjFlip(p.mo)
        local height = 32 * p.mo.scale
        local dist = FU/4
        b3d.cameraOffset.height = min($ + height / (TICRATE / 3), height) * flip
        b3d.cameraOffset.dist = max($ - dist / (TICRATE / 3), dist)

        cam.z = $ + b3d.cameraOffset.height ---@diagnostic disable-line: assign-type-mismatch
        cam.aiming = approachAngle($, FixedAngle(270 * FU * flip), 8)
    else
        if b3d.cameraOffset.height ~= -1 then
            b3d.cameraOffset.height = -1
        end
        if b3d.cameraOffset.dist ~= -1 then
            b3d.cameraOffset.dist = -1
        end
    end
end

addHook("PostThinkFrame", function()
    local dist
    if (consoleplayer.pflags & PF_ANALOGMODE) then
        dist = cam_simpledist.value
    else
        dist = cam_dist.value
    end
    doDaCameraStuff(consoleplayer, camera, dist) ---@diagnostic disable-line: param-type-mismatch

    if (secondarydisplayplayer and secondarydisplayplayer.valid) then
        if (consoleplayer.pflags & PF_ANALOGMODE) then
            dist = cam2_simpledist.value
        else
            dist = cam2_dist.value
        end
        doDaCameraStuff(secondarydisplayplayer, camera2, dist) ---@diagnostic disable-line: param-type-mismatch
    end
end)