# dotfiles
My macOS configuration files.
<img width="1512" alt="Screenshot 2023-02-23 at 20 45 12" src="https://user-images.githubusercontent.com/22680421/221013836-9c06a95a-d33b-48d0-bf1e-ae72e78eb6a1.png">





jklö centric navigation and vim moves for my german keyboard.
nvim as a capable C/C++ debugging environment.
color scheme consistency across all configurations.

* [sketchybar](https://github.com/FelixKratz/SketchyBar)
* [yabai](https://github.com/koekeishiya/yabai) (personal fork)
* [skhd](https://github.com/koekeishiya/skhd)
* [neovim](https://github.com/neovim/neovim)
* [nnn](https://github.com/jarun/nnn) (personal fork)

Most setup steps are in `.install.sh`

SketchyBar Features:
----------------------

* I am using the excellent [sketchybar-app-font](https://github.com/kvndrsslr/sketchybar-app-font) to display the active applications in the spaces.

* Left clicking a space will focus it, right clicking a space will destroy that space; clicking in the separator (>) will create a new space (all using yabai SIP disabled; optional)

* Mousing over the music icon in the center gives a small Spotify player widget with player controls:
<img width="381" alt="spotify" src="https://user-images.githubusercontent.com/22680421/211197221-a3d6f8dd-4a72-4cc1-9224-78c1e7ebbb75.png">


* The volume icon on the right side can be clicked to toggle the volume slider and animates volume changes:

https://user-images.githubusercontent.com/22680421/211197240-632582a1-7f88-4cf2-bec7-88587112b996.mp4

* The volume icon on the right side can be right-clicked to show and select the audio output device:
![Screenshot 2022-12-11 at 12 46 48](https://user-images.githubusercontent.com/22680421/206901837-f4f8793e-ba0f-465b-b3a5-72d4fea17de4.png)

* The bell can be hovered to view github notifications

* Clicking the date/time toggles a "zen" mode, hiding all distracting items in the bar:
<img width="1512" alt="Screenshot 2022-11-11 at 18 01 32" src="https://user-images.githubusercontent.com/22680421/201391668-c4282435-9866-491d-a007-398942abdfb9.png">

* The battery indicator is only shown when below 60%:
<img width="552" alt="battery" src="https://user-images.githubusercontent.com/22680421/211197318-6b6b5164-3fa9-44a1-856b-391c3b233fe2.png">

SketchyBar Setup
----------------------
* Dependencies(`sf-symbols`, `jq`, `github-cli`, `switchaudio-osx`, [sketchybar-app-font](https://github.com/kvndrsslr/sketchybar-app-font)):
```bash
brew install --cask sf-symbols
brew install jq
brew install gh
brew install switchaudio-osx
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v1.0.16/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf
```
* (optional) `gh auth login` for GitHub notifications
* (optional) If you don't use yabai you can safely remove the `yabai` item from `items/yabai.sh` or `sketchybarrc`
* (optional; needed for yabai window state and running application icons) yabai events:
```bash
yabai -m signal --add event=window_focused action="sketchybar --trigger window_focus"
yabai -m signal --add event=window_created action="sketchybar --trigger windows_on_spaces"
yabai -m signal --add event=window_destroyed action="sketchybar --trigger windows_on_spaces"
```
* (optional; needed for yabai window state and running application icons) skhd shortcuts should trigger the sketchybar events, e.g.:
```bash
lalt - space : yabai -m window --toggle float; sketchybar --trigger window_focus
shift + lalt - f : yabai -m window --toggle zoom-fullscreen; sketchybar --trigger window_focus
lalt - f : yabai -m window --toggle zoom-parent; sketchybar --trigger window_focus
shift + lalt - 1 : yabai -m window --space 1 && sketchybar --trigger windows_on_spaces
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
