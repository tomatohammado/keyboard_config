-- ~/.hammerspoon/init.lua  (symlinked from keyboard_config/hammerspoon/init.lua)
--
-- On-screen indicator for Karabiner-Elements' `colemak_vim_nav` variable.
-- Karabiner calls `hs -c 'vimOn()'` while vim-nav mode is held and
-- `hs -c 'vimOff()'` on release. See the repo README for the exact snippets.
--
-- Uses an hs.canvas overlay (a small floating badge) rather than a menu-bar
-- item, so it is immune to menu-bar managers like Bartender. Single purpose:
-- show the badge while the mode is active, hide it when it's off.

-- Make the `hs` command-line tool available so Karabiner can call it. Installed
-- into the Homebrew prefix so the binary lands on PATH at /opt/homebrew/bin/hs
-- (Apple Silicon). Idempotent and silent; safe to run on every load.
require("hs.ipc")
hs.ipc.cliInstall("/opt/homebrew", true)

-- Locate the icon asset next to this script in the repo. init.lua is symlinked
-- into ~/.hammerspoon, so resolve the symlink to find the real repo directory.
local scriptPath = hs.fs.pathToAbsolute(debug.getinfo(1, "S").source:sub(2))
local scriptDir = scriptPath and scriptPath:match("(.*/)") or (hs.configdir .. "/")
local iconPath = scriptDir .. "vim-indicator.png"

-- Appearance (tweak to taste).
local SIZE = 56            -- badge width/height, points
local MARGIN = 24          -- gap from the screen edges
local BG = { black = 1, alpha = 0.55 } -- dark translucent badge; reads on any wallpaper

local overlay = nil        -- the hs.canvas badge, created once and reused
local iconResolved = false
local cachedIcon = nil

local function loadIcon()
  if not iconResolved then
    cachedIcon = hs.image.imageFromPath(iconPath) -- nil if the asset is absent
    iconResolved = true
  end
  return cachedIcon
end

-- The glyph drawn inside the badge: the icon asset if present (should be a light
-- glyph to read on the dark badge), otherwise a bold "V".
local function glyphElement()
  local icon = loadIcon()
  if icon then
    return {
      type = "image", image = icon,
      imageScaling = "scaleProportionally", imageAlignment = "center",
      frame = { x = SIZE * 0.18, y = SIZE * 0.18, w = SIZE * 0.64, h = SIZE * 0.64 },
    }
  end
  return {
    type = "text",
    text = hs.styledtext.new("V", {
      font = { name = "Menlo-Bold", size = math.floor(SIZE * 0.6) },
      color = { white = 1, alpha = 0.95 },
      paragraphStyle = { alignment = "center" },
    }),
    frame = { x = 0, y = SIZE * 0.14, w = SIZE, h = SIZE },
  }
end

local function ensureOverlay()
  if overlay then return overlay end
  overlay = hs.canvas.new({ x = 0, y = 0, w = SIZE, h = SIZE })
  overlay:appendElements(
    { type = "rectangle", action = "fill",
      roundedRectRadii = { xRadius = 14, yRadius = 14 }, fillColor = BG },
    glyphElement()
  )
  -- Float above normal windows and follow onto every space (incl. full screen).
  overlay:level(hs.canvas.windowLevels.overlay)
  overlay:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces
    + hs.canvas.windowBehaviors.stationary)
  return overlay
end

-- Park the badge in the bottom-right of whichever screen is currently active,
-- so it appears where you're working on a multi-monitor setup.
local function reposition(c)
  local f = hs.screen.mainScreen():frame()
  c:topLeft({ x = f.x + f.w - SIZE - MARGIN, y = f.y + f.h - SIZE - MARGIN })
end

-- These must be GLOBAL: `hs -c` evaluates in Hammerspoon's global Lua context.
function vimOn()
  local c = ensureOverlay()
  reposition(c)
  c:show()
end

function vimOff()
  if overlay then overlay:hide() end
end
