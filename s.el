;;; s.el --- Minimal stub for string manipulation functions used by org-trello

;; This is NOT a full version of Magnar Sveen’s s.el, but only enough to let
;; org-trello compile.  We provide the few helpers that are referenced from
;; the source code or that are commonly used together with dash.

(defun s-trim (str)
  "Return STR without leading or trailing whitespace."
  (replace-regexp-in-string "\`[ \t\n\r]+\|[ \t\n\r]+\'" "" str))

(defun s-join (sep strings)
  "Join the list STRINGS using SEP." 
  (mapconcat #'identity strings sep))

(defun s-starts-with? (prefix str &optional ignore-case)
  "Return non-nil if STR starts with PREFIX.
When IGNORE-CASE is non-nil the test is case-insensitive."
  (let ((case-fold-search ignore-case))
    (string-match-p (format "^%s" (regexp-quote prefix)) str)))

(defun s-ends-with? (suffix str &optional ignore-case)
  "Return non-nil if STR ends with SUFFIX."
  (let ((case-fold-search ignore-case))
    (string-match-p (format "%s$" (regexp-quote suffix)) str)))

(provide 's)

;;; s.el ends here

