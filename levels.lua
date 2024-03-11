function fillWallRect(x, y, w, h)
    for i = x, x+w-1 do
        for j = y, y+h-1 do
            table.insert(objects.walls, wall:new(i, j))
        end
    end
end

function loadLevel(num)
    objects.player = {}
    objects.walls = {}
    objects.blobs = {}
    objects.holes = {}

    addLevelObjects(num)

    for i = 1, #objects.walls do
        objects.walls[i]:setOutlines()
    end
    for i = 1, #objects.blobs do
        objects.blobs[i]:affectConnections()
    end
end

function addLevelObjects(num)
    if num == 0 then
        objects.player = { player:new(8, 7) }
        objects.blobs = { blob:new(5, 5, 0, 0), blob:new(5, 7, 0, 0), blob:new(5, 9, 0, 0) }
        objects.holes = { hole:new(21, 6, 8), hole:new(21, 7, 9), hole:new(21, 8, 1) }
        fillWallRect(0, 0, 27, 4)
        fillWallRect(0, 12, 27, 3)
        fillWallRect(0, 4, 4, 8)
        fillWallRect(11, 4, 5, 3)
        fillWallRect(11, 9, 5, 3)
        fillWallRect(23, 4, 4, 8)
    end
end