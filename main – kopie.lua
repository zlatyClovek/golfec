-----------------------------------------------------------------------------------------
--
-- main.lua
--
-- All walles are called "wall"
-- ball = "ball"
-----------------------------------------------------------------------------------------

local tiled = require "com.ponywolf.ponytiled"
local physics = require "physics"
local math = require "math"
--physics.setDrawMode("hybrid")
local ballHitSound = audio.loadSound( "audio/ballHit.mp3" )
physics.start()
physics.setGravity( 0, 0 )

local json = require "json"
-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )
local strokes = 5 -- Amount of strokes for level
local ballSize = 7
local linDamping = 0.5
local correctBallPosX = 63
local correctBallPosY = -129
local velocityStopRange = 10
local maxSpeedToScore = 400
local ballScored = false
local stroke -- Predeclare function

local physicsData = (require "holeTest").physicsData(1.0)

-- Set up display groups
local physGroup = display.newGroup() --All physical objects
local backGroup = display.newGroup()
local aimGroup = display.newGroup()
local uiGroup = display.newGroup()


--Load background
local background = display.newImageRect( backGroup, "texture/background/background.jpg", 1080 , 1920 )
background.x = display.contentCenterX
background.y = display.contentCenterY

--Load map
local mapData = json.decodeFile(system.pathForFile("mapa2.json", system.ResourceDirectory))  -- load from json export
local map = tiled.new(mapData)
--Get Starting posititon
local start = map:findObject( "start" )
--Load mapa2
map.x,map.y = display.contentCenterX - map.designedWidth/2, display.contentCenterY - map.designedHeight/2
map:insert(physGroup)

--Get array of wall objects
local walls_vert = map:listTypes( "wall_vert" )

--Set wall properties
for i = #walls_vert, 1, -1 do
  physics.addBody(walls_vert[i], "static")
  walls_vert[i].myName = "wall"
  walls_vert[i].isSleepingAllowed = false
end

-- Add hole
local hole = map:findObject("hole")
hole.myName = "hole"


-- Display lives and score
local strokesText = display.newText( uiGroup, "Strokes: " .. strokes, display.contentCenterX, -80, native.systemFont, 36 )

--Add ball
local ball = display.newCircle( physGroup, start.x, start.y, ballSize )
physGroup:toFront()
aimGroup:toFront()
--Add ball to physics
physics.addBody( ball, "dynamic", { radius=ballSize, isSensor=false, bounce=0.7, density = 0.9 , isBullet = true } )
ball.myName = "ball"
ball.linearDamping = linDamping
ball.isSleepingAllowed = false

-- Get distance of an object and ball
local function getObjBallDistance(objA, objB)
    -- Get the length for each of the components x and y
    local ballX = objB.x + correctBallPosX
    local ballY = objB.y + correctBallPosY
    local xDist = ballX - objA.x
    local yDist = ballY - objA.y
    return math.sqrt( (xDist ^ 2) + (yDist ^ 2) )
end
-- Get distance of event current position compared to event starting pos
function getDistance( event )
    local xDist = event.x - event.xStart
    local yDist = event.y - event.yStart
    return math.sqrt( (xDist ^ 2) + (yDist ^ 2) )
end

-- Updates strokes left
local function updateText()
    strokesText.text = "Strokes: " .. strokes
end
--Sets ball linear damping
local function setBallLinDamping(ballObj, value, time)
  transition.to( ballObj, { linearDamping = value, time = time } )
end

local trailingBalls = {}
local leadingBall
local function updateAim( event )
  --Remove old trailingBalls from an array
  for i = #trailingBalls, 1, -1 do
    display.remove(trailingBalls[i])
  end
  trailingBalls = {}


  display.remove( leadingBall ) -- Remove leading ball
  local range = getDistance(event) --Range between finger and ball
  print("range " .. range)
  -- Show leading ball
  local xRange = event.x - event.xStart --x Range between finger start and current finger position
  local yRange = event.y - event.yStart --y Range between finger start and current finger position
