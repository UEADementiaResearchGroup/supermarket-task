local M={}
users=M

local lfs=require "lfs"
local env=require "util.env"
local timer=timer
local system=system
local display=display
local native=native

setfenv(1,M)

local path=system.pathForFile("users",system.DocumentsDirectory)
lfs.mkdir(path)

function getUsers()
  local profiles={}
  for file in lfs.dir(path) do
    if file:find("user") then
      profiles[#profiles+1]=path.."/"..file
    end
  end
  return profiles
end

function createFileName(userid)
  return "user_"..userid
end

function getDirectory(userid)
  return path.."/"..createFileName(userid)
end

function checkIfExists(userid)
  return lfs.attributes(getDirectory(userid),'mode')~=nil
end

function newUser(userid)
  if checkIfExists(userid) then
    return false
  end
  lfs.chdir(path)
  lfs.mkdir(createFileName(userid))
  return true
end

function getUserID(filepath)
  local s,e=filepath:reverse():find(("user"):reverse())

  return filepath:sub(filepath:len()-s+2)
end

local user
function setup(whenDone,force)
  if force then
    local isNew=newUser("test")
    user="test"
    return whenDone(isNew)
  end

  local instruction=display.newText({
    text="Enter the Participant ID",
    fontSize=48,
    align="center"
  })
  instruction:translate(display.contentCenterX, display.contentCenterY-160)

  local textField
  local function textListener(event)
    if event.phase == "submitted" then
      local text=textField.text

      if text:find("[%z\1-\127\194-\244][\128-\191]") then
        local warning="Participant IDs cannot contain any characters with diacritics (e.g. umlauts, accents or cedilla). Try using plain letters."
        local alert = native.showAlert("Invalid Character", warning, {"Okay" }, function(event)
          if event.action=="clicked" then
            return setup(whenDone,force)
          end
        end)
        instruction:removeSelf()
        textField:removeSelf()
        return
      end

      local function continue(isNewUser)
        local function onComplete( event )
          if event.action == "clicked" then
            local i = event.index
            if i == 1 then
              return setup(whenDone,force)
            elseif i == 2 then
              isNewUser=isNewUser and newUser(text)
              user=text
              whenDone(isNewUser)
            end
          end
        end

        timer.performWithDelay(1, function()
          -- Show alert with two buttons
          local alert = native.showAlert("Confirm", "Set Participant ID to " .. text .. ". All data will logged against this id", { "Cancel", "Okay" }, onComplete)
        end)
      end


      if checkIfExists(text) then
         local alert = native.showAlert("Existing User", "Participant ID " .. text .. " already exists. Data will be appended to existing files.", { "Cancel", "Okay" }, function(event)
          if event.action=="clicked" then
            if event.index==1 then
              return setup(whenDone,force)
            else
              continue(false)
            end
          end
        end)
      else
        continue(true)
      end
      instruction:removeSelf()
      textField:removeSelf()
    end
  end


  textField = native.newTextField(display.contentCenterX, display.contentCenterY-100, display.contentWidth-20, 50)
  textField.placeholder="Participant ID"
  textField:addEventListener("userInput", textListener)
  textField.autocorrectionType = "UITextAutocorrectionTypeNo"
  if env.isiOS() then
    textField.inputType="UIKeyboardTypeASCIICapable"
  end
end

function getID()
  return user
end

return M
