--native resolution (16:9)
screenWidth = 27*16
screenHeight = 27*9

debugMode = false

--scale the window starts as (multiplier of the native resolution)
defaultScale = 2
fullscreen = false
keepInteger = false

tileSize = 16
mapTileSize = 16

disolveGrid = 32
disolveSize = 4
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
    sparkle = {231/255, 231/255, 0/255},
    outline = {33/255, 33/255, 66/255}
}

animStates = {
    open = 0,
    ready = 1,
    moving = 2,
    waiting = 3,
    affect = 4,
    connect = 5,
    fill = 6,
    victory = 7
}
animLengths = {
    openTime = 180,
    moveTime = 10,
    affectTime = 10,
    connectTime = 10,
    fillTime = 5,
    waitTime = 2,
    victoryTime = 180
}

quitTime = 60
restartTime = 180

particleTypes = {
    circle = 0,
    sparkle = 1
}

blobEnlarge = 1.5
mapPlayerSpeed = 0.1
mapScrollSpeed = 4