-- architect/Block.lua

local facings = {"north","east","south","west"}
local indexes = {}
for i,f in pairs(facings) do
  indexes[f]=i
end

function Block:rotate(deg)
  if deg%90~=0 then
    error("deg must be a multiple of 90, but was %s", deg)
  end
  deg = deg % 360
  local facing = self.data.facing
  if facing ~= nil and facing ~= "up" and facing ~= "down" then
    local offset = ((deg+360)%360)/90
    local idx = indexes[facing]
    facing = facings[((offset+idx-1)%#facings)+1]
    return self:withData({facing=facing})
  end
  local rotation = self.data.rotation
  if rotation ~= nil then
    local offset = (((deg+360)%360)/90)*4
    rotation = (rotation + offset)%16
    return self:withData({rotation=rotation})
  end
  return self
end