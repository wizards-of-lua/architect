-- architect/startup.lua

-- Logs the given message into the chat
local function log(message, ...)
  local n = select('#', ...)
  if n>0 then
    message = string.format(message, ...)
  end
  spell:execute("say %s", message)
end

local DEFAULTS = {
  enableCommands = true      ,
  commandPermissionLevel = 1 
}
local STARTUP_EVENT = 'architect.StartupEvent'

local options = DEFAULTS
Events.fire(STARTUP_EVENT,options)

if options.enableCommands then
  require('architect.architect-command').registerCommand(commandPermissionLevel)
else
  require('architect.architect-command').deregisterCommand()
end

