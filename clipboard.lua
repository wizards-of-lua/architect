-- architect/clipboard.lua

local pkg = {}

function pkg.getClip(name)
  local playername = spell.owner.name
  name = name or playername.."-clipboard"
  local backChannel = name.."-backchannel"
  local queue=Events.collect(backChannel)
  Events.fire(name,{backChannel=backChannel})
  local event=queue:next(20*5)
  if event==nil then
    error("Can't get clip from clipboard. Timeout after 5 seconds.")
  end
  return event.data
end

function pkg.putClip(data, name)
  local playername = spell.owner.name
  name=name or playername.."-clipboard"
  spell:singleton(name)
  if data==nil then
    return
  end
  --spell:execute("say serving data at %s", name)
  local queue=Events.collect(name)
  while true do
    local event=queue:next()
    Events.fire(event.data.backChannel, data)
  end
end

return pkg