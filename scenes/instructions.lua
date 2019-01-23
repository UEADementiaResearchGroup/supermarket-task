local composer=require "composer"
local scene=composer.newScene()

local screentap=require "screentap"
local display=display
local table=table

setfenv(1,scene)

local instructions={
  {text="In this task you will be in a virtual supermarket"},
  {text="You will be following a trolley around the supermarket. It will take left and right turns as you move up and down the different aisles of the supermarket"},
  {text="You will always start in the same place which is the entrance to the supermarket"},
  {text="As you move try to remember where the entrance is in relation to where you currently are"},
  {text="When the trolley stops moving we will ask you to indicate the direction to the entrance. That is: based on where the trolley stopped which way to the entrance?"},
  {text="The entrance could be in front or behind you, or it could also be to your left or right"},
  {text="Next you will mark on a map of the supermarket where the trolley was when you stopped moving. We will also ask you what direction the trolley was facing in the supermarket when it stopped moving"},
  {text="Let's do some practice first"},
}

function scene:show(event)
  if event.phase=="will" then
    return
  end

  local instr=table.remove(instructions,1)
  if not instr then
    composer.gotoScene('scenes.playvideo',{
      params={
        first=true
      }
    })
    return
  end
  display.newText({
    parent=self.view,
    text=instr.text,
    x=display.contentCenterX,
    y=display.contentCenterY,
    width=display.contentWidth/2,
    fontSize=40,
    align="center"
  })

  local buttonLabel=display.newText({
    parent=self.view,
    text="Tap to continue",
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

  screentap.onFullScreenTap(function()
    composer.gotoScene("scenes.instructions")
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




