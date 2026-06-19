# Keyboard Configuration

This repository contains my macOS keyboard setup — Karabiner-Elements key
remappings plus a small Hammerspoon on-screen indicator — kept in version control
for synchronization across machines.

It is intentionally standalone and is the **first** thing set up on a new machine:
my Colemak-DH + vim-navigation layout is a prerequisite for comfortably doing
everything else, including the yadm dotfiles bootstrap.

## Background

This started as a fork of [`keyboard`](https://github.com/tomatohammado/keyboard)
(itself based on jasonrudolph/keyboard), which bundled an extensive Hammerspoon
setup. I stripped Hammerspoon out for a while to keep things lean. It's back now
in a deliberately minimal form: a single on-screen badge that shows when my
`colemak_vim_nav` mode is active — nothing more.

## Setup Instructions

### 1. Clone

Clone this repository on your new machine and `cd` into it.

### 2. Karabiner-Elements

Symlink the Karabiner config into place:

```sh
# https://github.com/tekezo/Karabiner-Elements/issues/597#issuecomment-282760186
mkdir -p ~/.config
ln -sfn $PWD/karabiner ~/.config/karabiner

# Verify
ls -l ~/.config/karabiner
# -> /Users/hammad/.config/karabiner -> /Users/hammad/Code/keyboard_config/karabiner
```

Install Karabiner-Elements from the [official site](https://karabiner-elements.pqrs.org/),
open it, and your configuration is applied. Enable auto-update in its preferences.

### 3. Hammerspoon on-screen indicator (optional)

A lightweight visual indicator for vim-navigation mode. While Left-Shift+Space is
held, Karabiner sets the `colemak_vim_nav` variable **and** calls Hammerspoon to
show a small floating badge (bottom-right of the active screen); on release it
hides again. It uses an `hs.canvas` overlay rather than a menu-bar item, so it is
immune to menu-bar managers like Bartender. It is purely cosmetic — if Hammerspoon
isn't installed, key remapping still works, because Karabiner runs the calls
asynchronously and a missing `hs` fails harmlessly.

**Dependency:** [Hammerspoon](https://www.hammerspoon.org/), installed manually
(I don't use Homebrew casks). Open it once and grant it Accessibility in
System Settings.

Symlink the config (backing up any existing `init.lua` first):

```sh
mkdir -p ~/.hammerspoon
[ -e ~/.hammerspoon/init.lua ] && [ ! -L ~/.hammerspoon/init.lua ] && \
  mv ~/.hammerspoon/init.lua ~/.hammerspoon/init.lua.backup
ln -sfn $PWD/hammerspoon/init.lua ~/.hammerspoon/init.lua
```

Reload Hammerspoon (menu bar → **Reload Config**, or relaunch the app). On load,
`init.lua` runs `hs.ipc.cliInstall("/opt/homebrew")`, which installs the `hs`
command-line tool to `/opt/homebrew/bin/hs` (Apple Silicon) so Karabiner can call
it. On an Intel Mac, use the default prefix (`hs.ipc.cliInstall()` →
`/usr/local/bin/hs`) and update the Karabiner snippets below to match.

> Hammerspoon must be **running** for the `hs` calls to work — keep it as a login
> item.

#### Karabiner wiring

These calls are already wired into this repo's config, in the
"Colemak Vim Navigation: Activate via Left Shift + Space" rule — in both
`karabiner/karabiner.json` (the live config Karabiner serves) and
`karabiner/assets/complex_modifications/colemak_vimish_navigation.json` (the
importable asset). For reference, the added `shell_command` events are:

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

The badge draws `hammerspoon/vim-indicator.png` if present (use a light/white glyph
so it reads on the dark badge); if the file is missing, `init.lua` falls back to a
bold "V". Appearance (size, margin, background) is configurable via constants at
the top of `init.lua`.

## Useful Links

- [StackOverflow about ln command flags](https://superuser.com/a/938865)
- [Karabiner issue on the symlinking solution](https://github.com/tekezo/Karabiner-Elements/issues/597#issuecomment-282760186)
- [Hammerspoon documentation](https://www.hammerspoon.org/docs/)

---

- [Old Medium article where I probably found the repo I forked](https://medium.com/@caulfieldOwen/turn-your-keyboard-into-a-text-editing-rocket-1514d8474d2d)
