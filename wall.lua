wall = class:new()

function wall:init(x, y)
    self.pos = {x=x, y=y}

    self.outlines = {up=false, left=false, right=false, down=false}
end

function wall:setOutlines()
    local up = getObjectAt(self.pos.x, self.pos.y - 1)
    local left = getObjectAt(self.pos.x - 1, self.pos.y)
    local right = getObjectAt(self.pos.x + 1, self.pos.y)
    local down = getObjectAt(self.pos.x, self.pos.y + 1)

    if not up.wall then self.outlines.up = true end
    if not left.wall then self.outlines.left = true end
    if not right.wall then self.outlines.right = true end
    if not down.wall then self.outlines.down = true end
end

function wall:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        images.wall,
        self.pos.x * tileSize,
        self.pos.y * tileSize
    )

    love.graphics.setColor(0, 0, 0)
    if self.outlines.up then love.graphics.rectangle("fill", self.pos.x*tileSize, self.pos.y*tileSize, tileSize, 1) end
    if self.outlines.left then love.graphics.rectangle("fill", self.pos.x*tileSize, self.pos.y*tileSize, 1, tileSize) end
    if self.outlines.right then love.graphics.rectangle("fill", self.pos.x*tileSize+15, self.pos.y*tileSize, 1, tileSize) end
    if self.outlines.down then love.graphics.rectangle("fill", self.pos.x*tileSize, self.pos.y*tileSize+15, tileSize, 1) end
end