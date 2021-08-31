-- Some handy utilities
local Utils = {}

-- Does nothing, returns nil
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

return Utils
