# CEDT LaTeX Assignment Template

Shared LaTeX styling and scaffolding for CEDT assignment repos, meant to be
vendored into each subject repo as a git submodule rather than copy-pasted.

## Contents

- `CEDT-Assignment-style.sty` — shared style package (problem/solution
  environments, title block, headers/footers, `\choices`, `\fig`, etc.).
- `templates/assignment-template.tex` — base template for a new assignment.
- `templates/.latexmkrc` — per-assignment latexmk config (aux dir, synctex).
- `.latexindent.yaml` — formatter config for `make fmt`.
- `new-assignment.sh` — scaffolds a new `assignment-XX/` folder.
- `Makefile.include` — generic `build`/`watch`/`clean`/`fmt`/`new` targets
  for a subject repo's Makefile to `include`.
- `course-config.tex.example` — template for the per-subject config file.

## Using this in a subject repo

```bash
# From the root of a subject repo:
git submodule add <this-repo-url> vendor/template
cp vendor/template/course-config.tex.example course-config.tex
# edit course-config.tex: CourseCode, CourseName, StudentID, StudentName, DefaultCollaborators
```

Subject repo's `Makefile`:

```makefile
.DEFAULT_GOAL := help

TEMPLATE_DIR := $(CURDIR)/vendor/template
include $(TEMPLATE_DIR)/Makefile.include
```

Then:

```bash
make new NAME=assignment-01   # scaffold assignment-01/ from the template
make build DIR=assignment-01  # compile it
```

Each assignment's `.tex` starts with:

```latex
\input{../course-config}
\usepackage{../vendor/template/CEDT-Assignment-style}
```

`\subject` (no argument) then falls back to `\CourseCode`/`\CourseName` from
`course-config.tex`, and `\asgntitle{...}` picks up `\StudentID`,
`\StudentName`, `\DefaultCollaborators` the same way — so a new subject repo
only ever needs to touch `course-config.tex`, never the template itself.

## Pulling in template updates

```bash
git submodule update --remote --merge vendor/template
```

This updates the pinned submodule commit; commit the resulting change in the
subject repo to record which template version it's on.

## Config file design

`course-config.tex` is deliberately plain LaTeX (`\newcommand{...}{...}`)
rather than YAML/JSON: it needs no parser, `\input` picks it up directly, and
`new-assignment.sh` only has to `grep` a couple of values out of it if it
ever needs to (currently it doesn't — all substitution happens at LaTeX
compile time via the macros, not at scaffold time). It lives in each subject
repo, never in this template repo, since it's the one piece of information
that's genuinely per-subject.
