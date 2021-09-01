--[[
    Useful components to assemble your game quickly.
]]
local Components = {}

local GUIObject = require 'GUIObject'
local Utils = require 'Utils'
local gc = love.graphics

---@class Container
Components.Container = Utils.class({
    -- Relative transforms of the children.
    -- Format: A list of {x, y, r, sx, sy, ox, oy, kx, ky}
    -- Alternatively, input a `love.Transform` list.
    ---@type love.Transform[]
    childrenTransform = nil,
}, {GUIObject.GUIObject})

Components.Container.view = Utils.class({
    -- Draws all the children.
    draw = function(self)
        local changed = false
        for _, c in ipairs(self.children) do
            local child_changed = c:draw()
            if child_changed or self.canvas==nil then
                changed = true
                gc.setBlendMode("alpha", "premultiplied")
                gc.draw(c.canvas, unpack(self.childrenTransform[c]))
                gc.setBlendMode("alpha")
            end
        end
        return changed
    end
}, {GUIObject.View})

function Components.Container:__instantiate(o)
    o:__super()
    o.childrenTransform = o.childrenTransform or {}
    setmetatable(o.childrenTransform, {__mode='k'})  -- weakens the keys
end

-- Add a child object. Note that this will remove the child from its previous parents (if any).
---@param child GUIObject
function Components.Container:addChild(child, ...)
    if child.parent then
        child:detachChild()
    end
    self.children[#self.children+1] = child
    self.childrenTransform[child] = {...}
    child.parent = self
end

return Components
