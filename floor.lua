floor = class:new()

function floor:init(x, y)
    self.pos = {x=x, y=y}
end

function floor:draw()
    if (self.pos.x+self.pos.y)%2 == 0 then
        love.graphics.setColor(colors.checkerLight)
    else
        love.graphics.setColor(colors.checkerDark)
    end
    love.graphics.rectangle("fill", self.pos.x*tileSize, self.pos.y*tileSize, tileSize, tileSize)
end