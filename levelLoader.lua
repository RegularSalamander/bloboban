function fillWallRect(x, y, w, h)
    for i = x, x+w-1 do
        for j = y, y+h-1 do
            table.insert(objects.walls, wall:new(i, j))
        end
    end
end

function addFloorRect(x, y, w, h)
    table.insert(floorQuads, {x=x, y=y, w=w, h=h})
end

function loadLevel(num)
    objects.player = {}
    objects.walls = {}
    objects.blobs = {}
    objects.holes = {}
    objects.affectors = {}

    floorQuads = {}

    readLevel(num)

    for i = 1, #objects.walls do
        objects.walls[i]:setOutlines()
    end
    for i = 1, #objects.blobs do
        objects.blobs[i]:applyConnect()
    end
end

function compileLevel(num)
    local str = ""

    local img = love.image.newImageData("levels/" .. num .. ".png")
    for y = 0, img:getHeight()-1 do
        for x = 0, img:getWidth()-1 do
            local r, g, b, a = img:getPixel(x, y)
            r = r * 255
            g = g * 255
            b = b * 255
            a = a * 255
            if r == 0 and g == 0 and b == 0 and a == 255 then --wall
                str = str .. "w"
                str = str .. string.char(x+65)
                str = str .. string.char(y+65)
            elseif r == 255 and g == 128 and b == 0 and a == 255 then --player
                str = str .. "p"
                str = str .. string.char(x+65)
                str = str .. string.char(y+65)
            elseif r == 255 and g == 0 and b == 0 and a == 255 then --red blob
                str = str .. "b"
                str = str .. string.char(x+65)
                str = str .. string.char(y+65)
                str = str .. string.char(65)
            elseif r == 0 and g == 255 and b == 0 and a == 255 then --green blob
                str = str .. "b"
                str = str .. string.char(x+65)
                str = str .. string.char(y+65)
                str = str .. string.char(66)
            elseif r == 0 and g == 0 and b == 255 and a == 255 then --blue blob
                str = str .. "b"
                str = str .. string.char(x+65)
                str = str .. string.char(y+65)
                str = str .. string.char(67)
            elseif r == 128 and g == 128 and a == 255 then --hole
                str = str .. "h"
                str = str .. string.char(x+65)
                str = str .. string.char(y+65)
                str = str .. string.char(b+65)
            elseif g == 128 and b == 128 and a == 255 then --color changer
                str = str .. "c"
                str = str .. string.char(x+65)
                str = str .. string.char(y+65)
                str = str .. string.char(r+65)
            elseif r == 128 and b == 128 and a == 255 then --hole disconnector
                str = str .. "d"
                str = str .. string.char(x+65)
                str = str .. string.char(y+65)
                str = str .. string.char(g+65)
            end
        end
    end

    io.write(str)
    return str
end

function readLevel(num)
    local line = floors[num] .. levels[num]
    local i = 1

    while i <= #line do
        t = util.charAt(line, i)
        if t == "w" then
            table.insert(objects.walls, wall:new(
                string.byte(util.charAt(line, i+1)) - 65,
                string.byte(util.charAt(line, i+2)) - 65
            ))
            i = i + 3
        elseif t == "p" then
            objects.player = {player:new(
                string.byte(util.charAt(line, i+1)) - 65,
                string.byte(util.charAt(line, i+2)) - 65
            )}
            i = i + 3
        elseif t == "b" then
            table.insert(objects.blobs, blob:new(
                string.byte(util.charAt(line, i+1)) - 65,
                string.byte(util.charAt(line, i+2)) - 65,
                string.byte(util.charAt(line, i+3)) - 65
            ))
            i = i + 4
        elseif t == "h" then
            table.insert(objects.holes, hole:new(
                string.byte(util.charAt(line, i+1)) - 65,
                string.byte(util.charAt(line, i+2)) - 65,
                string.byte(util.charAt(line, i+3)) - 65
            ))
            i = i + 4
        elseif t == "c" then
            table.insert(objects.affectors, colorChanger:new(
                string.byte(util.charAt(line, i+1)) - 65,
                string.byte(util.charAt(line, i+2)) - 65,
                string.byte(util.charAt(line, i+3)) - 65
            ))
            i = i + 4
        elseif t == "d" then
            table.insert(objects.affectors, holeDisconnector:new(
                string.byte(util.charAt(line, i+1)) - 65,
                string.byte(util.charAt(line, i+2)) - 65,
                string.byte(util.charAt(line, i+3)) - 65
            ))
            i = i + 4
        elseif t == "f" then
            io.write("AHHH")
            addFloorRect(
                string.byte(util.charAt(line, i+1)) - 65,
                string.byte(util.charAt(line, i+2)) - 65,
                string.byte(util.charAt(line, i+3)) - 65,
                string.byte(util.charAt(line, i+4)) - 65
            )
            i = i + 5
        end
    end
end