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

## Concrete Fixes

1. Replace all uses of obsolete `flet`, `lexical-let`, `macrolet` from `cl`
with their `cl-lib` equivalents (`cl-flet`, `cl-macrolet`). Files:
  - `org-trello-backend.el`
  - `org-trello-buffer-test.el` (four local redefinitions)

2. Vendor-switch from `el-mock` to `ert-mock` (already bundled since Emacs 28). Steps:
  - `package el-mock` → remove from Cask
  - `require 'ert-mock` in each `*-test.el` using mocks
  - Update `(stub foo => val)` → `(ert-stub foo val)`
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

## Stretch Goals

- Migrate from Cask to `straight-el` or `Eask` to reduce dependency on an
  unmaintained tool.
- Replace `undercover` with built-in `ert` coverage once Emacs 30 lands the
  feature.
