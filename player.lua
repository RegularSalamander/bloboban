player = class:new()

function player:init(x, y)
    self.pos = {x=x, y=y}
    self.nextPos = {x=x, y=y}
end

function player:draw()
    local drawx = util.map(math.min(animationFrame, tweenTime), 0, tweenTime, self.pos.x, self.nextPos.x)
    local drawy = util.map(math.min(animationFrame, tweenTime), 0, tweenTime, self.pos.y, self.nextPos.y)

    love.graphics.draw(
        images.player,
        drawx * tileSize,
        drawy * tileSize
    )
end

function player:control()
    local allowMove = false

    --movement
    if controls["up"] >= 1 then
        allowMove = self:move(0, -1)
    elseif controls["down"] >= 1 then
        allowMove = self:move(0, 1)
    elseif controls["left"] >= 1 then
        allowMove = self:move(-1, 0)
    elseif controls["right"] >= 1 then
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