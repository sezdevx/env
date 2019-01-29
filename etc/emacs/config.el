;; -*- Mode: Emacs-Lisp -*-

;; where emacs backup and autosave files go
(setq env_home_dir (getenv "ENV_HOME_DIR"))
(defconst backups-dir
  (concat (if (stringp env_home_dir) env_home_dir (expand-file-name "~/.env"))  "/data/emacs/backups"))
(defconst autosaves-dir
  (concat
   (if (stringp env_home_dir) env_home_dir (expand-file-name "~/.env")) "/data/emacs/autosaves"))
(defconst ext-dir
  (concat
   (if (stringp env_home_dir) env_home_dir (expand-file-name "~/.env")) "/ext/emacs"))

;; create backup and autosave directories if not created already
(make-directory backups-dir t)
(make-directory autosaves-dir t)

(add-to-list 'load-path (concat ext-dir "/modules"))

;;When moving to another screen using up or down arrow don't move the cursor
;;keep it either at the bottom when moving down or at the top when moving up
(setq scroll-step 1)

;;Don't use tabs to indent lines, always use spaces
(setq-default indent-tabs-mode nil)
(setq tab-width 2)
(setq-default tab-always-indent 'complete)

;; default to better frame titles
(setq frame-title-format (concat  "%b - emacs@" system-name))

;;Highlight currentline
;;(global-hl-line-mode 1)
(set-face-background 'region "blue3")
(setq colors-file (expand-file-name "colors.el" ext-dir))
(if (file-exists-p colors-file) (load-file colors-file)
  (progn
    ;; Sure this is not pretty, but works find in many different old settings
    (set-face-foreground 'font-lock-string-face "Red")
    (set-face-foreground 'font-lock-comment-face "Purple2")
    (set-face-foreground 'font-lock-keyword-face "purple2")
    (set-face-foreground 'font-lock-function-name-face "blue")
    (set-face-foreground 'font-lock-variable-name-face "blue")
    (set-face-foreground 'font-lock-warning-face "Yellow")
    (set-face-foreground 'font-lock-type-face "red")
    (set-face-foreground 'font-lock-builtin-face "cyan")
    (set-face-foreground 'font-lock-constant-face "green")
    ))

;;Turn on colors for all
(global-font-lock-mode 1)

;;Abbreviations
(setq abbrev-file (expand-file-name "abbreviations.el" ext-dir))
(when (file-exists-p abbrev-file)
  (progn
    (setq-default abbrev-mode t)
    (read-abbrev-file abbrev-file)
    (setq save-abbrevs t)))

;;Setup Backup
(setq make-backup-files t)
(setq version-control t)
(setq delete-old-versions t)
(setq kept-new-versions 2)
(setq kept-old-versions 1)
(setq backup-directory-alist (list (cons ".*" backups-dir)))

;;Setup Autosave Files
(defun auto-save-file-name-p (filename)  (string-match "^#.*#$" (file-name-nondirectory filename)))
(defun make-auto-save-file-name ()
  (concat autosaves-dir
          (if buffer-file-name
              (concat "#" (file-name-nondirectory buffer-file-name) "#")
            (expand-file-name
             (concat "#%" (buffer-name) "#")))))


;; Enable line and column numbering
(line-number-mode 1)
(column-number-mode 1)

;; Wrap lines when the cursor goes beyond the column limit
(setq auto-fill-mode 1)

;; Let the default mode be text mode
(setq default-major-mode 'text-mode)

;;Fix Ctrl-Left and Ctrl-Right
(global-set-key "\M-[1;5C"    'forward-word) ; Ctrl+right   => forward word
(global-set-key "\M-[1;5D"    'backward-word) ; Ctrl+left    => backward word
;; Make sure backspace and delete works as expected

;;(normal-erase-is-backspace-mode 1)


;;Save some space exept when running in x window
(cond
 ((string= "x" window-system) (menu-bar-mode t) )
 ( t (menu-bar-mode 0) )
 )

;;Programming
;;define C-c C-c as the key to save and compile
;;(defun my-save-and-compile ()
;;  (interactive "")
;;  (save-buffer 0)
;;  (compile "make -k"))

;;(define-key c++-mode-map "\C-c\C-c" 'my-save-and-compile)
;;(define-key c-mode-map "\C-c\C-c" 'my-save-and-compile)


;;Use "%" to jump to the matching parenthesis.
(defun goto-match-paren (arg)
  "Go to the matching parenthesis if on parenthesis, otherwise insert the character typed."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        (t                    (self-insert-command (or arg 1))) ))
(global-set-key "%" `goto-match-paren)


;;Global Key Bindings
(global-set-key "\C-x\C-c"      'goto-line)
(global-set-key "\C-x\C-v"      'find-tag)

;;Config File Extensions
;;Auto-mode list
(setq auto-mode-alist
      (append '(("\\.cxx$"        .       c++-mode)
                ("\\.CPP$"        .       c++-mode)
                ("\\.cc$"         .       c++-mode)
                ("\\.css$"        .       css-mode)
                ("\\.cs$"         .       java-mode)
                ("\\.js$"         .       javascript-mode)
                ("\\.tex$"        .       tex-mode)
                ("\\.C$"          .       c++-mode)
                ("\\.c$"          .       c-mode)
                ("\\.h$"          .       c++-mode)
                ("\\.java$"       .       java-mode)
                ("\\.emacs$"      .       emacs-lisp-mode)
                ("\\.kan$"        .       java-mode)
                ("\\.pl$"         .       cperl-mode)
                ("\\.xml$"        .       xml-mode)
                ("\\.pm$"         .       cperl-mode)
                ("\\.emacs$"      .       emacs-lisp-mode)
                ("make_[a-z]*$"   .       makefile-mode)
                ("Make_[a-z]*$"   .       makefile-mode)
                ("\\.txt$"        .       text-mode)
                ("\\.php$"        .       php-mode)
                ("\\.inc$"        .       php-mode)
                ("\\.html$"       .       html-mode)
                ("\\.lp$"         .       lisp-interaction-mode))
              auto-mode-alist))

;;Config C++
(defun my-cc-c++-hook ()
  ;; already default (font-lock-mode t)
  ;; already default (abbrev-mode t)
  (c-set-style "ellemtel")
  (setq c-indent-level 4 )
  (ggtags-mode 1)
  )
(add-hook 'c++-mode-hook 'my-cc-c++-hook)


(defun indent-whole-buffer ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

(global-set-key (kbd "<f12>") 'indent-whole-buffer)
(setq initial-scratch-message "")  ;; no need to show me what scratch is for
(setq visible-bell t) ;; get rid of beeps


