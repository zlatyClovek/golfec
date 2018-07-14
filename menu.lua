
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoGame()
    composer.gotoScene( "level1", { time=800, effect="flip" } )
end

local function gotoLevelSelect()
    composer.gotoScene( "levelSelect" )
end

local function gotoHighScores()
    composer.gotoScene( "highscores" )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view -- Main group
	-- Code here runs when the scene is first created but has not yet appeared on screen
  local background = display.newImageRect( sceneGroup, "texture/background/donut.png", 592 , 1512 )
  --local background = display.newImageRect( sceneGroup, "texture/background/background.jpg", 1080 , 1920 )
      background.x = display.contentCenterX
      background.y = display.contentCenterY

  local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, 510, native.systemFont, 44 )
  playButton:setFillColor( 0.82, 0.86, 1 )

  local levelSelectButton = display.newText( sceneGroup, "Select level", display.contentCenterX, 610, native.systemFont, 44 )
  levelSelectButton:setFillColor( 0.75, 0.78, 1 )

  local highScoresButton = display.newText( sceneGroup, "High Scores", display.contentCenterX, 710, native.systemFont, 44 )
  highScoresButton:setFillColor( 0.75, 0.78, 1 )

  playButton:addEventListener( "tap", gotoGame )
  levelSelectButton:addEventListener( "tap", gotoLevelSelect )
  highScoresButton:addEventListener( "tap", gotoHighScores )
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

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
