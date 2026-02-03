;; -*- no-byte-compile: t; -*-
;;; tools/vulpea/packages.el

;; vulpea v2 - standalone, no org-roam dependency
(package! vulpea)

;; Disabled: causes empty title/slug when creating new notes
;; (package! consult-vulpea
;;   :recipe (:host github :repo "d12frosted/consult-vulpea"))
