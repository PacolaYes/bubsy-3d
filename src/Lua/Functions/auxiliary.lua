
-- stuff that helps me out
-- yay !!

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