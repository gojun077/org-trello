;;; test-helper.el ---                               -*- lexical-binding: t; -*-

;; Copyright (C) 2015-2017  Antoine R. Dumont (@ardumont) <antoine.romain.dumont@gmail.com>

;; Author: Antoine R. Dumont (@ardumont) <antoine.romain.dumont@gmail.com>
;; Keywords:

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
;;; Code:


;; Ensure cl-lib is available and provide a small alias for legacy code/tests.
(when (require 'cl-lib nil t)
  (defalias 'incf 'cl-incf))

;; Load undercover if available in the environment.
(when (require 'undercover nil t)
  ;; Limit coverage to project sources and exclude tests and pkg file.
  ;; Use `eval` to avoid compile-time warnings about keyword forms.
  (eval '(undercover "org-trello-*.el"
                    (:exclude "org-trello-pkg.el" "*-test.el")
                    (:report-file "/tmp/undercover-report.json"))))

;; Minimal mocking/stubbing helpers for ERT-based tests
;; Usage:
;;   (ot-with-stub format-time-string "fixed"
;;     (foo (format-time-string "%Y")))
;;   (ot-with-wrap some-fn (lambda (orig)
;;                           (lambda (&rest args)
;;                             (message "called")
;;                             (apply orig args)))
;;     (some-fn 1 2 3))
(defmacro ot-with-stub (fn value &rest body)
  "Temporarily make FN return VALUE while executing BODY.
FN is a symbol of a function to stub. VALUE is the return value.
All arguments passed to FN are ignored."
  (declare (indent 1))
  `(ot-with-stub* ',fn ,value (lambda () ,@body)))

(defmacro ot-with-wrap (fn wrapper &rest body)
  "Temporarily wrap FN using WRAPPER while executing BODY.
WRAPPER is a function that receives the original function and must
return a new function to be installed as FN."
  (declare (indent 1))
  `(let ((orig (symbol-function ,fn)))
     (unwind-protect
         (progn (fset ,fn (funcall ,wrapper orig))
                ,@body)
       (fset ,fn orig))))

;; Function variant to avoid macroexpansion timing issues in some runners
(defun ot-with-stub* (fn value thunk)
  "Dynamically bind function cell of FN to a constant VALUE for THUNK.
FN is a symbol naming a function. THUNK is a zero-arg function."
  (let ((orig (symbol-function fn)))
    (unwind-protect
        (progn (fset fn (lambda (&rest _) value))
               (funcall thunk))
      (fset fn orig))))

(require 'org-trello nil t)

(provide 'test-helper)
;;; test-helper.el ends here
