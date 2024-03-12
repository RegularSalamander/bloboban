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
        objects.blobs[i]:applyChanges()
    end
end

function addLevelObjects(num)
    if num == 0 then
        objects.player = { player:new(9, 5) }
        objects.blobs = { blob:new(7, 9, 0, 0), blob:new(9, 9, 0, 0), blob:new(11, 9, 0, 0) }
        objects.holes = { hole:new(20, 6, 8), hole:new(20, 7, 9), hole:new(20, 8, 1) }
        objects.affectors = {}
        -- fillWallRect()
        fillWallRect(5, 2, 1, 11)
        fillWallRect(6, 12, 8, 1)
        fillWallRect(13, 10, 1, 2)
        fillWallRect(13, 9, 9, 1)
        fillWallRect(21, 5, 1, 4)
        fillWallRect(16, 5, 5, 1)
        fillWallRect(13, 6, 4, 1)
        fillWallRect(13, 2, 1, 4)
        fillWallRect(6, 2, 7, 1)
    elseif num == 1 then
        objects.player = { player:new(9, 5) }
        objects.blobs = { blob:new(7, 9, 0, 0), blob:new(9, 9, 0, 0), blob:new(11, 9, 0, 0) }
        objects.holes = { hole:new(20, 6, 8), hole:new(20, 7, 9), hole:new(20, 8, 1) }
        objects.affectors = { colorChanger:new(10, 6, 1) }
        -- fillWallRect()
        fillWallRect(0, 0, 6, 15)
        fillWallRect(6, 0, 7, 3)
        fillWallRect(13, 0, 4, 7)
        fillWallRect(17, 0, 4, 6)
        fillWallRect(6, 12, 7, 3)
        fillWallRect(13, 9, 8, 6)
        fillWallRect(21, 0, 6, 15)
        fillWallRect(6, 3, 1, 9)
    end
end