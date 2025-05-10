--[[
outside of when you want to use the nixCats global command
to decide if something should be loaded, or to pass info from nix to lua,
thats pretty much everything specific to nixCats that
needs to be in your config.
If you always want to load it via nix,
you pretty much dont need this file at all, and you also won't need
anything within lua/nixCatsUtils, nor will that be in the default template.
that directory is addable via the luaUtils template.
it is not required, but has some useful utility functions.
--]]

--[[
ok thats enough for 1 file. Off to lua/myLuaConf/init.lua
all the config starts there in this example config.
This config is loadable with and without nix due to the above,
and the lua/myLuaConf/non_nix_download.lua file.
the rest is just example of how to configure nvim making use of various
features of nixCats and using the plugin lze for lazy loading.
--]]
require('nixCats').init_main
require('myLuaConf')
