# CEDT LaTeX Assignment Template

Shared LaTeX styling and scaffolding for CEDT assignment repos, meant to be
vendored into each subject repo as a git submodule rather than copy-pasted.

## Contents

- `CEDT-Assignment-style.sty` — shared style package (problem/solution
  environments, title block, headers/footers, `\choices`, `\fig`, Thai text,
  etc.). Compiles with **XeLaTeX** (see "Build engine" below).
- `templates/template/` — everything `make new` copies into a freshly
  scaffolded assignment: `assignment-template.tex` (deliberately lean — only
  what every assignment needs, nothing that points at a file that won't exist
  in a fresh folder), `.latexmkrc`, and demo `code/`/`images/` folders for
  the style guide's examples below (`new-assignment.sh` creates empty
  `code/`/`images/` folders of their own alongside every scaffolded
  assignment — see "Then:" below).
- `templates/style-guide/` — the exhaustive reference instead:
  `style-guide.tex` (compiled: `style-guide.pdf`), one worked example of
  every macro/environment `CEDT-Assignment-style.sty` provides. Never
  scaffolded by `make new` — it's documentation, not a starting point, so
  it's free to point at real files in `templates/template/code/` and
  `templates/template/images/` for its demos.
- `templates/nbconvert/cedt-assignment/` — custom `jupyter nbconvert` LaTeX
  template so notebook-exported PDFs (`make nb-pdf`) get the same
  fonts/margins/header as the `.tex` write-ups.
- `.latexindent.yaml` — formatter config for `make fmt`.
- `new-assignment.sh` — scaffolds a new `assignment-XX/` folder.
- `Makefile.include` — generic `build`/`watch`/`clean`/`fmt`/`new`/`nb-pdf`
  targets for a subject repo's Makefile to `include`.
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

`make new` creates `assignment-01/assignment-01.tex` plus empty
`assignment-01/code/` and `assignment-01/images/` folders alongside it, ready
for a notebook (see "Notebook → styled PDF" below) or `\fig`-ed images.

Each assignment's `.tex` starts with:

```latex
\input{../course-config}
\usepackage{../vendor/template/CEDT-Assignment-style}
```

`\subject` (no argument) then falls back to `\CourseCode`/`\CourseName` from
`course-config.tex`, and `\asgntitle{...}` picks up `\StudentID`,
`\StudentName`, `\DefaultCollaborators` the same way — so a new subject repo
only ever needs to touch `course-config.tex`, never the template itself.

## Build engine

`CEDT-Assignment-style.sty` requires **XeLaTeX** — a Unicode engine is needed
for Thai (below), and it's already what the notebook → PDF path uses. The
scaffolded `.latexmkrc` sets `$pdf_mode = 5`, so `make build` / `make watch`
pick it up automatically. If you compile by hand, use `xelatex` (or
`latexmk -xelatex`), not `pdflatex`/`lualatex`.

Assignment folders scaffolded before this change keep their own older
`.latexmkrc`; add `$pdf_mode = 5;` (and `$emulate_aux = 1;`) to it, or re-copy
it from `vendor/template/templates/template/.latexmkrc`.

## Writing in Thai

The document language is English, but Thai can go anywhere — problem
statements, `\choices`, section titles, `\asgntitle`. Thai text has to be
wrapped so it gets the Thai font and the dictionary-based line breaker;
unwrapped Thai falls back to the Latin font and prints as blank boxes.

```latex
\textthai{ตัวอักษรไทย}                    % a few words inline
\begin{thai} ... whole Thai paragraphs ... \end{thai}
```

The Thai font is Norasi (it carries Latin + italic/bold, so an English word
inside Thai still typesets). Override per document, after the `\usepackage`:

```latex
\newfontfamily\thaifont[Script=Thai]{TH Sarabun New}
```

`templates/style-guide/style-guide.pdf` has the worked examples. (Thai in a
notebook markdown cell still needs a `\textthai{}` / `thai` wrapper in a raw
LaTeX cell — plain Thai markdown won't render.)

## Notebook → styled PDF

For notebook-based assignments, `make nb-pdf` exports a `.ipynb` straight to
PDF via `jupyter nbconvert`, styled with the same `CEDT-Assignment-style.sty`
fonts/margins/header as the `.tex` write-ups:

```bash
make nb-pdf NB=assignment-01/code/assignment-01.ipynb
```

The PDF is written next to the notebook, same as `jupyter nbconvert`'s
default. This needs `jupyter`/`nbconvert` in the subject repo's own
`.venv/` (`JUPYTER := $(CURDIR)/.venv/bin/jupyter` in `Makefile.include` —
each subject repo owns its own Python env, since not every subject needs
one) plus a working `xelatex`, the only engine `nbconvert`'s PDF exporter
shells out to.

`nbconvert`'s `PDFExporter` always compiles in an isolated temp directory,
so `CEDT-Assignment-style.sty` and the subject repo's `course-config.tex`
can't be found by relative path — `make nb-pdf` works around this by
exporting `TEXINPUTS` to cover both the subject repo root (for
`course-config.tex`) and `vendor/template/` (for the `.sty`), and the
template locates both as bare filenames via kpathsea. Running nbconvert by
hand instead of through `make nb-pdf`? Set `TEXINPUTS` the same way first:

```bash
export TEXINPUTS="$(pwd):$(pwd)/vendor/template:$TEXINPUTS"
jupyter nbconvert --to pdf \
  --TemplateExporter.extra_template_basedirs=vendor/template/templates/nbconvert \
  --template=cedt-assignment \
  assignment-01/code/assignment-01.ipynb
```

## Pulling in template updates

```bash
git submodule update --remote --merge vendor/template
```

This updates the pinned submodule commit; commit the resulting change in the
subject repo to record which template version it's on.

After pulling a version that switched the build to XeLaTeX, existing
assignment folders also need the `.latexmkrc` bump described under "Build
engine" above.

## Config file design

`course-config.tex` is deliberately plain LaTeX (`\newcommand{...}{...}`)
rather than YAML/JSON: it needs no parser, `\input` picks it up directly, and
`new-assignment.sh` only has to `grep` a couple of values out of it if it
ever needs to (currently it doesn't — all substitution happens at LaTeX
compile time via the macros, not at scaffold time). It lives in each subject
repo, never in this template repo, since it's the one piece of information
that's genuinely per-subject.
