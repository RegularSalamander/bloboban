function saveProgress()
    handle = love.filesystem.newFile("save" , "w")

    str = string.char(currentLevel)

    for i = 1, #levelMap do
        if levelMap[i].complete then
            str = str .. string.char(i)
        end
    end
    
    handle:write(str)
end

function loadSave()
    handle, err = love.filesystem.newFile("save" , "r")
    if err then return
    else
        local line = handle:read()
        currentLevel = string.byte(util.charAt(line, 1))

        for i = 2, #line do
            local idx = string.byte(util.charAt(line, i))
            io.write(idx)

            levelMap[idx].complete = true
        end
    end
end

function resetSave()
    currentLevel = 1
    for i = 1, #levelMap do
        levelMap[i].complete = false
    end
    saveProgress()
end