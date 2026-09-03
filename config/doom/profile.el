;;; profile.el -*- lexical-binding: t; -*-
;;
;; Which optional config groups this machine runs.
;;
;; Declared in ~/.config/dotfiles/profile: one group per line, blank lines and
;; `#' comments ignored. The file is hand-written and read-only as far as the
;; dotfiles are concerned — `link.sh' reads it and never writes it, so no
;; ordinary command can silently change what a machine is. (An earlier design
;; had `./link.sh --minimal' rewrite the marker as a side effect, which turned
;; a routine relink of a desktop into a mail-and-notes outage.)
;;
;; Groups:
;;   desktop  window manager, launcher, terminal, PDF, notebooks, writing tools
;;   mail     notmuch, the mail config, and its supporting daemons
;;   notes    org-mode, org-roam/vulpea, bibliography
;;
;; Loaded from init.el and from the packages block of config.org, so the module
;; list and the package list always agree.

(defvar sf/doom-profile-file
  (expand-file-name "dotfiles/profile"
                    (or (getenv "XDG_CONFIG_HOME") (expand-file-name "~/.config")))
  "File declaring which config groups this machine runs.")

(defvar sf/doom-groups
  (if (file-readable-p sf/doom-profile-file)
      (with-temp-buffer
        (insert-file-contents sf/doom-profile-file)
        (let (groups)
          (dolist (line (split-string (buffer-string) "\n"))
            (let ((entry (string-trim (replace-regexp-in-string "#.*" "" line))))
              (unless (string-empty-p entry)
                (push (intern entry) groups))))
          (nreverse groups)))
    ;; Fail closed rather than guessing: a machine that loads mail modules it
    ;; has no binaries for is worse than one that loads none. The warning is
    ;; what makes the difference from silence.
    (warn "No dotfiles profile at %s — no optional groups enabled. See docs/profiles.md"
          sf/doom-profile-file)
    nil)
  "List of config groups enabled on this machine, e.g. (desktop mail notes).")

(defun sf/doom-group-p (group)
  "Return non-nil if GROUP is enabled on this machine."
  (memq group sf/doom-groups))

(defvar sf/doom-full (sf/doom-group-p 'desktop)
  "Non-nil on machines running the `desktop' group.
Kept for gates that predate the group split and have not been sorted into a
more specific group yet.")
