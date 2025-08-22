AGENTS.md
========================================================

- Created on: Fri 22 Aug 2025
- Last Updated: Fri 22 Aug 2025OB

This file provides guidance to agentic coding tools like OpenAI Codex,
Sourcegraph Ampcode, Gemini CLI, Augment Auggie, etc. for working with code
in this repository.

## Project Overview

org-trello is an Emacs minor mode that synchronizes org-mode buffers with
Trello boards. It's written in Emacs Lisp and provides bidirectional sync
between org-mode files and Trello boards.

## Development Workflow

1. Before making any changes, create and checkout a feature branch named
   `feature-[brief-description]`
2. Write comprehensive tests for all new functionality
3. Compile code and run all tests before committing
   - `make lint` check `elisp` syntax
   - `make test` run all test cases in `./test` folder
4. Write detailed commit messages explaining the changes and rationale
5. In the `docs` folder, generate documentation for each new feature
   - use custom command `/document-feature` to generate docs
   - in `docs/dev/` generate developer documentation
   - in `docs/user/` generate user documentation
6. Commit all changes to the feature branch
7. Update `session_notes.md` with a summary of the new feature
   - use custom command `/session-end` to update `session_notes.md`
   - files created/modified during session
   - summarize completed work and pending items

## Development Commands

### Build & Package
```bash
make build          # Build the package using Cask
make package        # Create distribution package (.tar file)
make clean          # Clean build artifacts and cache
```

### Testing
```bash
make lint           # run `(byte-compile-file)` and `(check-parens)`
                    # on elisp source files in `.test/`
make test           # Run all tests using ert-runner
make install        # Install dependencies via Cask
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


## Quality Gates

- All code must compile without errors
- Test coverage must remain above 80%
- All tests must pass before committing
