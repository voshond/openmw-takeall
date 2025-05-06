### High Level Goal

Give the player the ability to press a key to take all contents from a container during interacting with it.

### Description

The player has a take-all button, but that takes time and effort to find and click every time a player wants to quickly loot all the contents. Instead, i would like to bind this action to a hotkey (R) when i just opened a container to massively speed up looting.

### Aproach

1. After opening a container, get it's reference
2. Execute the takeAll function to this reference

### Hints

-   The Quickloot Project has a function for "takeAll" that we might be able to modify in the ql_g.lua
-   Try to separate helpers/utilities into their own files, same for settings handlers
-   Use these LUA Scripting docs for reference: https://openmw.readthedocs.io/en/latest/reference/lua-scripting/index.html
