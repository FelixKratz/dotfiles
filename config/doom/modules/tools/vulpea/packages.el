;; -*- no-byte-compile: t; -*-
;;; tools/vulpea/packages.el

;; vulpea v2 - standalone, no org-roam dependency
(package! vulpea)

;; Enhanced selection with consult (use upstream, not stale d12frosted fork)
(package! consult-vulpea
  :recipe (:host github :repo "fabcontigiani/consult-vulpea"))
