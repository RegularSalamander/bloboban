--native resolution (16:9)
screenWidth = 432
screenHeight = 243

--scale the window starts as (multiplier of the native resolution)
defaultScale = 3

updatesPerFrame = 1

tileSize = 16

colors = {
    background = {220/255, 220/255, 220/255},
    checkerLight = {159/255, 209/255, 234/255},
    checkerDark = {94/255, 144/255, 168/255},
    particle = {220/255, 220/255, 220/255}
}

animStates = {
    ready = 0,
    moving = 1,
    waiting = 2,
    affect = 3,
    connect = 4,
    fill = 5
}
--controlTime = 0
moveTime = 10
affectTime = 10
connectTime = 10
fillTime = 5
waitTime = 2

blobEnlarge = 1.5