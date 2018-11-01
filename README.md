# The Architect's Spell Pack

This spell pack is a [Wizards of Lua](http://www.wizards-of-lua.net) add-on that adds the /architect command to the Minecraft game.

By executing the /architect command you can turn yourself into an architect.
As an architect you are able to define what happens when you place a block into the world.
For example, if you activate the BAR tool, you can build a stack of blocks with just one click.


## How to Install?
This spell pack is dependent on [Minecraft Forge](http://files.minecraftforge.net/maven/net/minecraftforge/forge/index_1.12.2.html) 
and the [Wizards of Lua Modification](https://minecraft.curseforge.com/projects/wizards-of-lua/files), version 2.5.0 or later.

These are the steps to install and run this spell pack on your Minecraft Server:

1. **Install Minecraft Forge**

     Well, you should already know how to do that.
2. **Install Wizards of Lua**

     Download the JAR file containing the latest Version of 
     [Wizards of Lua Modification](https://minecraft.curseforge.com/projects/wizards-of-lua/files) and place it
     into the `mods` directory of your Minecraft server.
     
3. **Install The Rocket Launcher Spell Pack**

    Download the JAR file containing the latest Version of 
    [The Architect's Spell Pack](https://minecraft.curseforge.com/projects/architects-spell-pack/files) and place it
    into the `mods` directory of your Minecraft server.
    
4. **Restart the Server**

## Playing Instructions
### How to Become an Architect?
#### By Spell Pack Command
```
/architect
```

### How to Change the Active Tool? 
To change the active tool just type the tool's name into the chat window. Please ensure to only use upper case characters.
For example, to activate the "bar" tool you have to type "BAR" (followed by the "Enter" key).

The following tools are currently supported: [BAR](#bar), [FLOOR](#floor), [WALL](#wall), [CUT](#cut), [COPY](#copy), [PASTE](#paste), [REPLACE](#replace), [FILL](#fill), [DELETE](#delete), and [OFF](#off).

To deactivate the current tool just type "OFF". This will set you back into the normal mode.

### BAR
Whenever you place a block into the world this tool adds some more blocks on top of it, or dependening on the side you clicked at, next to it. You can change the number of blocks that will be added by typing "BAR n" into the chat window, where n should be replaced with the number. For example, when typing
```
BAR 4
```
you will create a bar of 4 blocks if you place a block.
 
### FLOOR
This tool can fill a horizontal area with copies of the block you place inside that area. By default this tool is restricted to place only a maximum number of 4096 blocks. You can change this by typing "FLOOR n" into the chat window, where n should be replaced with the number. For example, when typing
```
FLOOR 10000
```
you will create a floor with a maximum of 10000 blocks if you place a block.

### WALL
This tool can fill a vertical area with copies of the block you place inside that area. By default this tool is restricted to place only a maximum number of 4096 blocks. You can change this by typing "WALL n" into the chat window, where n should be replaced with the number. For example, when typing
```
WALL 10000
```
you will create a wall with a maximum of 10000 blocks if you place a block.

### CUT
This tool can cut a structure of connected blocks from the world, relative to the placed block, but only blocks that are at the same height level or higher. The structure will be copied into the architect's memory and can be placed with the PASTE tool any time later.

By default this tool is restricted to select only a maximum number of 4096 blocks. You can change this by typing "CUT n" into the chat window, where n should be replaced with the number. For example, when typing
```
CUT 10000
```
you will cut a structure with a maximum of 10000 blocks if you place a block next to the structure.

### COPY
This tool can copy a structure of connected blocks in the world, relative to the placed block, but only blocks that are at the same height level or higher. The structure will be copied into the architect's memory and can be placed with the PASTE tool any time later.

By default this tool is restricted to select only a maximum number of 4096 blocks. You can change this by typing "COPY n" into the chat window, where n should be replaced with the number. For example, when typing
```
COPY 10000
```
you will copy a structure with a maximum of 10000 blocks if you place a block next to the structure.

### PASTE
This tool can paste a copied structure into the world, relative to the placed block. The structure will be copied from the architect's memory. In order to make this work you must use the COPY or the CUT tool prior to this.

### REPLACE
This tool can select a structure of connected and equal blocks, relative to the placed block and replace them with copies of the placed block. 

By default this tool is restricted to select only a maximum number of 4096 blocks. You can change this by typing "REPLACE n" into the chat window, where n should be replaced with the number. For example, when typing
```
REPLACE 10000
```
you will replace a structure with a maximum of 10000 blocks if you place a block next to the structure.

### FILL
This tool can fill a hole relative to the placed block, but only downwards, with copies of the placed block. 

By default this tool is restricted to select only a maximum number of 4096 blocks. You can change this by typing "FILL n" into the chat window, where n should be replaced with the number. For example, when typing
```
FILL 10000
```
you will replace a structure with a maximum of 10000 blocks if you place a block next to the structure.

### DELETE

This tool can select a structure of connected and equal blocks, relative to the placed block and replace them with air.

By default this tool is restricted to select only a maximum number of 4096 blocks. You can change this by typing "DELETE n" into the chat window, where n should be replaced with the number. For example, when typing
```
DELETE 10000
```
you will delete a structure with a maximum of 10000 blocks if you place a block next to the structure.

### OFF

This will deactivate the current tool.
