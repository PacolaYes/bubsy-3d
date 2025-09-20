
-- functions related to da playar
-- -pac

-- maybe not really necessary, but ehhhh :þ

local supercoolVideoLibReplacement = {
    new = function(v)
        local nv = {}

        function nv.draw(x, y, patch, flags, c)
            if splitscreen then
                y = $/2
                if nv.secondplyr then
                    y = $+100
                end

                v.drawStretched(x * FU, y * FU, FU, FU/2, patch, flags, c)
            else
                v.draw(x, y, patch, flags, c)
            end
        end

        function nv.drawFill(x, y, width, height, color)
            if splitscreen then
                if x == nil
                and y == nil
                and width == nil
                and height == nil
                and color == nil then
                    x = 0
                    y = 0
                    width = v.width() / v.dupx()
                    height = v.height() / v.dupy()
                    color = 31|V_SNAPTOTOP|V_SNAPTOLEFT
                end

                y = $/2
                height = $/2
                if nv.secondplyr then
                    y = $+100
                end

                v.drawFill(x, y, width, height, color)
            else
                v.drawFill(x, y, width, height, color)
            end
        end
        return nv
    end
}

--- executes the function as the display player, taking splitscreen into account.
---@param v videolib
---@param func function takes a player as the only parameter.
function Bubsy3D.scoresSplitscreen(v, func)
    local nv = supercoolVideoLibReplacement.new(v)

    func(nv, displayplayer)
    if splitscreen then
        nv.secondplyr = true
        func(nv, secondarydisplayplayer)
    end
end

--- checks if the player is Bubsy and can do stuff
---@param p player_t
function Bubsy3D.playerCheck(p)
    return (p.mo and p.mo.valid)
    and p.mo.skin == "3dbubsy"
    and p.bubsy3d
end