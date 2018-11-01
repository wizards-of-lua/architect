-- architect/construction.lua

require "architect.math-extension"
require "architect.Block"

local pkg = {}

function pkg.box(l,w,h,blk)
  if type(blk)=='string' then
    blk = Blocks.get(blk)
  end
  blk = blk or spell.block
  local sl = math.sign(l)
  local sw = math.sign(w)
  local sh = math.sign(h)

  for z=1,l*sl do
    for x=1,w*sw do
      for y=1,h*sh do
        spell.block = blk
        spell:move('up',sh)
        sleep()
      end
      spell:move('up',-h)
      spell:move('right',sw)
    end
    spell:move('right',-w)
    spell:move('forward',sl)
  end
  spell:move('forward',-l)
end

function pkg.woolbox(l,w,h)
  local origin=spell.pos
  local colors={"white","orange","magenta","light_blue","yellow","lime","pink","gray",
    "silver","cyan","purple","blue","brown","green","red","black"
  }
  local from,to,step = pkg.bounds(l,w,h)

  local c=0
  for y=from.y,to.y,step.y do
    for x=from.x,to.x,step.x do
      for z=from.z,to.z,step.z do
        c=c+1
        if c%200==0 then
          sleep(1)
        end
        spell.pos=Vec3.from(x,y,z)
        color=colors[math.random(#colors)]
        spell.block=Blocks.get("wool"):withData({color=color})
      end
    end
  end
  spell.pos=origin
end

function pkg.bounds(l,w,h)
  local from=spell.pos
  spell:move("forward",l-math.sign(l))
  spell:move("right",w-math.sign(w))
  spell:move("up",h-math.sign(h))
  local to=spell.pos
  spell.pos=from

  local delta=to-from
  local step=Vec3(
    math.sign(delta.x),
    math.sign(delta.y),
    math.sign(delta.z)
  )

  return from,to,step
end

function pkg.copy(l,w,h)
  if ( spell.facing == "up" or spell.facing == "down") then
    error("can't copy when spell.facing==%s",spell.facing)
  end
  local origin = spell.pos
  local facing = spell.facing
  local blocks = {}
  local vecs = pkg.select(l,w,h)
  for i,vec in pairs(vecs) do
    spell.pos = vec
    blocks[i] = {pos=vec-origin, state=spell.block}
  end
  spell.pos = origin
  return {pivot=Vec3(0,0,0), facing=facing, blocks=blocks}
end

local rots={["south"]=0,["west"]=90,["north"]=180,["east"]=270}

local function rotationBetween(o1, o2)
  local r1=rots[o1]
  local r2=rots[o2]
  return rots[o2]-rots[o1]
end

function pkg.paste(snapshot)
  local origin = spell.pos
  local facing = snapshot.facing
  local pivot = snapshot.pivot
  local rot=rotationBetween(facing, spell.facing)
  for i,block in pairs(snapshot.blocks) do
    spell.pos   = origin + pkg.rotate(pivot,rot,block.pos)
    spell.block = block.state:rotate(rot)
  end
  spell.pos = origin
end

function pkg.select(l,w,h)
  local result = {}
  local from,to,step = pkg.bounds(l,w,h)
  local i=0
  for y=from.y,to.y,step.y do
    for x=from.x,to.x,step.x do
      for z=from.z,to.z,step.z do
        i=i+1
        result[i]=Vec3.from(x,y,z)
      end
    end
  end
  return result
end

function pkg.rotate(pivot,deg,vec)
  if deg%90~=0 then
    error("deg must be a multiple of 90, but was %s", deg)
  end
  deg = ((deg % 360) + 360) % 360
  if instanceOf(Vec3,vec) then
    local v = vec-pivot
    if deg == 90 then
      return Vec3(-v.z,v.y,v.x)+pivot
    elseif deg == 180 then
      return Vec3(-v.x,v.y,-v.z)+pivot
    elseif deg == 270 then
      return Vec3(v.z,v.y,-v.x)+pivot
    end
    return vec
  elseif type(vec)=="table" then
    local result = {}
    for i,v in pairs(vec) do
      result[i]=pkg.rotate(pivot,deg,v)
    end
    return result
  else
    error("Expected vec to be Vec3 or table, but got %s",type(vec))
  end
end

return pkg
