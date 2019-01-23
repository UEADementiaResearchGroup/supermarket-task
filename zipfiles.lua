local M={}
zipfiles=M

local zip = require "plugin.zip"
local tostring=tostring
local system=system
local os=os

setfenv(1,M)

function zipData(participantID,filelist,onComplete)
  local filename=("%s_%s_supermarket_data.zip"):format(tostring(participantID),os.date("%d-%m-%Y"))
  zip.compress({
    zipFile=filename,
    zipBaseDir=system.TemporaryDirectory,
    srcFiles=filelist,
    srcBaseDir=system.DocumentsDirectory,
    listener=onComplete,
  })
  return filename
end

return M



