;; where emacs backup and autosave files go
(setq env_home_dir (if (stringp (getenv "ENV_HOME_DIR")) (getenv "ENV_HOME_DIR") (expand-file-name "~/env")))
(setq env_data_dir (if (stringp (getenv "ENV_DATA_DIR")) (getenv "ENV_DATA_DIR") (expand-file-name "~/.env")))
;;(defconst backups-dir (concat env_home_dir "/data/emacs/backups"))
(defconst autosaves-dir (concat env_data_dir "/data/emacs/autosaves"))
(defconst ext-modules-dir (concat env_data_dir "/ext/emacs/modules"))
(defconst data-dir (concat env_data_dir "/data/emacs"))
(setq user-emacs-directory data-dir)

;; (setq is-mac (equal system-type 'darwin))
;; (when is-mac ... do something)

;; create backup and autosave directories if not created already
;;(make-directory backups-dir t)
(make-directory autosaves-dir t)
(add-to-list 'load-path ext-modules-dir)

;;(setq backup-directory-alist (list (cons ".*" backups-dir)))

;; Setup Autosave Files
(defun auto-save-file-name-p (filename)  (string-match "^#.*#$" (file-name-nondirectory filename)))
(defun make-auto-save-file-name ()
  (concat autosaves-dir
          (if buffer-file-name
              (concat "/#" (file-name-nondirectory buffer-file-name) "#")
            (expand-file-name
             (concat "/#%" (buffer-name) "#")))))


;;When moving to another screen using up or down arrow don't move the cursor
;;keep it either at the bottom when moving down or at the top when moving up
(setq scroll-step 1)

;;Don't use tabs to indent lines, always use spaces
(setq-default indent-tabs-mode nil)
(setq tab-width 4)
(setq-default tab-always-indent 'complete)

;; default to better frame titles
(setq frame-title-format (concat  "%b - emacs@" system-name))

(defun set-light-colors ()
  (set-face-background 'region "DodgerBlue2")
  (set-face-foreground 'font-lock-string-face "Red")
  (set-face-foreground 'font-lock-comment-face "Purple2")
  (set-face-foreground 'font-lock-keyword-face "purple2")
  (set-face-foreground 'font-lock-function-name-face "blue")
  (set-face-foreground 'font-lock-variable-name-face "blue")
  (set-face-foreground 'font-lock-warning-face "Yellow")
  (set-face-foreground 'font-lock-type-face "red")
  (set-face-foreground 'font-lock-builtin-face "cyan")
  (set-face-foreground 'font-lock-constant-face "green")
  (set-background-color "#FFFFFF")
  (set-foreground-color "black")
  (set-cursor-color "black")
    )
(defun set-dark-colors ()
  ;;Customize colors (To see the font lock applying to a point Ctrl-u Ctrl-x =)
  (set-face-background 'region "DodgerBlue2")
  (set-face-foreground 'font-lock-string-face "#76CB58")
  (set-face-foreground 'font-lock-comment-face "#629755")
  (set-face-foreground 'font-lock-keyword-face "#CC7832")
  (set-face-foreground 'font-lock-function-name-face "#3E7EFF")
  (set-face-foreground 'font-lock-variable-name-face "#FFC66D")
  (set-face-foreground 'font-lock-warning-face "#FFC66D")
  (set-face-foreground 'font-lock-type-face "#A9B7C6")
  (set-face-foreground 'font-lock-builtin-face "#BBB529")
  (set-face-foreground 'font-lock-constant-face "#6897BB")
  (set-background-color "black")
  (set-foreground-color "#FFFFFF")
  (set-cursor-color "#FFFFFF")
  )

(set-face-foreground 'mode-line "#ffffff")
(set-face-background 'mode-line "#5f5faf")
(set-face-foreground 'mode-line-inactive "#000000")
(set-face-background 'mode-line-inactive "#89aaf0")

(setenv "TZ" (getenv "LOCAL_TIME_ZONE"))
(defun set-current-theme ()
  (setq hour 
        (string-to-number 
         (substring (current-time-string) 11 13)))
  (if (member hour (number-sequence 6 18))
      ;;(set-light-colors)
      (set-dark-colors)
    (set-dark-colors)
    ))
(run-with-timer 0 3600 'set-current-theme)


;;Turn on colors for all
(global-font-lock-mode 1)

;;Abbreviations
(setq abbrev-file (expand-file-name "abbreviations.el" (concat env_home_dir "/emacs")))
(when (file-exists-p abbrev-file)
  (progn
    (setq-default abbrev-mode t)
    (read-abbrev-file abbrev-file)
    ;;(setq save-abbrevs t)
    ))

;;Setup Backup
(setq make-backup-files nil)
;;(setq make-backup-files t)
;;(setq version-control t)
;;(setq delete-old-versions t)
;;(setq kept-new-versions 2)
;;(setq kept-old-versions 1)


;;utf-8
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; delete the selection once we type something
(delete-selection-mode t)

;; Enable line and column numbering
(line-number-mode t)
(column-number-mode t)

;; Wrap lines when the cursor goes beyond the column limit
(setq auto-fill-mode 1)

;; Let the default mode be text mode
(setq default-major-mode 'text-mode)

;; Fix Ctrl-Left and Ctrl-Right (Opion-left and Option-right on macs)
(global-set-key "\M-[1;5C"    'forward-word) ; Ctrl+right   => forward word
(global-set-key "\M-[1;5D"    'backward-word) ; Ctrl+left    => backward word
;; Make sure backspace and delete works as expected

;;Save some space exept when running in x window
(cond
 ((string= "x" window-system) (menu-bar-mode t) )
 ( t (menu-bar-mode 0) ))

;;Use "%" to jump to the matching parenthesis.
(defun goto-match-paren (arg)
  "Go to the matching parenthesis if on parenthesis, otherwise insert the character typed."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        (t                    (self-insert-command (or arg 1))) ))
(global-set-key "%" `goto-match-paren)


;;Global Key Bindings
(global-set-key (kbd "M-i") 'imenu)
(global-set-key "\C-x\C-g" 'goto-line)
(global-set-key "\C-x\C-c" 'comment-line)
(global-set-key "\C-x\C-v" 'find-tag)
(global-set-key "\C-x\C-o" 'occur)
(global-set-key "\C-x\C-r" 'run-current-file)
(global-set-key "\C-c+" 'v-resize)
(global-set-key "\C-c|" 'h-resize)
;;(global-set-key "\C-c\C-c" 'compile)


;; from https://www.emacswiki.org/emacs/WindowResize
(defun v-resize (key)
  "interactively resize the window"
  (interactive "cHit +/- to enlarge/shrink")
  (cond
   ((eq key (string-to-char "+"))
    (enlarge-window 1)
    (call-interactively 'v-resize))
   ((eq key (string-to-char "-"))
    (enlarge-window -1)
    (call-interactively 'v-resize))
   (t (push key unread-command-events))))
(defun h-resize (key)
  "interactively resize the window"
  (interactive "cHit +/- to enlarge/shrink")
  (cond
   ((eq key (string-to-char "+"))
    (enlarge-window-horizontally 1)
    (call-interactively 'h-resize))
   ((eq key (string-to-char "-"))
    (enlarge-window-horizontally -1)
    (call-interactively 'h-resize))
   (t (push key unread-command-events))))


;;Config C++
(require 'compile)

(defconst mine/custom-c-style
  '((c-tab-always-indent         . t)
    (c-hanging-braces-alist      . ((substatement-open after)
                                    (brace-list-open)))
    (c-hanging-colons-alist      . ((member-init-intro before)
                                    (inher-intro)
                                    (case-label after)
                                    (label after)
                                    (access-label after)))
    (c-cleanu-list               . (scope-operator
                                    empty-defun-braces
                                    defun-close-semi))
    (c-offsets-alist             . ((arglist-close . c-lineup-arglist)
                                    (substatement-open . 0)
                                    (case-label        . +)
                                    (block-open        . 0)
                                    (access-label      . -)
                                    (knr-argdecl-intro . -)))))

(c-add-style "mine" mine/custom-c-style)

(defun my-cc-c++-hook ()
  (abbrev-mode t)
  (c-set-style "mine")
  (c-set-offset 'innamespace '2)
  (c-set-offset 'inextern-lang '0)
  (c-set-offset 'inline-open '0)
  (c-set-offset 'label '*)
  (c-set-offset 'case-label '*)
  (c-set-offset 'access-label '/)
  (c-set-offset 'substatement-open 0)
  (c-set-offset 'case-label 2)
  (setq c-basic-offset 2)
  (setq tab-width 2)
  (setq c-indent-level 2 ))

(add-hook 'c-mode-hook 'my-cc-c++-hook)
(add-hook 'java-mode-hook 'my-cc-c++-hook)
(add-hook 'c++-mode-hook 'my-cc-c++-hook)


(defun indent-whole-buffer ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

(global-set-key (kbd "C-x C-i") 'indent-whole-buffer)
(setq initial-scratch-message "")  ;; no need to show me what scratch is for
(setq visible-bell t) ;; get rid of beeps

(fset 'yes-or-no-p 'y-or-n-p)
(setq message-log-max t)

(setq completion-ignored-extensions
      '(".o" ".elc" ".tgz" ".dvi" ".aux" ".ps" ".pyc" ".class" ".exe"))


(global-set-key [remap goto-line] 'goto-line-with-numbers)

(defun goto-line-with-numbers ()
  "Show line numbers while prompting for the number"
  (interactive)
  (unwind-protect
      (progn
        ;;(linum-mode 1)
        (global-display-line-numbers-mode 1)
        (goto-line (read-number "Goto line: ")))
                                        ;(linum-mode -1)
    (global-display-line-numbers-mode -1)
    ))

(defvar run-current-file-before-hook nil "Hook for `run-current-file'. Before the file is run.")
(defvar run-current-file-after-hook nil "Hook for `run-current-file'. After the file is run.")

;; http://ergoemacs.org/emacs/elisp_run_current_file.html
(defun run-current-file ()
  "Execute the current file."
  (interactive)
  (let (
        ($outputb "*run output*")
        (resize-mini-windows nil)
        ($suffix-map
         ;; (‹extension› . ‹shell program name›)
         `(
           ("php" . "php")
           ("pl" . "perl")
           ("py" . "python3")
           ("rb" . "ruby")
           ("sh" . "bash")
           ("java" . "javac")
           ))
        $fname
        $fSuffix
        $prog-name
        $cmd-str)
    (when (not (buffer-file-name)) (save-buffer))
    (when (buffer-modified-p) (save-buffer))
    (setq $fname (buffer-file-name))
    (setq $fSuffix (file-name-extension $fname))
    (setq $prog-name (cdr (assoc $fSuffix $suffix-map)))
    (setq $cmd-str (concat $prog-name " \""   $fname "\" &"))
    (run-hooks 'run-current-file-before-hook)
    (cond
     ((string-equal $fSuffix "el")
      (load $fname))
     ((or (string-equal $fSuffix "ts") (string-equal $fSuffix "tsx"))
      (if (fboundp 'ts-compile-file)
          (progn
            (ts-compile-file current-prefix-arg))
        (if $prog-name
            (progn
              (message "Running")
              (shell-command $cmd-str $outputb ))
          (error "No recognized program file suffix for this file."))))
     ((string-equal $fSuffix "java")
      (progn
        (shell-command (format "java %s" (file-name-sans-extension (file-name-nondirectory $fname))) $outputb )))
     (t (if $prog-name
            (progn
              (message "Running")
              (shell-command $cmd-str $outputb ))
          (error "No recognized program file suffix for this file."))))
    (run-hooks 'run-current-file-after-hook)))

;; https://www.emacswiki.org/emacs/WholeLineOrRegion
(put 'kill-ring-save 'interactive-form
     '(interactive
       (if (use-region-p)
           (list (region-beginning) (region-end))
         (list (line-beginning-position) (line-beginning-position 2)))))
(put 'kill-region 'interactive-form
     '(interactive
       (if (use-region-p)
           (list (region-beginning) (region-end))
         (list (line-beginning-position) (line-beginning-position 2)))))


;; https://www.emacswiki.org/emacs/SavePlace
(save-place-mode 1)

;; https://stackoverflow.com/questions/10266986/how-to-enable-show-paren-mode-only-for-el-files
(show-paren-mode)
(setq show-paren-mode ())
(defun show-paren-local-mode ()
  (interactive)
  (make-local-variable 'show-paren-mode)
  (setq show-paren-mode t))
(add-hook 'emacs-lisp-mode-hook 'show-paren-local-mode)

(global-set-key (kbd "M-/") 'hippie-expand)
(when (file-exists-p ext-modules-dir)
  (mapc 'load (directory-files ext-modules-dir nil "^[^#].*el$")))

;;(when (file-exists-p (concat ext-dir "/modules/php-mode.el"))
;;  (load (concat ext-dir "/modules/php-mode.el")))
;;(when (file-exists-p (concat ext-dir "/modules/markdown-mode.el"))
;;  (load (concat ext-dir "/modules/markdown-mode.el")))

;; slows down emacs startup
;; (when (>= emacs-major-version 24)
;; (require 'package)
;; (add-to-list
;; 'package-archives
;; '("MELPA" . "https://melpa.org/packages/") t)
;; (package-initialize)
;; (package-refresh-contents)
;; )



;; (defconst base-emacs-dir (concat env_home_dir "/emacs/custom"))
;; (add-to-list 'load-path (concat base-emacs-dir))
;; (when (file-exists-p base-emacs-dir)
;;   (mapc 'load (directory-files base-emacs-dir nil "^[^#].*el$")))


;; (add-hook 'c++-mode-hook
;;           (lambda ()
;;             (unless (file-exists-p "Makefile")
;;               (set (make-local-variable 'compile-command)
;;                    ;; $(CC) -c -o $@ $(CPPFLAGS) $(CFLAGS) $<
;;                    (let ((file (file-name-nondirectory buffer-file-name)))
;;                      (format "%s -c -o %s.o %s %s %s"
;;                              (or (getenv "CC") "gcc")
;;                              (file-name-sans-extension file)
;;                              (or (getenv "CPPFLAGS") "-DDEBUG=9")
;;                              (or (getenv "CFLAGS") "-ansi -pedantic -Wall -g")
;;                              file))))))
;; (add-hook 'java-mode-hook
;;           (lambda ()
;;             (unless (file-exists-p "pom.xml")
;;               (set (make-local-variable 'compile-command)
;;                    (let ((file (file-name-nondirectory buffer-file-name)))
;;                      (format "javac %s" file))))))

;; define C-x C-c as the key to save and compile
;; (defun my-save-and-compile ()
;;  (interactive "")
;;  (save-buffer 0)
;;  (compile "make -k"))

;; ;;(define-key c++-mode-map "\C-c\C-c" 'my-save-and-compile)
;;(define-key c-mode-map "\C-c\C-c" 'my-save-and-compile)

;;(normal-erase-is-backspace-mode 1)

;;Highlight currentline
;;(global-hl-line-mode 1)

;;Config File Extensions
;;Auto-mode list
;; (setq auto-mode-alist
      ;; (append '(("\\.cxx$"        .       c++-mode)
                ;; ("\\.CPP$"        .       c++-mode)
                ;; ("\\.cc$"         .       c++-mode)
                ;; ("\\.css$"        .       css-mode)
                ;; ("\\.cs$"         .       java-mode)
                ;; ("\\.js$"         .       javascript-mode)
                ;; ("\\.tex$"        .       tex-mode)
                ;; ("\\.C$"          .       c++-mode)
                ;; ("\\.c$"          .       c-mode)
                ;; ("\\.h$"          .       c++-mode)
                ;; ("\\.java$"       .       java-mode)
                ;; ("\\.emacs$"      .       emacs-lisp-mode)
                ;; ("\\.kan$"        .       java-mode)
                ;; ("\\.pl$"         .       cperl-mode)
                ;; ("\\.xml$"        .       xml-mode)
                ;; ("\\.pm$"         .       cperl-mode)
                ;; ("\\.emacs$"      .       emacs-lisp-mode)
                ;; ("make_[a-z]*$"   .       makefile-mode)
                ;; ("Make_[a-z]*$"   .       makefile-mode)
                ;; ("\\.txt$"        .       text-mode)
                ;; ("\\.md$"         .       markdown-mode)
                ;; ("\\.php$"        .       php-mode)
                ;; ("\\.inc$"        .       php-mode)
                ;; ("\\.html$"       .       html-mode)
                ;; ("\\.lp$"         .       lisp-interaction-mode))
              ;; auto-mode-alist))
