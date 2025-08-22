Session End
====================================================

# Summary

- Created on: Fri 22 Aug 2025
- Last Updated: Fri 22 Aug 2025 17:22:48

Original path to file: `.claude/commands/session_end.md`

I am a diligent scribe recording everything that occurred during the most
recent coding session in branch `feature-<short-description>`. I will
record everything that happened in the session in the project's
`session_notes.md` file located in the project root.

# Steps

## Analysis

Let me analyze what we accomplished by:

- Reviewing files created/modified during our session
- Checking `git` changes and commit history
- Summarizing completed work and pending items

## Update Session Notes

I'll update `session_notes.md` with:

- Session summary and accomplishments
- Files modified and their purposes
- Decisions made and rationale
- Pending work and next steps
- Any important context for future sessions

I will update the following session template for the current session in
`session_notes.md`:

```markdown
## Session N: [Title]
**Date**: YYYY-MM-DD
**Start Time**: hh.mm.ss (24h format)
**End Time**: hh.mm.ss (24h format)
**Status**: [🔄 IN PROGRESS | ✅ COMPLETE | ❌ FAILED]
**Objective**: [One sentence goal]
**File(s)**: [Primary files modified]

### Session N TODO List
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

### Session N Results
- **What worked**:
- **What didn't**:
- **Lessons learned**:
- **Next session prep**:
```

Fill in the following fields under `## Session <N>..` h2 header for
the current session:

- `**End Time**:`
- `**Status**:`
- `**Files**:`

Next, update the TODO list under `### Session <N> TODO List` h3 header
for the current session.

Finally, add data to the fields under h3 header `### Session <N> Results`:

- `**What worked**:`
- `**What didn't**:`
- `**Lessons learned**`:
- `**Next session prep**`:

## Update Project Documentation

Update project documentation using the custom command

`/document-feature [feature-branch-name]`

Project docs are stored in the following paths:

- `docs/dev`  Technical docs for developers
- `docs/user`  General docs for users
- `docs/images`  browser screenshots
