player = class:new()

function player:init(x, y)
    self.pos = {x=x, y=y}
    self.nextPos = {x=x, y=y}
end

function player:draw()
    local drawx = util.map(animationFrame, 0, animLengths.moveTime, self.pos.x, self.nextPos.x)
    local drawy = util.map(animationFrame, 0, animLengths.moveTime, self.pos.y, self.nextPos.y)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        images.player,
        math.floor(drawx * tileSize),
        math.floor(drawy * tileSize)
    )
end

function player:control()
    local allowMove = false

    --determine most recently pressed button
    local input = "up"
    local mostRecentPressed = controls["up"]
    if controls["left"] > mostRecentPressed then
        mostRecentPressed = controls["left"]
        input = "left"
    end
    if controls["right"] > mostRecentPressed then
        mostRecentPressed = controls["right"]
        input = "right"
    end
    if controls["down"] > mostRecentPressed then
        mostRecentPressed = controls["down"]
        input = "down"
    end
    
    --don't move unless buffered or actively pressing
    if mostRecentPressed <= 0 and not bufferedControl then
        return false
    end

    --movement
    if input == "up" then
        allowMove = self:move(0, -1)
    elseif input == "down" then
        allowMove = self:move(0, 1)
    elseif input == "left" then
        allowMove = self:move(-1, 0)
    elseif input == "right" then
        allowMove = self:move(1, 0)
    end

    return allowMove
end

function player:move(dx, dy)
    local doMove = true

    local next = getObjectAt(self.pos.x + dx, self.pos.y + dy)
    if next.wall then return false end

    if next.blob then
        doMove = next.blob:push(dx, dy)
    end

    if next.hole then
        doMove = doMove and next.hole:push(dx, dy)
    end

    if doMove then
        self.nextPos.x = self.pos.x + dx
        self.nextPos.y = self.pos.y + dy
    end

    return doMove
end

function player:applyMove()
    self.pos.x = self.nextPos.x
    self.pos.y = self.nextPos.y
end

function player:cancelMove()
    self.nextPos.x = self.pos.x
    self.nextPos.y = self.pos.y
end