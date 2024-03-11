blob = class:new()

function blob:init(x, y, color, cn)
    self.pos = {x=x, y=y}
    self.nextPos = {x=x, y=y}

    self.connectNum = cn
    self.connections = {up=false, left=false, right=false, down=false}
    if cn % 2 == 1 then self.connections.up = true end
    if cn/2 % 2 == 1 then self.connections.left = true end
    if cn/4 % 2 == 1 then self.connections.right = true end
    if cn/8 % 2 == 1 then self.connections.down = true end
    self.color = color --0=red, 1=green, 2=blue

    self.alive = true

    self.checked = false
end

function blob:draw()
    local drawScale = 1
    if animationState == animStates.preconnect and self.willConnect then
        drawScale = util.map(animationFrame, 0, preconnectTime, 1, blobEnlarge)
    elseif animationState == animStates.postconnect and self.willConnect then
        drawScale = util.map(animationFrame, 0, postconnectTime, blobEnlarge, 1)
    end
    local drawx = util.map(animationFrame, 0, moveTime, self.pos.x, self.nextPos.x)
    local drawy = util.map(animationFrame, 0, moveTime, self.pos.y, self.nextPos.y)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        images.blob,
        love.graphics.newQuad(self.connectNum*tileSize, self.color*tileSize, tileSize, tileSize, tileSize*16, tileSize*3),
        math.floor(drawx * tileSize) - 0.5*tileSize*(drawScale-1),
        math.floor(drawy * tileSize) - 0.5*tileSize*(drawScale-1),
        0,
        drawScale,
        drawScale
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

function blob:testConnections()
    self.willConnect = false

    local up = getObjectAt(self.pos.x, self.pos.y - 1)
    local left = getObjectAt(self.pos.x - 1, self.pos.y)
    local right = getObjectAt(self.pos.x + 1, self.pos.y)
    local down = getObjectAt(self.pos.x, self.pos.y + 1)

    if up.blob and up.blob.color == self.color and not self.connections.up then self.willConnect = true end
    if left.blob and left.blob.color == self.color and not self.connections.left then self.willConnect = true end
    if right.blob and right.blob.color == self.color and not self.connections.right then self.willConnect = true end
    if down.blob and down.blob.color == self.color and not self.connections.down then self.willConnect = true end

    return self.willConnect
end

function blob:affectConnections()
    local up = getObjectAt(self.pos.x, self.pos.y - 1)
    local left = getObjectAt(self.pos.x - 1, self.pos.y)
    local right = getObjectAt(self.pos.x + 1, self.pos.y)
    local down = getObjectAt(self.pos.x, self.pos.y + 1)

    if up.blob and up.blob.color == self.color then self.connections.up = true end
    if left.blob and left.blob.color == self.color then self.connections.left = true end
    if right.blob and right.blob.color == self.color then self.connections.right = true end
    if down.blob and down.blob.color == self.color then self.connections.down = true end

    self.connectNum = 0
    if self.connections.up then self.connectNum = self.connectNum + 1 end
    if self.connections.left then self.connectNum = self.connectNum + 2 end
    if self.connections.right then self.connectNum = self.connectNum + 4 end
    if self.connections.down then self.connectNum = self.connectNum + 8 end
end