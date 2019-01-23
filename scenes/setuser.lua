local composer=require "composer"
local scene=composer.newScene()

local users=require "users"

setfenv(1,scene)

function scene:show(event)
  if event.phase=="will" then
    return
  end
  users.setup(function()
    composer.gotoScene('scenes.instructions',{
      params={
        first=true
      }
    })
  end)
end
scene:addEventListener("show")

return scene