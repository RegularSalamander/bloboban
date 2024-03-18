function disolveTransition_load()
    tuples = {}
    for i = 0, disolveGrid-1 do
        for j = 0, disolveGrid-1 do
            table.insert(tuples, {i, j})
        end
    end

    overlayCanvas = nil
end

function disolveTransition_update()
    for i = 1, disolvesPerFrame do
        local i = math.ceil(#tuples*love.math.random())
        table.remove(tuples, i)
    end

    if #tuples == 0 then
        gameState = nextGameState
    end
end

function disolveTransition_draw()
    if not overlayCanvas then
        if _G[oldGameState .. "_draw"] then
            _G[oldGameState .. "_draw"]()
        end

        love.graphics.setCanvas()
        pic = love.graphics.newImage(gameCanvas:newImageData())
        overlayCanvas = love.graphics.newCanvas(screenWidth, screenHeight)

        if _G[nextGameState .. "_load"] then
            _G[nextGameState .. "_load"]()
        end
    end

    love.graphics.setCanvas(overlayCanvas)
    love.graphics.clear(0, 0, 0, 0)

    love.graphics.setCanvas({overlayCanvas, stencil = true})
    love.graphics.stencil(stencilFunc, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(pic)
    love.graphics.setStencilTest()

    love.graphics.setCanvas(gameCanvas)
    if _G[nextGameState .. "_draw"] then
        _G[nextGameState .. "_draw"]()
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(overlayCanvas)
end

function stencilFunc()
    love.graphics.setColor(1, 1, 1, 1)
    for x = 0, screenWidth, disolveGrid*disolveSize do
        for y = 0, screenHeight, disolveGrid*disolveSize do
            for i = 1, #tuples do
                love.graphics.rectangle("fill", tuples[i][1]*disolveSize+x, tuples[i][2]*disolveSize+y, disolveSize, disolveSize)
            end
        end
    end
end