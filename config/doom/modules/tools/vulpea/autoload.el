;;; tools/vulpea/autoload.el -*- lexical-binding: t; -*-
;;; vulpea v2 - standalone, no org-roam dependency

;;;###autoload
(defun vulpea-agenda-category (&optional len)
  "Get category of item at point for agenda.

Category is defined by one of the following items:

- CATEGORY property
- TITLE keyword
- TITLE property
- filename without directory and extension

When LEN is a number, resulting string is padded right with
spaces and then truncated with ... on the right if result is
longer than LEN.

Usage example:

  (setq org-agenda-prefix-format
        '((agenda . \" %(vulpea-agenda-category) %?-12t %12s\")))

Refer to `org-agenda-prefix-format' for more information."
  (let* ((file-name (when buffer-file-name
                      (file-name-sans-extension
                       (file-name-nondirectory buffer-file-name))))
         (title (vulpea-buffer-prop-get "title"))
         (category (org-get-category))
         (result
          (or (if (and
                   title
                   (string-equal category file-name))
                  title
                category)
              "")))
    (if (numberp len)
        (s-truncate len (s-pad-right len " " result))
      result)))

;;; --- Tag handling ---

(defun vulpea--title-to-tag (title)
  "Convert TITLE to tag."
  (concat "@" (s-replace " " "" title)))

(defun vulpea--title-as-tag ()
  "Return title of the current note as tag."
  (vulpea--title-to-tag (vulpea-buffer-title-get)))

(defun vulpea-ensure-filetag ()
  "Add respective file tag if it's missing in the current note."
  (interactive)
  (let ((tags (vulpea-buffer-tags-get))
        (tag (vulpea--title-as-tag)))
    (when (and (seq-contains-p tags "people")
               (not (seq-contains-p tags tag)))
      (vulpea-buffer-tags-add tag))))

;;;###autoload
(defun vulpea-tags-add ()
  "Add a tag to current note."
  (interactive)
  (let ((tag (completing-read "Tag: " (vulpea-db-query-tags))))
    (vulpea-buffer-tags-add tag)
    (vulpea-ensure-filetag)))

;;; --- Insert handling ---

(defun vulpea-insert-handle (note)
  "Hook to be called on NOTE after `vulpea-insert'."
  (when-let* ((title (vulpea-note-title note))
              (tags (vulpea-note-tags note)))
    (when (seq-contains-p tags "people")
      (save-excursion
        (ignore-errors
          (org-back-to-heading)
          (when (eq 'todo (org-element-property
                           :todo-type
                           (org-element-at-point)))
            (org-set-tags
             (seq-uniq
              (cons
               (vulpea--title-to-tag title)
               (org-get-tags nil t))))))))))

(add-hook 'vulpea-insert-handle-functions #'vulpea-insert-handle)

;;; --- Project handling ---

