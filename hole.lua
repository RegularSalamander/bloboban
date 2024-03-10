hole = class:new()

function hole:init(x, y, cn)
    self.pos = {x=x, y=y}
    self.nextPos = {x=x, y=y}

    self.connectNum = cn
    self.connections = {up=false, left=false, right=false, down=false}
    if math.floor(cn/1) % 2 ~= 0 then self.connections.up = true end
    if math.floor(cn/2) % 2 ~= 0 then self.connections.left = true end
    if math.floor(cn/4) % 2 ~= 0 then self.connections.right = true end
    if math.floor(cn/8) % 2 ~= 0 then self.connections.down = true end

    self.filled = false

    self.checked = false
end

function hole:draw()
    local drawx = util.map(animationFrame, 0, tweenTime, self.pos.x, self.nextPos.x)
    local drawy = util.map(animationFrame, 0, tweenTime, self.pos.y, self.nextPos.y)
    if self.filled then
        love.graphics.draw(
            images.filledhole,
            love.graphics.newQuad(self.connectNum*tileSize, 0, 12, 12, 192, 12),
            drawx * tileSize,
            drawy * tileSize,
            0,
            1,
            1
        )
    else
        love.graphics.draw(
            images.hole,
            love.graphics.newQuad(self.connectNum*tileSize, 0, 12, 12, 192, 12),
            drawx * tileSize,
            drawy * tileSize,
            0,
            1,
            1
        )
    end
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

function hole:checkFill()
    if self.checked then return true end
    if self.filled then return false end

    self.checked = true

    local filling = true

    here = getObjectAt(self.pos.x, self.pos.y)

    if here.blob then
        if self.connections.up == here.blob.connections.up
        and self.connections.left == here.blob.connections.left
        and self.connections.right == here.blob.connections.right
        and self.connections.down == here.blob.connections.down then
            if self.connections.up then
                filling = getObjectAt(self.pos.x, self.pos.y - 1).hole:checkFill()
            end
            if self.connections.left then
                filling = filling and getObjectAt(self.pos.x - 1, self.pos.y).hole:checkFill()
            end
            if self.connections.right then
                filling = filling and getObjectAt(self.pos.x + 1, self.pos.y).hole:checkFill()
            end
            if self.connections.down then
                filling = filling and getObjectAt(self.pos.x, self.pos.y + 1).hole:checkFill()
            end
        else
            filling = false
        end
    else
        filling = false
    end

    self.checked = false
    return filling
end

function hole:applyFill()
    if self.filled then return end

    here = getObjectAt(self.pos.x, self.pos.y)

    self.filled = true
    here.blob.alive = false

    if self.connections.up then
        getObjectAt(self.pos.x, self.pos.y - 1).hole:applyFill()
    end
    if self.connections.left then
        getObjectAt(self.pos.x - 1, self.pos.y).hole:applyFill()
    end
    if self.connections.right then
        getObjectAt(self.pos.x + 1, self.pos.y).hole:applyFill()
    end
    if self.connections.down then
        getObjectAt(self.pos.x, self.pos.y + 1).hole:applyFill()
    end
end