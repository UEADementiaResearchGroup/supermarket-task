local composer=require "composer"
local scene=composer.newScene()

local screentap=require "screentap"
local display=display
local table=table
local system=system
local media=media

setfenv(1,scene)

local videos={
  {file="practice.mp4",text={t1="Let's try that again"},feedback=true},
  {file="practice.mp4",text={t1="Practice Complete"},feedback=true},
  {file="practice.mp4",text={t1="Practice Complete"},
    feedback=true,skipIf=function()
      return composer.getVariable('lastDirectionFeedback')
    end
  },
  {
    file="S1Trial01_HQ_1.mp4",
    abortIf=function()
      return not composer.getVariable('lastDirectionFeedback')
    end,
    preText="You have completed the practice session. You will no longer receive feedback."
  },
  {file="S1Trial02_HQ.mp4"},
  {file="S1Trial03_HQ.mp4"},
  {file="S1Trial04_HQ.mp4"},
  {file="S1Trial05_HQ.mp4"},
  {file="S1Trial06_HQ.mp4"},
  {file="S1Trial07_HQ.mp4"},
  {
    file="S2Trial01_HQ.mp4",
    preText="Each video will now last a little longer, as the trolley will make a few more turns"
  },
  {file="S2Trial02_HQ.mp4"},
  {file="S2Trial03_HQ.mp4"},
  {file="S2Trial04_HQ.mp4"},
  {file="S2Trial05_HQ.mp4"},
  {file="S2Trial06_HQ.mp4"},
  {file="S2Trial07_HQ.mp4"},
}

function scene:show(event)
  if event.phase=="will" then
    return
  end

  local vid
  repeat
    vid=table.remove(videos,1)
  until not vid or not vid.skipIf or not vid.skipIf()

  if not vid or vid.abortIf and vid.abortIf() then
    composer.gotoScene("scenes.taskcomplete")
    return
  end

  display.newText({
    parent=self.view,
    text=event.params and event.params.first and "First the practice video" or (vid.preText or ""),
    x=display.contentCenterX,
    y=display.contentCenterY,
    fontSize=vid.preText and 80 or 180,
    width=display.contentWidth,
    align='center'})

  local instruction=display.newText({
    parent=self.view,
    text="Tap to play video",
    x=display.contentCenterX,
    y=display.contentCenterY+200,
    fontSize=72})

  local button=display.newRect(
    self.view,
    instruction.x,
    instruction.y,
    instruction.width+20,
    instruction.height+20)
  button:setFillColor(0.15, 0.9, 0.3)
  instruction:toFront()

  local tapListener
  tapListener=function()
    button:removeEventListener('tap',tapListener)
    local function onVideoComplete()
      composer.gotoScene('scenes.direction',{
        params={
          video=vid.file,
          postMapMessage=vid.text and vid.text.t1,
          enableFeedback=vid.feedback
        }
      })
    end

    if system.getInfo('environment')=='simulator' then
      onVideoComplete()
    else
      media.playVideo("videos/"..vid.file, false, onVideoComplete)
    end
  end

  button:addEventListener('tap',tapListener)
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




