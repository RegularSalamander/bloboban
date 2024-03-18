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

function readLevel(num)
    local line = levels[num]
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
        elseif t == "r" then
            table.insert(objects.affectors, holeConnector:new(
                string.byte(util.charAt(line, i+1)) - 65,
                string.byte(util.charAt(line, i+2)) - 65,
                string.byte(util.charAt(line, i+3)) - 65
            ))
            i = i + 4
        elseif t == "f" then
            table.insert(floors, {
                x=string.byte(util.charAt(line, i+1)) - 65,
                y=string.byte(util.charAt(line, i+2)) - 65
            })
            i = i + 3
        end
    end
end