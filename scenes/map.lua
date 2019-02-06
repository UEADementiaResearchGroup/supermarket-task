local composer=require "composer"
local scene=composer.newScene()

local csv=require "csv"
local users=require "users"
local jsonreader=require "util.jsonreader"
local display=display
local native=native
local ipairs=ipairs
local pairs=pairs
local graphics=graphics
local os=os
local system=system
local print=print

setfenv(1,scene)

local mapMask = graphics.newMask( "img/mapnew_mask.png" )

function scene:show(event)
  if event.phase=="will" then
    return
  end

  local id=users.getID()
  local path=users.getDirectory(id)..("/supermarket_%s.csv"):format(id)
  local writeLine=csv.create(path,{
    "Participant ID",
    "date",
    "video",
    "map width",
    "map height",
    "map location x",
    "map location y",
    "map location correct x",
    "map location correct y",
    "map selection attempts",
    "heading direction",
    "heading direction attempts",
    "heading direction correct direction",
    "map selection response time",
    "map selection final response time",
    "heading direction response time",
    "heading direction final response time",
    "egocentric direction x",
    "egocentric direction y",
    "egocentric angle",
    "egocentric attempts",
    "egocentric response time",
    "egocentric final response time",
    "egocentric correct quadrant",
    "egocentric quadrant reponse"
  })

  local data={
    ["Participant ID"]=id,
    date=os.date('%c'),
  }

  for k,v in pairs(event.params.data) do
    data[k]=v
  end

  local directions=jsonreader.load(system.pathForFile('data/correctdirections.json'))
  data["egocentric correct quadrant"]=directions[data.video].quadrant
  data["heading direction correct direction"]=directions[data.video].direction

  local time=system.getTimer()

  local group=display.newGroup()
  self.view:insert(group)
  local map=display.newImage(group,'img/mapnew.png')
  map:setMask(mapMask)
  map:translate(display.contentCenterX,display.contentCenterY)

  local t1=display.newText({
    parent=group,
    text="Touch the map of the supermarket to show where you finished.\nThe circle shows where you started",
    x=display.contentCenterX,
    y=20,
    fontSize=70,
    align='center',
    width=display.contentWidth-40
  })
  t1.anchorY=0

  local scale=(display.contentHeight-t1.contentBounds.yMax-160)/map.contentHeight
  map:scale(scale,scale)

  local positions=jsonreader.load(system.pathForFile('data/correctpositions.json'))

  local points=display.newGroup()
  local pos=positions[data.video]
  local correctSpot=display.newCircle(points,pos.x*scale, pos.y*scale, 40)
  correctSpot:setFillColor(1,0,0)
  group:insert(points)
  points:translate(map.x-map.contentWidth/2, map.y-map.contentHeight/2)

  correctSpot.isVisible=false
  correctSpot.isHitTestable=true

  -- local count=0
  -- for k,v in pairs(positions) do
  --   local correctSpot=display.newCircle(points,v.x*scale, v.y*scale, 40)
  --   correctSpot:setFillColor(1,0,0)
  --   group:insert(points)
  --   display.newText(points,k,correctSpot.x,correctSpot.y):setFillColor(0,count,1-count*0.3)
  --   count=count+0.1
  -- end

  -- correctSpot:addEventListener("tap", function()
  --   correctSpot.tapped=true
  --   correctSpot.isVisible=true
  -- end)

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

  local badTouchSensor=display.newRect(
    group,
    map.x,
    map.y,
    map.contentWidth,
    map.contentHeight)
  badTouchSensor:setFillColor(0.2)
  badTouchSensor:toBack()
  local badTap=function()
    native.showAlert("Try again", "The grey areas and walls and shelves",{'Ok'})
  end
  local loc
  local tap
  local textBg

  button:addEventListener("tap", function()
    t1.text="Now tap the arrow which indicates the direction you were facing."
    t1.y=loc.y+180+20+loc.height+140
    t1.anchorY=0
    if t1.contentBounds.yMax>display.contentHeight then
      t1.y=loc.y-180-20-loc.height-140
      t1.anchorY=1
    end

    display.remove(textBg)
    textBg=display.newRect(group,
      t1.x,
      t1.y-t1.height*(t1.anchorY-0.5),
      t1.width+20,
      t1.height+20)
    textBg:setFillColor(0, 0.8)
    t1:toFront()

    map:removeEventListener('tap', tap)
    button.isVisible=false
    buttonLabel.isVisible=false
    badTouchSensor:removeEventListener('tap',badTap)

    time=system.getTimer()

    local cardinalButtons={
      {compass="W",x=loc.x-loc.width-140,y=loc.y,dir=270},
      {compass="N",x=loc.x,y=loc.y-loc.height-140,dir=0},
      {compass="E",x=loc.x+loc.width+140,y=loc.y,dir=90},
      {compass="S",x=loc.x,y=loc.y+loc.height+140,dir=180},
    }

    for _,v in ipairs(cardinalButtons) do
      local arrowButtonLabel=display.newImage(group,'img/arrow.png')
      arrowButtonLabel.rotation=v.dir
      arrowButtonLabel:translate(v.x, v.y)

      local arrowButton=display.newRect(
        group,
        arrowButtonLabel.x,
        arrowButtonLabel.y,
        180,
        180)
      arrowButton:setFillColor(0.15, 0.9, 0.3)
      arrowButtonLabel:toFront()
      arrowButtonLabel:scale(2,2)

      local direction=v.compass
      arrowButton:addEventListener('tap', function()
        for i=1,group.numChildren do
          group[i].isVisible=false
        end

        data["heading direction"]=direction
        data["heading direction response time"]=data["heading direction response time"] or (system.getTimer()-time)
        data["heading direction final response time"]=system.getTimer()-time
        data["heading direction attempts"]=(data["heading direction attempts"] or 0) +1

        t1.isVisible=true
        t1.text=event.params.postMapMessage or "Press Continue to proceed"
        t1.y=display.contentCenterX
        t1.anchorY=1
        button.isVisible=true
        buttonLabel.isVisible=true
        button:addEventListener("tap", function()
          group:removeSelf()
          writeLine(data)
          composer.gotoScene('scenes.playvideo')
        end)
      return true
      end)
    end

    return true
  end)

  badTouchSensor:addEventListener("tap",badTap)

  local touchAreaBounds={
    x=68,
    y=67,
    width=1355,
    height=903
  }

  for k,v in pairs(touchAreaBounds) do
    touchAreaBounds[k]=v*scale
  end

  tap=function(event)
    local x,y=event.x-map.contentBounds.xMin,event.y-map.contentBounds.yMin
    if x-touchAreaBounds.x<0 or y-touchAreaBounds.y<0 then
      return false
    end

    if x-touchAreaBounds.x>touchAreaBounds.width or y-touchAreaBounds.y>touchAreaBounds.height then
      return false
    end

    correctSpot.isVisible=false
    display.remove(loc)
    loc=display.newCircle(group,event.x,event.y, 25)
    loc:setFillColor(0.3, 0.5, 0.9)

    data["map width"]=map.contentWidth
    data["map height"]=map.contentHeight
    data["map selection response time"]=data["map selection response time"] or (system.getTimer()-time)
    data["map selection final response time"]=system.getTimer()-time
    data["map location x"]=event.x-map.x
    data["map location y"]=event.y-map.y
    data["map selection attempts"]=(data["map selection attempts"] or 0) +1
    data["map location correct x"],data["map location correct y"]=correctSpot:localToContent(0, 0)
    data["map location correct x"]=data["map location correct x"]-map.x
    data["map location correct y"]=data["map location correct y"]-map.y
    buttonLabel.isVisible=true
    button.isVisible=true
    return true
  end
  map:addEventListener('tap', tap)
end
scene:addEventListener("show")


function scene:hide(event)
  if event.phase=="will" then
    return
  end
end
scene:addEventListener("hide")


return scene

