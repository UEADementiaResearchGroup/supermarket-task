local M={}
jsonreader=M

local json=require "json"

local io=io

setfenv(1,M)

function load(path)
	local fh,err=io.open(path,"r")
	if not err then
		local contents=fh:read("*a")
		fh:close()
		return json.decode(contents),nil
	end
	return nil,err
end

function store(path,t)
	local fh,err=io.open(path,"w")
	if not err then
		local contents=json.encode(t)
		fh:write(contents)
		fh:close()
		return
	end
	return err
end

return M