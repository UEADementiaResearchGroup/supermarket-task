local M={}
screentap=M

local Runtime=Runtime

setfenv(1,M)

function onFullScreenTap(func)
  local listener
  listener=function(event)
    Runtime:removeEventListener("tap",listener)
    func()
  end
  Runtime:addEventListener("tap",listener)
end

return M

