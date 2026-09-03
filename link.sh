#!/bin/zsh

# Re-link dotfiles (safe to run multiple times, works on macOS and Linux)
#
# Usage:
#   ./link.sh
#
# What gets linked is decided by ~/.config/dotfiles/profile, which lists the
# config groups this machine runs (one per line; # comments ignored):
#
#   desktop  window manager, launcher, terminal, browser integration
#   mail     mail config and its supporting daemons
#   notes    org-roam notes (no config dirs of its own; Doom modules only)
#
# This script only ever READS that file. It used to take --full/--minimal and
# write the answer as a side effect, which meant relinking a desktop with
# --minimal quietly demoted it and took mail and notes out of Emacs. The
# profile is a property of the machine, so it is declared once, by hand.

CODE_DIR=$HOME/code
OS="$(uname)"
PROFILE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/profile"

if [[ ! -r "$PROFILE_FILE" ]]; then
  cat >&2 <<EOF
link.sh: no profile at $PROFILE_FILE

Declare what this machine runs before linking, one group per line:

  mkdir -p ${PROFILE_FILE:h}
  cat > $PROFILE_FILE <<'PROFILE'
  desktop
  mail
  notes
  PROFILE

A machine that declares nothing still gets the shell, editors and CLI tools.
See docs/profiles.md.
EOF
  exit 1
fi

# Strip comments and blanks; anything left is a group name.
typeset -a GROUPS
GROUPS=(${(f)"$(sed -e 's/#.*//' -e 's/[[:space:]]//g' $PROFILE_FILE | grep -v '^$')"})
echo "Profile: ${GROUPS:-(none)}"

# macOS ln uses -h, GNU ln uses -n to avoid following existing symlinks
[[ "$OS" == "Darwin" ]] && LN_FLAG="-sfh" || LN_FLAG="-sfn"

# Configs owned by a group. Anything not listed here is linked on every
# machine — `doom` included, since Emacs is there for magit and file editing on
# servers too, and gates its own optional modules on the same profile file.
typeset -A CONFIG_GROUP
CONFIG_GROUP=(
  aerospace      desktop
  alfred         desktop
  kitty          desktop
  sketchybar     desktop
  svim           desktop
  github-copilot desktop
  email          mail
  doom-private   mail
  goimapnotify   mail
  oauth2ms       mail
)

mkdir -p $HOME/.config
[[ "$OS" == "Darwin" ]] && mkdir -p $HOME/Library/LaunchAgents
typeset -a CODEX_GUIDANCE

