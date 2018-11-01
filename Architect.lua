-- architect/Architect.lua
-- /lua require('architect.Architect'); Architect('mickkay'):start()
local module = ...
local log

require "architect.Spell"
clipboard    = require "architect.clipboard"
construction = require "architect.construction"

-- Declare a new class "Architect"
declare("Architect")

-- This declares a convenient 'constructor' delegating to Architect.new()
-- Use it like this: Architect('mickkay')
local mt = {
  __call = function(tbl,player)
             return Architect.new(player)
           end;
}
setmetatable(Architect,mt)

-- Some constants
local SYNC  = "SYNC"
local ASYNC = "ASYNC"
local tools = {
  OFF    = "",       BAR   = "bar",   FLOOR   = "floor",   WALL = "wall",
  COPY   = "copy",   PASTE = "paste", REPLACE = "replace", FILL = "fill",
  DELETE = "delete", CUT   = "cut"
}

-- The constructor
function Architect.new(player)
  player = player or spell.owner
  if type(player)=="string" then
    local p = Entities.find("@a[name="..player.."]")[1]
    if p == nil then
      error("Can't find player '%s'",player)
    else
      player = p
    end
  end
  if not instanceOf(Player,player) then
    error("Expected Player instance, but got: %s", type(player))
  end
  local self = {
    playerName = player.name ,
    tool       = "OFF" ,
    mode       = ASYNC ,
    facing     = player.facing ,
    castCount  = 0 ,
    options    = {
          BAR     = { length=4 } ,
          FLOOR   = { maxsel=16*16*16 } ,
          WALL    = { maxsel=16*16*16 } ,
          COPY    = { maxsel=16*16*16 } ,
          PASTE   = { } ,
          REPLACE = { maxsel=16*16*16 } ,
          FILL    = { maxsel=16*16*16 } ,
          DELETE  = { maxsel=16*16*16, radius=8 },
          CUT     = { maxsel=16*16*16}
    }
  }
  setmetatable(self,Architect)
  return self
end

-- Starts the spell loop
function Architect:start()
  spell:singleton(module.."-"..self.playerName)
  self:whisper("Welcome Architect "..self.playerName..".")
  self:whisper("Select your tool by typing its name into the chat.")
  self:whisper("Available tools are "..self:getToolNames()..".")
  self:whisper("Show your current tool by typing TOOL.")
  self:whisper("Current tool is "..self.tool..".")
  Events.on("ChatEvent"):call(
    function(event)
      if event.player.name==self.playerName then
        if event.name=="ChatEvent" then
          local message = event.message
          if message=="TOOL" then
            event.canceled = true
            --self:whisper("Current Tool is "..self.tool)
          elseif tools[message] then
            self.tool = message
            event.canceled = true
          else
            if message:match("BAR %d+") then
              self.tool = "BAR"
              local val = tonumber(message:match("%d+"))
              self.options[self.tool].length = val
              event.canceled = true
            elseif message:match("FLOOR %d+") then
              self.tool = "FLOOR"
              local val = tonumber(message:match("%d+"))
              self.options[self.tool].maxsel = val
              event.canceled = true
            elseif message:match("COPY %d+") then
              self.tool = "COPY"
              local val = tonumber(message:match("%d+"))
              self.options[self.tool].maxsel = val
              event.canceled = true
            elseif message:match("CUT %d+") then
              self.tool = "CUT"
              local val = tonumber(message:match("%d+"))
              self.options[self.tool].maxsel = val
              event.canceled = true
            elseif message:match("REPLACE %d+") then
              self.tool = "REPLACE"
              local val = tonumber(message:match("%d+"))
              self.options[self.tool].maxsel = val
              event.canceled = true
            elseif message:match("FILL %d+") then
              self.tool = "FILL"
              local val = tonumber(message:match("%d+"))
              self.options[self.tool].maxsel = val
              event.canceled = true
            elseif message:match("DELETE %d+") then
              self.tool = "DELETE"
              local val = tonumber(message:match("%d+"))
              self.options[self.tool].radius = val
              event.canceled = true
            end
          end
          self:whisper("Current Tool is "..self.tool)
        end
      end
    end
  )
  local queue = Events.collect("RightClickBlockEvent")
  while true do
    local event = queue:next()
    if event.player.name==self.playerName then
      --print("Click",self.tool,event.pos)
      if self.tool~="OFF" and event.player.mainhand ~= nil then
        self:handle(event)
      end
    end
  end
