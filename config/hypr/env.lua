-- ==============================================================================
-- Environment Variables
-- ==============================================================================
--
-- All hl.env() calls, set prior to display server initialization.
-- Not using uwsm, so everything lives here.

local shared = require("shared")

-- Toolkit backends: tell apps to prefer Wayland
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Scaling
hl.env("GDK_DPI_SCALE", tostring(shared.dpi_scale))
hl.env("GDK_SCALE", tostring(shared.dpi_scale))
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", tostring(shared.dpi_scale))

-- Theme and menu integration
hl.env("GTK_THEME", shared.system_theme)
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("XDG_MENU_PREFIX", "plasma-")

-- Nvidia
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- Cursors
hl.env("HYPRCURSOR_SIZE", tostring(shared.cursor_size))
hl.env("HYPRCURSOR_THEME", shared.cursor_theme)
hl.env("XCURSOR_SIZE", tostring(shared.cursor_size))
hl.env("XCURSOR_THEME", shared.cursor_theme)

-- Input method (fcitx5)
-- See https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("GLFW_IM_MODULE", "ibus")
hl.env("INPUT_METHOD", "fcitx")
