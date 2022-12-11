# dotfiles
My macOS configuration files.
<img width="1512" alt="Screenshot 2022-11-11 at 17 33 00" src="https://user-images.githubusercontent.com/22680421/201389026-20255532-8c7a-4c48-a34c-e8e3b1cb03fa.png">





jklö centric navigation and vim moves for my german keyboard.
nvim as a capable C/C++ debugging environment.
color scheme consistency across all configurations.

* neovim
* skhd
* nnn (personal fork)
* yabai (personal fork)
* sketchybar

Most setup steps are in `.install.sh`

SketchyBar Features:
----------------------

<img width="1512" alt="Screenshot 2022-11-11 at 17 33 00" src="https://user-images.githubusercontent.com/22680421/201389564-97d4cfd6-18f0-4ed5-be6a-47388d8d53c0.png">

* I am using the excellent [sketchybar-app-font](https://github.com/kvndrsslr/sketchybar-app-font) to display the active applications in the spaces. The active space animates their active applications to disappear:

https://user-images.githubusercontent.com/22680421/201390794-92b37f3a-631f-4312-bb3f-342a5c963928.mov

* Left clicking a space will focus it, right clicking a space will destroy that space; clicking in the separator (>) will create a new space (all using yabai SIP disabled)

* Mousing over the music icon in the center gives a small spotify player widget with player controls:
<img width="492" alt="Screenshot 2022-11-11 at 17 54 31" src="https://user-images.githubusercontent.com/22680421/201390348-2b3d038d-24fc-448c-b5e5-827275303295.png">

* The volume icon on the right side can be clicked to toggle mute and animates volume changes:

https://user-images.githubusercontent.com/22680421/201391279-14c89e0b-af16-4b29-b815-82da2d230863.mov

* The volume icon on the right side can be right-clicked to show and select the audio output device:
![Screenshot 2022-12-11 at 12 46 48](https://user-images.githubusercontent.com/22680421/206901837-f4f8793e-ba0f-465b-b3a5-72d4fea17de4.png)

* The bell can be hovered to view github notifications

* Clicking the date/time toggles a "zen" mode, hiding all distracting items in the bar:
<img width="1512" alt="Screenshot 2022-11-11 at 18 01 32" src="https://user-images.githubusercontent.com/22680421/201391668-c4282435-9866-491d-a007-398942abdfb9.png">


SketchyBar Setup
----------------------
* Uses `sf-symbols`: `brew install --cask sf-symbols`
* Uses `jq`: `brew install jq`
* Uses `github-cli`: `brew install gh` (`gh auth login` for notifications)
* Uses [sketchybar-app-font](https://github.com/kvndrsslr/sketchybar-app-font):
```bash
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v1.0.3/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf
```
* The volume icon is an `alias`, make sure to give screen capture permission. If your system is british, you need to rename "Control Center" to "Control Centre" in `items/volume.sh`. The volume icon should be enabled to always show in the macOS bar via System Preferences.
* If you don't use yabai you can safely remove the `yabai` item from `ìtems/front_app.sh`
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
* (optional) Uses `brew install switchaudio-osx` for audio device switching context menu on volume alias right click
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
* Paste my .confg/nvim/ folder
* Run PackerSync
```bash
nvim +PackerSync
```
* My remappings are in .config/nvim/lua/mappings.lua, you can change or remove them freely.
* (optional) Install font and set it as the terminal font:
```bash
git clone git@github.com:shaunsingh/SFMono-Nerd-Font-Ligaturized.git /tmp/SFMono_Nerd_Font
mv /tmp/SFMono_Nerd_Font/* $HOME/Library/Fonts
rm -rf /tmp/SFMono_Nerd_Font/
```
