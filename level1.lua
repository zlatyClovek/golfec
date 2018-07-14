
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local tiled = require "com.ponywolf.ponytiled"
local physics = require "physics"
physics.start()
physics.setGravity( 0, 0 )
local math = require "math"
local json = require "json"
-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- ----------------------------------------------------------------------------
-- Load sounds
local ballHitSound = audio.loadSound( "audio/ballHit.wav" )
local ouchSound = audio.loadSound( "audio/ouch.wav" )
audio.setVolume( 0.3, { channel=0 } )
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- Predeclare objects
local ball
local strokesText
local hole
local start -- Starting position
local map
local mapData
local background
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- Settings
local strokes = 69	 -- Amount of strokes for level
local ballSize = 7
local linDamping = 0.5
--local correctBallPosX = 63
--local correctBallPosY = -129
local correctBallPosX = 0
local correctBallPosY = 0
local velocityStopRange = 10
local maxSpeedToScore = 300
local ballScored = false
local maxPower = 500
local stroke -- Predeclare function
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- Set up display groups
local physGroup --All physical objects
local backGroup
local aimGroup
local uiGroup
-- ----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- HELP FUNCTIONS

local function gotoMenu()
    composer.gotoScene( "menu", { time=800, effect="crossFade" } )
end

-- Handles game end scenarios like no strokes left or ball scoring
local function endGame( event )
	physics.pause()
  local menuButton = display.newText( uiGroup, "Go to menu", map.designedWidth/2, 0, native.systemFont, 36 )
	menuButton:addEventListener( "tap", gotoMenu )
end

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

  -- Make sure that stroke power cant be over limit
  if range > maxPower then
    xRange = -(( maxPower/range ) * ( event.xStart - event.x ) )
    yRange = -(( maxPower/range ) * ( event.yStart - event.y ) )
  end

  print ("xrange " .. xRange .. " yrange " .. yRange)
  -- Display aiming assistant
  leadingBall = display.newCircle(aimGroup, (ball.x + correctBallPosX) - 0.5 * xRange , (ball.y + correctBallPosY) - 0.5 * yRange, 6 )
  table.insert(trailingBalls, display.newCircle(aimGroup, (ball.x) - 0.4 * xRange , (ball.y ) - 0.4 * yRange, 4 ))
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
						audio.play(ouchSound)
        end
        --When ball and hole colides
        if ( ( obj1.myName == "hole" and obj2.myName == "ball" ) or ( obj1.myName == "ball" and obj2.myName == "hole" ) ) then
          local currX, currY = ball:getLinearVelocity()
          if currX < maxSpeedToScore and currY < maxSpeedToScore and currX > -maxSpeedToScore and currY > -maxSpeedToScore then
            ballScored = true -- Set flag
						ball.isVisible = false
						endGame()
          end
        end
  end
end

-- Handles ball moving event
local function checkIfBallIsMoving( event )
	if ballScored == false then
		local currX, currY = ball:getLinearVelocity() -- Get current speed of ball
	  -- If ball moves slowly then stop movement entirely
	  if currX < velocityStopRange and currY < velocityStopRange and currX > -velocityStopRange and currY > -velocityStopRange then
	    ball.linearDamping = 50000
	    timer.performWithDelay(1, setBallLinDampingInstant)
	    -- No strokes left handle
	    if ( strokes > 0 ) then
	      backGroup:addEventListener ( "touch", stroke )
	    else
				timer.performWithDelay( 1000, endGame )
			end
	  else
	    local xBallTime = ball.x
	    local yBallTime = ball.y
	    local tm = timer.performWithDelay(50, checkIfBallIsMoving) -- check if ball is not moving and add stroke listener
	  end
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
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	physics.pause()  -- Temporarily pause the physics engine

	physGroup = display.newGroup()
	sceneGroup:insert( physGroup )
	backGroup = display.newGroup()
	sceneGroup:insert( backGroup )
	aimGroup = display.newGroup()
	physGroup:insert( aimGroup )
	uiGroup = display.newGroup()
	physGroup:insert( uiGroup )
	uiGroup:toFront()


	--Load background
	background = display.newImageRect( backGroup, "texture/background/background.jpg", 1080 , 1920 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	--Load map
	mapData = json.decodeFile(system.pathForFile("mapa2.json", system.ResourceDirectory))  -- load from json export
	map = tiled.new(mapData)
	map.isVisible = false
	--Get Starting posititon
	start = map:findObject( "start" )
	--Display map on screen
	map.x,map.y = display.contentCenterX - map.designedWidth/2, display.contentCenterY - map.designedHeight/2
	map:insert(physGroup) -- All physical object must be in the same group

	-- Display lives and score
	strokesText = display.newText( uiGroup, "Strokes: " .. strokes, map.designedWidth/2, 100, native.systemFont, 36 )

	--Get array of wall objects in the map
	local walls_vert = map:listTypes( "wall_vert" )
	--Set wall properties
	for i = #walls_vert, 1, -1 do
	  physics.addBody(walls_vert[i], "static")
	  walls_vert[i].myName = "wall"
	  walls_vert[i].isSleepingAllowed = false
	end

	-- Add hole
	hole = map:findObject("hole")
	hole.myName = "hole"

	--Add ball
	ball = display.newCircle( physGroup, start.x, start.y, ballSize )

	--Add ball to physics and set properties
	physics.addBody( ball, "dynamic", { radius=ballSize, isSleepingAllowed = false, isSensor=false, bounce=0.7, density = 0.9 , isBullet = true } )
	ball.myName = "ball"
	ball.linearDamping = linDamping

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		map.isVisible = true
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
		backGroup:addEventListener ( "touch", stroke ) -- Set listener for ball stroke
		Runtime:addEventListener( "collision", onCollision )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase


	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		backGroup:removeEventListener ( "touch", stroke )
		Runtime:removeEventListener( "collision", onCollision )
		physics:pause()
		display.remove(map)
		composer.removeScene( "level1" )

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
