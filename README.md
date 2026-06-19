# Keyboard Configuration

My macOS keyboard setup — Karabiner-Elements remappings and a Hammerspoon vim-mode
indicator — version-controlled for syncing across machines.

> **Prerequisite:** the [Colemak-DH](https://github.com/ColemakMods/mod-dh/tree/master/macOS)
> keyboard layout. Install that input source bundle first — everything here assumes it.

These keyboard dotfiles are a deliberate **high-priority exception** to my
[yadm_dotfiles (GH)](https://github.com/tomatohammado/yadm_dotfiles) dotfile
management: they're pulled out into this standalone repo and set up early, ahead
of the main yadm bootstrap, so a new machine is comfortable to type on as soon
as possible.

## Setup Instructions

### 1. Clone

Clone this repo on the new machine and `cd` into it.

### 2. Karabiner-Elements

Symlink the config into place:

```sh
# https://github.com/tekezo/Karabiner-Elements/issues/597#issuecomment-282760186
mkdir -p ~/.config
ln -sfn $PWD/karabiner ~/.config/karabiner

# Verify
ls -l ~/.config/karabiner
# -> /Users/hammad/.config/karabiner -> /Users/hammad/Code/keyboard_config/karabiner
```

Then install Karabiner-Elements from the [official site](https://karabiner-elements.pqrs.org/),
open it, and the config is applied. Enable auto-update in its preferences.

### 3. Hammerspoon

Install [Hammerspoon](https://www.hammerspoon.org/) (manual download — no Homebrew cask),
then open it once and:

- Enable **"Launch Hammerspoon at login"**.
- Grant **Accessibility** (and any related) permissions in System Settings.

> On this first launch — before the symlink in the next step — Hammerspoon's console
> may warn that it can't find `init.lua`. That's expected; the next step puts it in place.

Symlink the config:

```sh
mkdir -p ~/.hammerspoon

# If an init.lua already exists, back it up first:
# mv ~/.hammerspoon/init.lua ~/.hammerspoon/init.lua.backup

# Symlink our config into place
ln -sfn $PWD/hammerspoon/init.lua ~/.hammerspoon/init.lua

# Verify
ls -l ~/.hammerspoon/init.lua
```

Reload the config (Hammerspoon menu → **Reload Config**, or relaunch the app).

## Features

> Apple Silicon (arm64) only — this setup is known not to work on Intel Macs.

### Karabiner-Elements

- **Space Cadet Caps Lock** — Right Control on hold, Escape on tap.
- **Better Shift Keys** — tapping a shift key produces a parenthesis.
- **Colemak Vim Navigation** — home-row arrows, Page Up/Down, and Home/End. Shift + "up/down" -> 5 up/5 down

### Hammerspoon

**Colemak Vim Navigation indicator** — a small floating badge appears while the mode is
active. Karabiner drives it directly from the activate rule:

```jsonc
"to": [
  { "set_variable": { "name": "colemak_vim_nav", "value": 1 } },
  { "shell_command": "/opt/homebrew/bin/hs -c 'vimOn()'" }
],
"to_after_key_up": [
  { "set_variable": { "name": "colemak_vim_nav", "value": 0 } },
  { "shell_command": "/opt/homebrew/bin/hs -c 'vimOff()'" }
]
```

## Useful Links

- [StackOverflow about ln command flags](https://superuser.com/a/938865)
- [Karabiner issue on the symlinking solution](https://github.com/tekezo/Karabiner-Elements/issues/597#issuecomment-282760186)
- [Hammerspoon documentation](https://www.hammerspoon.org/docs/)

---

- [Old Medium article where I probably found the repo I forked](https://medium.com/@caulfieldOwen/turn-your-keyboard-into-a-text-editing-rocket-1514d8474d2d)

### Origin

I forked [`keyboard`](https://github.com/tomatohammado/keyboard) (based on
jasonrudolph/keyboard) and learned a lot from that opinionated setup. I created this
repo when I wanted a small, focused, intentional config of just what I use.