(defun vulpea-project-p ()
  "Return non-nil if current buffer has any todo entry.

TODO entries marked as done are ignored, meaning this
function returns nil if current buffer contains only completed
tasks."
  (seq-find
   (lambda (type) (eq type 'todo))
   (org-element-map
       (org-element-parse-buffer 'headline)
       'headline
     (lambda (h)
       (org-element-property :todo-type h)))))

(defun vulpea-project-update-tag ()
  "Update PROJECT tag in the current buffer."
  (when (and (not (active-minibuffer-window))
             (vulpea-buffer-p))
    (save-excursion
      (goto-char (point-min))
      (let* ((tags (vulpea-buffer-tags-get))
             (original-tags tags))
        (if (vulpea-project-p)
            (setq tags (cons "project" tags))
          (setq tags (remove "project" tags)))
        (setq tags (seq-uniq tags))
        (when (or (seq-difference tags original-tags)
                  (seq-difference original-tags tags))
          (apply #'vulpea-buffer-tags-set tags))))))

(defun vulpea-buffer-p ()
  "Return non-nil if the currently visited buffer is a vulpea note."
  (and buffer-file-name
       (seq-some
        (lambda (dir)
          (string-prefix-p
           (file-truename (file-name-as-directory (expand-file-name dir)))
           (file-truename buffer-file-name)))
        vulpea-db-sync-directories)))

(defun vulpea-project-files ()
  "Return a list of note files containing 'project' tag."
  (seq-uniq
   (seq-map
    #'vulpea-note-path
    (vulpea-db-query-by-tags-some '("project")))))

(defun vulpea-agenda-files-update (&rest _)
  "Update the value of `org-agenda-files'."
  (setq org-agenda-files (vulpea-project-files)))

(add-hook 'find-file-hook #'vulpea-project-update-tag)
(add-hook 'before-save-hook #'vulpea-project-update-tag)

(advice-add 'org-agenda :before #'vulpea-agenda-files-update)
(advice-add 'org-todo-list :before #'vulpea-agenda-files-update)

;;; --- Capture functions ---

;;;###autoload
(defun vulpea-capture-task ()
  "Capture a task to inbox."
  (interactive)
  (org-capture nil "t"))

;;;###autoload
(defun vulpea-capture-task-with-project ()
  "Capture a task with project selection."
  (interactive)
  (org-capture nil "T"))

;;;###autoload
(defun vulpea-capture-meeting ()
  "Capture a meeting."
  (interactive)
  (org-capture nil "m"))

(defun vulpea-capture-project-task-target ()
  "Return a target for a project task capture."
  (let ((project (vulpea-select
                  "Project"
                  :filter-fn
                  (lambda (note)
                    (seq-contains-p (vulpea-note-tags note) "project")))))
    (if (vulpea-note-id project)
        (let ((path (vulpea-note-path project))
              (headline "Tasks"))
          (set-buffer (org-capture-target-buffer path))
          (unless (derived-mode-p 'org-mode)
            (org-mode))
          (org-capture-put-target-region-and-position)
          (widen)
          (goto-char (point-min))
          (if (re-search-forward
               (format org-complex-heading-regexp-format
                       (regexp-quote headline))
               nil t)
              (beginning-of-line)
            (goto-char (point-max))
            (unless (bolp) (insert "\n"))
            (insert "* " headline "\n")
            (beginning-of-line 0)))
      ;; Fallback to inbox
      (let ((path vulpea-capture-inbox-file))
        (set-buffer (org-capture-target-buffer path))
        (org-capture-put-target-region-and-position)
        (widen)))))

(defun vulpea-capture-meeting-template ()
  "Return a template for a meeting capture."
  (let ((person (vulpea-select
                 "Person"
                 :filter-fn
                 (lambda (note)
                   (seq-contains-p (vulpea-note-tags note) "people")))))
    (org-capture-put :meeting-person person)
    (if (vulpea-note-id person)
        "* MEETING [%<%Y-%m-%d %a>] :REFILE:MEETING:\n%U\n\n%?"
      (concat "* MEETING with "
              (vulpea-note-title person)
              " on [%<%Y-%m-%d %a>] :MEETING:\n%U\n\n%?"))))

(defun vulpea-capture-meeting-target ()
  "Return a target for a meeting capture."
  (let ((person (org-capture-get :meeting-person)))
    (if (vulpea-note-id person)
        (let ((path (vulpea-note-path person))
              (headline "Meetings"))
          (set-buffer (org-capture-target-buffer path))
          (unless (derived-mode-p 'org-mode)
            (org-mode))
          (org-capture-put-target-region-and-position)
          (widen)
          (goto-char (point-min))
          (if (re-search-forward
               (format org-complex-heading-regexp-format
                       (regexp-quote headline))
               nil t)
              (beginning-of-line)
            (goto-char (point-max))
            (unless (bolp) (insert "\n"))
            (insert "* " headline "\n")
            (beginning-of-line 0)))
      (let ((path vulpea-capture-inbox-file))
        (set-buffer (org-capture-target-buffer path))
        (org-capture-put-target-region-and-position)
        (widen)))))

;;; --- Agenda views ---

;;;###autoload
(defun vulpea-agenda-person ()
  "Show agenda for a specific person."
  (interactive)
  (let* ((person (vulpea-select-from
                  "Person"
                  (vulpea-db-query-by-tags-some '("people"))))
         (names (cons (vulpea-note-title person)
                      (vulpea-note-aliases person)))
         (tags (seq-map #'vulpea--title-to-tag names))
         (query (string-join tags "|")))
    (let ((org-agenda-overriding-arguments (list t query)))
      (org-agenda nil "M"))))

;;; --- Agenda skip functions ---

;;;###autoload
(defun vulpea-agenda-skip-habits ()
  "Skip habits in agenda."
  (when (string= (org-entry-get nil "STYLE") "habit")
    (save-excursion (or (outline-next-heading) (point-max)))))

;;;###autoload
(defun vulpea-agenda-skip-non-tasks ()
  "Skip entries that are not tasks."
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((member (org-get-todo-state) org-done-keywords) next-headline)
       ((not (org-get-todo-state)) next-headline)
       (t nil)))))

;;;###autoload
(defun vulpea-agenda-skip-non-projects ()
  "Skip entries that are not projects."
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (if (vulpea-project-p)
          nil
        next-headline))))

;;;###autoload
(defun vulpea-agenda-skip-non-stuck-projects ()
  "Skip entries that are not stuck projects."
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (if (and (vulpea-project-p)
               (not (save-excursion
                      (org-goto-first-child)
                      (re-search-forward org-not-done-heading-regexp next-headline t))))
          nil
        next-headline))))

(provide 'vulpea-autoload)