end

-- Handles the given event
function Architect:handle(event)
  if self.mode==ASYNC then
    -- handle the event in another spell
    self.castCount = self.castCount+1
    local channel  = module.."-"..self.playerName.."-"..self.castCount
    local cmd      = "lua require('%s'); Architect('%s'):worker('%s')"
    spell:execute(cmd, module, self.playerName, channel)
    sleep(1) -- wait 1 tick to ensure that the receiver has time to get connected
    Events.fire(channel, {
      tool    = self.tool ,
      options = self.options[self.tool] ,
      event   = event ,
      facing  = event.player.facing
    })
  elseif self.mode==SYNC then
    -- handle the event in this spell
    local fName    = tools[self.tool]
    local func     = Architect[fName]
    local options  = self.options[self.tool]
    func(self,event,options)
  else
    error("Unknown mode %s",self.mode)
  end
end

-- Send a message to the architect
function Architect:whisper(message)
  spell:execute('/tellraw %s [{"text":"Architect: ","color":"gold"},{"text":"%s","color":"green"}]',self.playerName, message)
end


-- Returns a string with all tool names
function Architect:getToolNames()
  local result = ""
  for k,v in pairs(tools) do
    if result~="" then
      result = result..", "
    end
    result = result..k
  end
  return result
end

-- Handles the next event transmitted on the given channel
function Architect:worker(channel)
  self.mode   = SYNC
  local queue = Events.collect(channel)
  local event = queue:next(20)
  if event then
    self.tool               = event.data.tool
    self.facing             = event.data.facing
    self.options[self.tool] = event.data.options
    self:handle(event.data.event)
  else
    error("Can't do my work. Timeout occured!")
  end
end

-- Creates a bar of blocks
function Architect:bar(event,options)
  local n   = options.length
  spell.pos = event.pos
  spell:move(event.face)
  local b   = spell.block
  for i=1,n-1 do
    spell:move(event.face)
    spell.block = b
  end
end

local SAME_X = {}
function SAME_X.neighbors(pos)
  return {
    Vec3(pos.x, pos.y+1, pos.z),
    Vec3(pos.x, pos.y-1, pos.z),
    Vec3(pos.x, pos.y, pos.z+1),
    Vec3(pos.x, pos.y, pos.z-1)
  }
end
local SAME_Y = {}
function SAME_Y.neighbors(pos)
  return {
    Vec3(pos.x+1, pos.y, pos.z),
    Vec3(pos.x-1, pos.y, pos.z),
    Vec3(pos.x, pos.y, pos.z+1),
    Vec3(pos.x, pos.y, pos.z-1)
  }
end
local SAME_Z = {}
function SAME_Z.neighbors(pos)
  return {
    Vec3(pos.x+1, pos.y, pos.z),
    Vec3(pos.x-1, pos.y, pos.z),
    Vec3(pos.x, pos.y+1, pos.z),
    Vec3(pos.x, pos.y-1, pos.z)
  }
end
local ANY_DIRECTION = {}
function ANY_DIRECTION.neighbors(pos)
  return {
    Vec3(pos.x+1, pos.y, pos.z),
    Vec3(pos.x-1, pos.y, pos.z),
    Vec3(pos.x, pos.y+1, pos.z),
    Vec3(pos.x, pos.y-1, pos.z),
    Vec3(pos.x, pos.y, pos.z+1),
    Vec3(pos.x, pos.y, pos.z-1)
  }
end
local function SAME_OR_ABOVE_Y(y)
  return {
    neighbors = function(pos)
      local result = {
        Vec3(pos.x+1, pos.y, pos.z),
        Vec3(pos.x-1, pos.y, pos.z),
        Vec3(pos.x, pos.y, pos.z+1),
        Vec3(pos.x, pos.y, pos.z-1),
        Vec3(pos.x, pos.y+1, pos.z)
      }
      if pos.y>y then
        table.insert(result,Vec3(pos.x, pos.y-1, pos.z))
      end
      return result
    end
  }
