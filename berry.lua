-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

--local tiled = require "com.ponywolf.ponytiled"
--local dusk = require("Dusk.Dusk")
local physics = require "physics"
physics.setDrawMode("hybrid")
local json = require "json"
physics.start()
physics.setGravity( 0, 0 )

berry = require( 'pl.ldurniat.berry' )
local map = berry.loadMap( "map.json", "" )
local visual = berry.createVisual( map )
berry.buildPhysical( map )
berry:enableDebugMode()


-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )
local ballSize = 12



local background = display.newImageRect( "texture/background/background.jpg", 1080 , 1920 )
background.x = display.contentCenterX
background.y = display.contentCenterY

--Add ball
local ball = display.newCircle(display.contentCenterX, display.contentCenterY, ballSize )
--ballGroup:toFront()

--Add ball to physics
physics.addBody( ball, "dynamic", { radius=ballSize, isSensor=false, bounce=0.6, density = 10 } )
ball.myName = "ball"
ball.linearDamping = 1
--Add walls to physics
--[[
local offsetRectParams
for i = #walls_vert, 1, -1 do
  offsetRectParams = { halfWidth = walls_vert[i].width * 0.5, halfHeight=walls_vert[i].height * 0.5}
  physics.addBody( walls_vert[i], "static", { box=offsetRectParams } )
  --walls_vert[i].x = display.contentCenterX - walls_vert[i].x
   walls_vert[i].myName = "wallV" .. i
end



for i = #walls_hor, 1, -1 do
  offsetRectParams = { halfWidth=32, halfHeight=3, x=walls_vert[i].x, y=walls_hor[i].y }
  physics.addBody( walls_hor[i], "static", { box=offsetRectParams } )
  walls_hor[i].myName = "wallH" .. i
end
--]]

--Function that moves ball depending on touch start and release
local begX
local begY
local endX
local endY
local finX
local finY
local function stroke(event)
  if ( event.phase == "began" ) then
    print( "Touch event began on: " .. event.x .. " " .. event.y )
    begX = event.x
    begY = event.y

  elseif event.phase == "moved" then
    --print( "Touch event moved on: " .. event.x .. " " .. event.y )
	elseif event.phase == "ended" then
    endX = event.x
    endY = event.y
    finX = begX - endX
    finY = begY - endY
    ball:applyLinearImpulse( finX * 0.5, finY * 0.5, ball.x, ball.y )
		print( "Touch event ended on: " .. event.x .. " " .. event.y )
	end
  --transition.to( ball, { linearDamping = 0.7, time = 250 } )
end
background:addEventListener( "touch", stroke )
background:toBack()
