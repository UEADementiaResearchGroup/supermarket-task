local videos={
  {file="practice.mp4",text={t1="Practice Complete",t2="Tap to start"}},
  {file="S1Trial01_HQ_1.mp4"},
  {file="S1Trial02_HQ.mp4"},
  {file="S1Trial03_HQ.mp4"},
  {file="S1Trial04_HQ.mp4"},
  {file="S1Trial05_HQ.mp4"},
  {file="S1Trial06_HQ.mp4"},
  {file="S1Trial07_HQ.mp4"},
  {file="S2Trial01_HQ.mp4"},
  {file="S2Trial02_HQ.mp4"},
  {file="S2Trial03_HQ.mp4"},
  {file="S2Trial04_HQ.mp4"},
  {file="S2Trial05_HQ.mp4"},
  {file="S2Trial06_HQ.mp4"},
  {file="S2Trial07_HQ.mp4"},
}
local start=display.newText({
  text="First the practice video",
  x=display.contentCenterX,
  y=display.contentCenterY,
  fontSize=180})

local instruction=display.newText({
    text="Tap to start",
    x=display.contentCenterX,
    y=display.contentCenterY+200,
    fontSize=40})

local function onFullScreenTap(func)
  local listener
  listener=function(event)
    Runtime:removeEventListener("tap",listener)
    func()
  end
  Runtime:addEventListener("tap",listener)
end

function play()
  local vid=table.remove(videos,1)
  if not vid then
    display.newText({
      text="Done",
      x=display.contentCenterX,
      y=display.contentCenterY,
      fontSize=180})
    return
  end
  media.playVideo("videos/"..vid.file, false, function()
    local t1=display.newText({
      text="Which way is the entrance?",
      x=display.contentCenterX,
      y=display.contentCenterY,
      fontSize=70
    })
    timer.performWithDelay(1000, function()
      local t2=display.newText({
        text="Tap to continue",
        x=display.contentCenterX,
        y=display.contentCenterY+200,
        fontSize=40})
      onFullScreenTap(function() 
        if vid.text then
          t1.text=vid.text.t1
          t2.text=vid.text.t2
          t2.isVisible=false
          timer.performWithDelay(1000, function()
            t2.isVisible=true
            onFullScreenTap(function()
              t1:removeSelf()
              t2:removeSelf()
              play()
            end)
          end)
        else
          t1:removeSelf()
          t2:removeSelf()
          play()
        end
      end)
    end)
  end)
end

onFullScreenTap(function()
  instruction:removeSelf()
  start:removeSelf()
  play()
end)



