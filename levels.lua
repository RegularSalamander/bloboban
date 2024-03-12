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

    addLevelObjects(num)

    for i = 1, #objects.walls do
        objects.walls[i]:setOutlines()
    end
    for i = 1, #objects.blobs do
        objects.blobs[i]:applyConnect()
    end
end

function addLevelObjects(num)
    if num == 0 then
        objects.player = { player:new(10, 6) }
        objects.blobs = { blob:new(8, 8, 0), blob:new(10, 8, 0), blob:new(12, 8, 0) }
        objects.holes = { hole:new(19, 5, 8), hole:new(19, 6, 9), hole:new(19, 7, 1) }
        fillWallRect(6, 4, 15, 1)
        fillWallRect(6, 5, 1, 4)
        fillWallRect(7, 8, 1, 3)
        fillWallRect(8, 10, 6, 1)
        fillWallRect(13, 7, 1, 3)
        fillWallRect(14, 7, 2, 1)
        fillWallRect(15, 8, 6, 1)
        fillWallRect(20, 5, 1, 3)
        
        addFloorRect(7, 5, 6, 5)
        addFloorRect(13, 5, 7, 3)
    elseif num == 1 then
        objects.player = { player:new(9, 6) }
        objects.blobs = { blob:new(8, 8, 0), blob:new(10, 8, 0), blob:new(12, 8, 0) }
        objects.holes = { hole:new(19, 5, 8), hole:new(19, 6, 9), hole:new(19, 7, 1) }
        objects.affectors = { colorChanger:new(11, 6, 1) }
        fillWallRect(7, 4, 14, 1)
        fillWallRect(7, 5, 1, 6)
        fillWallRect(8, 10, 7, 1)
        fillWallRect(14, 7, 1, 3)
        fillWallRect(15, 7, 1, 2)
        fillWallRect(16, 8, 5, 1)
        fillWallRect(20, 5, 1, 3)
        
        addFloorRect(8, 5, 6, 5)
        addFloorRect(14, 5, 6, 3)
    elseif num == 2 then
        objects.player = { player:new(7, 7) }
        objects.blobs = {
            blob:new(8, 7, 0), blob:new(19, 6, 0),
            blob:new(12, 5, 1),
            blob:new(13, 6, 1), blob:new(15, 6, 1),
            blob:new(12, 7, 1), blob:new(14, 7, 1),
            blob:new(13, 8, 1), blob:new(15, 8, 1),
            blob:new(14, 9, 1)
        }
        objects.holes = { hole:new(19, 6, 8), hole:new(19, 7, 1) }

        fillWallRect(6, 4, 15, 1)
        fillWallRect(6, 5, 1, 6)
        fillWallRect(7, 10, 14, 1)
        -- fillWallRect(11, 5, 1, 1)
        -- fillWallRect(13, 5, 1, 1)
        fillWallRect(13, 9, 1, 1)
        fillWallRect(15, 9, 1, 1)
        fillWallRect(18, 5, 1, 2)
        fillWallRect(19, 5, 2, 1)
        fillWallRect(20, 6, 1, 4)
        fillWallRect(19, 8, 1, 2)

        addFloorRect(7, 5, 13, 5)
    end
end