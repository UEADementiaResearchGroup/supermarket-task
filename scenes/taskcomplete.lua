local composer=require "composer"
local scene=composer.newScene()

local screentap=require "screentap"
local zipfiles=require "zipfiles"
local email=require "email"
local users=require "users"
local lfs=require "lfs"
local display=display
local native=native
local print=print

setfenv(1,scene)

function scene:show(event)
  if event.phase=="will" then
    return
  end

  display.newText({
    parent=self.view,
    text="Thank you for participating in this study!",
    x=display.contentCenterX,
    y=display.contentCenterY,
    width=display.contentWidth/2,
    fontSize=40,
    align="center"
  })

  local buttonLabel=display.newText({
    parent=self.view,
    text="Test New Participant",
    x=display.contentCenterX,
    y=display.contentCenterY+200,
    fontSize=40})

  local button=display.newRect(
    self.view,
    buttonLabel.x,
    buttonLabel.y,
    buttonLabel.width+20,
    buttonLabel.height+20)
  button:setFillColor(0.15, 0.9, 0.3)
  buttonLabel:toFront()

  if native.canShowPopup("mail") then
    buttonLabel.text="Send Data"
  end

  screentap.onFullScreenTap(function()
    if not native.canShowPopup("mail") then
      composer.removeScene("scenes.playvideo")
      composer.removeScene("scenes.instructions")
      composer.gotoScene("scenes.setuser")
      return
    end
    local id=users.getID()
    local path=users.getDirectory(id)

    local files={}
    for file in lfs.dir(path) do
      if file:find('.csv') then
        files[#files+1]='users/'..users.createFileName(id)..'/'..file
      end
    end

    native.setActivityIndicator(true)
    local zipFileName
    zipFileName=zipfiles.zipData(id,files,function()
      native.setActivityIndicator(false)
      email.send(id,zipFileName)
      buttonLabel.text="Test New Participant"

      screentap.onFullScreenTap(function()
        composer.removeScene("scenes.playvideo")
        composer.removeScene("scenes.instructions")
        composer.gotoScene("scenes.setuser")
      end)
    end)
  end)
end
scene:addEventListener("show")


function scene:hide(event)
  if event.phase=="will" then
    return
  end

  for i=self.view.numChildren,1,-1 do
    self.view[i]:removeSelf()
  end
end
scene:addEventListener("hide")


return scene




