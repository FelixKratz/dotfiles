;;; tools/vulpea/config.el -*- lexical-binding: t; -*-

;; vulpea v2 configuration - standalone, no org-roam dependency

(use-package! vulpea
  :demand t
  :init
  ;; Default to work context
  (setq vulpea-db-sync-directories '("~/org-roam/")
        vulpea-db-location (expand-file-name "~/.config/vulpea/work.db"))

  ;; Inbox file for quick captures
  (defvar vulpea-capture-inbox-file
    (expand-file-name "inbox.org" "~/org-roam/")
    "The path to the inbox file.")

  (after! org
    (unless org-default-notes-file
      (setq org-default-notes-file vulpea-capture-inbox-file)))

  ;; Exclude 'active' tag from inheritance (auto-managed for agenda)
  (after! org
    (add-to-list 'org-tags-exclude-from-inheritance "active"))

  :config
  ;; Scan all files when autosync is enabled (needed after db clear/creation)
  ;; Options: nil (skip), 'async (background), 'blocking (wait)
  (setq vulpea-db-sync-scan-on-enable 'blocking)
  ;; Enable autosync mode for background updates
  (vulpea-db-autosync-mode +1)

  ;; Enable @mention expansion in captures
  (add-hook 'org-capture-before-finalize-hook #'vulpea-capture-expand-mentions))

;; vulpea note creation template
;; Note: vulpea adds #+title: automatically, :head is for additional content
(after! vulpea
  ;; Set default directory for new notes (first sync directory)
  (setq vulpea-default-notes-directory (car vulpea-db-sync-directories))
  (setq vulpea-create-default-template
        '(:file-name "${timestamp}-${slug}.org"
          :head "#+filetags:\n")))

;; Capture templates - defined outside use-package to avoid timing issues
(after! (:all vulpea org)
  (setq org-capture-templates
        '(("t" "todo" entry (file vulpea-capture-inbox-file)
           "* TODO %?\n%U\n" :clock-in t :clock-resume t)
          ("T" "todo with project" entry
           (function vulpea-capture-project-task-target)
           "* TODO %?\n%U\n" :clock-in t :clock-resume t)
          ("m" "Meeting" entry
           (function vulpea-capture-meeting-target)
           (function vulpea-capture-meeting-template)
           :clock-in t
           :clock-resume t)
          ("r" "Review" plain
           (function sf/capture-review-target)
           (function sf/capture-review-template)
           :unnarrowed t))))

;; Review capture: prompt for title, create file in reviews/
(defvar sf/capture-review--title nil
  "Stores the review title for template use.")

(defun sf/capture-review-target ()
  "Return path for new review note, prompting for title."
  (setq sf/capture-review--title (read-string "Review title: "))
  (let* ((slug (concat (format-time-string "%Y-%m-")
                       (replace-regexp-in-string
                        "[^a-z0-9]+" "-"
                        (downcase sf/capture-review--title))))
         (dir (expand-file-name "reviews/" (car vulpea-db-sync-directories))))
    (make-directory dir t)
    (set-buffer (org-capture-target-buffer
                 (expand-file-name (concat slug ".org") dir)))
    (goto-char (point-max))))

(defun sf/capture-review-template ()
  "Return template for review capture."
  (concat "#+title: " sf/capture-review--title "\n"
          "#+filetags: :review:\n\n"
          "%?"))

;; Consult integration for better fuzzy search and preview
(use-package! consult-vulpea
  :after vulpea
  :config
  (consult-vulpea-mode 1))

;;; === Dual context: Work / Private ===

(defvar sf/vulpea-context 'work
  "Current vulpea context: 'work or 'private.")

(defvar sf/vulpea-work-config
  '(:directories ("~/org-roam/")
    :db "~/.config/vulpea/work.db"
    :inbox "~/org-roam/inbox.org")
  "Configuration for work notes.")

(defvar sf/vulpea-private-config
  '(:directories ("~/private/notes/")
    :db "~/.config/vulpea/private.db"
    :inbox "~/private/notes/inbox.org")
  "Configuration for private notes.")

