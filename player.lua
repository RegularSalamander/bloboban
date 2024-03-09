player = class:new()

function player:init(x, y)
    self.pos = {x=x, y=y}
    self.alive = true
end

function player:draw()
    love.graphics.draw(
        images.player,
        self.pos.x * tileSize,
        self.pos.y * tileSize
    )
end