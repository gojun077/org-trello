CLAUDE.md
========================================================

This file provides guidance to Claude Code (claude.ai/code) and other agentic
coding tools when working with code in this repository.

## Project Overview

org-trello is an Emacs minor mode that synchronizes org-mode buffers with
Trello boards. It's written in Emacs Lisp and provides bidirectional sync
between org-mode files and Trello boards.

## Development Commands

### Build & Package
```bash
make build          # Build the package using Cask
make package        # Create distribution package (.tar file)
make clean          # Clean build artifacts and cache
```

### Testing
```bash
make test           # Run all tests using ert-runner
make install        # Install dependencies via Cask
```

### Development Environment
```bash
make activate       # Start nix development shell with Emacs + org-trello
```

### Release
```bash
make pr             # Create pull request (requires hub CLI)
make release        # Full release process with tagging
```

## Architecture

The codebase follows a namespace-based architecture with strict naming
conventions:

### Core Architecture Layers (in dependency order)
1. **Foundation**: `org-trello-log.el`, `org-trello-setup.el`, `org-trello-date.el`
2. **Data Layer**: `org-trello-hash.el`, `org-trello-data.el`, `org-trello-entity.el`
3. **API Layer**: `org-trello-api.el`, `org-trello-query.el`, `org-trello-backend.el`
4. **Control Layer**: `org-trello-proxy.el`, `org-trello-controller.el`
5. **UI Layer**: `org-trello-buffer.el`, `org-trello-input.el`, `org-trello-cbx.el`
6. **Main**: `org-trello.el` (interactive commands and minor mode)

### Function Naming Conventions
- Public functions: `orgtrello-<namespace>-<function-name>`
- Private functions: `orgtrello-<namespace>--<function-name>` (double dash prefix)
- Predicates: `orgtrello-<namespace>-<name>-p` (suffix with `-p`)
- Interactive commands: `org-trello-<command-name>` (in org-trello.el only)

### Key Namespaces
- **org-trello-api.el**: Trello API abstraction DSL
- **org-trello-backend.el**: HTTP request handling for Trello
- **org-trello-proxy.el**: Request orchestration and coordination
- **org-trello-controller.el**: Main business logic controller
- **org-trello-buffer.el**: Org-mode buffer manipulation
- **org-trello-data.el**: Internal data structure manipulation

## Development Setup

The project uses:
- **Cask** for dependency management
- **ert-runner** for testing
- **Nix** for development environment (optional)
- Standard Emacs Lisp development practices

## Testing

Tests are located in the `test/` directory with corresponding `-test.el`
files for each namespace. Use `make test` to run the full test suite.

## Feature: add support for updating a Trello card's idBoard value

Reference: [Update a Card](https://developer.atlassian.com/cloud/trello/rest/api-group-cards/#api-cards-id-put)

**Problem Statement**
`org-trello` is a minor mode of the `org-mode` major mode. One key
feature in `org-mode` is the `org-refile` command which moves an
entry to another heading in a different file.

In `org-trello` aware buffers or files, each file represents a Trello
*board*. Each `org-trello` file buffer contains the a `:PROPERTIES:`
drawer containing metadata about the Trello board, for example:

```org
:PROPERTIES:
#+PROPERTY: board-name Next Actions
#+PROPERTY: board-id 60d40ccb5c969f134d85812c
#+PROPERTY: Canceled 6110f1ffca6d774611c45b3c
#+PROPERTY: DONE 60d47610156506022c3713e7
#+PROPERTY: Office 60d40e893e069b1bca146169
#+PROPERTY: Home 60d40e85f1b31f6afcfb3908
#+PROPERTY: Errands 60d40e83d5987d6aaeb2d394
#+PROPERTY: Computer 60d40e803e28583852f7c41a
#+PROPERTY: Calls 60d40e7ded11954a50ca9ccc
#+PROPERTY: Read/Review 60d40e7a3612e189a6e8709e
#+PROPERTY: Anywhere 60d40e79fd89dc4b808fe8f4
#+TODO: Anywhere Read/Review Calls Computer Errands Home Office | DONE Canceled
#+PROPERTY: orgtrello_user_jungo 517a187f619dd57134002550
#+PROPERTY: :yellow
#+PROPERTY: :red
#+PROPERTY: :purple
#+PROPERTY: :orange
#+PROPERTY: :green
#+PROPERTY: :blue
#+PROPERTY: orgtrello_user_me jungo
:END:
```

In addition, individual tasks (Trello cards) in an `org-trello` buffer
(Trello board) contain their own `:PROPERTIES:` drawer containing
the Trello Card's UUID (known as `id TrelloID` in the API docs) and
an `org-trello` only hash to identify changes in task / card content:

```org
* Read/Review *Placeholder* Read/Review
:PROPERTIES:
:orgtrello_id: 669d18e7ee2f975ef3d6a6b1
:orgtrello_local_checksum: 44812305a7f9c56465a002135af4b03c72e7f96dba2b9f9c87127118f68c517b
:END:
```

However, when a local `org-mode` H1 heading representing a Trello card
is moved to another `org-trello` file buffer with `org-refile` and
then the task is synced to Trello with `org-trello-sync-card`,
the card's `idBoard` field is not being updated with the new `idBoard`
TrelloID for the new `org-trello` file buffer. The new `idBoard` value
can be found in the `:PROPERTIES:` drawer near the top of the file in
the key `#+PROPERTY: board-id`.

**Goal**

When an H1 header representing a Trello Card in one `org-trello` buffer is
moved to another `org-trello` buffer via `org-refile`, `org-trello` should
update the Trello Card's `idBoard` value (known as `board-id` in
`org-trello`) to reflect the new `org-trello` file buffer aka Trello
Board the card / H1 header is located in.

**Partial Progress**

If you examine the last 12 commits between the most recent SHA1 commit hash
`c85063518bf43169281ab6b3584a35f3c32a15c6` to the start of commits for this
new feature in `b7136c2e2bad1aabc3cdd915ac648919b8d1a57d` I have made edits
to the following elisp files in the org-trello repo:

- `org-trello-setup.el`
- `org-trello-buffer.el`
- `org-trello-controller.el`

Most of the changes have occurred in `org-trello-controller.el`. I recommend
perusing the `git log` to get some context on the changes made so far.

One major change in existing `org-trello` behavior is that I added a new
`PROPERTY` `:orgtrello_id_board:` to the `:PROPERTIES:` drawer of each
org task / Trello card in an `org-trello` file buffer.

Currently there is an `elisp` parsing error in `org-trello-controller.el`
probably due to unmatched parens.

Also, when an org task is refiled to another buffer with `org-refile`, the
Trello Card's `idBoard` field is not being updated.

**Testing with curl**

In the `org-trello` repo root path you can find `APIKey` and `APIToken` credentials
necessary for making an HTTP PUT request to the Trello API. Here is a sample request
to update a Trello card. You can update a field by specifying it in the query or
by adding an entire JSON payload to the request.

```sh
  curl --request PUT \
    --url 'https://api.trello.com/1/cards/{id}?key=APIKey&token=APIToken' \
    --header 'Accept: application/json'
```

For `curl` tests, use the `id` `687bd98c6b20f556e9d6d558` with Name `Refactor brainworkshop`.
