#!/usr/bin/env bash
# Scaffold a new assignment-XX/ folder from templates/assignment-template.tex.
# Meant to be called via `make new NAME=...` in a subject repo, which passes
# repo-root and template-dir explicitly (this script is vendored via a git
# submodule, so it can't assume its own location is the subject repo root).
set -euo pipefail

usage() {
    echo "Usage: $0 <number-or-name> <repo-root> <template-dir>" >&2
    echo "  e.g. $0 07 /path/to/subject-repo /path/to/subject-repo/vendor/template" >&2
    exit 1
}

[ $# -eq 3 ] || usage

raw="$1"
repo_root="$2"
template_dir="$3"

if [[ "$raw" =~ ^[0-9]+$ ]]; then
    name="assignment-$(printf "%02d" "$raw")"
else
    name="$raw"
fi

target="$repo_root/$name"

if [ -e "$target" ]; then
    echo "Error: $target already exists" >&2
    exit 1
fi

if [ ! -f "$repo_root/course-config.tex" ]; then
    echo "Error: $repo_root/course-config.tex not found." >&2
    echo "  Copy $template_dir/course-config.tex.example to $repo_root/course-config.tex and fill it in." >&2
    exit 1
fi

mkdir -p "$target" "$target/.build"
cp "$template_dir/templates/.latexmkrc" "$target/.latexmkrc"

tex_file="$target/$name.tex"
cp "$template_dir/templates/assignment-template.tex" "$tex_file"

if [[ "$name" =~ ^assignment-0*([0-9]+)$ ]]; then
    asgnnum="${BASH_REMATCH[1]}"
    sed -i "s/asgntitle{X}/asgntitle{$asgnnum}/" "$tex_file"
fi

echo "Created $target/$name.tex"
echo "Next steps:"
echo "  1. Fill in the Week number and section title in $tex_file"
echo "  2. Build with: make build DIR=$name"
