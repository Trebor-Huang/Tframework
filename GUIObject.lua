local Utils = require 'Utils'

--[[
    Basic classes for the HMVC framework.

    The MVC component methods are not intended to receive `self` as a parameter.
    Instead, they receive the GUIObject. So constructs like `controller:foo()`
    should never appear. Use `guiObject:foo()` instead.
]]
local GUIObject = {}

---@class Controller
GUIObject.Controller = {
    process = Utils.nop,  -- Processes events.
    update = Utils.nop,  -- Updats the model, given `dt` as argument.
}

---@class View
GUIObject.View = {
    ---@type love.Canvas
    canvas = nil,
    draw = Utils.nop,  -- Draws on its canvas.
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
    children = {},
    -- Should not be altered. The parent is maintained by the framework.
    ---@type GUIObject|nil
    parent = nil
}

-- To get quick navigation, the index function looks up the methods in the MVC components too.
GUIObject.GUIObject.__index = function(o, k)
    local method = o.model.k
    if method ~= nil then return method end
    method = o.view.k
    if method ~= nil then return method end
    return o.model.k
end

---@return GUIObject
function GUIObject.GUIObject:new()
    local o = {__index = self}
    setmetatable(o, self)
    return o
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
