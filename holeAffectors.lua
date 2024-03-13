holeDisconnector = class:new()

function holeDisconnector:init(x, y, cn)
    self.pos = {x=x, y=y}
    
    self.connectNum = cn
    self.connections = {up=false, left=false, right=false, down=false}
    if math.floor(cn/1) % 2 ~= 0 then self.connections.up = true end
    if math.floor(cn/2) % 2 ~= 0 then self.connections.left = true end
    if math.floor(cn/4) % 2 ~= 0 then self.connections.right = true end
    if math.floor(cn/8) % 2 ~= 0 then self.connections.down = true end

    self.type = "holeDisconnector"
end

function holeDisconnector:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
            images.holeAffector,
            love.graphics.newQuad(self.connectNum*tileSize, 0, tileSize, tileSize, tileSize*16, tileSize*2),
            self.pos.x * tileSize,
            self.pos.y * tileSize,
            0,
            1,
            1
        )
end

holeConnector = class:new()

function holeConnector:init(x, y, cn)
    self.pos = {x=x, y=y}
    
    self.connectNum = cn
    self.connections = {up=false, left=false, right=false, down=false}
    if math.floor(cn/1) % 2 ~= 0 then self.connections.up = true end
    if math.floor(cn/2) % 2 ~= 0 then self.connections.left = true end
    if math.floor(cn/4) % 2 ~= 0 then self.connections.right = true end
    if math.floor(cn/8) % 2 ~= 0 then self.connections.down = true end

    self.type = "holeConnector"
end

function holeConnector:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
            images.holeAffector,
            love.graphics.newQuad(self.connectNum*tileSize, tileSize, tileSize, tileSize, tileSize*16, tileSize*2),
            self.pos.x * tileSize,
            self.pos.y * tileSize,
            0,
            1,
            1
        )
end