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
local timer = timer

setfenv(1,scene)

function scene:show(event)
  if event.phase=="will" then
    return
  end

  local time=system.getTimer()

  local group=display.newGroup()
  self.view:insert(group)


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

  local height = button.contentBounds.yMin - t1.contentBounds.yMax

  local man=display.newImage(group,'img/man.png')
  man:translate(display.contentCenterX, (t1.contentBounds.yMax + button.contentBounds.yMin)/2)

  local r = height * 5/6 / 2
  local dots = 100
  for i = 1, dots do
    local t = i/dots * math.pi * 2
    local x = math.cos(t) * r + display.contentCenterX
    local y = math.sin(t) * r + man.y
    display.newCircle(group, x, y, 10)
  end

  local labels={
    {
      x=display.contentCenterX - r - 20,
      y=man.y,
      align = "right",
      anchorX = 1,
      label="Left"
    },
    {
      x=display.contentCenterX + r + 20,
      y=man.y,
      align = "left",
      anchorX = 0,
      label="Right"
    },
    {
      x=display.contentCenterX,
      y=man.y - r - 20,
      align = "center",
      anchorY = 1,
      label="Forwards"
    },
    {
      x=display.contentCenterX,
      y=man.y + r + 20,
      align = "center",
      anchorY = 0,
      label="Backwards"
    },
  }

  for i=1,#labels do
    local lab=labels[i]

    local text = display.newText({
      parent=group,
      text=lab.label,
      x=lab.x,
      y=lab.y,
      fontSize=50,
      align=lab.align,
    })
    text.anchorX = lab.anchorX or 0.5
    text.anchorY = lab.anchorY or 0.5
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

  local feedback=event.params.enableFeedback
  local deg, angle, dx, dy

  local bgTap = function(event)
    dx=event.x-display.contentCenterX
    dy=event.y-man.y

    angle=math.atan2(dy, dx)+math.pi/2
    deg = math.deg(angle) % 360
    if deg < 0 then
      deg = deg + 360
    end

    man.rotation=deg
    buttonLabel.isVisible=true
    button.isVisible=true

  end
  bg:addEventListener('tap', bgTap)

  tap=function(event)
    bg:removeEventListener('tap', bgTap)
    button:removeEventListener('tap', tap)

    local delay=event.time-time
    if data["direction response time"] then
      local dt=delay-data["direction response time"]
      if dt<215 then
        return
      end
    end

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

    if feedback then
      feedback=false
      button.isVisible = false
      buttonLabel.isVisible = false
      timer.performWithDelay(1000, function()
        button.isVisible =true
        buttonLabel.isVisible =true
      end)
      local feedbackRect=display.newRect(
        group,
        display.contentWidth*(dx<0 and 0.25 or 0.75),
        display.contentHeight*(dy<0 and 0.25 or 0.75),
        display.contentCenterX,
        display.contentCenterY)
      feedbackRect:toBack()
      t1.x = feedbackRect.x
      t1.y = feedbackRect.y
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
        local correctRect=display.newRect(
          group,
          display.contentWidth*(0.25),
          display.contentHeight*(0.75),
          display.contentCenterX,
          display.contentCenterY)
        correctRect:setFillColor(1, 1, 0, 0.5)
        correctRect:toBack()

        display.newText({
          parent=group,
          text="The correct direction",
          x=correctRect.x,
          y=correctRect.y,
          fontSize=70,
          align='center',
          width=display.contentWidth-40
        }):setFillColor(1,1,0)
      end
      -- bg:removeEventListener('tap',tap)
      button:addEventListener("tap", function()
        bg:removeSelf()
        composer.gotoScene("scenes.map",{
          params={
            data=data
          }
        })
        return true
      end)
    else
      bg:removeSelf()
      composer.gotoScene("scenes.map",{
        params={
          data=data
        }
      })
    end
    bg:toBack()

    return true
  end
  button:addEventListener("tap", tap)
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

