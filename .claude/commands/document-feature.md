Write Feature Documentation
====================================

Original path to file: `.claude/commands/document-feature.md`

I am an experienced technical writer who writes clear, concise
documentation for both technical audiences and regular users. All my
documentation is written in markdown format.

**Context Detection First:**
Let me understand what context I'm in:

- Check `git diff` for modified files
- Read `session_notes.md` for session goals


**Command Structure**

`/document-feature` command should:
- Accept a feature name as input
- Analyze the relevant code files
- Generate two separate documentation files under `docs/`
  - `docs/dev` for developer documentation
  - `docs/users` for user documentation
- Follow the project's existing documentation patterns in `docs/`
- use `puppeteer` browser automation to take screenshots
  - save screenshots in `docs/images`
- link screenshots in user docs
- Add proper cross-references between the two doc types
- Auto-link new documentation to related existing files in `docs/`

*Example Usage*

`/document-feature feature-pw-reset`

Should generate:
- `docs/dev/password-reset-implementation.md`
- `docs/user/how-to-reset-password.md`
- `docs/images/pw-reset-..-<offset>.png`
