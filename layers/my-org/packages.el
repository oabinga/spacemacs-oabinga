;;; packages.el --- my-org layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author:  <yangshaobin@YANGSHAOBIN-PC>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `my-org-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `my-org/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `my-org/pre-init-PACKAGE' and/or
;;   `my-org/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst my-org-packages
  '(
    org
    )
  "The list of Lisp packages required by the my-org layer.

Each entry is either:

1. A symbol, which is interpreted as a package to be installed, or

2. A list of the form (PACKAGE KEYS...), where PACKAGE is the
    name of the package to be installed or loaded, and KEYS are
    any number of keyword-value-pairs.

    The following keys are accepted:

    - :excluded (t or nil): Prevent the package from being loaded
      if value is non-nil

    - :location: Specify a custom installation location.
      The following values are legal:

      - The symbol `elpa' (default) means PACKAGE will be
        installed using the Emacs package manager.

      - The symbol `local' directs Spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'

      - A list beginning with the symbol `recipe' is a melpa
        recipe.  See: https://github.com/milkypostman/melpa#recipe-format")


(defun my-org/post-init-org ()
  (with-eval-after-load 'org
    (progn
      ;; define the refile targets
      (setq org-agenda-files (quote ("~/org")))
      (setq org-default-notes-file "~/org/inbox.org")

      (with-eval-after-load 'org-agenda
        (define-key org-agenda-mode-map (kbd "P") 'org-pomodoro))
      (setq org-capture-templates
            '(("t" "Todo" entry (file+headline "~/org/inbox.org" "Inbox")
               "* TODO %?\n  %i\n"
               :empty-lines 1)
              ("n" "Notes" entry (file+headline "~/org/notes.org" "Quick Notes")
               "* %?\n  %i\n%U"
               :empty-lines 1)
              ("l" "Links" entry (file+headline "~/org/notes.org" "Links")
               "* %?\n %A\n %i\n%U"
               :empty-lines 1)
              ("j" "Journal" entry (file+datetree "~/org/journal.org")
               "* %?\n%U\n"
               :empty-lines 1)
              ("f" "Financial" entry (file+headline "~/org/financial.org" "Financial")
               "* %T %?\n"
               :empty-lines 1)))

      ;;An entry without a cookie is treated just like priority ' B '.
      ;;So when create new task, they are default 重要且紧急
      (setq org-agenda-custom-commands
            '(
              ("w" . "任务安排")
              ("wa" "重要且紧急的任务" tags-todo "+PRIORITY=\"A\"")
              ("wb" "重要且不紧急的任务" tags-todo "-Weekly-Monthly-Daily+PRIORITY=\"B\"")
              ("wc" "不重要且紧急的任务" tags-todo "+PRIORITY=\"C\"")
              ("b" "Blog" tags-todo "BLOG")
              ("W" "Weekly Review"
               ((stuck "")            ;; review stuck projects as designated by org-stuck-projects
                (tags-todo "PROJECT") ;; review all projects (assuming you use todo keywords to designate projects)
                ))))
      (defun org-summary-todo (n-done n-not-done)
        "Switch entry to DONE when all subentries are done, to TODO otherwise."
        (let (org-log-done org-log-states)  ; turn off logging
          (org-todo (if (= n-not-done 0) "DONE" "TODO"))))
      (add-hook 'org-after-todo-statistics-hook 'org-summary-todo)

      (setq org-tag-alist (quote ((:startgroup)
                                  ("@OFFICE" . ?o)
                                  ("@HOME" . ?h)
                                  ("@WAY" . ?w)
                                  (:endgroup)
                                  ("COMPUTER" . ?c)
                                  ("READING" . ?r)
                                  ("PROJECT" . ?p)
                                  ("ENGLISH" . ?e)
                                  ("STUDY" . ?s)
                                  ("MEMO" . ?m)
                                  ("WAITING" . ?W)
                                  ("SOMEDAY" . ?H)
                                  ("CANCELLED" . ?C))))
      ;; The tags are used to filter tasks in the agenda views conveniently
      (setq org-todo-state-tags-triggers
            (quote (("CANCELLED" ("CANCELLED" . t))                   ;; Moving a task to CANCELLED adds a CANCELLED tag
                    ("WAITING" ("WAITING" . t))                       ;; Moving a task to WAITING adds a WAITING tag
                    ("SOMEDAY" ("WAITING") ("SOMEDAY" . t))                 ;; Moving a task to SOMEDAY adds WAITING and SOMEDAY tags
                    ("DONE" ("WAITING") ("SOMEDAY"))                     ;; Moving a task to a done state removes WAITING and SOMEDAY tags
                    ("TODO" ("WAITING") ("CANCELLED") ("SOMEDAY"))       ;; Moving a task to TODO removes WAITING, CANCELLED, and SOMEDAY tags
                    ("STARTED" ("WAITING") ("CANCELLED") ("SOMEDAY"))       ;; Moving a task to STARTED removes WAITING, CANCELLED, and SOMEDAY tags
                    ("DONE" ("WAITING") ("CANCELLED") ("SOMEDAY")))))    ;; Moving a task to DONE removes WAITING, CANCELLED, and SOMEDAY tags

      (setq org-todo-keywords
            (quote ((sequence "TODO(t)" "STARTED(s)" "|" "DONE(d)")
                    (sequence "WAITING(w@/!)" "SOMEDAY(S@/!)" "|" "CANCELLED(c@/!)"))))

      (setq org-todo-keyword-faces
            (quote (("TODO" :foreground "#f44" :weight bold)
                    ("STARTED" :foreground "#19ADE6" :weight bold)
                    ("DONE" :foreground "forest green" :weight normal :strike-through t)
                    ("WAITING" :foreground "orange" :weight bold)
                    ("SOMEDAY" :foreground "magenta" :weight bold)
                    ("CANCELLED" :foreground "forest green" :weight bold)
                    )))
      ;; Agenda clock report parameters
      (setq org-agenda-clockreport-parameter-plist
            (quote (:link t :maxlevel 5 :fileskip0 t :compact t :narrow 80)))

      ;; global Effort estimate values
      ;; global STYLE property values for completion
      (setq org-global-properties (quote (("Effort_ALL" . "0:15 0:30 0:45 1:00 2:00 3:00 4:00 5:00 6:00 0:00")
                                          ("STYLE_ALL" . "habit"))))

      ;; Set default column view headings: Task Effort Clock_Summary
      (setq org-columns-default-format "%80ITEM(Task) %10Effort(Effort){:} %10CLOCKSUM")

      ;; Agenda log mode items to display (closed and state changes by default)
      (setq org-agenda-log-mode-items (quote (closed state)))
      ;; Targets include this file and any file contributing to the agenda - up to 9 levels deep
      (setq org-refile-targets (quote ((nil :maxlevel . 9)
                                       (org-agenda-files :maxlevel . 9))))
      ;; Use full outline paths for refile targets - we file directly with IDO
      (setq org-refile-use-outline-path t)

      ;; Targets complete directly with IDO
      (setq org-outline-path-complete-in-steps nil)

      ;; Allow refile to create parent tasks with confirmation
      (setq org-refile-allow-creating-parent-nodes (quote confirm))

      ;; Use IDO for both buffer and file completion and ido-everywhere to t
      (setq org-completion-use-ido t)
      (setq ido-everywhere t)
      (setq ido-max-directory-size 100000)
      (ido-mode (quote both))
      ;; Use the current window when visiting files and buffers with ido
      (setq ido-default-file-method 'selected-window)
      (setq ido-default-buffer-method 'selected-window)
      ;; Use the current window for indirect buffer display
      (setq org-indirect-buffer-display 'current-window)

      ;; Refile settings
      ;; Exclude DONE state tasks from refile targets
      (defun bh/verify-refile-target ()
        "Exclude todo keywords with a done state from refile targets"
        (not (member (nth 2 (org-heading-components)) org-done-keywords)))

      (setq org-refile-target-verify-function 'bh/verify-refile-target)

      ;; (setq org-todo-keywords
      ;;       (quote ((sequence "TODO(t)" "STARTED(s)" "|" "DONE(d!/!)")
      ;;               (sequence "WAITING(w@/!)" "SOMEDAY(S)"  "|" "CANCELLED(c@/!)" "MEETING(m)" "PHONE(p)"))))

      ;; Change task state to STARTED when clocking in
      (setq org-clock-in-switch-to-state "STARTED")
      ;; Save clock data and notes in the LOGBOOK drawer
      (setq org-clock-into-drawer t)
      ;; Removes clocked tasks with 0:00 duration
      (setq org-clock-out-remove-zero-time-clocks t) ;; Show the clocked-in task - if any - in the header line
      )))
;;; packages.el ends here
