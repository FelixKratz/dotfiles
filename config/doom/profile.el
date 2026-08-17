;;; profile.el -*- lexical-binding: t; -*-
;;
;; Which dotfiles profile this machine was installed with. link.sh writes the
;; marker file; where it is absent (machines linked before it existed) we assume
;; the full desktop config, so nothing disappears from an existing setup.
;;
;; Loaded from init.el and from the packages block of config.org, so the module
;; list and the package list always agree on the profile.

(defvar sf/doom-full
  (let ((marker (expand-file-name
                 "dotfiles/profile"
                 (or (getenv "XDG_CACHE_HOME") (expand-file-name "~/.cache")))))
    (not (and (file-readable-p marker)
              (with-temp-buffer
                (insert-file-contents marker)
                (string-match-p "\\`[ \t\n]*minimal[ \t\n]*\\'" (buffer-string))))))
  "Non-nil unless this machine was installed with `./install.sh --minimal'.
Minimal machines are headless servers: they get Emacs for magit and file
editing, but no org-mode, notes, mail or other desktop-only modules.")
