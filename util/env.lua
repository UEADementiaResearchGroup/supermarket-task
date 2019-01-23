local M={}
env=M

local system=system
local display=display

setfenv(1,M)

local platformsIsMobile={
  android=true,
  ios=true,
  macos=false,
  tvos=true,
  win32=false,
  winphone=true,
}

function isOnMobile()
  return platformsIsMobile[system.getInfo("platform")]
end

function isAndroid()
  return system.getInfo("platform")=="android"
end

function isiOS()
  return system.getInfo("platform")=="ios"
end

local function androidTabletSize()
  if system.getInfo("environment")=="simulator" then
    return "phone"
  end
  local approximateDpi=system.getInfo("androidDisplayApproximateDpi")
  local width,height
  if approximateDpi then
    width=display.pixelWidth/approximateDpi
    height=display.pixelHeight/approximateDpi
  else
    width=system.getInfo("androidDisplayWidthInInches")
    height=system.getInfo("androidDisplayHeightInInches")
  end

  local deviceType="phone"
  if width > 4.5 and height > 7 then
    deviceType = "large tablet"
  elseif width > 3.25 and height > 5.4 then
    deviceType = "small tablet"
  end
  return deviceType
end

function isTablet()
  if system.getInfo("model")=="iPad" then
    return true
  end
  if not isAndroid() then
    return false
  end
  return androidTabletSize()~="phone"
end

return M