end
local function SAME_OR_BELOW_Y(y)
  return {
    neighbors = function(pos)
      local result = {
        Vec3(pos.x+1, pos.y, pos.z),
        Vec3(pos.x-1, pos.y, pos.z),
        Vec3(pos.x, pos.y, pos.z+1),
        Vec3(pos.x, pos.y, pos.z-1),
        Vec3(pos.x, pos.y-1, pos.z)
      }
      if pos.y<y then
        table.insert(result,Vec3(pos.x, pos.y+1, pos.z))
      end
      return result
    end
  }
end
local function WITHIN_RADIUS(center,r)
  local rsqr=r*r
  return {
    neighbors = function(pos)
      local result = {}
      for _,v in pairs({
        Vec3(pos.x+1, pos.y, pos.z),
        Vec3(pos.x-1, pos.y, pos.z),
        Vec3(pos.x, pos.y, pos.z+1),
        Vec3(pos.x, pos.y, pos.z-1),
        Vec3(pos.x, pos.y+1, pos.z),
        Vec3(pos.x, pos.y-1, pos.z)
      }) do
        if (v-center):sqrMagnitude() <= rsqr then
          table.insert(result,v)
        end
      end
      return result
    end
  }
end

local NOT_SOLID = {}
function NOT_SOLID.matches(pos)
  spell.pos = pos
  return not spell.block.material.solid
end

local SOLID = {}
function SOLID.matches(pos)
  spell.pos = pos
  return spell.block.material.solid
end

local ALL_BUT_AIR = {}
function ALL_BUT_AIR.matches(pos)
  spell.pos = pos
  return spell.block.name~="air"
end

local function EQUAL(block)
  return {
    matches = function(pos)
      spell.pos = pos
      -- TODO also compare data
      return spell.block.name==block.name
    end
  }
end

-- Fills an area with a floor
function Architect:floor(event,options)
  local maxsel = options.maxsel
  spell.pos    = event.pos
  spell:move(event.face)

  local block  = spell.block
  local posL   = self:selectblocks(spell.pos, maxsel, SAME_Y, NOT_SOLID)
  for i,pos in pairs(posL) do
    spell.pos   = pos
    spell.block = block
  end
end

local areaByFace = {
  south=SAME_X, west=SAME_Z, north=SAME_X, east=SAME_Z
}

-- Fills an area with a wall
function Architect:wall(event,options)
  local maxsel = options.maxsel
  spell.pos    = event.pos
  spell:move(event.face)

  --print("wall",maxsel, spell.pos)
  local area = areaByFace[event.face]
  if not area then
    error("Can't select blocks when face is '%s'", event.face)
  end

  local block = spell.block
  local posL  = self:selectblocks(spell.pos, maxsel, area, NOT_SOLID)
  for i,pos in pairs(posL) do
    spell.pos   = pos
    spell.block = block
  end
end

-- Copies an area into the clipboard
function Architect:copy(event,options)
  local maxsel = options.maxsel
  spell.pos    = event.pos
  spell:move(event.face)
  spell.block  = Blocks.get("air")
  spell.pos    = event.pos

  --print("copy",maxsel, spell.pos)
  --local vecS = self:selectblocks(spell.pos, maxsel, SAME_OR_ABOVE_Y(spell.pos.y), SOLID)
  local vecS = self:selectblocks(spell.pos, maxsel, SAME_OR_ABOVE_Y(spell.pos.y), ALL_BUT_AIR)

  local origin = event.pos
  local blocks = {}
  for i,vec in pairs(vecS) do
    spell.pos = vec
    blocks[i] = {
      pos   = vec-origin  ,
      state = spell.block:copy()
    }
  end
  local snapshot = {
    pivot  = Vec3(0,0,0)   ,
    facing = self.facing  ,
    blocks = blocks
  }
  clipboard.putClip(snapshot,self.playerName.."-clipboard")
end

local rot={south=0, west=90, north=180, east=270}

