--native resolution (16:9)
screenWidth = 432
screenHeight = 243

--scale the window starts as (multiplier of the native resolution)
defaultScale = 3

updatesPerFrame = 1

tileSize = 16
mapTileSize = 16

disolveGrid = 32
disolveSize = 1
disolvesPerFrame = 40

colors = {
    checkerLight = {
        {234/255, 225/255, 159/255},
        {159/255, 209/255, 234/255},
        {205/255, 182/255, 237/255}
    },
    checkerDark = {
        {168/255, 159/255, 94/255},
        {94/255, 144/255, 168/255},
        {184/255, 111/255, 233/255}
    },
    particle = {231/255, 231/255, 231/255},
    outline = {33/255, 33/255, 66/255}
}

animStates = {
    ready = 0,
    moving = 1,
    waiting = 2,
    affect = 3,
    connect = 4,
    fill = 5,
    victory = 6
}
--controlTime = 0
moveTime = 10
affectTime = 10
connectTime = 10
fillTime = 5
waitTime = 2
victoryTime = 180

blobEnlarge = 1.5