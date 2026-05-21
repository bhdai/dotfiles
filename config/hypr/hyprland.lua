-- ==============================================================================
-- Hyprland Configuration Entrypoint
-- ==============================================================================
--
-- Each require() runs in an isolated Lua scope. An error in one file does
-- not stop the others from loading.
--
-- Load order matters for env (must be early, before display server init)
-- and for rules (evaluated top to bottom).

-- Environment variables — must be first, before display server initialization
require("env")

-- Monitor declarations
require("monitors")

-- Compositor settings: input, cursor, general, layouts, misc, xwayland
require("compositor")

-- Visual: decoration, blur, shadow, curves, animations
require("appearance")

-- Window rules and layer rules (order-sensitive)
require("rules")

-- Keybindings, submaps, and gestures
require("binds")

-- Autostart: services, app launches, clipboard watchers
require("autostart")
