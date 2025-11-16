;; Auto-revert in Emacs is a feature that automatically updates the
;; contents of a buffer to reflect changes made to the underlying file
;; on disk.
(use-package autorevert
  :ensure nil
  :commands (auto-revert-mode global-auto-revert-mode)
  :hook
  (after-init . global-auto-revert-mode)
  :custom
  (auto-revert-interval 3)
  (auto-revert-remote-files nil)
  (auto-revert-use-notify t)
  (auto-revert-avoid-polling nil)
  (auto-revert-verbose t))

;; Recentf is an Emacs package that maintains a list of recently
;; accessed files, making it easier to reopen files you have worked on
;; recently.
(use-package recentf
  :ensure nil
  :commands (recentf-mode recentf-cleanup)
  :hook
  (after-init . recentf-mode)

  :custom
  (recentf-auto-cleanup (if (daemonp) 300 'never))
  (recentf-exclude
   (list "\\.tar$" "\\.tbz2$" "\\.tbz$" "\\.tgz$" "\\.bz2$"
         "\\.bz$" "\\.gz$" "\\.gzip$" "\\.xz$" "\\.zip$"
         "\\.7z$" "\\.rar$"
         "COMMIT_EDITMSG\\'"
         "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
         "-autoloads\\.el$" "autoload\\.el$"))

  :config
  ;; A cleanup depth of -90 ensures that `recentf-cleanup' runs before
  ;; `recentf-save-list', allowing stale entries to be removed before the list
  ;; is saved by `recentf-save-list', which is automatically added to
  ;; `kill-emacs-hook' by `recentf-mode'.
  (add-hook 'kill-emacs-hook #'recentf-cleanup -90))

;; savehist is an Emacs feature that preserves the minibuffer history between
;; sessions. It saves the history of inputs in the minibuffer, such as commands,
;; search strings, and other prompts, to a file. This allows users to retain
;; their minibuffer history across Emacs restarts.
(use-package savehist
  :ensure nil
  :commands (savehist-mode savehist-save)
  :hook
  (after-init . savehist-mode)
  :custom
  (savehist-autosave-interval 600)
  (savehist-additional-variables
   '(kill-ring                        ; clipboard
     register-alist                   ; macros
     mark-ring global-mark-ring       ; marks
     search-ring regexp-search-ring)))

;; save-place-mode enables Emacs to remember the last location within a file
;; upon reopening. This feature is particularly beneficial for resuming work at
;; the precise point where you previously left off.
(use-package saveplace
  :ensure nil
  :commands (save-place-mode save-place-local-mode)
  :hook
  (after-init . save-place-mode)
  :custom
  (save-place-limit 400))


;; Corfu enhances in-buffer completion by displaying a compact popup with
;; current candidates, positioned either below or above the point. Candidates
;; can be selected by navigating up or down.
(use-package corfu
  :ensure t
  :commands (corfu-mode global-corfu-mode)

  :hook ((prog-mode . corfu-mode)
         (shell-mode . corfu-mode)
         (eshell-mode . corfu-mode))

  :custom
  ;; Hide commands in M-x which do not apply to the current mode.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Disable Ispell completion function. As an alternative try `cape-dict'.
  (text-mode-ispell-word-completion nil)
  (tab-always-indent 'complete)

  ;; Enable Corfu
  :config
  (global-corfu-mode))

;; Cape, or Completion At Point Extensions, extends the capabilities of
;; in-buffer completion. It integrates with Corfu or the default completion UI,
;; by providing additional backends through completion-at-point-functions.
(use-package cape
  :ensure t
  :commands (cape-dabbrev cape-file cape-elisp-block)
  :bind ("C-c p" . cape-prefix-map)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block))


;; Vertico provides a vertical completion interface, making it easier to
;; navigate and select from completion candidates (e.g., when `M-x` is pressed).
(use-package vertico
  ;; (Note: It is recommended to also enable the savehist package.)
  :ensure t
  :config
  (vertico-mode))

;; Vertico leverages Orderless' flexible matching capabilities, allowing users
;; to input multiple patterns separated by spaces, which Orderless then
;; matches in any order against the candidates.
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; Marginalia allows Embark to offer you preconfigured actions in more contexts.
;; In addition to that, Marginalia also enhances Vertico by adding rich
;; annotations to the completion candidates displayed in Vertico's interface.
(use-package marginalia
  :ensure t
  :commands (marginalia-mode marginalia-cycle)
  :hook (after-init . marginalia-mode))

;; Embark integrates with Consult and Vertico to provide context-sensitive
;; actions and quick access to commands based on the current selection, further
;; improving user efficiency and workflow within Emacs. Together, they create a
;; cohesive and powerful environment for managing completions and interactions.
(use-package embark
  ;; Embark is an Emacs package that acts like a context menu, allowing
  ;; users to perform context-sensitive actions on selected items
  ;; directly from the completion interface.
  :ensure t
  :commands (embark-act
             embark-dwim
             embark-export
             embark-collect
             embark-bindings
             embark-prefix-help-command)
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init
  (setq prefix-help-command #'embark-prefix-help-command)

  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))


(use-package embark-consult
  :ensure t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; Consult offers a suite of commands for efficient searching, previewing, and
;; interacting with buffers, file contents, and more, improving various tasks.
(use-package consult
  :ensure t
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ("C-x t b" . consult-buffer-other-tab)
         ("C-x r b" . consult-bookmark)
         ("C-x p b" . consult-project-buffer)
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g o" . consult-outline)
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)
         ("M-s e" . consult-isearch-history)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)
         ("M-r" . consult-history))

  ;; Enable automatic preview at point in the *Completions* buffer.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  :init
  ;; Optionally configure the register formatting. This improves the register
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Aggressive asynchronous that yield instantaneous results. (suitable for
  ;; high-performance systems.) Note: Minad, the author of Consult, does not
  ;; recommend aggressive values.
  ;; Read: https://github.com/minad/consult/discussions/951
  ;;
  ;; However, the author of minimal-emacs.d uses these parameters to achieve
  ;; immediate feedback from Consult.
  ;; (setq consult-async-input-debounce 0.02
  ;;       consult-async-input-throttle 0.05
  ;;       consult-async-refresh-delay 0.02)

  :config
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))
  (setq consult-narrow-key "<"))


(mapc #'disable-theme custom-enabled-themes)  ; Disable all active themes
(load-theme 'modus-operandi t)  ; Load the built-in theme
  
;; Set up the Language Server Protocol (LSP) servers using Eglot.
(use-package eglot
  :ensure nil
  :commands (eglot-ensure
             eglot-rename
             eglot-format-buffer))

;; Org mode is a major mode designed for organizing notes, planning, task
;; management, and authoring documents using plain text with a simple and
;; expressive markup syntax. It supports hierarchical outlines, TODO lists,
;; scheduling, deadlines, time tracking, and exporting to multiple formats
;; including HTML, LaTeX, PDF, and Markdown.
(use-package org
  :ensure t
  :commands (org-mode org-version)
  :mode
  ("\\.org\\'" . org-mode)
  :custom
  (org-hide-leading-stars t)
  (org-startup-indented t)
  (org-adapt-indentation nil)
  (org-edit-src-content-indentation 0)
  ;; (org-fontify-done-headline t)
  ;; (org-fontify-todo-headline t)
  ;; (org-fontify-whole-heading-line t)
  ;; (org-fontify-quote-and-verse-blocks t)
  (org-startup-truncated t))


;; The markdown-mode package provides a major mode for Emacs for syntax
;; highlighting, editing commands, and preview support for Markdown documents.
;; It supports core Markdown syntax as well as extensions like GitHub Flavored
;; Markdown (GFM).
(use-package markdown-mode
  :commands (gfm-mode
             gfm-view-mode
             markdown-mode
             markdown-view-mode)
  :mode (("\\.markdown\\'" . markdown-mode)
         ("\\.md\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :bind
  (:map markdown-mode-map
        ("C-c C-e" . markdown-do)))


;; Tree-sitter in Emacs is an incremental parsing system introduced in Emacs 29
;; that provides precise, high-performance syntax highlighting. It supports a
;; broad set of programming languages, including Bash, C, C++, C#, CMake, CSS,
;; Dockerfile, Go, Java, JavaScript, JSON, Python, Rust, TOML, TypeScript, YAML,
;; Elisp, Lua, Markdown, and many others.
(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))


;; This automates the process of updating installed packages
(use-package auto-package-update
  :ensure t
  :custom
  ;; Set the number of days between automatic updates.
  ;; Here, packages will only be updated if at least 7 days have passed
  ;; since the last successful update.
  (auto-package-update-interval 7)

  ;; Suppress display of the *auto-package-update results* buffer after updates.
  ;; This keeps the user interface clean and avoids unnecessary interruptions.
  (auto-package-update-hide-results t)

  ;; Automatically delete old package versions after updates to reduce disk
  ;; usage and keep the package directory clean. This prevents the accumulation
  ;; of outdated files in Emacs’s package directory, which consume
  ;; unnecessary disk space over time.
  (auto-package-update-delete-old-versions t)

  ;; Uncomment the following line to enable a confirmation prompt
  ;; before applying updates. This can be useful if you want manual control.
  ;; (auto-package-update-prompt-before-update t)

  :config
  ;; Run package updates automatically at startup, but only if the configured
  ;; interval has elapsed.
  (auto-package-update-maybe)

  ;; Schedule a background update attempt daily at 10:00 AM.
  ;; This uses Emacs' internal timer system. If Emacs is running at that time,
  ;; the update will be triggered. Otherwise, the update is skipped for that
  ;; day. Note that this scheduled update is independent of
  ;; `auto-package-update-maybe` and can be used as a complementary or
  ;; alternative mechanism.
  (auto-package-update-at-time "10:00"))

;; Helpful is an alternative to the built-in Emacs help that provides much more
;; contextual information.
(use-package helpful
  :ensure t
  :commands (helpful-callable
             helpful-variable
             helpful-key
             helpful-command
             helpful-at-point
             helpful-function)
  :bind
  ([remap describe-command] . helpful-command)
  ([remap describe-function] . helpful-callable)
  ([remap describe-key] . helpful-key)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  :custom
  (helpful-max-buffers 7))

;; Set the default font to Maple Mono NF CN with specific size and weight
(set-face-attribute 'default nil
                    :height 110 :weight 'normal :family "Maple Mono NF CN")

;; Allow Emacs to upgrade built-in packages, such as Org mode
(setq package-install-upgrade-built-in t)

;; When Delete Selection mode is enabled, typed text replaces the selection
;; if the selection is active.
(delete-selection-mode 1)

;; Display the current line and column numbers in the mode line
(setq line-number-mode t)
(setq column-number-mode t)
(setq mode-line-position-column-line-format '("%l:%C"))

;; Display of line numbers in the buffer:
(setq-default display-line-numbers-type 'relative)
(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook #'display-line-numbers-mode))

;; Set the maximum level of syntax highlighting for Tree-sitter modes
(setq treesit-font-lock-level 4)

(use-package which-key
  :ensure nil ; builtin
  :commands which-key-mode
  :hook (after-init . which-key-mode)
  :custom
  (which-key-idle-delay 1.5)
  (which-key-idle-secondary-delay 0.25)
  (which-key-add-column-padding 1)
  (which-key-max-description-length 40))

(unless (and (eq window-system 'mac)
             (bound-and-true-p mac-carbon-version-string))
  ;; Enables `pixel-scroll-precision-mode' on all operating systems and Emacs
  ;; versions, except for emacs-mac.
  ;;
  ;; Enabling `pixel-scroll-precision-mode' is unnecessary with emacs-mac, as
  ;; this version of Emacs natively supports smooth scrolling.
  ;; https://bitbucket.org/mituharu/emacs-mac/commits/65c6c96f27afa446df6f9d8eff63f9cc012cc738
  (setq pixel-scroll-precision-use-momentum nil) ; Precise/smoother scrolling
  (pixel-scroll-precision-mode 1))

;; Display the time in the modeline
(add-hook 'after-init-hook #'display-time-mode)

;; Paren match highlighting
(add-hook 'after-init-hook #'show-paren-mode)

;; Track changes in the window configuration, allowing undoing actions such as
;; closing windows.
(add-hook 'after-init-hook #'winner-mode)

(use-package uniquify
  :ensure nil
  :custom
  (uniquify-buffer-name-style 'reverse)
  (uniquify-separator "•")
  (uniquify-after-kill-buffer-p t))

;; Window dividers separate windows visually. Window dividers are bars that can
;; be dragged with the mouse, thus allowing you to easily resize adjacent
;; windows.
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Window-Dividers.html
(add-hook 'after-init-hook #'window-divider-mode)

;; Constrain vertical cursor movement to lines within the buffer
(setq dired-movement-style 'bounded-files)

;; Dired buffers: Automatically hide file details (permissions, size,
;; modification date, etc.) and all the files in the `dired-omit-files' regular
;; expression for a cleaner display.
(add-hook 'dired-mode-hook #'dired-hide-details-mode)

;; Hide files from dired
(setq dired-omit-files (concat "\\`[.]\\'"
                               "\\|\\(?:\\.js\\)?\\.meta\\'"
                               "\\|\\.\\(?:elc|a\\|o\\|pyc\\|pyo\\|swp\\|class\\)\\'"
                               "\\|^\\.DS_Store\\'"
                               "\\|^\\.\\(?:svn\\|git\\)\\'"
                               "\\|^\\.ccls-cache\\'"
                               "\\|^__pycache__\\'"
                               "\\|^\\.project\\(?:ile\\)?\\'"
                               "\\|^flycheck_.*"
                               "\\|^flymake_.*"))
(add-hook 'dired-mode-hook #'dired-omit-mode)

;; dired: Group directories first
(with-eval-after-load 'dired
  (let ((args "--group-directories-first -ahlv"))
    (when (or (eq system-type 'darwin) (eq system-type 'berkeley-unix))
      (if-let* ((gls (executable-find "gls")))
          (setq insert-directory-program gls)
        (setq args nil)))
    (when args
      (setq dired-listing-switches args))))

;; Enables visual indication of minibuffer recursion depth after initialization.
(add-hook 'after-init-hook #'minibuffer-depth-indicate-mode)

;; Configure Emacs to ask for confirmation before exiting
(setq confirm-kill-emacs 'y-or-n-p)

;; Enabled backups save your changes to a file intermittently
(setq make-backup-files t)
(setq vc-make-backup-files t)
(setq kept-old-versions 10)
(setq kept-new-versions 10)

;; When tooltip-mode is enabled, certain UI elements (e.g., help text,
;; mouse-hover hints) will appear as native system tooltips (pop-up windows),
;; rather than as echo area messages. This is useful in graphical Emacs sessions
;; where tooltips can appear near the cursor.
(setq tooltip-hide-delay 20)    ; Time in seconds before a tooltip disappears (default: 10)
(setq tooltip-delay 0.4)        ; Delay before showing a tooltip after mouse hover (default: 0.7)
(setq tooltip-short-delay 0.08) ; Delay before showing a short tooltip (Default: 0.1)
(tooltip-mode 1)

;; Configure the built-in Emacs server to start after initialization,
;; allowing the use of the emacsclient command to open files in the
;; current session.
(use-package server
  :ensure nil
  :commands server-start
  :hook
  (after-init . server-start))
