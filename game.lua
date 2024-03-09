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
    objects.blobs = { blob:new(10, 10), blob:new(12, 12) }
    objects.walls = { wall:new(14, 10) }
    objects.holes = {}
end

function game_update(delta)
    --default frame rate is 60, delta time is dealt with in frames
    delta = delta * 60
    --if we're at less than 30 fps that probably means the game was unfocused
    delta = math.min(delta, 2)

    --[[
        Steps in updating objects:
        - for each object group:
            - keep a list of objects slated for deletion
            - for each object:
                - update some number of times per frame
                - stop if the update function returns false, meaning it can be deleted
            - go through the list of objects to be deleted, backwards, removing them
    ]]
    for k in pairs(objects) do
        local inactive = {}
        for i = 1, #objects[k] do
            if objects[k][i].update then
                for updateNum = 1, updatesPerFrame do
                    if not objects[k][i]:update(delta / updatesPerFrame, updateNum) then
                        --update function returned false
                        table.insert(inactive, i)
                        break
                    end
                end
            end
        end
        if #inactive then
            for i = #inactive, 1, -1 do
                table.remove(objects[k], inactive[i])
            end
        end
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

    love.graphics.setBackgroundColor(0.5, 0.5, 0.5)
    love.graphics.clear()

    for k in pairs(objects) do
        for i = 1, #objects[k] do
            if objects[k][i].draw then
                objects[k][i]:draw()
            end
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