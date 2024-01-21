# dotfiles
My macOS configuration files.
<img width="1512" alt="Screenshot 2023-02-23 at 20 45 12" src="https://user-images.githubusercontent.com/22680421/221013836-9c06a95a-d33b-48d0-bf1e-ae72e78eb6a1.png">





jklö centric navigation and vim moves for my german keyboard.
nvim as a capable C/C++ debugging environment.
color scheme consistency across all configurations.

* [SketchyBar](https://github.com/FelixKratz/SketchyBar)
* [JankyBorders](https://github.com/FelixKratz/JankyBorders)
* [SketchyVim](https://github.com/FelixKratz/SketchyVim)
* [yabai](https://github.com/koekeishiya/yabai) (personal fork)
* [skhd](https://github.com/koekeishiya/skhd)
* [neovim](https://github.com/neovim/neovim)
* [nnn](https://github.com/jarun/nnn) (personal fork)

Most setup steps are in `.install.sh`

SketchyBar Setup
----------------------
* Dependencies(`sf-symbols`, `jq`, `github-cli`, `switchaudio-osx`, [sketchybar-app-font](https://github.com/kvndrsslr/sketchybar-app-font)):
```bash
brew install --cask sf-symbols
brew install jq
brew install gh
brew install switchaudio-osx
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v1.0.23/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf
```
* (optional) `gh auth login` for GitHub notifications
* (optional) If you don't use yabai you can safely remove the `yabai` item from `items/yabai.sh` or `sketchybarrc`
* (optional; needed for yabai window state) yabai event:
```bash
yabai -m signal --add event=window_focused action="sketchybar --trigger window_focus"
```
* (optional; needed for yabai window state) skhd shortcuts should trigger the sketchybar event, e.g.:
```bash
lalt - space : yabai -m window --toggle float; sketchybar --trigger window_focus
shift + lalt - f : yabai -m window --toggle zoom-fullscreen; sketchybar --trigger window_focus
lalt - f : yabai -m window --toggle zoom-parent; sketchybar --trigger window_focus
```
* (optional) update outdated packages after running brew commands (add to `.zshrc`):
```bash
function brew() {
  command brew "$@" 

  if [[ $* =~ "upgrade" ]] || [[ $* =~ "update" ]] || [[ $* =~ "outdated" ]]; then
    sketchybar --trigger brew_update
  fi
}
```

NOTE: The `helper` C program is included here only to show off this specific
functionality of sketchybar and is not needed generally. It provides the data
for the cpu graph. Using a `mach_helper` provides a *much*
lower overhead solution for performance sensitive tasks, since the `helper`
talks directly to sketchybar via kernel level messages.
For most tasks (including those listed above) this difference in performance
does not matter at all.

neovim setup
---------------
* Paste my `.confg/nvim/` folder
* My remappings are in `.config/nvim/lua/mappings.lua`, you can change or remove them freely.
* (optional) Install font and set it as the terminal font:
```bash
git clone git@github.com:shaunsingh/SFMono-Nerd-Font-Ligaturized.git /tmp/SFMono_Nerd_Font
mv /tmp/SFMono_Nerd_Font/* $HOME/Library/Fonts
rm -rf /tmp/SFMono_Nerd_Font/
```
