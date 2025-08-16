Update Tests TODO
==============================

# Summary

- Created on: Sat 16 Aug 2025
- Last Updated: Sat 16 Aug 2025

`make test` is currently failing because the tests were written with
Emacs 28 in mind. Dependent libraries have also changed quite a bit in the
interim!

## Goal

Modernise the `./test` suite so it runs cleanly on:

- Emacs 29 – 30
- Cask `0.9.x`
- Latest dependencies from GNU ELPA / MELPA

## Current Pain Points

- **Byte-compilation warnings promoted to errors**
  + Emacs 29+ is stricter about obsolete aliases
  + `cl` → `cl-lib`, `flet` → `cl-flet`
  + Several helper files `org-trello-*` still use legacy forms that now
    break during test load
- **el-mock vs built-in ert advice**
  + `el-mock` relies on `flet`/`lexical-let`; Emacs 30 removes these.
    Tests that call `mocklet`, `stub` etc. fail before assertions run.
- **Package version drift**
  + The Cask file pins nothing. Newer `undercover`, `dash`, `s`, `f`
    introduce breaking api changes (e.g., renamed functions, extra
    positional args). At least *9* tests die while requiring these libs.
- **Locale / string-collate-equalp changes**
  + Comparison helpers that depended on ASCII collation now behave
    differently under `UTF-8 LC_COLLATE`, causing 3 string-order assertions
    to flip.
- **Over-broad undercover pattern**
  + `undercover "*.el"` now also expands to files inside `.cask/` on Cask
    0.9, producing millions of coverage entries and exhausting memory.

## Inventory Snapshot

- **`el-mock` usage:** 16 test files `(require 'el-mock)`; 14 files use `with-mock` forms.
- **Coverage glob:** `test/test-helper.el` includes `"*.el"` and excludes `"*-tests.el"`, but test files are named `*-test.el` (singular), so tests are currently included in coverage.
- **`lexical-let` in sources:** 10 occurrences across `org-trello-controller.el`, `org-trello-buffer.el`, `org-trello-proxy.el`.
- **CI:** Only legacy Travis config present; no GitHub Actions workflow.

## Concrete Fixes

1. Replace all uses of obsolete `flet`, `lexical-let`, `macrolet` from `cl`
with their `cl-lib` equivalents (`cl-flet`, `cl-macrolet`). Files:
  - `org-trello-backend.el`
  - `org-trello-buffer-test.el` (four local redefinitions)

