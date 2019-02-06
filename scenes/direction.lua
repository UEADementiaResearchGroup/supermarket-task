local composer=require "composer"
local scene=composer.newScene()

local csv=require "csv"
local users=require "users"
local display=display
local native=native
local ipairs=ipairs
local pairs=pairs
local graphics=graphics
local os=os
local system=system
local math=math

setfenv(1,scene)

function scene:show(event)
  if event.phase=="will" then
    return
  end

  local time=system.getTimer()

  local group=display.newGroup()
  self.view:insert(group)
  local man=display.newImage(group,'img/man.png')
  man:translate(display.contentCenterX,display.contentCenterY)

  local t1=display.newText({
    parent=group,
    text="Which way should you turn to face the point where you started?\nTap anywhere to pick a direction",
    x=display.contentCenterX,
    y=20,
    fontSize=70,
    align='center',
    width=display.contentWidth-40
  })
  t1.anchorY=0

  local buttonLabel=display.newText({
    parent=group,
    text="Continue",
    x=display.contentCenterX,
    y=display.contentHeight-20,
    fontSize=70,
    align='center',
  })
  buttonLabel.anchorY=1

  local button=display.newRect(
    group,
    buttonLabel.x,
    buttonLabel.y-buttonLabel.height/2,
    buttonLabel.width+20,
    buttonLabel.height+20)
  button:setFillColor(0.15, 0.9, 0.3)
  buttonLabel:toFront()
  buttonLabel.isVisible=false
  button.isVisible=false

  local labels={
    {x=display.contentWidth*0.25,y=display.contentCenterY,label="Left"},
    {x=display.contentWidth*0.75,y=display.contentCenterY,label="Right"},
    {x=display.contentCenterX,y=display.contentHeight*0.25,label="Forwards"},
    {x=display.contentCenterX,y=display.contentHeight*0.75,label="Backwards"},
  }

  for i=1,#labels do
    local lab=labels[i]

    display.newText({
      parent=group,
      text=lab.label,
      x=lab.x,
      y=lab.y,
      fontSize=70,
      align='center',
    })
  end

  local bg=display.newRect(
    group,
    display.contentCenterX,
    display.contentCenterY,
    display.contentWidth,
    display.contentHeight)
  bg:setFillColor(0)
  bg:toBack()

  local tap
  local data={}
  data.video=event.params.video


  button:addEventListener("tap", function()
    bg:removeSelf()
    composer.gotoScene("scenes.map",{
      params={
        data=data
      }
    })
    return true
  end)

  local feedback=event.params.enableFeedback
  tap=function(event)
    local delay=event.time-time
    if data["direction response time"] then
      local dt=delay-data["direction response time"]
      if dt<215 then
        return
      end
    end
    local dx=event.x-display.contentCenterX
    local dy=event.y-display.contentCenterY

    if feedback then
      feedback=false
      local feedbackRect=display.newRect(
        group,
        display.contentWidth*(dx<0 and 0.25 or 0.75),
        display.contentHeight*(dy<0 and 0.25 or 0.75),
        display.contentCenterX,
        display.contentCenterY)
      feedbackRect:toBack()
      bg:toBack()
      if dx<0 and dy>0 then
        composer.setVariable('lastDirectionFeedback',true)
        t1.text="Correct"
        t1:setFillColor(0,1,0)
        feedbackRect:setFillColor(0,1,0,0.5)
      else
        composer.setVariable('lastDirectionFeedback',false)
        t1.text="Wrong"
        t1:setFillColor(1,0,0)
        feedbackRect:setFillColor(1,0,0,0.5)
      end
      -- bg:removeEventListener('tap',tap)
    end

    local angle=math.atan2(dy, dx)+math.pi/2
    local deg = math.deg(angle) % 360
    if deg < 0 then
      deg = deg + 360
    end

    man.rotation=deg
    data["egocentric direction x"]=dx * 100 / display.contentWidth
    data["egocentric direction y"]=dy * 100 / display.contentHeight
    data["egocentric angle"]=deg
    data["egocentric attempts"]=(data["egocentric attempts"] or 0) + 1
    data["egocentric response time"]=data["egocentric response time"] or delay
    data["egocentric final response time"]=delay
    local quadrant
    local sin=math.sin(angle)
    local cos=math.cos(angle)
    if cos>0 then
      if sin>0 then
        quadrant=2
      else
        quadrant=1
      end
    else
      if sin>0 then
        quadrant=3
      else
        quadrant=4
      end
    end
    data["egocentric quadrant reponse"]=quadrant
    buttonLabel.isVisible=true
    button.isVisible=true
    return true
  end
  bg:addEventListener('tap', tap)
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

