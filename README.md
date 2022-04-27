# dotfiles
My macOS configuration files.
![Screen Shot 2022-03-30 at 16 44 37](https://user-images.githubusercontent.com/22680421/160863687-d7ba7ef5-4001-452d-810d-36e99a75d372.png)

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
* Works only with sketchybar v2.4.3+
* Remove the MeetingBar alias if you don't use this app
* If you don't use yabai you can safely remove the `yabai` item from system.sh
* (optional) yabai events (v4.0.0 required):
```bash
yabai -m signal --add event=window_focused action="sketchybar --trigger window_focus"
```
* (optional) skhd shortcuts should trigger the sketchybar events, e.g.:
```bash
lalt - space : yabai -m window --toggle float; sketchybar --trigger window_focus
shift + lalt - f : yabai -m window --toggle zoom-fullscreen; sketchybar --trigger monocle
lalt - f : yabai -m window --toggle zoom-parent; sketchybar --trigger monocle
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
git clone https://github.com/NvChad/NvChad ~/.config/nvim
cd ~/.config/nvim && git checkout 1c8a677024179b966ba2ab420e6edbe8dfda146b
```
(*): This is only temporary till I fix the configuration for the newest upstream version
* Paste my .confg/nvim/lua/custom folder
* Run PackerSync
```bash
nvim +PackerSync
```
* My remappings are in .config/nvim/lua/custom/init.lua and .config/nvim/lua/custom/chadrc.lua, you can change them freely.
* (optional) Install font and set it as the terminal font:
```bash
git clone git@github.com:shaunsingh/SFMono-Nerd-Font-Ligaturized.git /tmp/SFMono_Nerd_Font
mv /tmp/SFMono_Nerd_Font/* $HOME/Library/Fonts
rm -rf /tmp/SFMono_Nerd_Font/
```
