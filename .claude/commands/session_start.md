Session Start
===================================

# Summary

- Created on: Fri 22 Aug 2025
- Last Updated: Fri 22 Aug 2025 17:35:34

Original path to file: `.claude/commands/session_start.md`

I am a wise planner who sets out discrete, concrete goals to accomplish
during a single coding session. I will record session plans in
`session_notes.md` located in the project root.

**Command Structure**

`/session_start` command should:
- accept a session title as optional input
  + ex: `/session_start "refactor tests"`
- If no input is provided, analyze `session_notes.md` for a suitable
  session title
- Create a new h2 header `## Session <N>: [Title]`
- Populate with data or placeholders following a provided template


# Steps

## 1. Review most recent session

Each session has its own h3 header that looks like `### Session <N>:`
Headings are arranged in ascending temporal and cardinal order, i.e.

```markdown
## Session 1: Create build harness Makefile
**Date**: 2025-01-01
...

## Session 2: Add test recipe to Makefile
**Date**: 2025-01-02
...

## Session 3: Add unit tests to ./test folder
**Date**: 2025-01-10
...
```

Under each h2 header there are two h3 headers:

- `### Session <N> TODO List`
  + [ ] checklist items under TODO list
- `### Session <N> Results`
  + notes to aid continuous improvement of the development process

If there are any `TODO` tasks items not showing `[x]`, those TODO tasks
will be added to the next Session <N>'s TODO List in the next step. Also
note the comments from `Session <N> Results` which will guide session
planning in the next step.

If there are *no* pre-existing h2 `## Session <N>` headers, skip this
step.

## 2. Create Session Plan

After the last `## Session <N> ...`  h2 header, create a new header
`## Session <N+1>: [TITLE]` using information from the previous
step, if applicable.

Use the following session template:

```markdown
## Session N: [Title]
- **Date**: YYYY-MM-DD
- **Start Time**: hh.mm.ss (24h format)
- **End Time**: hh.mm.ss (24h format)
- **Status**: [🔄 IN PROGRESS | ✅ COMPLETE | ❌ FAILED]
- **Objective**: [One sentence goal]
- **File(s)**: [Primary files modified]

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

Fill in the following fields under `## Session <N>..` h2 header:

- `**Date**:`
- `**Start Time**:`
- `**Status**:`
- `**Objective**:`

Also increment `N` to an appropriate value for the h3 header fields.

Next, populate the TODO list under h3 header `### Session <N> TODO List`
with appropriate atomic tasks for the planned session.

In the last h3 header `### Session <N> Results` under the h2 header
for the session plan, simply add the fields. The field data will be
populated later when the coding session is finished.
