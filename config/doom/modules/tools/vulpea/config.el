;;; tools/vulpea/config.el -*- lexical-binding: t; -*-

;; vulpea v2 configuration - standalone, no org-roam dependency

(use-package! vulpea
  :demand t
  :init
  ;; Sync directories (your org-roam directory)
  (setq vulpea-db-sync-directories '("~/org-roam/"))

  ;; Inbox file for quick captures
  (defvar vulpea-capture-inbox-file
    (expand-file-name (format "inbox-%s.org" (system-name)) "~/org-roam/")
    "The path to the inbox file.")

  (after! org
    (unless org-default-notes-file
      (setq org-default-notes-file vulpea-capture-inbox-file)))

  ;; Exclude 'active' tag from inheritance (auto-managed for agenda)
  (after! org
    (add-to-list 'org-tags-exclude-from-inheritance "active"))

  :config
  ;; Enable autosync mode for background updates
  (vulpea-db-autosync-mode +1)

  ;; Enable @mention expansion in captures
  (add-hook 'org-capture-before-finalize-hook #'vulpea-capture-expand-mentions)

  ;; Capture templates - must run AFTER Doom's +org-init-capture-defaults-h
  ;; Using depth 100 ensures this runs after Doom's org-load-hook additions
  (add-hook! 'org-load-hook :depth 100
    (defun +vulpea-init-capture-templates-h ()
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
               :clock-resume t))))))

;; Consult integration for better fuzzy search and preview
(use-package! consult-vulpea
  :after vulpea
  :config
  (consult-vulpea-mode 1))

;; Note: vulpea-journal is a v2 feature, not yet available

;; Quick insert for people (filtered vulpea-insert)
(defun vulpea-insert-person ()
  "Insert a link to a person note with completion."
  (interactive)
  (vulpea-insert :filter-fn (lambda (note)
                              (let ((tags (vulpea-note-tags note)))
                                (or (member "people" tags)
                                    (seq-find (lambda (tag) (string-prefix-p "@" tag)) tags))))))

;; Keybindings - mirror old org-roam bindings under SPC n r
(map! :leader
      (:prefix ("n" . "notes")
       (:prefix ("r" . "roam")
        :desc "Find note" "f" #'vulpea-find
        :desc "Grep notes" "g" #'consult-vulpea-grep
        :desc "Insert link" "i" #'vulpea-insert
        :desc "Insert person" "p" #'vulpea-insert-person
        :desc "Find backlink" "b" #'vulpea-find-backlink
        :desc "Add tag" "a" #'vulpea-buffer-tags-add
        :desc "Remove tag" "d" #'vulpea-buffer-tags-remove
        :desc "Sync database" "s" #'vulpea-db-sync-full-scan)))

;; Insert-mode keybinding for quick person insertion while typing
(map! :map org-mode-map
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
