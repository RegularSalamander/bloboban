blob = class:new()

function blob:init(x, y, color)
    self.pos = {x=x, y=y}
    self.nextPos = {x=x, y=y}

    self.connectNum = 0
    self.connections = {up=false, left=false, right=false, down=false}
    self.color = color --0=red, 1=green, 2=blue

    self.alive = true

    self.checked = false
end

function blob:draw()
    local drawScale = 1
    if animationState == animStates.affect and self.willChange then
        if animationFrame <= animLengths.affectTime then
            drawScale = util.map(animationFrame, 0, animLengths.affectTime, 1, blobEnlarge)
        else
            drawScale = util.map(animationFrame, animLengths.affectTime, animLengths.affectTime*2, blobEnlarge, 1)
        end
    elseif animationState == animStates.connect and self.willChange then
        if animationFrame <= animLengths.connectTime then
            drawScale = util.map(animationFrame, 0, animLengths.connectTime, 1, blobEnlarge)
        else
            drawScale = util.map(animationFrame, animLengths.connectTime, animLengths.connectTime*2, blobEnlarge, 1)
        end
    end
    local drawx = util.map(animationFrame, 0, animLengths.moveTime, self.pos.x, self.nextPos.x)
    local drawy = util.map(animationFrame, 0, animLengths.moveTime, self.pos.y, self.nextPos.y)

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

function blob:checkAffect()
    self.willChange = false

    local affector = getObjectAt(self.pos.x, self.pos.y).affector

    if affector then
        if affector.type == "colorChanger" then
            if self.color ~= affector.color then
                self.willChange = true
                if self.connections.up then
                    getObjectAt(self.pos.x, self.pos.y - 1).blob.willChange = true
                end
                if self.connections.left then
                    getObjectAt(self.pos.x - 1, self.pos.y).blob.willChange = true
                end
                if self.connections.right then
                    getObjectAt(self.pos.x + 1, self.pos.y).blob.willChange = true
                end
                if self.connections.down then
                    getObjectAt(self.pos.x, self.pos.y + 1).blob.willChange = true
                end
            end
        end
    end

    return self.willChange
end

function blob:applyAffect()
    local up = getObjectAt(self.pos.x, self.pos.y - 1)
    local left = getObjectAt(self.pos.x - 1, self.pos.y)
    local right = getObjectAt(self.pos.x + 1, self.pos.y)
    local down = getObjectAt(self.pos.x, self.pos.y + 1)

    local affector = getObjectAt(self.pos.x, self.pos.y).affector

    if affector then
        if affector.type == "colorChanger" then
            if self.color ~= affector.color then
                spawnParticleSquare(particleTypes.circle, 50, self.pos.x*tileSize, self.pos.y*tileSize, tileSize, tileSize, 0.5, 5, 30)

                self.color = affector.color
                if self.connections.up then
                    self.connections.up = false
                    up.blob.connections.down = false
                    up.blob:changeConnectNum()
                end
                if self.connections.left then
                    self.connections.left = false
                    left.blob.connections.right = false
                    left.blob:changeConnectNum()
                end
                if self.connections.right then
                    self.connections.right = false
                    right.blob.connections.left = false
                    right.blob:changeConnectNum()
                end
                if self.connections.down then
                    self.connections.down = false
                    down.blob.connections.up = false
                    down.blob:changeConnectNum()
                end
            end
        end
    end

    self:changeConnectNum()
end

function blob:checkConnect()
    self.willChange = false

    local up = getObjectAt(self.pos.x, self.pos.y - 1)
    local left = getObjectAt(self.pos.x - 1, self.pos.y)
    local right = getObjectAt(self.pos.x + 1, self.pos.y)
    local down = getObjectAt(self.pos.x, self.pos.y + 1)

    if up.blob and up.blob.color == self.color and not self.connections.up then self.willChange = true end
    if left.blob and left.blob.color == self.color and not self.connections.left then self.willChange = true end
    if right.blob and right.blob.color == self.color and not self.connections.right then self.willChange = true end
    if down.blob and down.blob.color == self.color and not self.connections.down then self.willChange = true end

    return self.willChange
end

function blob:applyConnect()
    local up = getObjectAt(self.pos.x, self.pos.y - 1)
    local left = getObjectAt(self.pos.x - 1, self.pos.y)
    local right = getObjectAt(self.pos.x + 1, self.pos.y)
    local down = getObjectAt(self.pos.x, self.pos.y + 1)

    if up.blob and up.blob.color == self.color then self.connections.up = true end
    if left.blob and left.blob.color == self.color then self.connections.left = true end
    if right.blob and right.blob.color == self.color then self.connections.right = true end
    if down.blob and down.blob.color == self.color then self.connections.down = true end

    self:changeConnectNum()
end

function blob:changeConnectNum()
    self.connectNum = 0
    if self.connections.up then self.connectNum = self.connectNum + 1 end
    if self.connections.left then self.connectNum = self.connectNum + 2 end
    if self.connections.right then self.connectNum = self.connectNum + 4 end
    if self.connections.down then self.connectNum = self.connectNum + 8 end
end