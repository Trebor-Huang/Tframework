--[[
    Default testing code.
]]
Tframework = require 'init'

local pi, sin, cos, pow, tanh, log = math.pi, math.sin, math.cos, math.pow, math.tanh, math.log
local getTime = love.timer.getTime
local gc = love.graphics
local keys = {}
local releasedkeys = {}
local KeyPosition = {
    z = {30, 230},
    s = {50, 200},
    e = {70, 170},
    x = {80, 230},
    d = {100, 200},
    r = {120, 170},
    c = {130, 230},
    f = {150, 200},
    v = {170, 230},
    g = {190, 200},
    y = {210, 170},
    b = {220, 230},
    h = {240, 200},
    u = {260, 170},
    n = {270, 230},
    j = {290, 200},
    i = {310, 170},
    m = {320, 230},
    k = {340, 200},
    [","] = {360, 230},
}
local KeyPitch = {
    z = 0,
    s = 1,
    e = 2,
    x = 3,
    d = 4,
    r = 5,
    c = 6,
    f = 7,
    v = 8,
    g = 9,
    y = 10,
    b = 11,
    h = 12,
    u = 13,
    n = 14,
    j = 15,
    i = 16,
    m = 17,
    k = 18,
    [","] = 19,
}
local KeySources = {}

for k, p in pairs(KeyPitch) do
    local length = 44100 / pow(2, (p-14)/19)
    local data = love.sound.newSoundData(length, 44100, 16, 1)
    for i = 0,length-1 do
        local wave = 0.5*sin(2 * pi * i/44100 * 440 * pow(2, (p-14)/19))
        data:setSample(i, wave)
    end
    KeySources[k] = love.audio.newSource(data)
end

local KeyView = Tframework.Utils.class(Tframework.GUIObject.View)
function KeyView:__instantiate(o)
    o.__super()
    o.canvas = gc.newCanvas(30, 30)
    return o
end

function KeyView:draw()
    -- Draws keys depending on whether the key is pressed
    if self.pressed ~= self.drawpressed then
        gc.clear(self.pressed and {0.7,0.3,0.4} or {0.5,0.5,0.5})
        gc.printf({self.pressed and {0, 1, 1} or {1, 1, 0}, self.key}, 0, 8, 30, 'center')
        self.drawpressed = self.pressed
        return true
    end
    return false
end

---@type Model
local KeyModel = {pressed = false, drawpressed = true}

local KeyObjects = {}
local KeyTransforms = {}
for k, i in pairs(KeyPitch) do
    local o = Tframework.Utils.instantiate(Tframework.GUIObject.GUIObject)
    o.view = Tframework.Utils.instantiate(KeyView, {key=k})
    -- o.controller = nil -- TODO
    o.model = Tframework.Utils.instantiate(KeyModel)
    KeyObjects[i+1] = o
    KeyTransforms[o] = KeyPosition[k]
end
local MainScene = Tframework.Utils.instantiate(Tframework.GUIObject.Components.Container,
    {children = KeyObjects, childrenTransform = KeyTransforms})

function MainScene.controller:update(dt)
    for k, s in pairs(KeySources) do
        if keys[k] then
            if releasedkeys[k] then
                s:setVolume(s:getVolume() * (1 - 10*dt))
            else
                s:setVolume(1-(1 - s:getVolume()) * (1-10*dt))
            end
        end
    end
end

function Tframework.handlers.keypressed(_, key)
    if not KeySources[key] then return end
    keys[key] = getTime()
    MainScene.children[KeyPitch[key]+1].pressed = true
    KeySources[key]:play()
    KeySources[key]:setLooping(true)
    KeySources[key]:setVolume(0)
    releasedkeys[key] = nil
end

function Tframework.handlers.keyreleased(_, key)
    if not KeySources[key] then return end
    releasedkeys[key] = getTime()
    MainScene.children[KeyPitch[key]+1].pressed = false
end

Tframework.scene = MainScene
