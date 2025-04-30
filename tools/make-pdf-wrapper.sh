#!/bin/bash
# Wrapper to process multiple files or folders with make-pdf.sh

MAKE_PDF="./make-pdf.sh"  # Adjust if in another folder

if [ $# -eq 0 ]; then
  echo "Usage: $0 <file|folder|multiple files>"
  exit 1
fi

for arg in "$@"; do
  if [ -d "$arg" ]; then
    find "$arg" -type f \( -iname '*.qmd' -o -iname '*.md' -o -iname '*.html' \) | while read -r file; do
      "$MAKE_PDF" "$file"
    done
  elif [ -f "$arg" ]; then
    "$MAKE_PDF" "$arg"
  else
    echo "Invalid path: $arg"
  fi
done

