local M={}
emailzip=M

local native=native
local system=system
local assert=assert
local os=os
local tostring=tostring

setfenv(1,M)

function send(userid,zipFile)
  local options = {
    subject = "Supermarket Data - Results " .. os.date(),
    isBodyHtml = true,
    body = "<html><body>The results for user <b>".. tostring(userid) .. "</b>.</body></html>",
    attachment = {
      filename=zipFile,
      baseDir=system.TemporaryDirectory,
      type="application/zip"
    },
  }
  native.showPopup("mail", options)
end

return M