particle = class:new()

function particle:init(t, x, y, vx, vy, r, ttl)
    self.type = t

    self.pos = {x=x, y=y}
    self.vel = {x=vx, y=vy}

    self.maxRad = r
    self.rad = r

    self.maxttl = ttl
    self.ttl = ttl
    self.alive = true
end

function particle:draw()
    if self.type == particleTypes.circle then
        love.graphics.setColor(colors.particle)
        love.graphics.circle("fill", self.pos.x, self.pos.y, self.rad)
    elseif self.type == particleTypes.sparkle then
        love.graphics.setColor(colors.sparkle)
        love.graphics.line(self.pos.x, self.pos.y, self.pos.x, self.pos.y-self.rad)
        love.graphics.line(self.pos.x, self.pos.y, self.pos.x, self.pos.y+self.rad)
        love.graphics.line(self.pos.x, self.pos.y, self.pos.x+self.rad, self.pos.y)
        love.graphics.line(self.pos.x, self.pos.y, self.pos.x-self.rad, self.pos.y)
    end
end

function particle:update()
    self.pos.x = self.pos.x + self.vel.x
    self.pos.y = self.pos.y + self.vel.y

    self.rad = util.map(self.ttl, self.maxttl, 0, self.maxRad, 0)

    self.ttl = self.ttl - 1
    if self.ttl <= 0 then
        self.alive = false
    end
end

function spawnParticleSquare(t, n, x, y, w, h, v, r, ttl)
    for i = 1, n do
        local theta = love.math.random() * 2*math.pi
        table.insert(objects.particles, particle:new(
            t,
            x + love.math.random() * w,
            y + love.math.random() * h,
            math.cos(theta) * v,
            math.sin(theta) * v,
            r,
            ttl
        ))
    end
end