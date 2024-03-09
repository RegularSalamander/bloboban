blob = class:new()

function blob:init(x, y, cn)
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

function blob:draw()
    local drawx = util.map(animationFrame, 0, tweenTime, self.pos.x, self.nextPos.x)
    local drawy = util.map(animationFrame, 0, tweenTime, self.pos.y, self.nextPos.y)

    love.graphics.draw(
        images.blob,
        love.graphics.newQuad(self.connectNum*tileSize, 0, 12, 12, 192, 12),
        drawx * tileSize,
        drawy * tileSize,
        0,
        1,
        1
    )
end

function blob:push(dx, dy)
    if self.checked then return true end

    local doMove = true

    local next = getObjectAt(self.pos.x + dx, self.pos.y + dy)
    if next.wall then return false end

    if next.blob then
        doMove = next.blob:push(dx, dy)
    end

    self.checked = true

    if self.connectNum ~= 0 then
        if self.connections.up then
            doMove = doMove and getObjectAt(self.pos.x, self.pos.y - 1).blob:push(dx, dy)
        end
        if self.connections.left then
            doMove = doMove and getObjectAt(self.pos.x - 1, self.pos.y).blob:push(dx, dy)
        end
        if self.connections.right then
            doMove = doMove and getObjectAt(self.pos.x + 1, self.pos.y).blob:push(dx, dy)
        end
        if self.connections.down then
            doMove = doMove and getObjectAt(self.pos.x, self.pos.y + 1).blob:push(dx, dy)
        end
    end

    if doMove then
        self.nextPos.x = self.pos.x + dx
        self.nextPos.y = self.pos.y + dy
    end

    return doMove
end

function blob:applyMove()
    self.pos.x = self.nextPos.x
    self.pos.y = self.nextPos.y
    self.checked = false
end

function blob:cancelMove()
    self.nextPos.x = self.pos.x
    self.nextPos.y = self.pos.y
    self.checked = false
end

function blob:affectConnections()
    local up = getObjectAt(self.pos.x, self.pos.y - 1)
    local left = getObjectAt(self.pos.x - 1, self.pos.y)
    local right = getObjectAt(self.pos.x + 1, self.pos.y)
    local down = getObjectAt(self.pos.x, self.pos.y + 1)

    if up.blob then self.connections.up = true end
    if left.blob then self.connections.left = true end
    if right.blob then self.connections.right = true end
    if down.blob then self.connections.down = true end

    self.connectNum = 0
    if self.connections.up then self.connectNum = self.connectNum + 1 end
    if self.connections.left then self.connectNum = self.connectNum + 2 end
    if self.connections.right then self.connectNum = self.connectNum + 4 end
    if self.connections.down then self.connectNum = self.connectNum + 8 end
end