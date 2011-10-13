;;; flymake-haml.el --- Flymake handler for haml-mode and sass-mode files
;;
;;; Author: Steve Purcell <steve@sanityinc.com>
;;; URL: https://github.com/purcell/flymake-haml
;;; Version: DEV
;;
;;; Commentary:
;;
;; Usage:
;;   (require 'flymake-haml)
;;   (add-hook 'haml-mode-hook 'flymake-haml-load)
;;   (add-hook 'sass-mode-hook 'flymake-sass-load)
(require 'flymake)

(defvar flymake-haml-err-line-patterns '(("^Syntax error on line \\([0-9]+\\): \\(.*\\)$" nil 1 nil 2)))
(defvar flymake-haml-allowed-file-name-masks '((".+\\.\\(haml\\)$" flymake-haml-init)
                                               (".+\\.\\(sass\\)$" flymake-sass-init)))

;; Invoke utilities with '-c' to get syntax checking
(defun flymake-haml-init ()
  (list "haml" (list "-c" (flymake-init-create-temp-buffer-copy
                           'flymake-create-temp-inplace))))
(defun flymake-sass-init ()
  (list "sass" (list "-c" (flymake-init-create-temp-buffer-copy
                           'flymake-create-temp-inplace))))

;;;###autoload
(defun flymake-haml-load ()
  "Configure flymake mode to check the current buffer's haml/sass syntax.

This function is designed to be called in `sass-mode-hook' or
`haml-mode-hook'; it does not alter flymake's global
configuration, so `flymake-mode' alone will not suffice."
  (interactive)
  (set (make-local-variable 'flymake-allowed-file-name-masks) flymake-haml-allowed-file-name-masks)
  (set (make-local-variable 'flymake-err-line-patterns) flymake-haml-err-line-patterns)
  (if (executable-find "haml")
      (flymake-mode t)
    (message "Not enabling flymake: haml command not found")))

(defalias 'flymake-sass-load 'flymake-haml-load)


(provide 'flymake-haml)
;;; flymake-haml.el ends here
