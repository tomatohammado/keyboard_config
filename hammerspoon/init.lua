-- ~/.hammerspoon/init.lua  (symlinked from keyboard_config/hammerspoon/init.lua)
--
-- Menu-bar indicator for Karabiner-Elements' `colemak_vim_nav` variable.
-- Karabiner calls `hs -c 'vimOn()'` while vim-nav mode is held and
-- `hs -c 'vimOff()'` on release. See the repo README for the exact snippets.
--
-- Single purpose: show a menu-bar item while the mode is active, hide it when
-- it's off. Nothing else lives here.

-- Make the `hs` command-line tool available so Karabiner can call it. Installed
-- into the Homebrew prefix so the binary lands on PATH at /opt/homebrew/bin/hs
-- (Apple Silicon). Idempotent and silent; safe to run on every load.
require("hs.ipc")
hs.ipc.cliInstall("/opt/homebrew", true)

-- Locate the icon asset next to this script in the repo. init.lua is symlinked
-- into ~/.hammerspoon, so resolve the symlink to find the real repo directory.
-- This keeps ~/.hammerspoon clean -- only the one init.lua symlink is needed.
local scriptPath = hs.fs.pathToAbsolute(debug.getinfo(1, "S").source:sub(2))
local scriptDir = scriptPath and scriptPath:match("(.*/)") or (hs.configdir .. "/")
local iconPath = scriptDir .. "vim-indicator.png"

-- Template images render as a monochrome mask that adapts to light/dark menu
-- bars automatically. Set to false to show the asset in its original colors.
local USE_TEMPLATE = true

local indicator = nil      -- the single menu-bar item, created once and reused
local iconResolved = false -- whether we've tried to load the icon asset yet
local cachedIcon = nil     -- the loaded template image, or nil if unavailable

local function loadIcon()
  if not iconResolved then
    local img = hs.image.imageFromPath(iconPath)
    cachedIcon = img and img:template(USE_TEMPLATE) or nil
    iconResolved = true
  end
  return cachedIcon
end

-- returnToMenuBar() clears the item's icon/title on this macOS + Hammerspoon, so
-- the content must be (re)applied every time the item is shown, not just once at
-- creation. Falls back to a bold "V" if the icon asset is missing/unreadable.
local function applyContent(item)
  local icon = loadIcon()
  if icon then
    item:setTitle(nil)
    item:setIcon(icon)
  else
    item:setIcon(nil)
    item:setTitle(hs.styledtext.new("V", { font = { name = "Menlo-Bold", size = 14 } }))
  end
  item:setTooltip("Colemak vim navigation active")
end

-- These must be GLOBAL: `hs -c` evaluates in Hammerspoon's global Lua context.
function vimOn()
  if not indicator then indicator = hs.menubar.new(false) end
  if not indicator then return end -- creation failed; nothing to show
  indicator:returnToMenuBar()
  applyContent(indicator)
end

function vimOff()
  if indicator then indicator:removeFromMenuBar() end
end
