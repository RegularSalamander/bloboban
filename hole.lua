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
    self.color = 0

    self.checked = false
end

function hole:draw()
    local drawx = util.map(animationFrame, 0, animLengths.moveTime, self.pos.x, self.nextPos.x)
    local drawy = util.map(animationFrame, 0, animLengths.moveTime, self.pos.y, self.nextPos.y)
    
    love.graphics.setColor(1, 1, 1, 1)
    if self.filled then
        love.graphics.draw(
            images.filledhole,
            love.graphics.newQuad(self.connectNum*tileSize, self.color*tileSize, tileSize, tileSize, tileSize*16, tileSize*3),
            math.floor(drawx * tileSize),
            math.floor(drawy * tileSize),
            0,
            1,
            1
        )
    else
        love.graphics.draw(
            images.hole,
            love.graphics.newQuad(self.connectNum*tileSize, 0, tileSize, tileSize, tileSize*16, tileSize),
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

function hole:checkAffect()
    local affector = getObjectAt(self.pos.x, self.pos.y).affector

    local willChange = false

    if affector then
        if affector.type == "holeDisconnector" then
            if self.connections.up and affector.connections.up then
                willChange = true
            end
            if self.connections.left and affector.connections.left then
                willChange = true
            end
            if self.connections.right and affector.connections.right then
                willChange = true
            end
            if self.connections.down and affector.connections.down then
                willChange = true
            end
        elseif affector.type == "holeConnector" then
            if not self.connections.up and affector.connections.up and getObjectAt(self.pos.x, self.pos.y - 1).hole then
                willChange = true
            end
            if not self.connections.left and affector.connections.left and getObjectAt(self.pos.x - 1, self.pos.y).hole then
                willChange = true
            end
            if not self.connections.right and affector.connections.right and getObjectAt(self.pos.x + 1, self.pos.y).hole then
                willChange = true
            end
            if not self.connections.down and affector.connections.down and getObjectAt(self.pos.x, self.pos.y + 1).hole then
                willChange = true
            end
        end
    end

    return willChange
end

function hole:applyAffect()
    local affector = getObjectAt(self.pos.x, self.pos.y).affector

    local willChange = false

    if affector then
        if affector.type == "holeDisconnector" then
            if self.connections.up and affector.connections.up then
                willChange = true
                self.connections.up = false
            end
            if self.connections.left and affector.connections.left then
                willChange = true
                self.connections.left = false
            end
            if self.connections.right and affector.connections.right then
                willChange = true
                self.connections.right = false
            end
            if self.connections.down and affector.connections.down then
                willChange = true
                self.connections.down = false
            end
        elseif affector.type == "holeConnector" then
            if not self.connections.up and affector.connections.up and getObjectAt(self.pos.x, self.pos.y - 1).hole then
                willChange = true
                self.connections.up = true
            end
            if not self.connections.left and affector.connections.left and getObjectAt(self.pos.x - 1, self.pos.y).hole then
                willChange = true
                self.connections.left = true
            end
            if not self.connections.right and affector.connections.right and getObjectAt(self.pos.x + 1, self.pos.y).hole then
                willChange = true
                self.connections.right = true
            end
            if not self.connections.down and affector.connections.down and getObjectAt(self.pos.x, self.pos.y + 1).hole then
                willChange = true
                self.connections.down = true
            end
        end
    end

    if willChange then
        self:changeConnectNum()
        spawnParticleSquare(particleTypes.circle, 50, self.pos.x*tileSize, self.pos.y*tileSize, tileSize, tileSize, 0.5, 5, 30)
    end
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
    self.color = here.blob.color
    here.blob.alive = false

    spawnParticleSquare(particleTypes.sparkle, 50, self.pos.x*tileSize, self.pos.y*tileSize, tileSize, tileSize, 0.5, 5, 60)

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

function hole:changeConnectNum()
    self.connectNum = 0
    if self.connections.up then self.connectNum = self.connectNum + 1 end
    if self.connections.left then self.connectNum = self.connectNum + 2 end
    if self.connections.right then self.connectNum = self.connectNum + 4 end
    if self.connections.down then self.connectNum = self.connectNum + 8 end
end