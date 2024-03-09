wall = class:new()

function wall:init(x, y)
    self.pos = {x=x, y=y}
end

function wall:draw()
    love.graphics.draw(
        images.wall,
        self.pos.x * tileSize,
        self.pos.y * tileSize
    )
end