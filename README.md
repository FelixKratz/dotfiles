# dotfiles
My macOS configuration files.
<img width="1512" alt="Screen Shot 2022-06-27 at 20 14 14" src="https://user-images.githubusercontent.com/22680421/176008523-9fac2beb-b0a7-4995-9bbf-339abd034f09.png">


jklö centric navigation and vim moves for my german keyboard.
nvim as a capable C/C++ debugging environment.
color scheme consistency across all configurations.

* Alacritty
* Vimari
* neovim
* starship
* skhd
* nnn (personal fork)
* yabai (personal fork)
* sketchybar
* sketchyvim

Most setup steps are in `.install.sh`

SketchyBar Setup
----------------------
* Uses `sf-symbols`: `brew install --cask sf-symbols`
* Uses `jq`: `brew install jq`
* Uses `ifstat`: `brew install ifstat`
* Uses `github-cli`: `brew install gh` (`gh auth login` for notifications)
* Remove the MeetingBar alias if you don't use this app
* Animations and some mouse events will only work correctly for sketchybar > v2.6.0
* If you don't use yabai you can safely remove the `yabai` item from system.sh
* (optional) yabai events:
```bash
yabai -m signal --add event=window_focused action="sketchybar --trigger window_focus"
```
* (optional) skhd shortcuts should trigger the sketchybar events, e.g.:
```bash
lalt - space : yabai -m window --toggle float; sketchybar --trigger window_focus
shift + lalt - f : yabai -m window --toggle zoom-fullscreen; sketchybar --trigger window_focus
lalt - f : yabai -m window --toggle zoom-parent; sketchybar --trigger window_focus
```
* If you use british english your `Control Center` might be called  `Control Centre` which you would need to change manually for the system.sh aliases
* Custom refresh events that react to terminal interaction need this in `~/.zshrc`:
```bash
function brew() {
  command brew "$@" 

  if [[ $* =~ "upgrade" ]] || [[ $* =~ "update" ]] || [[ $* =~ "outdated" ]]; then
    sketchybar --trigger brew_upgrade
  fi
}

function mas() {
  command mas "$@" 

  if [[ $* =~ "upgrade" ]] || [[ $* =~ "update" ]] || [[ $* =~ "outdated" ]]; then
    sketchybar --trigger brew_upgrade
  fi
}

function push() {
  command git push
  sketchybar --trigger git_push
}
```

neovim setup
---------------
* Download NVChad and checkout the last supported commit in the repo(*)
```bash
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
```
* Paste my .confg/nvim/lua/custom folder
* Run PackerSync
```bash
nvim +PackerSync
```
* My remappings are in .config/nvim/lua/custom/mappings.lua, you can change or remove them freely.
* (optional) Install font and set it as the terminal font:
```bash
git clone git@github.com:shaunsingh/SFMono-Nerd-Font-Ligaturized.git /tmp/SFMono_Nerd_Font
mv /tmp/SFMono_Nerd_Font/* $HOME/Library/Fonts
rm -rf /tmp/SFMono_Nerd_Font/
```