for dir in $CODE_DIR/dotfiles*; do
  if [ -d $dir/config ]; then
    for file in $dir/config/*; do
      name="$(basename $file)"

      # Skip configs owned by a group this machine has not declared
      owner="${CONFIG_GROUP[$name]:-}"
      if [[ -n "$owner" ]] && (( ! ${GROUPS[(Ie)$owner]} )); then
        echo "Skipped $name (no '$owner' group)"
        continue
      fi

      case "$name" in
        claude)
          # Claude Code config: only link shareable config, not runtime state
          # Runtime state (history.jsonl, cache/, projects/, etc.) stays local
          mkdir -p $HOME/.claude
          for entry in CLAUDE.md settings.json; do
            cf="$file/$entry"
            [ -e "$cf" ] || continue
            ln $LN_FLAG $cf $HOME/.claude/
            echo "Linked $cf → ~/.claude/$entry"
          done
          # Link agents/commands/skills entry-by-entry so both dotfiles and
          # dotfiles_private can contribute, and locally-installed skills (e.g.
          # humanizer) survive. Replace any legacy whole-dir symlink.
          for subdir in agents commands skills; do
            sd="$file/$subdir"
            [ -d "$sd" ] || continue
            [ -L "$HOME/.claude/$subdir" ] && rm "$HOME/.claude/$subdir"
            mkdir -p "$HOME/.claude/$subdir"
            for f in $sd/*; do
              [ -e "$f" ] || continue
              ln $LN_FLAG "$f" "$HOME/.claude/$subdir/"
              echo "Linked $f → ~/.claude/$subdir/$(basename $f)"
            done
          done

          # Antigravity (AGY) config sync: link rules, skills, agents, commands
          mkdir -p $HOME/.gemini/antigravity-cli/rules $HOME/.gemini/antigravity-cli/skills
          if [ -e "$file/CLAUDE.md" ]; then
            ln $LN_FLAG "$file/CLAUDE.md" $HOME/.gemini/antigravity-cli/rules/global_rules.md
            echo "Linked $file/CLAUDE.md → ~/.gemini/antigravity-cli/rules/global_rules.md"
          fi
          if [ -d "$file/skills" ]; then
            for sk in "$file/skills"/*; do
              [ -e "$sk" ] || continue
              ln $LN_FLAG "$sk" $HOME/.gemini/antigravity-cli/skills/
              echo "Linked $sk → ~/.gemini/antigravity-cli/skills/$(basename $sk)"
            done
          fi
          if [ -d "$file/agents" ]; then
            for ag in "$file/agents"/*; do
              [ -e "$ag" ] || continue
              ag_name="$(basename "$ag" .md)"
              mkdir -p "$HOME/.gemini/antigravity-cli/skills/$ag_name"
              ln $LN_FLAG "$ag" "$HOME/.gemini/antigravity-cli/skills/$ag_name/SKILL.md"
              echo "Linked $ag → ~/.gemini/antigravity-cli/skills/$ag_name/SKILL.md"
            done
          fi
          if [ -d "$file/commands" ]; then
            for cmd in "$file/commands"/*; do
              [ -e "$cmd" ] || continue
              cmd_name="$(basename "$cmd" .md)"
              mkdir -p "$HOME/.gemini/antigravity-cli/skills/$cmd_name"
              ln $LN_FLAG "$cmd" "$HOME/.gemini/antigravity-cli/skills/$cmd_name/SKILL.md"
              echo "Linked $cmd → ~/.gemini/antigravity-cli/skills/$cmd_name/SKILL.md"
            done
          fi
          ;;
        codex)
          # Codex: combine public and private guidance in source order, then link
          # user-created skills. Runtime state (auth, history, caches, databases,
          # and bundled skills) stays local.
          mkdir -p "$HOME/.codex/skills"
          [ -f "$file/AGENTS.md" ] && CODEX_GUIDANCE+=("$file/AGENTS.md")
          if [ -d "$file/skills" ]; then
            for skill in "$file/skills"/*; do
              [ -e "$skill" ] || continue
              ln $LN_FLAG "$skill" "$HOME/.codex/skills/"
              echo "Linked $skill → ~/.codex/skills/$(basename "$skill")"
            done
          fi
          if [ -d "$file/prompts" ]; then
            # Codex exposes ~/.codex/prompts/<name>.md as the slash command /<name>.
            mkdir -p "$HOME/.codex/prompts"
            for prompt in "$file/prompts"/*.md; do
              [ -e "$prompt" ] || continue
              ln $LN_FLAG "$prompt" "$HOME/.codex/prompts/"
              echo "Linked $prompt → ~/.codex/prompts/$(basename "$prompt")"
            done
          fi
          if [ -f "$file/hooks.json" ]; then
            ln $LN_FLAG "$file/hooks.json" "$HOME/.codex/hooks.json"
            echo "Linked $file/hooks.json → ~/.codex/hooks.json"
          fi
          if [ -d "$file/hooks" ]; then
            mkdir -p "$HOME/.codex/hooks"
            for hook in "$file/hooks"/*; do
              [ -e "$hook" ] || continue
              ln $LN_FLAG "$hook" "$HOME/.codex/hooks/"
              echo "Linked $hook → ~/.codex/hooks/$(basename "$hook")"
            done
          fi
          ;;
        antigravity)
          # Antigravity CLI config: link settings, rules, skills, subagents
          mkdir -p $HOME/.gemini/antigravity-cli
          for entry in settings.json; do
            cf="$file/$entry"
            [ -e "$cf" ] || continue
            ln $LN_FLAG $cf $HOME/.gemini/antigravity-cli/
            echo "Linked $cf → ~/.gemini/antigravity-cli/$entry"
          done
          for subdir in rules subagents skills; do
            sd="$file/$subdir"
            [ -d "$sd" ] || continue
            mkdir -p "$HOME/.gemini/antigravity-cli/$subdir"
            for f in $sd/*; do
              [ -e "$f" ] || continue
              ln $LN_FLAG "$f" "$HOME/.gemini/antigravity-cli/$subdir/"
              echo "Linked $f → ~/.gemini/antigravity-cli/$subdir/$(basename $f)"
            done
          done
          ;;
        email|doom-private)
          # These configs are split across dotfiles and dotfiles_private:
          #   email/        — scripts/docs in public, accounts.yaml in private
          #   doom-private/ — generic elisp in public, generated/personal in private
          # Link file-by-file so both repos contribute to ~/.config/<name>/.
          [ -L "$HOME/.config/$name" ] && rm "$HOME/.config/$name"
          mkdir -p "$HOME/.config/$name"
          for f in $file/*; do
            [ -e "$f" ] || continue
            ln $LN_FLAG "$f" "$HOME/.config/$name/"
            echo "Linked $f → ~/.config/$name/$(basename $f)"
          done
          ;;
        *)
          ln $LN_FLAG $file $HOME/.config
          echo "Linked $file → ~/.config/$name"
          ;;
      esac
    done
  fi

  if [ -d $dir/root ]; then
    for file in $dir/root/*; do
      ln $LN_FLAG $file $HOME/.$(basename $file)
      echo "Linked $file → ~/.$(basename $file)"
    done
  fi

  if [[ "$OS" == "Darwin" ]] && [ -d "$dir/Application Support" ]; then
    for file in "$dir/Application Support"/*; do
      ln $LN_FLAG "$file" "$HOME/Library/Application Support"
      echo "Linked $file → ~/Library/Application Support/$(basename "$file")"
    done
  fi
done

if (( ${#CODEX_GUIDANCE[@]} )); then
  # Do not write through a legacy symlink from an earlier configuration.
  [ -L "$HOME/.codex/AGENTS.md" ] && rm "$HOME/.codex/AGENTS.md"
  {
    print "# Managed by dotfiles/link.sh; edit its source files, then re-run link.sh."
    for guidance in "${CODEX_GUIDANCE[@]}"; do
      print "\n<!-- Source: $guidance -->"
      cat "$guidance"
    done
  } > "$HOME/.codex/AGENTS.md"
  echo "Generated ~/.codex/AGENTS.md from ${#CODEX_GUIDANCE[@]} source file(s)"
fi

if [ -e "$HOME/.codex/hooks.json" ]; then
  codex_config="$HOME/.codex/config.toml"
  if [ -f "$codex_config" ]; then
    codex_config_tmp="$(mktemp "$HOME/.codex/config.toml.XXXXXX")" || exit 1
    if grep -q '^\[features\]$' "$codex_config"; then
      awk '
        /^\[features\]$/ { in_features = 1 }
        /^\[/ && $0 != "[features]" { in_features = 0 }
        in_features && /^hooks = / { next }
        { print }
        /^\[features\]$/ { print "hooks = true" }
      ' "$codex_config" > "$codex_config_tmp" && mv "$codex_config_tmp" "$codex_config"
    else
      cp "$codex_config" "$codex_config_tmp"
      print '\n[features]\nhooks = true' >> "$codex_config_tmp"
      mv "$codex_config_tmp" "$codex_config"
    fi
  else
    print '[features]\nhooks = true' > "$codex_config"
  fi
  echo "Enabled Codex lifecycle hooks"
fi

if [[ "$OS" == "Darwin" ]]; then
  mkdir -p $HOME/Library/LaunchAgents
  for file in $CODE_DIR/dotfiles/launchagents/*; do
    dest=$HOME/Library/LaunchAgents/$(basename $file)
    # Plists can't expand $HOME at runtime, so we substitute it at install
    # time. Remove any legacy symlink first to avoid writing through it
    # back into the repo.
    [ -L "$dest" ] && rm "$dest"
    sed "s|__HOME__|$HOME|g" "$file" > "$dest"
    echo "Generated $dest"
  done
fi

# systemd user timers (the Linux analogue of the launchd agents above). Units
# reference %h, so they can be symlinked straight from the repo — no $HOME
# substitution needed.
if [[ "$OS" == "Linux" ]] && command -v systemctl >/dev/null 2>&1; then
  mkdir -p $HOME/.config/systemd/user
  for file in $CODE_DIR/dotfiles/systemd/*; do
    ln $LN_FLAG $file $HOME/.config/systemd/user/
    echo "Linked $file → ~/.config/systemd/user/$(basename $file)"
  done
  systemctl --user daemon-reload 2>/dev/null
  # Enable the org-roam sync timer where the machine runs notes and the repo is
  # actually present. The repo check alone is not enough: a clone can outlive
  # the decision that the machine should be syncing it.
  if (( ${GROUPS[(Ie)notes]} )) && [ -d "$HOME/org-roam/.git" ]; then
    systemctl --user enable --now org-roam-sync.timer 2>/dev/null && \
      echo "Enabled org-roam-sync.timer"
  fi
  systemctl --user enable --now nudge-check.timer 2>/dev/null && \
    echo "Enabled nudge-check.timer"
fi

# Link scripts to ~/.local/bin. dotfiles-private is the companion repo for
# anything that should not be published; it is optional, so a machine without
# it links the public scripts and carries on.
mkdir -p ~/.local/bin ~/.msmtpq
for dir in $CODE_DIR/dotfiles/bin $CODE_DIR/dotfiles-private/bin; do
  [ -d "$dir" ] || continue
  for file in $dir/*; do
    [ -e "$file" ] || continue
    ln $LN_FLAG $file ~/.local/bin/
    echo "Linked $file → ~/.local/bin/$(basename $file)"
  done
done

echo "\nDone."
echo "Run 'doom sync' if Emacs config changed."
