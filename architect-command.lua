-- architect/architect-command.lua

local pkg = {}
local module = ...
local USAGE = "/architect [<player>]"

function pkg.registerCommand()
  pcall(function() Commands.deregister("architect") end)
  Commands.register("architect",string.format([[
    require('%s').architect(...)
  ]],module),USAGE,1)
end

function pkg.architect(name)
  if not name and spell.owner then
    name = spell.owner.name
  end
  require('architect.Architect')
  Architect(name):start()
end

return pkg