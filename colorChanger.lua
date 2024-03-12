colorChanger = class:new()

function colorChanger:init(x, y, color)
    self.pos = {x=x, y=y}
    self.color = color
    self.type = "colorChanger"
end

function colorChanger:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        images.wall,
        self.pos.x * tileSize,
        self.pos.y * tileSize
    )
end