-- Some handy utilities.
local Utils = {}

-- Does nothing, returns nil.
function Utils.nop() end

-- Placeholder for unimplemented functions, raises an error.
function Utils.unimplemented() error("Unimplemented function.") end

--#region Table

-- Check if the array contains the element, if so, returns the index.
-- If not, returns nil.
---@param array any[]
---@param element number|nil
function Utils.index(array, element)
    for i = 1, #array do
        if array[i] == element then return i end
    end
end

-- Removes the specified element from a list.
---@param array any[]
---@param element number|nil
function Utils.remove(array, element)
    for i = #array, 1, -1 do
        if array[i] == element then
            table.remove(array, i)
        end
    end
end

--#endregion

--#region OOP

--[[
    Basic design:
        - A class is just a table of methods and class variables.
        - A subclass is created with `Utils.class`
        - To find a method or variable in a class, first the class itself is queried.
          Then its superclasses, in order.
        - To find a method or variable of an object:
            - The object itself is queried first.
            - The class method and its superclasses are searched.
            - If the class has a key `__class_index`, then it is called.
        - To create an object:
            - If the class has a key `__instantiate`, it is called after all the initialization is done.
            - `obj.__super()` is used to call the superclass instantiation functions
]]

-- Creates a class from a table of methods and class variables (prototype).
---@param prototype table
---@param parents? table[]
---@return table
function Utils.class(prototype, parents)
    parents = parents or {}
    setmetatable(prototype, {__index=function(c, k)
        for _, p in ipairs(parents) do
            if p[k] then return p[k] end
        end
    end})
    prototype.__super_class = parents
    return prototype
end

-- Instantiates an object of a class.
---@param class table
---@param object? table
---@return table
function Utils.instantiate(class, object)
    object = object or {}
    object.__class = class
    setmetatable(object, {__index=function(o, k)
        if k=='__super' then
            return function(o)
                for i, s in ipairs(class.__super_class) do
                    if s.__instantiate then
                        s:__instantiate(o)
                    end
                end
            end
        end
        if o.__class[k] ~= nil then
            return o.__class[k]
        end
        if o.__class.__class_index then
            return o.__class.__class_index(o, k)
        end
    end})
    if class.__instantiate then class:__instantiate(object) end
    return object
end

--#endregion

return Utils
