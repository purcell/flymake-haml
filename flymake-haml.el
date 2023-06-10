;;; flymake-haml.el --- A flymake handler for haml files -*- lexical-binding: t; -*-

;; Copyright (c) 2011-2017 Steve Purcell

;; Author: Steve Purcell <steve@sanityinc.com>
;; URL: https://github.com/purcell/flymake-haml
;; Package-Version: 0.1
;; Package-Requires: ((emacs "28.1"))
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Usage:
;;   (require 'flymake-haml)
;;   (add-hook 'haml-mode-hook 'flymake-haml-load)
;;
;; `sass-mode' is a derived mode of 'haml-mode', so
;; `flymake-haml-load' is a no-op unless the current major mode is
;; `haml-mode'.
;;
;; TODO: remove this comment if it doesn't end up being used
;; Uses flymake-easy, from https://github.com/purcell/flymake-easy

;; TODO: basic haml -c lint checking
;; TODO: abstract the flymake command runner to handle both commands (or update flymake-easy?)

;;; Code:

;;; haml-lint backend, adapted from ruby-mode examples

(defcustom flymake-haml-lint-config ".haml-lint.yml"
  "Configuration file for `haml-lint'."
  :type 'string
  :group 'haml)

(defcustom flymake-haml-lint-use-bundler nil
  "If non-nil, run `haml-lint' with `bundle exec'."
  :type 'boolean
  :group 'haml)

(defvar-local flymake-haml--proc nil
  "Holds a reference to the haml flymake process.")

(defun flymake-haml-lint (report-fn &rest _args)
  "Haml-lint backend for Flymake.
REPORT-FN is the Flymake reporter callback."
  (unless (executable-find "haml-lint")
    (error "Cannot find the haml-lint executable"))

  (let ((command (list "haml-lint" "-r" "json" buffer-file-name))
        (default-directory default-directory)
        config-dir)

    (when buffer-file-name
      (setq config-dir (locate-dominating-file buffer-file-name
                                               flymake-haml-lint-config))
        (when flymake-haml-lint-use-bundler
          (setq command (append '("bundle" "exec") command))
          ;; In case of a project with multiple nested subprojects,
          ;; each one with a Gemfile.
          (setq default-directory config-dir)))

    (when (process-live-p flymake-haml--proc)
      (kill-process flymake-haml--proc))

    (let ((source (current-buffer)))
      (save-restriction
        (widen)
	(setq
	 flymake-haml--proc
	 (make-process
	  :name "flymake-haml-lint" :noquery t :connection-type 'pipe
	  :buffer (generate-new-buffer " *flymake-haml*")
	  :command command
	  :sentinel
	  (lambda (proc _event)
	    (when (and (eq 'exit (process-status proc)) (buffer-live-p source))
              (unwind-protect
                  (if (with-current-buffer source (eq proc flymake-haml--proc))
                      (with-current-buffer (process-buffer proc)
                        (goto-char (point-max))
		        (forward-line -1)
			(beginning-of-line)
			(let* ((data (json-read))
			       (files (cdr (assoc 'files data))))
			  (if (seq-empty-p files) (funcall report-fn nil)
			    (cl-loop for offense across (cdr (assoc 'offenses (seq-first files)))
				     for msg = (cdr (assoc 'message offense))
				     for line = (cdr (assoc 'line (cdr (assoc 'location offense))))
				     for (beg . end) = (flymake-diag-region source line)
				     for severity = (cdr (assoc 'severity offense))
				     for type = (or (intern-soft (format ":%s" severity)) :note)
				     collect (flymake-make-diagnostic
					      source
					      beg
					      end
					      type
					      msg)
				     into diags
				     finally (funcall report-fn diags)))))
		    (flymake-log :debug "Canceling obsolete check %s" proc)))))))))))

;;;###autoload
(defun flymake-haml-load ()
  "Setup `haml-lint' flymake backend."
  (add-hook 'flymake-diagnostic-functions 'flymake-haml-lint nil t))

(provide 'flymake-haml)
;;; flymake-haml.el ends here