--[[
if xRange > 500 then
  xRange = 500
elseif xRange < -500 then
   xRange = -500
 end
 if yRange > 500 then
   yRange = 500
 elseif yRange < -500 then
   yRange = -500
 end
--]]
  print ("xrange " .. xRange .. " yrange " .. yRange)
  -- Display aiming assistant
  leadingBall = display.newCircle(aimGroup, (ball.x + correctBallPosX) - 0.5 * xRange , (ball.y + correctBallPosY) - 0.5 * yRange, 6 )
  table.insert(trailingBalls, display.newCircle(aimGroup, (ball.x + correctBallPosX) - 0.4 * xRange , (ball.y + correctBallPosY) - 0.4 * yRange, 4 ))
  table.insert(trailingBalls, display.newCircle(aimGroup, (ball.x + correctBallPosX) - 0.3 * xRange , (ball.y + correctBallPosY) - 0.3 * yRange, 4 ))
  table.insert(trailingBalls, display.newCircle(aimGroup, (ball.x + correctBallPosX) - 0.2 * xRange , (ball.y + correctBallPosY) - 0.2 * yRange, 4 ))
  table.insert(trailingBalls, display.newCircle(aimGroup, (ball.x + correctBallPosX) - 0.1 * xRange , (ball.y + correctBallPosY) - 0.1 * yRange, 4 ))

  trailingBalls[1]:setFillColor(1,0,0)
end

-- Reset default lin damping on ball instantly
local function setBallLinDampingInstant()
  ball.linearDamping = linDamping
end

-- Collision handling
local function onCollision( event )
  if ( event.phase == "began" ) then
    local obj1 = event.object1
    local obj2 = event.object2
        if ( ( obj1.myName == "wall" and obj2.myName == "ball" ) or ( obj1.myName == "ball" and obj2.myName == "wall" ) ) then

        end
        --When ball and hole colides
        if ( ( obj1.myName == "hole" and obj2.myName == "ball" ) or ( obj1.myName == "ball" and obj2.myName == "hole" ) ) then
          local currX, currY = ball:getLinearVelocity()
          if currX < maxSpeedToScore and currY < maxSpeedToScore and currX > -maxSpeedToScore and currY > -maxSpeedToScore then
            ballScored = true -- Set flag
            ball.isVisible = false
          end
        end
  end
end
Runtime:addEventListener( "collision", onCollision )

-- Handles game end scenarios like no strokes left or ball scoring
local function endGame( event )
  backGroup:addEventListener ( "touch", stroke )
end

-- Handles ball moving event
local function checkIfBallIsMoving( event )
  local currX, currY = ball:getLinearVelocity() -- Get current speed of ball
  -- If ball moves slowly then stop movement entirely
  if currX < velocityStopRange and currY < velocityStopRange and currX > -velocityStopRange and currY > -velocityStopRange then
    ball.linearDamping = 50000
    timer.performWithDelay(1, setBallLinDampingInstant)
    -- No strokes left handle
    if ( strokes > 0 ) then
      endGame()
    end
  else
    local xBallTime = ball.x
    local yBallTime = ball.y
    local tm = timer.performWithDelay(50, checkIfBallIsMoving) -- check if ball is not moving and add stroke listener
  end
end


--Function that moves ball depending on touch start and release
local endX
local endY
local finX
local finY
local eventStartTime
function stroke(event)
  if ( event.phase == "began" ) then
    ball.linearDamping = linDamping
    eventStartTime = event.time/1000

  elseif event.phase == "moved" then
    -- Update aim helper
    if event.time/1000 - eventStartTime > 0.01 then
      eventStartTime = event.time/1000
      updateAim(event, event.xStart, event.yStart)
    end

	elseif event.phase == "ended" then
    audio.play(ballHitSound)
    backGroup:removeEventListener ( "touch", stroke ) -- Cant shoot while moving

    endX = event.x
    endY = event.y
    finX = event.xStart - endX
    finY = event.yStart - endY
    ball:applyForce( finX * 1.3, finY * 1.3 , ball.x, ball.y ) -- Push ball

    local tm = timer.performWithDelay(100, checkIfBallIsMoving) -- check if ball is not moving and add stroke listener

    -- Substract strokes only when ball moved
    if event.xStart ~= endX or event.yStart ~= endY then
      strokes = strokes - 1
      updateText()
    end
    -- Remove aim helper
    for i = #trailingBalls, 1, -1 do
      display.remove(trailingBalls[i])
    end
    display.remove( leadingBall )

	end
  transition.to( ball, { linearDamping = 2.0, time = 4000 } ) -- Slow down ball velocity
end
backGroup:addEventListener ( "touch", stroke ) -- Set listener for ball stroke




--awakeTimer = timer.performWithDelay(1500, checkIfBallIsMoving, 0)


--[[
local function neco( event )
print(event.source.a)
end

local pepa = timer.performWithDelay(1000, neco)
pepa.a = 10
--]]

-- Prevent Ball from being hit when moving
  --gameBg:removeEventListener('touch', shoot)

  --transition.to(ball, {x = start.x, y = 10, time = 10000, })
