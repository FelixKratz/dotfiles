;; -*- no-byte-compile: t; -*-
;;; tools/vulpea/packages.el

;; vulpea v2 - standalone, no org-roam dependency
(package! vulpea)

;; Optional: enhanced selection with consult
(package! consult-vulpea
  :recipe (:host github :repo "d12frosted/consult-vulpea"))
