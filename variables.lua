--native resolution (16:9)
screenWidth = 432
screenHeight = 243

--scale the window starts as (multiplier of the native resolution)
defaultScale = 3

updatesPerFrame = 1

tileSize = 16

animStates = {
    ready = 0,
    moving = 1,
    waiting = 2,
    preconnect = 3,
    postconnect = 4
}
--controlTime = 0
moveTime = 10
preconnectTime = 10
postconnectTime = 10
waitTime = 2

blobEnlarge = 1.5