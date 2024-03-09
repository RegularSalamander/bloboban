blob = class:new()

function blob:init(x, y)
    self.pos = {x=x, y=y}
end

function blob:draw()
    love.graphics.draw(
        images.blob,
        self.pos.x * tileSize,
        self.pos.y * tileSize
    )
end

function blob:push(dx, dy)
    local doMove = true

    local next = getObjectAt(self.pos.x + dx, self.pos.y + dy)
    if next.wall then return false end

    if next.blob then
        doMove = next.blob:push(dx, dy)
    end

    if doMove then
        self.pos.x = self.pos.x + dx
        self.pos.y = self.pos.y + dy
    end

    return doMove
end