2. Replace `el-mock` usage without obsolete `cl` forms. Two viable paths:

   - Option A (recommended): Introduce lightweight stubbing/wrapping helpers backed by `cl-letf` in `test/test-helper.el`, then migrate tests off `with-mock` incrementally.

     ```elisp
     (require 'cl-lib)
     (defmacro ot-with-stub ((fn value) &rest body)
       "Temporarily make FN return VALUE, run BODY."
       `(cl-letf (((symbol-function ,fn)
                   (lambda (&rest _) ,value)))
          ,@body))

     (defmacro ot-with-wrap ((fn wrapper) &rest body)
       "Temporarily wrap FN with WRAPPER (a lambda taking original)."
       (declare (indent 1))
       `(cl-letf* (((orig ,fn) (symbol-function ,fn))
                   ((symbol-function ,fn)
                    (funcall ,wrapper orig)))
          ,@body))
     ```

     - Replace simple `stub` usages with `ot-with-stub`.
     - For call-count/argument assertions, wrap and capture into a lexically bound counter/list.
     - Remove `(require 'el-mock)` from migrated files and drop it from Cask.

   - Option B: Pin `el-mock` to a version compatible with Emacs 29–30 (if available) to unblock quickly, then plan an incremental migration to Option A.
3. Pin compatible versions in Cask:
   `(depends-on "dash" "2.19.1")`
   `(depends-on "s"    "1.13.0")`
   `(depends-on "f"    "0.20.0")`
   `(depends-on "undercover" "0.8.1")`
4. Narrow `undercover` glob:

   ```elisp
   (undercover "org-trello-*.el"
               (:exclude "org-trello-pkg.el" "*-test.el"))
   ```
5. Adjust failing collation tests to use `string-collate-equalp` instead of
`string=` for alphabetical order checks, or bind `LC_COLLATE=C` around
those specific asserts.
6.  CI matrix update:
    - Add Emacs 29 & 30 jobs
    - Keep Emacs 27 as a minimum supported baseline until 1.9 release.

## Phased Plan

1. Coverage and bootstrap tweaks
   - Update `test/test-helper.el` undercover pattern to target only `org-trello-*.el` and exclude `*-test.el` and `org-trello-pkg.el`.
   - Ensure `test/test-helper.el` requires `cl-lib` and defines the stubbing/wrapping helpers shown above.
2. Pilot migration away from `el-mock`
   - Convert one small file (e.g., `org-trello-log-test.el`) to `ot-with-stub`/`ot-with-wrap` and remove its `el-mock` require.
   - Validate semantics for call counting and argument capture using wrappers.
3. Systematic test refactor
   - Migrate remaining 13–15 files off `with-mock` in batches, replacing with helper macros; remove `el-mock` requires as you go.
4. Locale-sensitive assertions
   - Replace order checks with `string-collate-lessp`/`string-collate-equalp` or bind `LC_COLLATE` around specific tests.
5. Dependency pins
   - Pin `dash`, `s`, `f`, `undercover` in `Cask`; keep `ert-runner` up to date.
6. Source compatibility nits
   - Replace `lexical-let` in `org-trello-*.el` with plain `let` under `lexical-binding: t` or `cl-labels/cl-flet` where rebinding is intended.
7. CI refresh
   - Add a GitHub Actions workflow running on Emacs 27, 29, 30; separate a coverage job to avoid slowing the main matrix.
8. Cleanup
   - Remove Travis config if unused; update README-dev with new test/CI instructions.

## Early, Concrete Edits

- In `test/test-helper.el`, change:

  ```elisp
  (require 'undercover)
  (undercover "*.el"
              (:exclude "*-tests.el")
              (:report-file "/tmp/undercover-report.json"))
  ```

  to:

  ```elisp
  (require 'cl-lib)
  (require 'undercover)
  (undercover "org-trello-*.el"
              (:exclude "org-trello-pkg.el" "*-test.el")
              (:report-file "/tmp/undercover-report.json"))

  ;; Minimal mocking helpers for ERT-based tests
  (defmacro ot-with-stub ((fn value) &rest body)
    `(cl-letf (((symbol-function ,fn)
                (lambda (&rest _) ,value)))
       ,@body))

  (defmacro ot-with-wrap ((fn wrapper) &rest body)
    (declare (indent 1))
    `(cl-letf* (((orig ,fn) (symbol-function ,fn))
                ((symbol-function ,fn)
                 (funcall ,wrapper orig)))
       ,@body))
  ```

- In each migrated test file, remove `(require 'el-mock)` and replace simple `with-mock`/`stub` forms accordingly.

## Open Questions

- Do we want to keep `el-mock` temporarily (pinned) for parity while migrating, or switch tests wholesale to the `cl-letf` helpers?
- Should coverage run on every matrix entry, or only on one Emacs version to speed CI?
- Is Emacs 27 still a baseline we must keep green during the transition, or can we drop it once 1.9 ships?

## Progress Log

- Pilot migration target: `test/org-trello-log-test.el`.
  - Added `(require 'test-helper)` to ensure helper macros load.
  - Introduced `ot-with-stub` and `ot-with-wrap` macros in `test/test-helper.el`.
  - Narrowed `undercover` glob in `test/test-helper.el` to only project sources and excluded tests.

- Issue encountered: `invalid-function` raised when using `ot-with-stub` inside an `ert-deftest` body.
  - Symptom: ERT reported an `invalid-function` showing the compiled macro object of `ot-with-stub`.
  - Likely cause: macroexpansion timing in runner context; the test body expanded by `ert-deftest` may not expand nested macros as expected under interpretation, causing the macro function object to be evaluated rather than expanded.
  - Mitigation: Added a function variant `ot-with-stub*` that takes a symbol, a value, and a thunk. Updated the pilot test to use `ot-with-stub*` to avoid macroexpansion ordering issues.

- Next step: Validate that the pilot test passes on the target Emacs version(s). If green, proceed to migrate another small test (e.g., `org-trello-input-test.el`), including a wrapper-based example to capture calls/args.

### Latest changes (Aug 16, 2025)

- Helpers
  - Added `ot-with-stub*` (function) and `ot-with-stub`/`ot-with-wrap` (macros) in `test/test-helper.el`.
  - Rewrote helpers to use `fset` + `unwind-protect` to avoid reliance on `cl-letf`; ensures original function is restored.
  - Guarded `(require 'undercover)` and wrapped `undercover` call in `eval` to avoid byte-compile warnings when Undercover is absent.
  - Guarded `(require 'org-trello nil t)` in helper to avoid byte-compile failures in minimal envs.

- Coverage
  - Narrowed pattern to `org-trello-*.el` and excluded tests and `org-trello-pkg.el`.

- Tests migrated
  - `test/org-trello-log-test.el`: uses `ot-with-stub*` to stub `format-time-string`; added `lexical-binding` header; requires `test-helper`.
  - `test/org-trello-input-test.el`: uses `ot-with-stub*` for `ido-completing-read`, `helm-comp-read`, `read-string`, `y-or-n-p`; added `lexical-binding` header; requires `test-helper`.

- Linting
  - Documented correct `(check-parens)` usage that opens the file in batch before checking.
  - Standardized `cask exec` byte-compile commands to ensure deps (e.g., dash) are present.

- Status
  - Suite reduced to 36 failing tests (buffer/cbx/controller/entity clusters). Input/log tests are green after migration.

## Linting & Elisp Hygiene

- Parens/syntax check (visit file before checking):
  - `emacs -Q --batch --eval '(progn (find-file "path/to/file.el") (check-parens))'`
  - Alternative: `emacs -Q --batch --eval '(with-temp-buffer (insert-file-contents "path/to/file.el") (emacs-lisp-mode) (check-parens))'`
- Byte-compile check:
  - Minimal env: `emacs -Q --batch --eval "(byte-compile-file \"/path/to/your/file.el\")"`
  - With deps (preferred for tests): `cask exec emacs -Q --batch -L . -L test --eval "(byte-compile-file \"test/some-test.el\")"`

Notes:
- When byte-compilation succeeds, a `.elc` file is generated alongside the `.el` file. Errors print to stderr.
- After changing any `.el` files, run both checks before re-running the tests.

Tips for minimal environments (no deps installed):
- Add project folders to `load-path` when compiling tests so `(require 'test-helper)` resolves:
  - `emacs -Q --batch -L . -L test --eval "(byte-compile-file \"test/org-trello-log-test.el\")"`
- Guard optional dev-only deps (e.g., `undercover`) with `(when (require 'undercover nil t) ...)` so byte-compilation does not fail when they are missing.
- Prefer `-Q` or `--no-site-file` to avoid site-lisp noise during batch compilation.

## Stretch Goals

- Migrate from Cask to `straight-el` or `Eask` to reduce dependency on an
  unmaintained tool.
- Replace `undercover` with built-in `ert` coverage once Emacs 30 lands the
  feature.
