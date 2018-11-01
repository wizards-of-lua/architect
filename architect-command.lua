-- architect/architect-command.lua

local pkg = {}
local module = ...
local USAGE = "/architect [<player>]"

function pkg.registerCommand()
  Commands.register("architect",string.format([[
    if spell.owner then
      spell.pos = spell.owner.pos
    end
    require('%s').architect(...)
  ]],module),USAGE,1)
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

return pkg