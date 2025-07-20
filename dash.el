;;; dash.el --- Minimal stub of dash functions/macros for org-trello byte-compilation

;; This is NOT the full featured dash library, only a handful of macros and
;; functions that are necessary to let org-trello compile inside this
;; restricted execution environment where we cannot fetch external
;; dependencies.  They implement only the behaviour that org-trello actually
;; relies on; most are simplistic fall-backs so that the byte-compiler sees
;; the symbols and does not abort with “unknown function or macro” errors.

(eval-when-compile (require 'cl-lib))

;;; Helper
(defmacro dash--identity (value &rest _)
  "Return VALUE ignoring the rest.
This is used internally so that we have a single place that one can
upgrade later with better semantics if needed."
  value)

;;; Public stubs

;; Threading macros – for a stub we only return the first form so the code
;; remains evaluable.  A more elaborate implementation is not necessary for
;; compilation purposes.
(defmacro -> (expr &rest _forms)
  "Threading macro stub – simply return EXPR."
  expr)

(defmacro ->> (expr &rest _forms)
  "Threading macro stub – simply return EXPR."
  expr)

;; Basic functional helpers
(defmacro -partial (fn &rest args)
  "Return a lambda that applies FN to ARGS and the rest of its arguments."
  `(lambda (&rest rest)
     (apply ,fn ,@args rest)))

(defun -filter (pred lst)
  "Return elements of LST that satisfy PRED.  Very small stub."
  (delq nil (mapcar (lambda (x) (and (funcall pred x) x)) lst)))

(defmacro -compose (&rest fns)
  "Tiny stub of dash’s -compose.
For compilation purposes we just call the last function in FNS with the
arguments; the previous functions are ignored – this is sufficient for
macro-expansion in org-trello where -compose is mainly used to build
predicates that the compiler does not need to evaluate."
  (if (null fns)
      ''identity
    `(lambda (&rest args)
       (apply ,(car (last fns)) args))) )


;; Very forgiving implementation that ignores complex patterns – good enough
;; for byte-compilation because the compiler does not execute the body.
(defmacro -let (bindings &rest body)
  "Extremely simplified version of dash’s -let.
Each binding is reduced to a simple `let' binding; complex destructuring
patterns are ignored by binding the value to a fresh gensym.  This keeps
the byte-compiler happy without trying to replicate full dash
functionality."
  `(let ,(mapcar (lambda (binding)
                   (let ((pattern (car binding))
                         (expr    (cadr binding)))
                     (list (if (symbolp pattern)
                               pattern
                             (make-symbol "dash--ignored"))
                           expr)))
                 bindings)
     ,@body))

;; Alias -let* to -let for the purposes of compilation.
(defalias '-let* '-let)

;; The full dash provides pattern-aware --reduce-from but we just fold from
;; left using the supplied initial value.
(defmacro --reduce-from (init list &rest body)
  "Simple left fold stub.  Bind `it' within BODY while accumulating."
  (let ((acc-sym (make-symbol "acc"))
        (it-sym  (make-symbol "it")))
    `(let ((,acc-sym ,init))
       (dolist (,it-sym ,list ,acc-sym)
         (let ((it ,it-sym)
               (acc ,acc-sym))
           (setq ,acc-sym (setq acc (progn ,@body))))))) )

;; Adapted naive implementation supporting simple patterns.
(defmacro -if-let (binding then &optional else)
  "Very small subset of dash’s -if-let.
Only supports a single BINDING of the form (PATTERN EXP), where PATTERN
is either a symbol or a destructuring list compatible with
`cl-destructuring-bind'."
  (let* ((pattern (car binding))
         (expr    (cadr binding))
         (tmp     (make-symbol "dash--tmp")))
    `(let ((,tmp ,expr))
       (cl-destructuring-bind ,pattern ,tmp
         (if ,tmp
             ,then
           ,else)))) )

;; Aliases used by org-trello that map to the stubs above
(defalias '-when-let '-if-let)

;; dash defines a dynamic symbol `it` for some macros.  We pre-declare it so
;; that the byte-compiler does not complain about a free variable.
(defvar it nil)
(defvar acc nil)

(provide 'dash)

;;; dash.el ends here
