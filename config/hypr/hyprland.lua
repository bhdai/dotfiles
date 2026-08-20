-- Each require() runs in an isolated Lua scope, so an error in one file does not
-- stop the others from loading.

require("env") -- must run before display server initialization
require("monitors")
require("compositor")
require("appearance")
require("rules") -- evaluated top to bottom, so load order is part of the semantics
require("quake")
require("binds")
require("autostart")
