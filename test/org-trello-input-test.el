;;; org-trello-input-test.el --- -*- lexical-binding: t; -*-

(require 'test-helper)
(require 'org-trello-input)

(ert-deftest test-orgtrello-input-ido-read-string-completion ()
  (should (eq :res-with-ido
              (let ((org-trello-input-completion-mechanism 'default))
                (ot-with-stub* 'ido-completing-read :res-with-ido
                  (lambda ()
                    (orgtrello-input-read-string-completion :prompt :choices)))))))

(if (boundp 'helm-comp-read)
    (ert-deftest test-orgtrello-input-helm-read-string-completion ()
      (should (eq :res-with-helm
                  (let ((org-trello-input-completion-mechanism 'other))
                    (ot-with-stub* 'helm-comp-read :res-with-helm
                      (lambda ()
                        (orgtrello-input-read-string-completion :prompt :choices))))))))

(ert-deftest test-orgtrello-input-read-not-empty ()
  (should (equal "something"
                 (ot-with-stub* 'read-string " something "
                   (lambda ()
                     (orgtrello-input-read-not-empty "prompt: "))))))

(ert-deftest test-orgtrello-input-read-string ()
  (should (equal :something
                 (ot-with-stub* 'read-string :something
                   (lambda ()
                     (orgtrello-input-read-string "prompt: "))))))

(ert-deftest test-orgtrello-input-confirm ()
  (should (equal 'y
                 (ot-with-stub* 'y-or-n-p 'y
                   (lambda ()
                     (orgtrello-input-confirm "prompt: ")))))
  (should-not (ot-with-stub* 'y-or-n-p nil
                 (lambda ()
                   (orgtrello-input-confirm "prompt: ")))))
