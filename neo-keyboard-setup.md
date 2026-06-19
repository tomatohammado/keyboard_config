# MacBook Neo — keyboard_config setup (temporary)

> Throwaway checklist for migrating **Neo** to the renamed `keyboard_config` repo and
> adding the Hammerspoon indicator. **Delete this file once Neo is set up.**

**Assumptions** (confirmed): Neo is Apple Silicon (`arm64`), already has the old
`~/Code/karabiner_config` clone with Karabiner-Elements + Colemak-DH working, and has
**no local changes** in that repo.

---

## 0. First, on the MacBook Pro

Push the latest so Neo can pull it:

```sh
git -C ~/Code/keyboard_config push
yadm push
```

---

## On the MacBook Neo

### 1. Migrate the repo: `karabiner_config` → `keyboard_config`

```sh
# Quit Karabiner-Elements so it doesn't see its config vanish mid-move
osascript -e 'quit app "Karabiner-Elements"'

# Rename the local clone
mv ~/Code/karabiner_config ~/Code/keyboard_config

# Point the remote at the renamed GitHub repo
git -C ~/Code/keyboard_config remote set-url origin git@github.com:tomatohammado/keyboard_config.git

# Pull the latest (Hammerspoon indicator + README updates)
git -C ~/Code/keyboard_config pull --ff-only
```

### 2. Re-point the Karabiner symlink

The old symlink now dangles — this is the key fix you flagged.

```sh
ln -sfn ~/Code/keyboard_config/karabiner ~/.config/karabiner

# Verify (should NOT be dangling)
readlink ~/.config/karabiner
# -> /Users/hammad/Code/keyboard_config/karabiner
```

Reopen Karabiner-Elements. Confirm in **EventViewer** that holding Left-Shift+Space
toggles the `colemak_vim_nav` variable.

### 3. Install Hammerspoon (new on Neo)

- Download [Hammerspoon](https://www.hammerspoon.org/) (manual — no Homebrew cask) and open it once.
- Enable **"Launch Hammerspoon at login"**.
- Grant **Accessibility** (and any related) permissions in System Settings.

### 4. Symlink the Hammerspoon config

```sh
mkdir -p ~/.hammerspoon

# If an init.lua already exists, back it up first:
# mv ~/.hammerspoon/init.lua ~/.hammerspoon/init.lua.backup

ln -sfn ~/Code/keyboard_config/hammerspoon/init.lua ~/.hammerspoon/init.lua

# Verify
readlink ~/.hammerspoon/init.lua
# -> /Users/hammad/Code/keyboard_config/hammerspoon/init.lua
```

Reload Hammerspoon (menu → **Reload Config**, or relaunch). You'll see a "Ready to rock"
notification; `init.lua` auto-installs the `hs` CLI to `/opt/homebrew/bin/hs`.

### 5. Verify end-to-end

```sh
which hs               # -> /opt/homebrew/bin/hs
hs -c 'print(1+1)'     # -> 2
```

Then hold **Left-Shift+Space** → the Vim badge appears at the bottom-right of the screen;
release → it disappears.

### 6. Update yadm

```sh
yadm pull
```

Picks up the renamed `~/README.md` reference.

---

## Done — clean up

Once Neo checks out, remove this file from the repo (on the Pro):

```sh
cd ~/Code/keyboard_config
git rm neo-keyboard-setup.md
git commit -m "Remove temporary Neo setup doc"
git push
```

Neo drops it on its next `git pull`.
