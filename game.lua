function game_load()
    --[[
        ints for controls
        -1 always means it was just released this frame
        1 always means it was just pressed this frame
        above 1 means the amount of time it's been pressed (in 1/60th seconds)
        below -1 means the amount of time since it was last pressed (times -1)
    ]]
    controls = {
        left = 0,
        right = 0,
        up = 0,
        down = 0,
        z = 0,
        x = 0,
        c = 0
    }

    --objects are anything we should call an update and/or draw function on each frame
    objects = {}
    objects.player = { player:new(0, 0) }
    objects.blobs = { blob:new(10, 10, 0), blob:new(8, 10, 0), blob:new(10, 8, 0), blob:new(10, 12, 0), blob:new(12, 10, 0) }
    objects.walls = { wall:new(14, 10) }
    objects.holes = { hole:new(10, 10, 15), hole:new(9, 10, 4), hole:new(10, 9, 8), hole:new(10, 11, 1), hole:new(11, 10, 2) }

    animationFrame = 0
end

function game_update(delta)
    --default frame rate is 60, delta time is dealt with in frames
    delta = delta * 60
    --if we're at less than 30 fps that probably means the game was unfocused
    delta = math.min(delta, 2)

    if animationFrame == 0 then
        if objects.player[1]:control() then
            animationFrame = 1
        else
            for i = 1, #objects.blobs do
                objects.blobs[i]:cancelMove()
            end
            for i = 1, #objects.holes do
                objects.holes[i]:cancelMove()
            end
        end
    elseif animationFrame == tweenTime + waitTime then
        --finalize movement
        objects.player[1]:applyMove()
        for i = 1, #objects.blobs do
            objects.blobs[i]:applyMove()
        end
        for i = 1, #objects.holes do
            objects.holes[i]:applyMove()
        end

        --affect the connections between objects
        for i = 1, #objects.blobs do
            objects.blobs[i]:affectConnections()
        end
        for i = 1, #objects.holes do
            objects.holes[i]:affectConnections()
        end

        --check for filled holes
        for i = 1, #objects.holes do
            if objects.holes[i]:checkFill() then objects.holes[i]:applyFill() end
        end

        --delete blobs from filled holes
        for i = #objects.blobs, 1, -1 do
            if not objects.blobs[i].alive then
                table.remove(objects.blobs, i)
            end
        end

        animationFrame = 0
    else
        animationFrame = animationFrame + 1
    end


    --keys are updated last so that objects can see if they're 1 or -1
    for k, v in pairs(controls) do
        if v > 0 then controls[k] = v + delta
        else controls[k] = v - delta
        end
    end
end

function game_draw()
    love.graphics.setCanvas(gameCanvas)

    love.graphics.setBackgroundColor(1, 1, 1)
    love.graphics.clear()

    objects.player[1]:draw()

    for i = 1, #objects.holes do
        if objects.holes[i].draw then
            objects.holes[i]:draw()
        end
    end

    for i = 1, #objects.blobs do
        if objects.blobs[i].draw then
            objects.blobs[i]:draw()
        end
    end

    for i = 1, #objects.walls do
        if objects.walls[i].draw then
            objects.walls[i]:draw()
        end
    end
end

function game_keypressed(key, scancode, isrepeat)
    --if you want to remap keys, do it by changing the scancode
    if isrepeat then return end
    if controls[scancode] ~= nil then controls[scancode] = 1 end
end

function game_keyreleased(key, scancode, isrepeat)
    if isrepeat then return end
    if controls[scancode] ~= nil then controls[scancode] = 0 end
end

function getObjectAt(x, y)
    local rv = {
        wall = nil,
        blob = nil,
        hole = nil
    }
    
    for i = 1, #objects.walls do
        if objects.walls[i].pos.x == x and objects.walls[i].pos.y == y then
            rv.wall = objects.walls[i] 
            break
        end
    end
    for i = 1, #objects.blobs do
        if objects.blobs[i].pos.x == x and objects.blobs[i].pos.y == y then
            rv.blob = objects.blobs[i] 
            break
        end
    end
    for i = 1, #objects.holes do
        if objects.holes[i].pos.x == x and objects.holes[i].pos.y == y then
            rv.hole = objects.holes[i] 
            break
        end
    end
    
    return rv
end