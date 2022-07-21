# dotfiles
My macOS configuration files.
<img width="1512" alt="Screen Shot 2022-07-01 at 13 15 37" src="https://user-images.githubusercontent.com/22680421/176889073-28b8e61b-66b2-48eb-8b2e-0bf3840eedde.png">



jklö centric navigation and vim moves for my german keyboard.
nvim as a capable C/C++ debugging environment.
color scheme consistency across all configurations.

* neovim
* skhd
* nnn (personal fork)
* yabai (personal fork)
* sketchybar

Most setup steps are in `.install.sh`

SketchyBar Setup
----------------------
* Uses `sf-symbols`: `brew install --cask sf-symbols`
* Uses `jq`: `brew install jq`
* Uses `ifstat`: `brew install ifstat`
* Uses `github-cli`: `brew install gh` (`gh auth login` for notifications)
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
