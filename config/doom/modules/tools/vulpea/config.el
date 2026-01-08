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

  (unless org-default-notes-file
    (setq org-default-notes-file vulpea-capture-inbox-file))

  ;; Exclude 'project' tag from inheritance
  (add-to-list 'org-tags-exclude-from-inheritance "project")

  :config
  ;; Enable autosync mode for background updates
  (vulpea-db-autosync-mode +1)

  ;; Capture templates
  (setq org-capture-templates
        '(("t" "todo" plain (file vulpea-capture-inbox-file)
           "* TODO %?\n%U\n" :clock-in t :clock-resume t)
          ("T" "todo with project" plain
           (function vulpea-capture-project-task-target)
           "* TODO %?\n%U\n" :clock-in t :clock-resume t)
          ("m" "Meeting" entry
           (function vulpea-capture-meeting-target)
           (function vulpea-capture-meeting-template)
           :clock-in t
           :clock-resume t))))

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
