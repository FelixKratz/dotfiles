;;; email.el --- Email configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; Hand-written. Account-derived bits (user vars, identities, fcc-dirs,
;; alternative-emails, per-account saved searches) live in email-accounts.el,
;; generated from accounts.yaml by config/email/generate.py.
;;; Code:

(load (expand-file-name "email-accounts" "~/.config/doom-private"))

(setq auth-sources '(macos-keychain-internet macos-keychain-generic "~/.authinfo.gpg"))

(after! message
  (setenv "MSMTP" "/opt/homebrew/bin/msmtp")
  (setq sendmail-program (expand-file-name "~/.local/bin/msmtpq")
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments '("--read-envelope-from")
        ;; Top-posting: reply above citation, signature between reply and citation
        message-cite-reply-position 'above
        message-cite-style message-cite-style-outlook
        message-forward-as-mime nil
        message-make-forward-subject-function #'message-forward-subject-fwd)

  (defun sf/send-mail-async ()
    "Send mail via msmtpq asynchronously."
    (let* ((buf (generate-new-buffer " *msmtpq*"))
           (recipients (message-options-get 'message-recipients))
           (args (append message-sendmail-extra-arguments
                         (list "--")
                         (message-tokenize-header recipients)))
           (from (message-field-value "from")))
      (unless message-sendmail-f-is-evil
        (push from args)
        (push "-f" args))
      (let* ((process-environment (cons "MSMTP=/opt/homebrew/bin/msmtp"
                                        process-environment))
             (proc (apply #'start-process "msmtpq" buf sendmail-program args)))
        (process-send-region proc (point-min) (point-max))
        (process-send-eof proc)
        (set-process-sentinel
         proc
         (lambda (p _event)
           (when (memq (process-status p) '(exit signal))
             (if (zerop (process-exit-status p))
                 (message "Mail sent via msmtpq")
               (message "msmtpq failed (exit %d) — check *msmtpq-error*"
                        (process-exit-status p))
               (with-current-buffer (process-buffer p)
                 (clone-buffer "*msmtpq-error*")))
             (ignore-errors (kill-buffer (process-buffer p)))))))))

  (setq message-send-mail-function #'sf/send-mail-async))

(defun sf/mail-queue-count ()
  "Return number of messages in msmtpq queue."
  (let ((queue-dir (expand-file-name "~/.msmtpq")))
    (if (file-directory-p queue-dir)
        (length (directory-files queue-dir nil "\\.mail$"))
      0)))

(defun sf/mail-queue-flush ()
  "Flush the msmtpq queue."
  (interactive)
  (let ((count (sf/mail-queue-count)))
    (if (zerop count)
        (message "Mail queue empty")
      (message "Flushing %d queued message(s)..." count)
      (async-shell-command "msmtp-queue -r" "*msmtp-queue*"))))

(defun sf/mail-queue-list ()
  "Show queued messages."
  (interactive)
  (async-shell-command "msmtp-queue -d" "*msmtp-queue*"))

(defvar sf/mail-log-file "~/.log/emacs-mail.log"
  "Log file for mail operations.")

(defun sf/mail-log (format-string &rest args)
  "Log a message to the mail log file."
  (let ((msg (format "[%s] %s\n"
                     (format-time-string "%Y-%m-%d %H:%M:%S")
                     (apply #'format format-string args))))
    (append-to-file msg nil sf/mail-log-file)
    (message "Mail: %s" (string-trim msg))))

(defun sf/mail-log-sent ()
  "Log when a message is sent."
  (sf/mail-log "SENT: To=%s Subject=%s"
               (message-fetch-field "to")
               (message-fetch-field "subject")))

(add-hook 'message-sent-hook #'sf/mail-log-sent)

(defvar sf/attachment-keywords
  "\\b\\(attach\\|attached\\|attachment\\|attachments\\|angehängt\\|anhang\\|anbei\\)\\b"
  "Regex for attachment keywords.")

(defun sf/check-attachment ()
  "Warn if message mentions attachment but has none."
  (save-excursion
    (goto-char (point-min))
    (let* ((has-keywords (re-search-forward sf/attachment-keywords nil t))
           (has-attachment (progn
                            (goto-char (point-min))
                            (or (re-search-forward "<#part\\|\\[Attachment:\\|^<#part" nil t)
                                (and (fboundp 'org-msg-get-prop)
                                     (org-msg-get-prop "attachment"))))))
      (when (and has-keywords (not has-attachment))
        (unless (y-or-n-p "No attachment found. Send anyway? ")
          (error "Aborted"))))))

(add-hook 'message-send-hook #'sf/check-attachment)

(defvar sf/email-signatures nil
  "Alist of signature names and content. Personal signatures are loaded from
`signatures.el' in the doom-private directory (kept out of the public repo).")

;; Personal signatures live in a separate file so this email config can stay
;; in the public repo. signatures.el should `(setq sf/email-signatures ...)`.
(load (expand-file-name "signatures" "~/.config/doom-private") t)

(defun sf/insert-signature ()
  "Insert a signature block, prompting for which one."
  (interactive)
  (let* ((names (mapcar #'car sf/email-signatures))
         (choice (completing-read "Signature: " names nil t))
         (sig (cdr (assoc choice sf/email-signatures))))
    (save-excursion
      (goto-char (point-max))
      (insert sig))))

(add-hook 'org-msg-edit-mode-hook #'flyspell-mode)
(add-hook 'org-msg-edit-mode-hook
          (lambda ()
            (evil-define-key 'normal org-msg-edit-mode-map [escape] #'evil-force-normal-state)))
(add-hook 'message-mode-hook #'flyspell-mode)

;; Auto-save drafts to protect against accidental buffer kills
(setq notmuch-draft-save-plaintext t)
(defun sf/auto-save-draft ()
  "Save draft silently if buffer has been modified."
  (when (buffer-modified-p)
    (notmuch-draft-save)))
(add-hook 'notmuch-message-mode-hook
          (lambda ()
            (add-hook 'auto-save-hook #'sf/auto-save-draft nil t)))

;; Doom's `company-global-modes' exclusion list has message-mode but not
;; org-msg-edit-mode (which derives from org-mode). Without this, company-box
;; pops dictionary words and snippet candidates over what we type in compose
;; buffers.
(after! company
  (setq company-global-modes
        (append company-global-modes
                '(org-msg-edit-mode notmuch-message-mode))))

;;; Notmuch
(require 'notmuch)

(after! notmuch
  ;; Doom's notmuch module sets `message-send-mail-function' to the
  ;; synchronous `message-send-mail-with-sendmail' when notmuch loads,
  ;; clobbering the async sender configured in `after! message' above.
  ;; Reassert it here, which runs after the module's config.
  (setq message-send-mail-function #'sf/send-mail-async)

  (setq browse-url-browser-function #'browse-url-default-macosx-browser)

  (defun sf/notmuch-folder-list ()
    "List maildir folders relative to the notmuch database root."
    (let* ((root (expand-file-name (notmuch-database-path)))
           (default-directory root)
           (out (shell-command-to-string
                 "find . -type d -name cur -not -path '*/\\.*' \
                    | sed 's|^\\./||;s|/cur$||' | sort")))
      (split-string out "\n" t)))

  (defun sf/notmuch-search-folder (folder)
    "Search messages in FOLDER, chosen with completion."
    (interactive
     (list (completing-read "Folder: " (sf/notmuch-folder-list) nil t)))
    (notmuch-search (format "folder:\"%s\"" folder)))

  ;; Saved searches — generic ones here, per-account inboxes from email-accounts.el
  (setq notmuch-search-oldest-first nil)
  (setq notmuch-saved-searches
        (append
         '((:name "new work"     :query "tag:unread AND folder:work/INBOX"   :sort-order newest-first   :key "n" :search-type unthreaded)
           (:name "new not-work" :query "tag:unread AND (folder:/INBOX/ OR folder:/inbox/) AND NOT folder:work/INBOX AND NOT tag:spam AND NOT tag:junk"   :sort-order newest-first   :key "N" :search-type unthreaded)
           (:name "github"       :query "folder:work/GitHub"   :sort-order newest-first   :key "g" :search-type unthreaded)
           (:name "inbox"        :query "tag:inbox"   :count-query "tag:inbox AND tag:unread"   :key "i" :search-type unthreaded)
           (:name "unread"       :query "tag:unread"   :key "u" :search-type unthreaded)
           (:name "flagged"      :query "tag:flagged"   :key "=" :search-type unthreaded)
           (:name "sent"         :query "tag:sent"   :key "s" :search-type unthreaded)
           (:name "drafts"       :query "tag:draft"   :key "d" :search-type unthreaded)
           (:name "all"          :query "*"   :count-query "tag:unread"   :key "a" :search-type unthreaded))
         sf/notmuch-account-saved-searches))

    ;; Kill stale notmuch buffers when opening new ones
    (defun sf/notmuch-kill-stale-buffers (mode &rest _)
      "Kill other notmuch buffers with the given MODE."
      (dolist (buf (buffer-list))
        (when (and (not (eq buf (current-buffer)))
                   (with-current-buffer buf (eq major-mode mode)))
          (kill-buffer buf))))
    (defadvice! sf/notmuch-search-kill-old (&rest _)
      :before #'notmuch-search
      (sf/notmuch-kill-stale-buffers 'notmuch-search-mode))
    (defadvice! sf/notmuch-show-kill-old (&rest _)
      :before #'notmuch-show
      (sf/notmuch-kill-stale-buffers 'notmuch-show-mode))
    (defadvice! sf/notmuch-tree-kill-old (&rest _)
      :before #'notmuch-unthreaded
      (sf/notmuch-kill-stale-buffers 'notmuch-tree-mode))

    ;; Fix +notmuch/quit error when no dedicated workspace is used
    (defun +notmuch/quit ()
      "Kill all notmuch buffers."
      (interactive)
      (doom-kill-matching-buffers "^\\*notmuch"))

  ;; notmuch-identities and notmuch-fcc-dirs come from email-accounts.el
  (setq notmuch-always-prompt-for-sender nil)

  ;; Use notmuch insert for Fcc so sent mail is marked as read

  (setq notmuch-maildir-use-notmuch-insert t)

  ;; Auto-detect identity from To/Cc when replying
  (defun sf/notmuch-guess-identity ()
    "Guess identity based on To/Cc of message being replied to."
    (when-let* ((original-to (notmuch-show-get-to))
                (original-cc (notmuch-show-get-cc))
                (all-recipients (concat original-to " " original-cc)))
      (seq-find (lambda (identity)
                  (let ((addr (cadr (mail-extract-address-components identity))))
                    (string-match-p (regexp-quote addr) all-recipients)))
                notmuch-identities)))

  (defun sf/notmuch-set-from-for-reply ()
    "Set From header based on detected identity."
    (when-let ((identity (sf/notmuch-guess-identity)))
      (message-replace-header "From" identity)))

  (add-hook 'notmuch-mua-reply-hook #'sf/notmuch-set-from-for-reply)

  (defun sf/notmuch-cycle-identity ()
    "Cycle through notmuch identities for From header."
    (interactive)
    (let* ((current-from (message-fetch-field "from"))
           (current-addr (and current-from
                              (cadr (mail-extract-address-components current-from))))
           (current-idx (or (seq-position notmuch-identities current-from #'string=)
                            (seq-position notmuch-identities
                                          current-addr
                                          (lambda (id addr)
                                            (string-match-p (regexp-quote addr) id)))
                            -1))
           (next-idx (mod (1+ current-idx) (length notmuch-identities)))
           (next-identity (nth next-idx notmuch-identities)))
      (message-replace-header "From" next-identity)
      (message "From: %s" next-identity)))

  (map! :map notmuch-message-mode-map
        "C-c C-f f" #'sf/notmuch-cycle-identity
        "C-c TAB"   #'notmuch-address-expand-name)

  ;; Address completion via CAPF (works with corfu)
  (setq notmuch-address-command 'internal
        notmuch-address-use-company nil)

  (defun sf/notmuch-on-address-header-p ()
    "Non-nil when point is on a recipient header line or its continuation."
    (save-excursion
      (let ((header-end (save-excursion
                          (goto-char (point-min))
                          (or (and (re-search-forward
                                    (concat "^" (regexp-quote mail-header-separator) "$")
                                    nil t)
                                   (line-beginning-position))
                              (point-max)))))
        (when (< (point) header-end)
          (beginning-of-line)
          (while (and (> (point) (point-min))
                      (looking-at "[ \t]"))
            (forward-line -1))
          (looking-at notmuch-address-completion-headers-regexp)))))

  (defun sf/notmuch-address-capf ()
    "Completion-at-point function for notmuch addresses in headers.
Exclusive by default, so when it returns non-nil on a header line
(even with empty matches) corfu won't fall through to other CAPFs."
    (when (sf/notmuch-on-address-header-p)
      (let ((start (save-excursion
                     (if (re-search-backward "[:,][ \t\n]*"
                                             (save-excursion
                                               (forward-line -5)
                                               (point))
                                             t)
                         (goto-char (match-end 0))
                       (line-beginning-position))
                     (point)))
            (end (point)))
        (when (>= end start)
          (list start end
                (completion-table-dynamic
                 (lambda (_prefix)
                   (unless (notmuch-address--harvest-ready)
                     (notmuch-address-harvest
                      (buffer-substring-no-properties start end) t))
                   (notmuch-address-harvest-trigger)
                   (notmuch-address-matching
                    (buffer-substring-no-properties start end)))))))))

  (defun sf/notmuch-compose-setup ()
    "Wire up compose-buffer completion: address CAPF first (exclusive,
so on header lines corfu shows only addresses), and `corfu-auto-prefix'
toggled to a value that never fires in the body."
    (add-hook 'completion-at-point-functions #'sf/notmuch-address-capf -90 t)
    (add-hook 'post-command-hook
              (lambda ()
                (setq-local corfu-auto-prefix
                            (if (sf/notmuch-on-address-header-p) 2 999)))
              nil t))

  (add-hook 'org-msg-edit-mode-hook #'sf/notmuch-compose-setup)
  (add-hook 'notmuch-message-mode-hook #'sf/notmuch-compose-setup)
  (add-hook 'message-mode-hook #'sf/notmuch-compose-setup)

  ;; View in browser
  (defun sf/notmuch-find-message-plist (tree)
    "Walk notmuch sexp TREE and return the first non-nil message plist."
    (cond
     ((null tree) nil)
     ((and (listp tree) (keywordp (car tree))) tree)
     ((listp tree)
      (catch 'found
        (dolist (item tree)
          (let ((r (sf/notmuch-find-message-plist item)))
            (when r (throw 'found r))))))))

  (defun sf/notmuch-view-in-browser ()
    "View current message in external browser."
    (interactive)
    (let* ((msg-id (if (derived-mode-p 'notmuch-tree-mode)
                       (notmuch-tree-get-message-id)
                     (notmuch-show-get-message-id)))
           (html-file (make-temp-file "notmuch-" nil ".html")))
      (with-temp-buffer
        (call-process "notmuch" nil t nil "show" "--format=sexp" "--include-html" "--entire-thread=false" msg-id)
        (goto-char (point-min))
        (let* ((sexp (read (current-buffer)))
               (msg (sf/notmuch-find-message-plist sexp))
               (body (plist-get msg :body))
               (html-content (sf/notmuch-find-html-part body)))
          (with-temp-file html-file
            (insert (or html-content "<html><body><pre>No HTML content</pre></body></html>")))))
      (browse-url (concat "file://" html-file))))

  (defun sf/notmuch-find-html-part (parts)
    "Recursively find HTML content in PARTS."
    (catch 'found
      (dolist (part parts)
        (let ((content-type (plist-get part :content-type)))
          (cond
           ((string= content-type "text/html")
            (throw 'found (plist-get part :content)))
           ((string-prefix-p "multipart/" content-type)
            (let ((sub (sf/notmuch-find-html-part (plist-get part :content))))
              (when sub (throw 'found sub)))))))))

  ;; Prefer HTML by default (many newsletters send garbled text/plain)
  (setq notmuch-multipart/alternative-discouraged '("text/plain" "text/x-amp-html"))

  ;; HTML rendering: ignore sender colours so dark-theme contrast stays readable.
  ;; If you want to keep sender colours, set shr-use-colors to t and rely on the
  ;; luminance/distance thresholds below to enforce minimum contrast.
  (setq shr-use-colors nil
        shr-color-visible-luminance-min 80
        shr-color-visible-distance-min 10)

  (defun sf/notmuch-toggle-html-preference ()
    "Toggle between preferring HTML and plain text in multipart emails."
    (interactive)
    (if (member "text/plain" notmuch-multipart/alternative-discouraged)
        (progn
          (setq notmuch-multipart/alternative-discouraged '("text/html" "text/x-amp-html"))
          (message "Preferring text/plain"))
      (setq notmuch-multipart/alternative-discouraged '("text/plain" "text/x-amp-html"))
      (message "Preferring text/html"))
    (notmuch-show-refresh-view))

  ;; Link navigation
  (defvar sf/notmuch-link-regex
    "\\(https?://\\|mailto:\\)[^ \t\n\r<>\"()]+"
    "Regex to match URLs in emails.")

  (defun sf/notmuch-next-link ()
    "Jump to next URL in the buffer."
    (interactive)
    (when (looking-at sf/notmuch-link-regex)
      (goto-char (match-end 0)))
    (if (re-search-forward sf/notmuch-link-regex nil t)
        (goto-char (match-beginning 0))
      (message "No more links")))

  (defun sf/notmuch-prev-link ()
    "Jump to previous URL in the buffer."
    (interactive)
    (if (re-search-backward sf/notmuch-link-regex nil t)
        (goto-char (match-beginning 0))
      (message "No previous links")))

  ;; Attachment navigation
  (defun sf/notmuch-next-attachment ()
    "Jump to next attachment in the message."
    (interactive)
    (let ((regex "\\[ [^]:]+: \\(application\\|image\\|audio\\|video\\)/"))
      (forward-char 1)
      (if (re-search-forward regex nil t)
          (goto-char (match-beginning 0))
        (message "No more attachments"))))

  (defun sf/notmuch-prev-attachment ()
    "Jump to previous attachment in the message."
    (interactive)
    (let ((regex "\\[ [^]:]+: \\(application\\|image\\|audio\\|video\\)/"))
      (if (re-search-backward regex nil t)
          (goto-char (match-beginning 0))
        (message "No previous attachments"))))

  (defun sf/notmuch-open-part-externally ()
    "Save current part to temp file and open with system default app."
    (interactive)
    (let* ((handle (notmuch-show-current-part-handle))
           (filename (or (mm-handle-filename handle) "attachment"))
           (temp-dir (make-temp-file "notmuch-" t))
           (temp-file (expand-file-name filename temp-dir)))
      (mm-save-part-to-file handle temp-file)
      (call-process "open" nil 0 nil temp-file)))

  ;; Move-to-trash support — sf/notmuch-trash-folders is set in email-accounts.el.
  (defun sf/notmuch-move-to-trash (filename)
    "Move FILENAME to the appropriate account's trash folder."
    (let* ((maildir (expand-file-name "~/Maildir/"))
           (relative (file-relative-name filename maildir))
           (account (car (split-string relative "/")))
           (trash (cdr (assoc account sf/notmuch-trash-folders))))
      (when (and trash (file-exists-p filename))
        (let* ((trash-dir (expand-file-name
                           (concat maildir account "/" trash "/cur/")))
               (new-path (expand-file-name
                          (file-name-nondirectory filename) trash-dir)))
          (make-directory trash-dir t)
          (rename-file filename new-path)))))

  ;; Tag helper functions
  (defun sf/notmuch-delete-message ()
    "Move message to trash and advance to next, or return to search."
    (interactive)
    (sf/notmuch-move-to-trash (notmuch-show-get-filename))
    (notmuch-show-tag-message "+deleted" "-inbox" "-unread")
    (unless (notmuch-show-next-open-message)
      (notmuch-bury-or-kill-this-buffer)))

  (defun sf/notmuch-show-archive ()
    "Archive message (remove inbox tag) in show mode."
    (interactive)
    (notmuch-show-tag-message "-inbox")
    (notmuch-show-next-open-message))

  (defun sf/notmuch-show-toggle-flag ()
    "Toggle flagged tag in show mode."
    (interactive)
    (if (member "flagged" (notmuch-show-get-tags))
        (notmuch-show-tag-message "-flagged")
      (notmuch-show-tag-message "+flagged")))

  (defun sf/notmuch-search-archive ()
    "Archive thread (remove inbox tag) in search mode."
    (interactive)
    (notmuch-search-tag '("-inbox"))
    (notmuch-search-next-thread))

  (defun sf/notmuch-search-delete ()
    "Tag thread as deleted and advance (files moved on next sync)."
    (interactive)
    (notmuch-search-tag '("+deleted" "-inbox" "-unread"))
    (notmuch-search-next-thread))

  (defun sf/notmuch-search-toggle-flag ()
    "Toggle flagged tag in search mode."
    (interactive)
    (if (member "flagged" (notmuch-search-get-tags))
        (notmuch-search-tag '("-flagged"))
      (notmuch-search-tag '("+flagged"))))

  (defun sf/notmuch-open-or-default ()
    "Open URL at point, or do default RET action."
    (interactive)
    (if (thing-at-point 'url)
        (browse-url (thing-at-point 'url))
      (notmuch-show-toggle-message)))

  ;; Filter thread view to unread messages only
  (defun sf/notmuch-show-filter-unread ()
    "Show only unread messages in the current thread."
    (interactive)
    (notmuch-show-filter-thread "tag:unread"))

  ;; Bounce/resend message to another address
  (defun sf/notmuch-bounce-message (&optional address)
    "Resend the current message to ADDRESS."
    (interactive "sBounce to: ")
    (notmuch-show-view-raw-message)
    (message-resend address))

  ;; Swap reply bindings: r = reply-all, R = reply-to-sender
  (define-key notmuch-show-mode-map "r" #'notmuch-show-reply)
  (define-key notmuch-show-mode-map "R" #'notmuch-show-reply-sender)
  (define-key notmuch-search-mode-map "r" #'notmuch-search-reply-to-thread)
  (define-key notmuch-search-mode-map "R" #'notmuch-search-reply-to-thread-sender)
  (define-key notmuch-search-mode-map (kbd "RET") #'notmuch-unthreaded-from-search-current-query)

  ;; Evil keybindings — show mode
  (evil-define-key 'normal notmuch-show-mode-map
    "n" #'notmuch-show-next-open-message
    "p" #'notmuch-show-previous-open-message
    "N" #'notmuch-show-next-thread-show
    "P" #'notmuch-show-previous-thread-show
    "J" #'notmuch-jump-search
    "H" #'sf/notmuch-toggle-html-preference
    "V" #'sf/notmuch-view-in-browser
    "q" #'notmuch-bury-or-kill-this-buffer
    "d" #'sf/notmuch-delete-message
    "A" #'sf/notmuch-show-archive
    "F" #'sf/notmuch-show-toggle-flag
    "cb" #'sf/notmuch-bounce-message
    "U" #'sf/notmuch-show-filter-unread
    "gl" #'sf/notmuch-next-link
    "gL" #'sf/notmuch-prev-link
    "ga" #'sf/notmuch-next-attachment
    "gA" #'sf/notmuch-prev-attachment
    "go" #'sf/notmuch-open-part-externally
    "gt" #'sf/notmuch-view-part-as-text
    "gx" #'browse-url-at-point
    (kbd "RET") #'sf/notmuch-open-or-default)

  ;; Preserve Re: prefix in unthreaded view
  (defadvice! sf/notmuch-tree-keep-re-prefix (orig-fn field format-string msg)
    :around #'notmuch-tree-format-field
    (if (and (stringp field)
             (string-equal field "subject")
             (bound-and-true-p notmuch-tree-unthreaded))
        (let* ((headers (plist-get msg :headers))
               (subject (or (plist-get headers :Subject) "(No subject)")))
          (format format-string subject))
      (funcall orig-fn field format-string msg)))

  ;; Toggle threaded/unthreaded view
  (defun sf/notmuch-toggle-threading ()
    "Toggle between threaded and unthreaded view for the current query."
    (interactive)
    (if (eq major-mode 'notmuch-tree-mode)
        (notmuch-search notmuch-tree-basic-query)
      (notmuch-unthreaded notmuch-search-query-string)))

  ;; Evil keybindings — search mode
  (evil-define-key 'normal notmuch-search-mode-map
    "S" #'notmuch-search-filter
    "A" #'sf/notmuch-search-archive
    "d" #'sf/notmuch-search-delete
    "F" #'sf/notmuch-search-toggle-flag
    "J" #'notmuch-jump-search
    "U" #'sf/notmuch-toggle-threading
    "q" #'notmuch-bury-or-kill-this-buffer)

  (evil-define-key 'normal notmuch-tree-mode-map
    "s" #'notmuch-unthreaded
    "S" #'notmuch-tree-filter
    "V" #'sf/notmuch-view-in-browser
    (kbd "*") #'sf/notmuch-tree-tag-all)

  (evil-define-key 'normal notmuch-unthreaded-mode-map
    "U" #'sf/notmuch-toggle-threading)

  ;; Tree/unthreaded view has no per-tag line styling built in, so overlay
  ;; unread (bold) and flagged (colour) ourselves after each line is drawn.
  (defface sf/notmuch-tree-unread-face
    '((t :weight bold))
    "Face for unread messages in notmuch tree/unthreaded view.")

  (defface sf/notmuch-tree-flagged-face
    '((t :foreground "#e5c07b"))
    "Face for flagged messages in notmuch tree/unthreaded view.")

  (defadvice! sf/notmuch-tree-highlight-tags (msg)
    :after #'notmuch-tree-insert-msg
    (save-excursion
      (forward-line -1)
      (let ((line-start (point))
            (line-end (line-end-position))
            (tags (plist-get msg :tags)))
        (when (member "unread" tags)
          (let ((ov (make-overlay line-start line-end)))
            (overlay-put ov 'face 'sf/notmuch-tree-unread-face)
            (overlay-put ov 'priority 10)
            (overlay-put ov 'evaporate t)))
        (when (member "flagged" tags)
          (let ((ov (make-overlay line-start line-end)))
            (overlay-put ov 'face 'sf/notmuch-tree-flagged-face)
            (overlay-put ov 'priority 5)
            (overlay-put ov 'evaporate t))))))

  ;; Bulk-tag every message matching the current tree query.
  ;; `!' marks all read; `=' flags all; any other key falls through to a prompt.
  (defun sf/notmuch-tree-tag-all ()
    "Apply tag changes to every message matching the current tree query."
    (interactive)
    (let* ((key (read-key "Tag all [! = mark read, = = flag, other = prompt]: "))
           (tag-changes
            (pcase key
              (?! '("-unread"))
              (?= '("+flagged"))
              (_ (setq unread-command-events (list key))
                 (notmuch-read-tag-changes nil "Tag all")))))
      (when tag-changes
        (notmuch-tag notmuch-tree-basic-query tag-changes)
        (when-let ((proc (get-buffer-process (current-buffer))))
          (delete-process proc))
        (notmuch-tree-refresh-view))))

  ;; Exclude spam/junk from searches
  (setq notmuch-search-hide-excluded t
        notmuch-excluded-tags '("spam" "junk" "deleted"))

  ;; Auto-decrypt and verify signed/encrypted messages
  (setq notmuch-crypto-process-mime t)

  ;; Highlight saved searches with unread messages
  (defface sf/notmuch-hello-active-search
    '((t :weight bold :foreground "#51afef"))
    "Face for saved searches with unread messages.")

  (defun sf/notmuch-hello-colour-searches ()
    "Highlight saved searches that have unread messages."
    (save-excursion
      (goto-char (point-min))
      (let ((inhibit-read-only t))
        (dolist (search notmuch-saved-searches)
          (let* ((name (plist-get search :name))
                 (count-query (or (plist-get search :count-query)
                                  (concat (plist-get search :query)
                                          " AND tag:unread")))
                 (count (string-to-number
                         (notmuch-saved-search-count count-query))))
            (when (> count 0)
              (goto-char (point-min))
              (when (search-forward name nil t)
                (let ((beg (match-beginning 0))
                      (end (match-end 0)))
                  (add-text-properties
                   beg end '(face sf/notmuch-hello-active-search))))))))))

  (add-hook 'notmuch-hello-refresh-hook #'sf/notmuch-hello-colour-searches)

  ;; Position cursor at first saved search on hello refresh
  (defun sf/notmuch-hello-goto-first-search ()
    "Move cursor to the first saved search button."
    (goto-char (point-min))
    (when (widget-forward 1)
      (widget-backward 1)))

  (add-hook 'notmuch-hello-refresh-hook
            #'sf/notmuch-hello-goto-first-search
            90)  ; run after colour hook

  ;; Inline viewing of PDF and DOCX attachments
  (defun sf/notmuch-view-part-as-text ()
    "Convert current attachment to text and display in a buffer."
    (interactive)
    (let* ((handle (notmuch-show-current-part-handle))
           (type (mm-handle-media-type handle))
           (filename (or (mm-handle-filename handle) "attachment"))
           (temp-file (make-temp-file "notmuch-part-" nil
                                      (file-name-extension filename t)))
           (buf-name (format "*notmuch: %s*" filename)))
      (mm-save-part-to-file handle temp-file)
      (with-current-buffer (get-buffer-create buf-name)
        (let ((inhibit-read-only t))
          (erase-buffer)
          (cond
           ((string= type "application/pdf")
            (call-process "pdftotext" nil t nil temp-file "-"))
           ((member type '("application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                           "application/msword"))
            (call-process "pandoc" nil t nil "-t" "plain" temp-file))
           (t
            (call-process "textutil" nil t nil "-convert" "txt" "-stdout" temp-file)))
          (goto-char (point-min))
          (view-mode 1))
        (switch-to-buffer-other-window (current-buffer)))
      (delete-file temp-file)))

  ;; Org-mode links to notmuch messages
  (require 'ol-notmuch)

  ;; Warn before sending with empty subject
  (defun sf/notmuch-check-subject ()
    "Prompt for confirmation if subject is empty."
    (let ((subject (message-fetch-field "Subject")))
      (when (or (not subject) (string-empty-p (string-trim subject)))
        (unless (y-or-n-p "Subject is empty. Send anyway? ")
          (error "Aborted: empty subject")))))

  (add-hook 'message-send-hook #'sf/notmuch-check-subject)

  ;; Show recipient instead of sender in sent mail
  (defun sf/notmuch-result-format-from (format-string result)
    "Show recipient when sender is the user, with truncation."
    (let* ((from (plist-get result :authors))
           (to (plist-get result :to))
           (dominated (and from
                           (string-match-p message-alternative-emails from)))
           (author (if (and dominated to)
                       (concat "To: " (car (split-string to "[,;]")))
                     (or from "")))
           (formatted (format format-string author))
           (sample (format format-string ""))
           (width (length sample)))
      (if (<= (length formatted) width)
          formatted
        (concat (substring author 0 (- width 4)) "... "))))

  (setq notmuch-search-result-format
        '(("date" . "%12s ")
          ("count" . "%-7s ")
          (sf/notmuch-result-format-from . "%-20s ")
          ("subject" . "%s ")
          ("tags" . "(%s)")))

  (setq notmuch-hello-sections
        '(notmuch-hello-insert-saved-searches
          notmuch-hello-insert-search
          notmuch-hello-insert-alltags
          notmuch-hello-insert-footer))

  (setq mail-user-agent 'notmuch-user-agent)

  ;; Keybindings under SPC e
  (map! :leader
        "e" nil
        (:prefix ("e" . "email")
         :desc "Notmuch"        "e" #'notmuch
         :desc "Jump"           "j" #'notmuch-jump-search
         :desc "Search"         "s" #'notmuch-unthreaded
         :desc "Find (consult)" "f" #'consult-notmuch
         :desc "Find tree"      "F" #'consult-notmuch-tree
         :desc "Folder"         "d" #'sf/notmuch-search-folder
         :desc "Compose"        "c" #'notmuch-mua-new-mail
         :desc "Queue flush"    "q" #'sf/mail-queue-flush))

) ;; end (after! notmuch)

;;; mu4e
(after! mu4e
  (setq browse-url-browser-function #'browse-url-default-macosx-browser)

  ;; General settings
  (setq mu4e-compose-complete-addresses t
        mu4e-compose-dont-reply-to-self t
        mu4e-get-mail-command "true"
        mu4e-search-threads nil
        mu4e-headers-include-related nil
        mu4e-change-filenames-when-moving t
        mu4e-index-cleanup nil
        mu4e-index-lazy-check t)

  ;; Invert U behaviour: plain U re-indexes, C-u U fetches mail
  (defun sf/mu4e-update-mail-and-index (orig-fun prefix &rest args)
    (interactive "P")
    (if prefix (funcall orig-fun nil) (mu4e-update-index)))

  (advice-add 'mu4e-update-mail-and-index
              :around #'sf/mu4e-update-mail-and-index)

  ;; Headers layout
  (setq mu4e-headers-fields
        '((:flags      .  6)
          (:human-date . 12)
          (:from-or-to . 22)
          (:subject    . nil))
        mu4e-headers-date-format "%d/%m/%Y"
        mu4e-headers-time-format "%H:%M"
        mu4e-headers-from-or-to-prefix '("" . "To "))

  ;; Nerd font icons for message marks
  (setq mu4e-use-fancy-chars t)
  (require 'nerd-icons)
  (setq mu4e-headers-unread-mark    `("u" . ,(nerd-icons-mdicon "nf-md-email_outline"))
        mu4e-headers-draft-mark     '("D" . "🚧")
        mu4e-headers-flagged-mark   `("F" . ,(nerd-icons-mdicon "nf-md-flag"))
        mu4e-headers-new-mark       `("N" . ,(nerd-icons-mdicon "nf-md-email_alert_outline"))
        mu4e-headers-passed-mark    `("P" . ,(nerd-icons-mdicon "nf-md-share"))
        mu4e-headers-replied-mark   `("R" . ,(nerd-icons-mdicon "nf-md-reply"))
        mu4e-headers-seen-mark      '("S" . " ")
        mu4e-headers-trashed-mark   `("T" . ,(nerd-icons-mdicon "nf-md-delete"))
        mu4e-headers-attach-mark    `("a" . ,(nerd-icons-mdicon "nf-md-paperclip"))
        mu4e-headers-encrypted-mark `("x" . ,(nerd-icons-mdicon "nf-md-lock"))
        mu4e-headers-signed-mark    `("s" . ,(nerd-icons-mdicon "nf-md-certificate"))
        mu4e-headers-list-mark      '("l" . " "))

  ;; Hide messages from self when not threading (toggle with Q)
  (setq mu4e-headers-hide-predicate
        (lambda (msg)
          (when-let ((from (car (mu4e-message-field msg :from)))
                     (addr (mu4e-contact-email from)))
            (mu4e-personal-address-p addr))))

  ;; Contexts: per-account ones come from email-accounts.el; local is appended.
  (setq mu4e-contexts
        (append (sf/mu4e-account-contexts)
                (list (make-mu4e-context
                       :name "local"
                       :match-func (lambda (msg)
                                     (when msg (string-prefix-p "/local" (mu4e-message-field msg :maildir))))
                       :vars '((mu4e-sent-folder   . "/local/Sent")
                               (mu4e-drafts-folder . "/local/Drafts")
                               (mu4e-trash-folder  . "/local/Trash"))))))

  ;; Build list of all email addresses from contexts
  (setq mu4e-user-mail-address-list
        (delq nil
              (mapcar (lambda (context)
                        (when (mu4e-context-vars context)
                          (cdr (assq 'user-mail-address (mu4e-context-vars context)))))
                      mu4e-contexts)))

  ;; Bookmarks: per-account ones come from email-accounts.el; the generic ones
  ;; (any-unread / local-archive) are appended here.
  (setq mu4e-bookmarks
        (append sf/mu4e-account-bookmarks
                '((:name "New email"     :query "flag:unread AND NOT flag:trashed" :key ?n)
                  (:name "Local archive" :query "maildir:/local/*"                 :key ?l))))

  ;; Coloured columns in headers view
  (require 'mu4e-column-faces)
  (mu4e-column-faces-mode)

  ;; Fix header-line alignment with fringe/line-numbers (Emacs 29+)
  (add-hook 'mu4e-headers-mode-hook #'header-line-indent-mode)

  ;; Extra evil keybindings (evil-collection provides the rest)
  (evil-define-key 'normal mu4e-view-mode-map
    "V" #'mu4e-action-view-in-browser)

  ;; Dedicated mu4e workspace
  (defun sf/switch-to-mu4e-workspace ()
    "Switch to or create the mu4e workspace."
    (+workspace-switch "*mu4e*" t))

  (defun sf/mu4e-in-workspace (orig-fun &rest args)
    "Run mu4e command in dedicated workspace."
    (let ((new-workspace-p (not (+workspace-exists-p "*mu4e*"))))
      (sf/switch-to-mu4e-workspace)
      (let ((default-buf (when new-workspace-p (current-buffer))))
        (apply orig-fun args)
        (delete-other-windows)
        (when (and default-buf
                   (buffer-live-p default-buf)
                   (not (eq default-buf (current-buffer))))
          (kill-buffer default-buf)))))

  (advice-add 'mu4e :around #'sf/mu4e-in-workspace)
  (advice-add 'mu4e-compose-new :around #'sf/mu4e-in-workspace)

  ;; Prevent persp-mode from auto-creating workspaces for mu4e buffers
  (after! persp-mode
    (persp-def-buffer-save/load
     :mode 'mu4e-main-mode :tag-symbol 'def-mu4e-main :save-vars nil)
    (persp-def-buffer-save/load
     :mode 'mu4e-headers-mode :tag-symbol 'def-mu4e-headers :save-vars nil)
    (persp-def-buffer-save/load
     :mode 'mu4e-view-mode :tag-symbol 'def-mu4e-view :save-vars nil))

  ;; Keep mu4e buffers in the workspace
  (add-hook! '(mu4e-main-mode-hook mu4e-headers-mode-hook mu4e-view-mode-hook)
    (defun sf/mu4e-buffer-to-mail-workspace ()
      (when (and (bound-and-true-p persp-mode)
                 (+workspace-exists-p "*mu4e*"))
        (persp-add-buffer (current-buffer) (+workspace-get "*mu4e*")))))

) ;; end (after! mu4e)

;;; org-msg for HTML composition
(after! notmuch
  (require 'org-msg)
  (require 'rfc2047)

  ;; Decode RFC 2047 encoded headers in org-msg citations
  (defun sf/org-msg-decode-header (orig-fun field)
    "Decode RFC 2047 encoded headers in citations."
    (when-let ((value (funcall orig-fun field)))
      (rfc2047-decode-string value)))

  (advice-add 'org-msg-message-fetch-field :around #'sf/org-msg-decode-header)
  (setq org-msg-options "html-postamble:nil H:5 num:nil ^:{} toc:nil author:nil email:nil \\n:t"
        org-msg-startup "hidestars indent inlineimages"
        org-msg-greeting-fmt "\nHi%s,\n\n"
        org-msg-greeting-name-limit 3
        org-msg-default-alternatives '((new . (text html))
                                       (reply-to-html . (text html))
                                       (reply-to-text . (text)))
        org-msg-convert-citation t
        org-msg-signature "")

  ;; Enlarge body font to 11pt (default is 10pt Arial) and add vertical
  ;; space above the reply citation so the signature is not flush against
  ;; the "From:" header block.
  (setq org-msg-enforce-css
        (mapcar
         (lambda (entry)
           (pcase-let* ((`(,tag ,class ,props) entry)
                        (new-props
                         (mapcar (lambda (prop)
                                   (pcase prop
                                     (`(font-size . "10pt") '(font-size . "11pt"))
                                     (`(line-height . "10pt") '(line-height . "12pt"))
                                     (`(line-height . "11pt") '(line-height . "13pt"))
                                     (_ prop)))
                                 props)))
             (when (and (eq tag 'div) (eq class 'reply-header))
               (setq new-props (append new-props '((margin-top . "20px")))))
             `(,tag ,class ,new-props)))
         org-msg-default-style))

  (org-msg-mode 1)
  (map! :map org-msg-edit-mode-map
        "C-c C-a" #'org-msg-attach)
  (map! :map org-msg-edit-mode-map
        "C-c C-s" #'sf/insert-signature)
  (map! :map org-msg-edit-mode-map
        "C-c TAB" #'notmuch-address-expand-name)
  (map! :map message-mode-map
        "C-c C-s" #'sf/insert-signature)
  (setq message-hidden-headers '("Fcc"))

  ;; Suppress org export buffer when org-msg generates text/plain
  (setq org-export-show-temporary-export-buffer nil)

  ;; Disable org-msg for forwards. The MML directive that embeds the
  ;; original message can't live inside an org body that gets exported to
  ;; HTML, so org-msg's keywords/greeting end up stranded outside the
  ;; forwarded block.
  (defun sf/notmuch-forward-without-org-msg (orig-fun &rest args)
    (let ((reenable org-msg-mode))
      (when reenable (org-msg-mode -1))
      (unwind-protect
          (apply orig-fun args)
        (when reenable (org-msg-mode 1)))))
  (advice-add 'notmuch-mua-new-forward-messages
              :around #'sf/notmuch-forward-without-org-msg))

;;; email.el ends here

