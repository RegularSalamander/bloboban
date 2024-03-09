hole = class:new()

function hole:init(x, y, cn)
    self.pos = {x=x, y=y}
    self.nextPos = {x=x, y=y}

    self.connectNum = cn
    self.connections = {up=false, left=false, right=false, down=false}
    if cn % 2 == 1 then self.connections.up = true end
    if cn/2 % 2 == 1 then self.connections.left = true end
    if cn/4 % 2 == 1 then self.connections.right = true end
    if cn/8 % 2 == 1 then self.connections.down = true end

    self.checked = false
end

function hole:draw()
    love.graphics.draw(
        images.hole,
        love.graphics.newQuad(self.connectNum*tileSize, 0, 12, 12, 192, 12),
        self.pos.x * tileSize,
        self.pos.y * tileSize,
        0,
        1,
        1
    )
end

function hole:push(dx, dy)
    if self.checked then return true end

    local doMove = true

    local next = getObjectAt(self.pos.x + dx, self.pos.y + dy)
    if next.wall then return false end

    if next.hole then
        doMove = next.hole:push(dx, dy)
    end

    self.checked = true

    if self.connectNum ~= 0 then
        if self.connections.up then
            doMove = doMove and getObjectAt(self.pos.x, self.pos.y - 1).hole:push(dx, dy)
        end
        if self.connections.left then
            doMove = doMove and getObjectAt(self.pos.x - 1, self.pos.y).hole:push(dx, dy)
        end
        if self.connections.right then
            doMove = doMove and getObjectAt(self.pos.x + 1, self.pos.y).hole:push(dx, dy)
        end
        if self.connections.down then
            doMove = doMove and getObjectAt(self.pos.x, self.pos.y + 1).hole:push(dx, dy)
        end
    end

    if doMove then
        self.nextPos.x = self.pos.x + dx
        self.nextPos.y = self.pos.y + dy
    end

    return doMove
end

function hole:applyMove()
    self.pos.x = self.nextPos.x
    self.pos.y = self.nextPos.y
    self.checked = false
end

function hole:cancelMove()
    self.nextPos.x = self.pos.x
    self.nextPos.y = self.pos.y
    self.checked = false
end

function hole:affectConnections()
    
end