-- Pastes the contents of the clipboard
function Architect:paste(event,options)
  spell.pos         = event.pos
  spell.rotationYaw = rot[self.facing]
  spell:move(event.face)
  spell.block       = Blocks.get("air")

  --print("paste",maxsel, spell.pos)
  local clip = clipboard.getClip(self.playerName.."-clipboard")
  construction.paste(clip)
end

-- Replaces all connected blocks equal to the clicked one with a copy of the created one
function Architect:replace(event,options)
  local maxsel   = options.maxsel
  spell.pos      = event.pos
  local oldBlock = spell.block
  spell:move(event.face)
  local newBlock = spell.block:copy();
  spell.block    = Blocks.get("air")

  --print("replace",maxsel, spell.pos)
  local posL = self:selectblocks(event.pos, maxsel, ANY_DIRECTION, EQUAL(oldBlock))
  
  for i,pos in pairs(posL) do
    spell.pos   = pos
    spell.block = newBlock
  end
end

-- Fills an area complete
function Architect:fill(event,options)
  local maxsel = options.maxsel
  spell.pos    = event.pos
  spell:move(event.face)

  local block  = spell.block
  local posL   = self:selectblocks(spell.pos, maxsel, SAME_OR_BELOW_Y(spell.pos.y), NOT_SOLID)
  for i,pos in pairs(posL) do
    spell.pos   = pos
    spell.block = block
  end
end

-- Deletes all connected blocks equal to the clicked one in a given radius
function Architect:delete(event,options)
  local maxsel   = options.maxsel
  local radius   = options.radius
  spell.pos      = event.pos
  local oldBlock = spell.block
  spell:move(event.face)
  local newBlock = Blocks.get("air")
  spell.block    = Blocks.get("air")

  --print("replace",maxsel, spell.pos)
  local posL     = self:selectblocks(event.pos, maxsel, WITHIN_RADIUS(event.pos,radius), EQUAL(oldBlock))

  for i,pos in pairs(posL) do
    spell.pos   = pos
    spell.block = newBlock
  end
end

-- Cuts an area from the world and copies it into the clipboard
function Architect:cut(event,options)
  local maxsel = options.maxsel
  spell.pos    = event.pos
  spell:move(event.face)
  local newBlock = Blocks.get("air")
  spell.block  = Blocks.get("air")
  spell.pos    = event.pos

  --print("cut",maxsel, spell.pos)
  --local vecS = self:selectblocks(spell.pos, maxsel, SAME_OR_ABOVE_Y(spell.pos.y), SOLID)
  local posL = self:selectblocks(spell.pos, maxsel, SAME_OR_ABOVE_Y(spell.pos.y), ALL_BUT_AIR)

  local origin = event.pos
  local blocks = {}
  for i,pos in pairs(posL) do
    spell.pos = pos
    blocks[i] = {
      pos   = pos-origin  ,
      state = spell.block:copy()
    }
  end
  local snapshot = {
    pivot  = Vec3(0,0,0)   ,
    facing = self.facing  ,
    blocks = blocks
  }
  
  for i,pos in pairs(posL) do
    spell.pos   = pos
    spell.block = newBlock
  end
  
  clipboard.putClip(snapshot,self.playerName.."-clipboard")
end

-- Selects a list of block positions
function Architect:selectblocks(start, maxsel, area, matcher)
  local original = spell.pos
  local result   = {}
  local selected = 0
  local done     = {}
  local todo     = {}
  table.insert(todo,start)
  while next(todo) do
    local pos  = table.remove(todo,1)
    local pkey = pos:tostring()
    if not done[pkey] then
      table.insert(result,pos)
      done[pkey] = true
      selected   = selected+1
      if selected > maxsel then
        error("Can't select more than %s blocks!", maxsel)
      end
      local neighbors = area.neighbors(pos)
      for i,npos in pairs(neighbors) do
        local nkey = npos:tostring()
        if not done[nkey] then
          if matcher.matches(npos) then
            table.insert(todo,npos)
          end
        end
      end
    end
  end
  spell.pos = original
  return result
end

-- Logs the given message into the chat
function log(message, ...)
  local n = select('#', ...)
  if n>0 then
    message = string.format(message, ...)
  end
  spell:execute("say %s", message)
end
