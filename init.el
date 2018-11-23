;;; init.el --- init file of this emacs dotfile, named LokEmacs for fun
;; Author: Mathias Bøe
;; Created: September 2018
;; Keywords: LokEmacs, emacs, dotfile, mathias, boe, bøe, dotfiles
;; URL: www.github.com/mrboen94/dotfiles
;;; Code:

;; This is an alist that helps emacs starting up faster, makes conifguration of packages very modular.
(setq package-archives
  '(("gnu" . "https://elpa.gnu.org/packages/")
    ("melpa" . "https://melpa.org/packages/")
    ("org" . "https://orgmode.org/elpa/")))
;; Prefer newer packages and load them
(setq-default load-prefer-newer t
	      use-package-always-ensure t
	      package-enable-at-startup nil)

;; Initialize package settings
(package-initialize)

;; Makes sure the use-package are ready when you start emacs
(eval-when-compile
  (require 'use-package))
(package-initialize)

;; Increase memory emacs is allowed to use, boosts the startup time slightly.
(setq gc-cons-threshold 10000000)

;; Restore after startup
(add-hook 'after-init-hook
          (lambda ()
            (setq gc-cons-threshold 10000000)
            (message "gc-cons-threshold restored to %S"
            gc-cons-threshold)))

;; prevent help screen on startup
(setq inhibit-startup-screen t)

;; Custom bindings, search for keybindings to find custom binds further down
(defvar lokemacs-leader-key "SPC"
  "The default leader key for LokEmacs.")

(defvar lokemacs-leader-secondary-key "C-SPC"
  "The secondary leader key for LokEmacs.")

(defvar lokemacs-major-leader-key ","
  "The default major mode leader key for LokEmacs.")

(defvar lokemacs-major-leader-secondary-key "M-,"
  "The secondary major mode leader key for LokEmacs.")

;; Mac settings for  command and right alt.
(when (eq system-type 'darwin)
	  (setq mac-right-command-modifier 'meta
		mac-right-option-modifier 'none))

;; Lets remove som clutter and customize some visual stuff
(global-visual-line-mode 1)
(tool-bar-mode -1)
(add-hook 'before-save-hook 'delete-trailing-whitespace) ; Delete whitespace at end of lines
(set-frame-font "Iosevka" nil t)                         ; Change the font
(setq ring-bell-function 'ignore)
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)) ; Imporve look and feel
(add-to-list 'default-frame-alist '(ns-appearance . dark))        ; Imporve look and feel
(global-hl-line-mode 1)
(add-to-list 'default-frame-alist '(width . 110))         ; Size of LokEmacs at startup
(add-to-list 'default-frame-alist '(height . 80))        ; Size of LokEmacs at startup
(when (version<= "26.0.50" emacs-version )
  (setq-default display-line-numbers 'visual
		display-line-numbers-current-absolute t
		display-line-numbers-width 4
		display-line-numbers-widen nil))
(setq initial-scratch-message ";;     +-+-+-+-+-+-+-+-+
;;     |L|o|k|E|m|a|c|s|
;;     +-+-+-+-+-+-+-+-+
;; Press \"SPC f f\" to start!
")

;; Makes yes or no functions shorter.
(defalias 'yes-or-no-p 'y-or-n-p)

(setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
      backup-by-copying t    ; Don't delink hardlinks
      version-control t      ; Use version numbers on backups
      delete-old-versions t  ; Automatically delete excess backups
      kept-new-versions 20   ; how many of the newest versions to keep
      kept-old-versions 5    ; and how many of the old
      )


;; Use evil mode (vim)
(use-package evil
  :ensure t
  :demand t
  :config
  (evil-mode 1))

(use-package smex)

(use-package ivy
  :diminish ivy-mode
  :config
  (ivy-mode t))

;; Say no to the updog boys (^)
(setq ivy-initial-inputs-alist nil)

(use-package ivy-hydra)

(use-package which-key
  :diminish which-key-mode
  :config
  (add-hook 'after-init-hook 'which-key-mode))

(use-package undo-tree
  :defer 5
  :diminish global-undo-tree-mode
  :config
  (global-undo-tree-mode 1))

;; Used for jumping around in text or lines
(use-package avy)

(use-package ace-window
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

(use-package expand-region
  :bind ("C-=" . er/expand-region))

(use-package neotree
  :config
  (global-set-key (kbd "C-c t") 'neotree-toggle))
(setq neo-smart-open t)
(setq neo-theme 'arrow)


(use-package feebleline
  :config
  (feebleline-mode 't))

(use-package emojify)

;; Removes syntax highlighting for everything except the line the cursor is on
(use-package focus)

;; parents of all colors
(use-package smartparens
  :diminish smartparens-mode
  :config
  (add-hook 'prog-mode-hook 'smartparens-mode))

(use-package rainbow-delimiters
  :config
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package rainbow-mode
  :config
  (setq rainbow-x-colors nil)
  (add-hook 'prog-mode-hook 'rainbow-mode))

(use-package general
  :demand t
  :commands (general-define-key general-override-mode general-evil-setup general--simulate-keys)
  :config
  (progn
    (setq general-override-states '(insert emacs hybrid normal visual motion operator replace))
    (general-override-mode)
    (general-evil-setup)
    (general-create-definer lokemacs-leader
			    :states '(normal insert emacs)
			    :prefix lokemacs-leader-key
			    :non-normal-prefix lokemacs-leader-secondary-key)
    (general-create-definer lokemacs-major-leader
			    :states '(normal insert emacs)
			    :prefix lokemacs-major-leader-key
			    :non-normal-prefix lokemacs-major-leader-secondary-key)
    (general-nmap "SPC m" (general-simulate-key "," :which-key "major mode"))))

;; Keybindings and counsel
(use-package counsel
  :commands (counsel-mode)
  :demand t
  :delight
  :general
  (:keymaps 'ivy-mode-map
	    [remap find-file]                'counsel-find-file
            [remap recentf]                  'counsel-recentf
            [remap imenu]                    'counsel-imenu
            [remap bookmark-jump]            'counsel-bookmark
            [remap execute-extended-command] 'counsel-M-x
            [remap describe-function]        'counsel-describe-function
            [remap describe-variable]        'counsel-describe-variable
            [remap describe-face]            'counsel-describe-face
	    [remap eshell-list-history]      'counsel-esh-history))

  (lokemacs-leader
  "SPC" '(counsel-M-x :wk "M-x")
  "<tab>" '(evil-next-buffer :wk "Next buffer")
  "<backtab>" '(evil-prev-buffer :wk "Prev buffer")
  "a" '(:ignore t :wk "applications")
  "b" '(:ignore t :wk "buffers")
  "b b" '(split-to-buffer :wk "New window buffer")
  "b s" '(switch-to-buffer :wk "Switch buffer")
  "b k" '(kill-buffer :wk "Kill buffer")
  "f" '(:ignore f :wk "Files")
  "f e d" '(find-config :wk "Open init file")
  "f s" '(save-buffer :wk "Save/write")
  "f f" '(find-file :wl "find file")
  "g" '(:ignore t :wk "git")
  "h" '(:ignore t :wk "help")
  "w" '(:ignore t :wk "windows")
  "w o" '(delete-other-windows :wk "Delete other window")
  "w h" '(evil-window-left :wk "Left window")
  "w j" '(evil-window-down :wk "Window down")
  "w k" '(evil-window-up :wk "Window up")
  "w l" '(evil-window-right :wk "Window right")
  "w s j" '(split-window-below :wk "Split down")
  "w s k" '(split-window-above :wk "Split above")
  "w s v" '(split-window-horizontally :wk "Split vertically")
  "w s h" '(split-window-vertically :wk "Split horizontally")
  "w d" '(delete-window :wk "Delete current window")
  "w m" '(maximize-window :wk "Maximize current window")
  "w b" '(balance-windows :wk "Balance windows")
  "q" '(:ignore t :wk "quit/restart")
  "q q" '(evil-quit :wk "quit")
  "q r" '(restart-emacs :wk "Restart emacs")
  "t" '(:ignore t :wk "Toggles")
  "t t" '(neotree-toggle :wk "Toggle tree")
  "t w" '(writegood-mode :wk "Toggle Write good")
  "t o" '(org-mode :wk "Toggle org mode")
  "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
  "t p" '(org-toggle-pretty-entities :wk "Toggle pretty entities")
  "t i" '(org-toggle-inline-images :wk "Toggle inline images"))

(use-package swiper
  :bind (("M-s" . counsel-grep-or-swiper)))

;; Help me not dent my head while programming
(use-package aggressive-indent)
;; Parenting my parenthesis
(add-hook 'prog-mode-hook 'electric-pair-mode)

;; Help me dashing
(use-package smart-dash
  :config
  (add-hook 'python-mode-hook 'smart-dash-mode))

;; Fuzzy search
(use-package fzf)

(use-package exec-path-from-shell
  :ensure t
  :init (exec-path-from-shell-initialize))

(use-package magit
  :bind ("C-x g" . magit-status))

(use-package git-gutter
  :config
  (global-git-gutter-mode 't)
  :diminish git-gutter-mode)

(use-package git-timemachine)

(use-package web-mode
  :mode ("\\.html\\'")
  :config
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-engines-alist
        '(("django" . "focus/.*\\.html\\'")
          ("ctemplate" . "realtimecrm/.*\\.html\\'"))))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(use-package go-mode
  :config
  (add-hook 'before-save-hook 'gofmt-before-save)

  (use-package go-eldoc
    :config
    (add-hook 'go-mode-hook 'go-eldoc-setup))

  (use-package godoctor)

  (use-package go-guru))

(defun split-to-buffer ()
  (interactive)
  (let (($buf (generate-new-buffer "untitled")))
    (split-window-below)
    (other-window 1)
    (switch-to-buffer $buf)
    (initial-major-mode)
    $buf
    ))

(defun jc/go-guru-set-current-package-as-main ()
  "GoGuru requires the scope to be set to a go package which
   contains a main, this function will make the current package the
   active go guru scope, assuming it contains a main"
  (interactive)
  (let* ((filename (buffer-file-name))
         (gopath-src-path (concat (file-name-as-directory (go-guess-gopath)) "src"))
         (relative-package-path (directory-file-name (file-name-directory (file-relative-name filename gopath-src-path)))))
    (setq go-guru-scope relative-package-path)))

;; Haskell
(use-package haskell-mode)
(use-package hindent)
(use-package ghc
  :config
  (add-hook 'haskell-mode-hook (lambda () (ghc-init))))

(use-package company-ghc
  :config
  (add-to-list 'company-backends 'company-ghc))

;; Python
(use-package anaconda-mode
  :config
  (add-hook 'python-mode-hook 'anaconda-mode)
  (add-hook 'python-mode-hook 'anaconda-eldoc-mode))

;; C/C++
(use-package irony
  :hook (c-mode . irony-mode))
(use-package company-irony
  :config
  (add-to-list 'company-backends 'company-irony))
(use-package flycheck-irony
  :hook (flycheck-mode . flycheck-irony-setup))

;; C#
(use-package csharp-mode)
(use-package omnisharp
  :hook ((csharp-mode . omnisharp-mode)
         (before-save . omnisharp-code-format-entire-file))
  :config
  (add-to-list 'company-backends 'company-omnisharp))

;; Org
(setq org-startup-indented 'f)
(setq org-directory "~/org")
(setq org-special-ctrl-a/e 't)
(setq org-default-notes-file (concat org-directory "/notes.org"))
(define-key global-map "\C-cc" 'org-capture)
(setq org-mobile-directory "~/Dropbox/Apps/MobileOrg")
(setq org-src-fontify-natively 't)
(setq org-src-tab-acts-natively t)
(setq org-src-window-setup 'current-window)
;; Org customization
(use-package org-bullets
  :config
  (setq org-bullets-bullet-list '("∙"))
  (add-hook 'org-mode-hook 'org-bullets-mode))
;; Org customization
(let*
    ((variable-tuple (cond
                      ((x-list-fonts "Source Sans Pro") '(:font "Source Sans Pro"))
                      ((x-list-fonts "Lucida Grande")   '(:font "Lucida Grande"))
                      ((x-list-fonts "Verdana")         '(:font "Verdana"))
                      ((x-family-fonts "Sans Serif")    '(:family "Sans Serif"))
                      (nil (warn "Cannot find a Sans Serif Font.  Install Source Sans Pro."))))
     (base-font-color     (face-foreground 'default nil 'default))
     (headline           `(:inherit default :weight normal :foreground ,base-font-color)))

  (custom-theme-set-faces 'user
                          `(org-level-8 ((t (,@headline ,@variable-tuple))))
                          `(org-level-7 ((t (,@headline ,@variable-tuple))))
                          `(org-level-6 ((t (,@headline ,@variable-tuple))))
                          `(org-level-5 ((t (,@headline ,@variable-tuple))))
                          `(org-level-4 ((t (,@headline ,@variable-tuple))))
                          `(org-level-3 ((t (,@headline ,@variable-tuple :height 1.33))))
                          `(org-level-2 ((t (,@headline ,@variable-tuple :height 1.33))))
                          `(org-level-1 ((t (,@headline ,@variable-tuple :height 1.33 ))))
                          `(org-document-title ((t (,@headline ,@variable-tuple :height 1.33 :underline nil))))))

;; Make html nice again
(use-package ox-twbs)

;; General writing
(use-package writegood-mode
  :bind ("C-c g" . writegood-mode)
  :config
  (add-to-list 'writegood-weasel-words "actionable"))

;; Stack overflow (will be deleted at some point, its never used)
(use-package sx
  :config
  (bind-keys :prefix "C-c s"
             :prefix-map my-sx-map
             :prefix-docstring "Global keymap for SX."
             ("q" . sx-tab-all-questions)
             ("i" . sx-inbox)
             ("o" . sx-open-link)
             ("u" . sx-tab-unanswered-my-tags)
             ("a" . sx-ask)
             ("s" . sx-search)))


;;; Custom functions
(defun find-config()                         ; Shortcut to init file--------
  "Edit config.org"
  (interactive)
  (find-file "~/.emacs.d/init.el"))

(defun my--switch-buffer (&optional window)  ; Switch buffers function-------
  (interactive)
  (let ((current-buffer (window-buffer window))
        (buffer-predicate
         (frame-parameter (window-frame window) 'buffer-predicate)))
    ;; switch to first buffer previously shown in this window that matches
    ;; frame-parameter `buffer-predicate'
    (switch-to-buffer
     (or (cl-find-if (lambda (buffer)
                       (and (not (eq buffer current-buffer))
                            (or (null buffer-predicate)
                                (funcall buffer-predicate buffer))))
                     (mapcar #'car (window-prev-buffers window)))
         ;; `other-buffer' honors `buffer-predicate' so no need to filter
         (other-buffer current-buffer t)))))


(use-package restart-emacs
  :config
  ;; Restart emacs with current buffers (PS: BETA)
  (setq restart-emacs-restore-frames 't))
;;  (global-set-key "\C-c\C-q" 'restart-emacs))


;;(Custom-set-faces)
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
;;  (default ((t (:inherit nil :stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 130 :width normal :foundry "nil" :family "iosevka"))))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#e090d7" "#8cc4ff" "#eeeeec"])
 '(custom-enabled-themes (quote (dracula)))
 '(custom-safe-themes
   (quote
    ("3a3de615f80a0e8706208f0a71bbcc7cc3816988f971b6d237223b6731f91605" "aaffceb9b0f539b6ad6becb8e96a04f2140c8faa1de8039a343a4f1e009174fb" default)))
 '(package-selected-packages
   (quote
    (htmlize ivy use-package evil-leader org-agenda-property restart-emacs which-key helm doom-themes dracula-theme evil org))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-document-title ((t (:inherit default :weight normal :foreground "#E6E6E6" :font "Lucida Grande" :height 1.33 :underline nil))))
 '(org-level-1 ((t (:inherit default :background "#1d1f20" :foreground "#A83434" :slant normal :weight normal :height 1.33 :width normal :foundry "nil" :family "Lucida Grande"))))
 '(org-level-2 ((t (:inherit default :foreground "#D43C47" :slant normal :weight normal :height 1.33 :width normal :foundry "nil" :family "Lucida Grande"))))
 '(org-level-3 ((t (:inherit default :foreground "#EF553C" :slant normal :weight normal :height 1.33 :width normal :foundry "nil" :family "Lucida Grande"))))
 '(org-level-4 ((t (:inherit default :foreground "#F37717" :slant normal :weight normal :height 120 :width normal :foundry "nil" :family "Lucida Grande"))))
 '(org-level-5 ((t (:inherit default :foreground "#F68E00" :slant normal :weight normal :height 120 :width normal :foundry "nil" :family "Lucida Grande"))))
 '(org-level-6 ((t (:inherit default :foreground "#FBAF00" :slant normal :weight normal :height 120 :width normal :foundry "nil" :family "Lucida Grande"))))
 '(org-level-7 ((t (:inherit default :foreground "#F4D128" :slant normal :weight normal :height 120 :width normal :foundry "nil" :family "Lucida Grande"))))
 '(org-level-8 ((t (:inherit default :foreground "#F1D700" :slant normal :weight normal :height 120 :width normal :foundry "nil" :family "Lucida Grande")))))
;;; filename ends here
