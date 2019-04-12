-- architect/architect-command.lua

local pkg = {}
local module = ...
local log
local USAGE = "/architect [<player>]"

function pkg.registerCommand(permissionLevel)
  permissionLevel = permissionLevel or 0
  Commands.register("architect",string.format([[
    if spell.owner then
      spell.pos = spell.owner.pos
    end
    require('%s').architect(...)
  ]], module), USAGE, permissionLevel)
end

function pkg.deregisterCommand()
  Commands.deregister("architect")
end

function pkg.architect(name)
  if not name and spell.owner then
    name = spell.owner.name
  end
  if name:match("^@.*") then
    local found = Entities.find(name)
    for _,p in pairs(found) do
      spell:execute([[/lua require('%s').architect('%s')]], module, p.name)
    end
  else
    require('architect.Architect')
    Architect(name):start()
  end
end

-- Logs the given message into the chat
function log(message, ...)
  local n = select('#', ...)
  if n>0 then
    message = string.format(message, ...)
  end
  spell:execute("say %s", message)
end

return pkg