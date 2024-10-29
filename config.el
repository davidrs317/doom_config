;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)
;; (setq doom-theme 'doom-ayu-light)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; set default coding system to utf-8
(set-default-coding-systems 'utf-8)

;; practical common lisp
(projectile-add-known-project "~/devspace/practical_common_lisp")

;; (add-hook 'c-mode-hook 'eglot-ensure)
;; (add-hook 'c++-mode-hook 'eglot-ensure)
;; (add-hook 'c-ts-mode-hook 'eglot-ensure)
;; (add-hook 'c++-ts-mode-hook 'eglot-ensure)
(setq lsp-clients-clangd-args '("-j=3"
                                "--background-index"
                                "--clang-tidy"
                                "--completion-style=detailed"
                                "--header-insertion=never"
                                "--header-insertion-decorators=0"))
(after! lsp-clangd (set-lsp-priority! 'clangd 2))
(require 'treesit)

;; turn off auto comment thingy
(eval-after-load 'cc-mode
  '(progn
     (define-key c-mode-base-map "/" 'self-insert-command)
     (define-key c-mode-base-map "*" 'self-insert-command)))

;; set treesitter grammar path
(setq treesit-extra-load-path '("/usr/local/lib"))

;; verify treesitter is available
(treesit-available-p)

;; override c and c++ modes to their treesitter variants
(push '(c-mode . c-ts-mode) major-mode-remap-alist)
(push '(c++-mode . c++-ts-mode) major-mode-remap-alist)
(push '(c-or-c++-mode . c-or-c++-ts-mode) major-mode-remap-alist)

;; bind % to move between matching parentheses
(defun goto-match-paren (arg)
  "Go to the matching parenthesis if on parenthesis & last command is for movement.
In other cases, insert %, vi style of % jumping to matching brace.
ARG is the parenthesis the function is going to match"
  (interactive "p")
  (message "%s" last-command)
  (if (not (memq last-command '(
                                set-mark
                                cua-set-mark
                                goto-match-paren
                                down-list
                                up-list
                                end-of-defun
                                beginning-of-defun
                                backward-sexp
                                forward-sexp
                                backward-up-list
                                forward-paragraph
                                backward-paragraph
                                end-of-buffer
                                beginning-of-buffer
                                backward-word
                                forward-word
                                mwheel-scroll
                                backward-word
                                forward-word
                                mouse-start-secondary
                                mouse-yank-secondary
                                mouse-secondary-save-then-kill
                                move-end-of-line
                                move-beginning-of-line
                                backward-char
                                forward-char
                                scroll-up
                                scroll-down
                                scroll-left
                                scroll-right
                                mouse-set-point
                                next-buffer
                                previous-buffer
                                )
                 ))
      (self-insert-command (or arg1))
    (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
          ((looking-at "\\s\)") (forward-char 1) (backward-char 1))
          (t (self-insert-command (or arg 1))))))

;; pandoc to convert org to docx
(defun hm/convert-org-to-docx-with-pandoc ()
  "Use Pandoc to convert .org to .docx.
Comments:
- The `-N` flag numbers the headers lines
- Use the `--from org` flag to have this function work on files
  that are in Org syntax but do not have a .org extension"
  (interactive)
  (message "exporting .org to .docx")
  (shell-command
   (concat "pandoc -N --from org " (buffer-file-name)
           " -o "
           (file-name-sans-extension (buffer-file-name))
           (format-time-string "-%Y-%m-%d-%H%M%S") ".docx")))

;; define pandoc conversion alias
(defalias 'd 'hm/convert-org-to-docx)

;; set tab-width to 4
(setq-default tab-width 4)
(electric-indent-mode 0)

;; Make compilation window automatically disappear - from enberg on #emacs
(setq compilation-finish-functions
      (lambda (buf str)
        (if (null (string-match ".*exited abnormally.*" str))
            ;; no errors, make the compilation window go away in a few seconds
            (progn
              (run-at-time
               "2 sec" nil 'delete-windows-on
               (get-buffer-create "*compilation*"))
              (message "No Compilation Errors!")))))

;; org capture templates
(after! org
  (setq org-capture-templates
        '(
          ("w" "Work Log Entry"
           entry (file+datetree "~/org/work-log.org")
           "* %?"
           :empty-lines 0)
          ("n" "Note"
           entry (file+headline "~/org/notes.org" "Random Notes")
           "** %?"
           :empty-lines 0)
          ("g" "General To-Do"
           entry (file+headline "~/org/todos.org" "General Tasks")
           "* TODO [#B] %?\n:Created: %T\n "
           :empty-lines 0)
          ("c" "Code To-Do"
           entry (file+headline "~/org/todos.org" "Code Related Tasks")
          "* TODO [#B] %?\n:Created: %T\n%i\n%a\nProposed Solution: "
          :empty-lines 0)
          ("m" "Meeting"
           entry (file+datetree "~/org/meetings.org")
           "* %? :meeting:%^g \n:Created: %T\n** Attendees\n*** \n** Notes\n** Action Items\n*** TODO[#A] "
           :tree-type week
           :clock-in t
           :clock-resume t
           :empty-lines 0)))
  (setq org-todo-keywords
        '((sequence "TODO(t)" "PLANNING(p)" "IN-PROGRESS(i@/!)" "VERIFYING(v!)" "BLOCKED(b@)" "|" "DONE(d!)" "OBE(o@!)" "WONT-DO(w@/!)" )))
  (setq org-todo-keyword-faces
        '(
          ("TODO" . (:foreground "GoldenRod" :weight bold))
          ("PLANNING" . (:foreground "DeepPink" :weight bold))
          ("IN-PROGRESS" . (:foreground "Cyan" :weight bold))
          ("VERIFYING" . (:foreground "DarkOrange" :weight bold))
          ("BLOCKED" . (:foreground "Red" :weight bold))
          ("DONE" . (:foreground "LimeGreen" :weight bold))
          ("OBE" . (:foreground "LimeGreen" :weight bold))
          ("WONT-DO" . (:foreground "LimeGreen" : weight bold))
          ))
  (setq org-agenda-custom-commands
        '(
          ;; David's Super View
          ("d" "David's Super View"
           (
            (agenda ""
                    (
                     (org-agenda-remove-tags t)
                     (org-agenda-span 7)
                    )
            )
            (alltodo ""
                     (
                      ;; Remove tags to make the view clearer
                      (org-agenda-remove-tags t)
                      (org-agenda-prefix-format " %t %s")
                      (org-agenda-overriding-header "CURRENT STATUS")

                      ;; Define super agneda groups (sorts by order)
                      (org-super-agenda-groups
                       '(
                         ;; Filter where tag is CRITICAL
                         (:name "Critical Tasks"
                                :tag "CRITICL"
                                :order 0
                         )
                         ;; Filter where TODO state is IN-PROGRESS
                         (:name "Currently Working"
                                :todo "IN-PROGRESS"
                                :order 1
                         )
                         ;; Filter where TODO state is PLANNING
                         (:name "Planning Next Steps"
                                :todo "PLANNING"
                                :order 2
                         )
                         ;; Flter where TODO state is BLOCKED or where the tag is obstacle
                         (:name "Problems & Blockers"
                                :todo "BLOCKED"
                                :tag "obstacle"
                                :order 3
                         )
                         ;; Filter where tag is @write_future_ticket
                         (:name "Tickets to Create"
                                :tag "@write_future_ticket"
                                :order 4
                         )
                         ;; Filter where tag is @research
                         (:name "Research Required"
                                :tag "@research"
                                :order 7
                         )
                         ;; Filter where tag is meeting and priority is A (only want TODOs from meetings)
                         (:name "Meeting Action Items"
                                :and (:tag "meeting" :priority "A")
                                :order 8
                         )
                         ;; Filter where state is TODO and priority is A and the tag is not meeting
                         (:name "Other Important Items"
                                :and (:todo "TODO" :priority "A" :not (:tag "meeting"))
                                :order 9
                         )
                         ;; Filter where state is TODO and priority is B
                         (:name "General Backlog"
                                :and (:todo "TODO" :priority "B")
                                :order 10
                         )
                         ;; Filter where priority is C Or less (supports future lower priorities)
                         (:name "Non Critical"
                                :priority <= "C"
                                :order 11
                         )
                         ;; Filter where TODO state is VERIFYING
                         (:name "Currently Being Verified"
                                :todo "VERIFYING"
                                :order 20
                         )
                         ))
                      ))
            ))
)))

(setq-default indent-tabs-mode nil)
(setq-default tab-wdith 4)
(setq indent-line-function 'insert-tab)

(map! :after sly
      :mode sly-mode
      :localleader
      :prefix "r"
      :desc "Open Repo" "o" #'sly-mrepl)
(map! :leader
      :desc "Open Eshell" "e" #'eshell)
