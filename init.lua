--[[
    Tframework.
]]
local Tframework = {}

Tframework.Utils = require 'Utils'
Tframework.GUIObject = require 'GUIObject'

-- Placeholder handler for Löve events that just uses the handlers given by Löve.
local function defaultHandler(s,...)
    love.handlers[s](...)
end
Tframework.defaultHandler = defaultHandler

-- Handlers. Usually you don't need to change them.
-- TODO should be more uniform
local handlers = {
    focus = defaultHandler, -- Window focus gained or lost
    joystickpressed = defaultHandler, -- Joystick pressed
    joystickreleased = defaultHandler, -- Joystick released
    keypressed = defaultHandler, -- Key pressed
    keyreleased = defaultHandler, -- Key released
    mousepressed = defaultHandler, -- Mouse pressed
    mousereleased = defaultHandler, -- Mouse released
    resize = defaultHandler, -- Window size changed by the user
    visible = defaultHandler, -- Window is minimized or un-minimized by the user
    mousefocus = defaultHandler, -- Window mouse focus gained or lost
    threaderror = defaultHandler, -- A Lua error has occurred in a thread
    joystickadded = defaultHandler, -- Joystick connected
    joystickremoved = defaultHandler, -- Joystick disconnected
    joystickaxis = defaultHandler, -- Joystick axis motion
    joystickhat = defaultHandler, -- Joystick hat pressed
    gamepadpressed = defaultHandler, -- Joystick's virtual gamepad button pressed
    gamepadreleased = defaultHandler, -- Joystick's virtual gamepad button released
    gamepadaxis = defaultHandler, -- Joystick's virtual gamepad axis moved
    textinput = defaultHandler, -- User entered text
    mousemoved = defaultHandler, -- Mouse position changed
    lowmemory = defaultHandler, -- Running out of memory on mobile devices system
    textedited = defaultHandler, -- Candidate text for an IME changed
    wheelmoved = defaultHandler, -- Mouse wheel moved
    touchpressed = defaultHandler, -- Touch screen touched
    touchreleased = defaultHandler, -- Touch screen stop touching
    touchmoved = defaultHandler, -- Touch press moved inside touch screen
    directorydropped = defaultHandler, -- Directory is dragged and dropped onto the window
    filedropped = defaultHandler, -- File is dragged and dropped onto the window.
}
Tframework.handlers = handlers
Tframework.scene = Tframework.GUIObject.GUIObject

function love.run()
    local love = love
    local event = love.event
    local timer, getTime = love.timer, love.timer.getTime
    local update = love.update
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

    -- We don't want the first frame's dt to include time taken by love.load.
    timer.step()

    local dt = 0

    -- A few variables to control the frame rate
    local startTime = getTime()
    local frameTimes = {}  -- A simple fixed-size queue
    for i = 1, 60 do
        frameTimes[i] = startTime-1+i/60
    end
    local currentFrameTimesIndex = 60
    local avg59FrameTime = 59/60
    local compensatoryFrameTime = 1/60
    local timePassed = 0

    -- Main loop time.
    return function()
        -- Process events.
        if event then
            event.pump()
            for name, a,b,c,d,e,f in event.poll() do
                if handlers[name] then
                    handlers[name](name,a,b,c,d,e,f)
                elseif name=='quit' then
                    if love.quit then love.quit() end
                    return a or 0
                end
            end
        end

        -- Update dt, as we'll be passing it to update
        dt = timer.step()

        -- Call update and draw
        Tframework.scene:update(dt)

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())
            Tframework.scene:draw()
            love.graphics.present()
        end

        -- Custom frame locking, with a simple Integral controller
        -- We have plenty of time left to waste here
        -- TODO but we should implement this in C anyways
        avg59FrameTime = frameTimes[currentFrameTimesIndex] - frameTimes[currentFrameTimesIndex%60+1]
        compensatoryFrameTime = math.min(math.max(1/30 - avg59FrameTime/59, 1/80), 1/40)
        timePassed = getTime() - frameTimes[currentFrameTimesIndex]
        while timePassed < compensatoryFrameTime - 1/500 do
            timer.sleep((compensatoryFrameTime - timePassed)*0.8)
            timePassed = getTime() - frameTimes[currentFrameTimesIndex]
        end
        -- Spinning helps with even better time control
        while getTime() - frameTimes[currentFrameTimesIndex] < compensatoryFrameTime do end
        currentFrameTimesIndex = currentFrameTimesIndex % 60 + 1  -- Intricate magic to keep it in the range 1..60
        frameTimes[currentFrameTimesIndex] = getTime()
    end
end

return Tframework
