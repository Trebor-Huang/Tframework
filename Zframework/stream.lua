--[[
Streams that accept multiple coroutines that reads values from it.

Note that Stream objects cannot be deep-copied.
When copying reader coroutines, remember to use the same Stream.
]]--

local STREAM={}
STREAM.Stream={}  -- Stream class prototype
STREAM.Reader={}  -- Reader class prototype
setmetatable(STREAM.Reader, {
    __call = function(self)
        self.index=self.index+1
        return self.stream:seek(self.index)
    end
})

-- Creates a stream from an iterable
function STREAM.wrap(iter)
    local stream={}
    for k,v in pairs(STREAM.Stream) do
        stream[k]=v
    end
    stream.iterator=iter
    stream.history={}
    return stream
end

-- A constant stream.
function STREAM.constant(value)
    return STREAM.wrap(coroutine.wrap(function() while true do coroutine.yield(value) end end))
end

-- Extends the stream. This is never directly called from the outside.
function STREAM.Stream:next()
    self.history[#(self.history)+1]=self.iterator()
end

-- Creates a reader at the index. If the index is unspecified, uses the latest index.
function STREAM.Stream:reader(index)
    index=index or #(self.history)
    local reader={index=index, stream=self}
    for k,v in pairs(STREAM.Reader) do
        reader[k]=v
    end
    setmetatable(reader, getmetatable(STREAM.Reader))
    return reader
end

-- Reads the value at a specific index.
function STREAM.Stream:seek(index)
    if index<=0 then return nil end
    while #self.history<index do
        self:next()
    end
    return self.history[index]
end

-- Seeks a index in the reader
function STREAM.Reader:seek(index)
    self.index=index
end

return STREAM
