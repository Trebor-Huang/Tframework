local Utils = require 'Utils'

--[[
    Basic classes for the HMVC framework.

    The MVC component methods are not intended to receive `self` as a parameter.
    Instead, they receive the GUIObject. So constructs like `controller:foo()`
    should never appear. Use `guiObject:foo()` instead.
]]
local GUIObject = {}

local gc = love.graphics

---@class Controller
GUIObject.Controller = {
    -- Processes events.
    -- Conventionally returns a boolean to indicate whether the event is to be consumed
    -- or to be passed to the next controller. But this is not guaranteed to be respected
    -- by the `GUIObject`.
    process = Utils.nop,
    update = Utils.nop,  -- Updats the model, given `dt` as argument.
}

---@class View
GUIObject.View = {
    -- The canvas associated with the `View`. Use `nil` for the screen itself.
    -- Mipmaps are not yet supported.
    ---@type love.Canvas
    canvas = nil,
    -- Draws on its canvas. Returns a boolean indicating whether any changes are done.
    ---@return boolean
    draw = Utils.nop,
}

---@class Model
GUIObject.Model = {}

---@class GUIObject
GUIObject.GUIObject = {
    ---@type Controller
    controller = GUIObject.Controller,
    ---@type View
    view = GUIObject.View,
    ---@type Model
    model = GUIObject.Model,
    -- Should not be altered. The children list is maintained by the framework.
    ---@type GUIObject[]
    children = nil,
    -- Should not be altered. The parent is maintained by the framework.
    ---@type GUIObject|nil
    parent = nil,
    -- The wrapper drawing function. Sets and unsets the canvas.
    draw = function(self)
        if self.canvas then
            gc.setCanvas(self.canvas)
        end
        local b = self.view.draw(self)
        if self.canvas then
            gc.setCanvas()
        end
        return b
    end,
    __class_index = function(o, k)
        local method = o.model[k]
        if method ~= nil then return method end
        method = o.view[k]
        if method ~= nil then return method end
        method = o.controller[k]
        if method ~= nil then return method end
    end,
}

function GUIObject.GUIObject:__instantiate(obj)
    if obj.parent then
        obj.parent:addChild(self)
    end
end

-- Add a child object. Note that this will remove the child from its previous parents (if any).
---@param child GUIObject
function GUIObject.GUIObject:addChild(child)
    if child.parent then
        child:detachChild()
    end
    self.children[#self.children+1] = child
    child.parent = self
end

-- Detach `self` from its parent.
function GUIObject.GUIObject:detachChild()
    Utils.remove(self.parent.children, self)
    self.parent = nil
end

return GUIObject