(defun sf/vulpea-switch-context (context)
  "Switch vulpea to CONTEXT ('work or 'private)."
  (let* ((config (if (eq context 'work)
                     sf/vulpea-work-config
                   sf/vulpea-private-config))
         (dirs (plist-get config :directories))
         (db (plist-get config :db))
         (inbox (plist-get config :inbox)))
    ;; Stop autosync and close db connection before switching
    (when vulpea-db-autosync-mode
      (vulpea-db-autosync-mode -1))
    (vulpea-db-close)
    ;; Update settings for new context
    (setq sf/vulpea-context context
          vulpea-db-sync-directories dirs
          vulpea-db-location (expand-file-name db)
          vulpea-capture-inbox-file (expand-file-name inbox)
          vulpea-default-notes-directory (car dirs))
    ;; Restart autosync (will scan if db empty due to scan-on-enable)
    (vulpea-db-autosync-mode +1)
    (message "Switched to %s notes" context)))

(defun sf/vulpea-work ()
  "Switch to work notes."
  (interactive)
  (sf/vulpea-switch-context 'work))

(defun sf/vulpea-private ()
  "Switch to private notes."
  (interactive)
  (sf/vulpea-switch-context 'private))

;;; === Private diary (daily files) ===

(defvar sf/diary-directory "~/private/journal/"
  "Directory for diary entries.")

(defun sf/diary-file-for-date (&optional date)
  "Return diary file path for DATE (default today)."
  (let* ((time (or date (current-time)))
         (dir (expand-file-name
               (format-time-string "%Y/%m/" time)
               sf/diary-directory))
         (file (format-time-string "%Y-%m-%d.org" time)))
    (concat dir file)))

(defun sf/diary (&optional date)
  "Open diary for DATE (default today).
Creates file with template if it doesn't exist."
  (interactive)
  (let* ((time (or date (current-time)))
         (file (sf/diary-file-for-date time))
         (dir (file-name-directory file))
         (exists (file-exists-p file)))
    (make-directory dir t)
    (find-file file)
    (unless exists
      (insert (format-time-string "#+title: %Y-%m-%d %A\n#+filetags: :diary:\n\n* " time))
      (goto-char (point-max)))))

(defun sf/diary-yesterday ()
  "Open yesterday's diary entry."
  (interactive)
  (sf/diary (time-subtract (current-time) (days-to-time 1))))

(defun sf/diary-calendar ()
  "Open diary entry for date selected from calendar."
  (interactive)
  (let ((date (org-read-date nil t nil "Diary date: ")))
    (sf/diary date)))

;;; === Keybindings ===

;; Quick insert for people (filtered vulpea-insert)
(defun vulpea-insert-person ()
  "Insert a link to a person note with completion."
  (interactive)
  (vulpea-insert :filter-fn (lambda (note)
                              (let ((tags (vulpea-note-tags note)))
                                (or (member "people" tags)
                                    (seq-find (lambda (tag) (string-prefix-p "@" tag)) tags))))))

;; Insert-mode keybinding for quick person insertion while typing
(map! :after vulpea
      :map org-mode-map
      :i "C-c @" #'vulpea-insert-person)

;; Agenda configuration
(defvar vulpea-agenda-main-buffer-name "*agenda:main*"
  "Name of the main agenda buffer.")

(defvar vulpea-agenda-hide-scheduled-and-waiting-next-tasks t
  "Non-nil means to hide scheduled and waiting tasks.")

(defconst vulpea-agenda-cmd-refile
  '(tags
    "REFILE"
    ((org-agenda-overriding-header "To refile")
     (org-tags-match-list-sublevels nil))))

(defconst vulpea-agenda-cmd-today
  '(agenda
    ""
    ((org-agenda-start-day nil)
     (org-agenda-span 'day)
     (org-agenda-skip-deadline-prewarning-if-scheduled t)
     (org-agenda-sorting-strategy '(habit-down
                                    time-up
                                    category-keep
                                    todo-state-down
                                    priority-down)))))

(defconst vulpea-agenda-cmd-focus
  '(tags-todo
    "FOCUS"
    ((org-agenda-overriding-header
      (concat "To focus on"
              (if vulpea-agenda-hide-scheduled-and-waiting-next-tasks
                  ""
                " (including WAITING and SCHEDULED tasks)")))
     (org-agenda-skip-function 'vulpea-agenda-skip-habits)
     (org-tags-match-list-sublevels t)
     (org-agenda-todo-ignore-scheduled
      vulpea-agenda-hide-scheduled-and-waiting-next-tasks)
     (org-agenda-todo-ignore-deadlines
      vulpea-agenda-hide-scheduled-and-waiting-next-tasks)
     (org-agenda-todo-ignore-with-date
      vulpea-agenda-hide-scheduled-and-waiting-next-tasks)
     (org-agenda-tags-todo-honor-ignore-options t)
     (org-agenda-sorting-strategy
      '(todo-state-down priority-down effort-up category-keep)))))

(defconst vulpea-agenda-cmd-stuck-projects
  '(tags-todo
    "PROJECT-CANCELLED-HOLD/!"
    ((org-agenda-overriding-header "Stuck Projects")
     (org-agenda-skip-function 'vulpea-agenda-skip-non-stuck-projects)
     (org-agenda-sorting-strategy
      '(todo-state-down priority-down effort-up category-keep)))))

(defconst vulpea-agenda-cmd-projects
  '(tags-todo
    "PROJECT-HOLD"
    ((org-agenda-overriding-header (concat "Projects"))
     (org-tags-match-list-sublevels t)
     (org-agenda-skip-function 'vulpea-agenda-skip-non-projects)
     (org-agenda-tags-todo-honor-ignore-options t)
     (org-agenda-sorting-strategy
      '(todo-state-down priority-down effort-up category-keep)))))

(defconst vulpea-agenda-cmd-waiting
  '(tags-todo
    "-CANCELLED+WAITING-READING-FOCUS|+HOLD/!"
    ((org-agenda-overriding-header
      (concat "Waiting and Postponed Tasks"
              (if vulpea-agenda-hide-scheduled-and-waiting-next-tasks
                  ""
                " (including WAITING and SCHEDULED tasks)")))
     (org-agenda-skip-function 'vulpea-agenda-skip-non-tasks)
     (org-tags-match-list-sublevels nil)
     (org-agenda-todo-ignore-scheduled
      vulpea-agenda-hide-scheduled-and-waiting-next-tasks)
     (org-agenda-todo-ignore-deadlines
      vulpea-agenda-hide-scheduled-and-waiting-next-tasks))))
