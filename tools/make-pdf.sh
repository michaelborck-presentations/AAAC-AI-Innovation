#!/bin/bash
# Script to generate modern PDF from Quarto, Markdown, or HTML document
# Usage: ./make-pdf.sh <input-file.[qmd|md|html]>

if [ -z "$1" ]; then
  echo "Please provide an input file (.qmd, .md, or .html)"
  exit 1
fi

INPUT_FILE="$1"
FILENAME=$(basename -- "$INPUT_FILE")
EXTENSION="${FILENAME##*.}"
BASENAME="${FILENAME%.*}"
HTML_FILE="${BASENAME}.html" # Default HTML output name

# Check file extension and render if necessary
if [[ "$EXTENSION" == "qmd" || "$EXTENSION" == "md" ]]; then
  echo "Input is .$EXTENSION. Generating HTML..."
  quarto render "$INPUT_FILE" --to html
  # Ensure HTML_FILE uses the PWD prefix like Chrome expects later
  HTML_FILE_PATH="${PWD}/${HTML_FILE}"
elif [[ "$EXTENSION" == "html" ]]; then
  echo "Input is already HTML. Skipping render step."
  # Use the input file directly, assuming it's in the PWD
  HTML_FILE_PATH="${PWD}/${INPUT_FILE}"
else
  echo "Unsupported file type: .$EXTENSION. Please provide a .qmd, .md, or .html file."
  exit 1
fi

# Check if the expected HTML file exists before proceeding
if [ ! -f "$HTML_FILE_PATH" ]; then
    # If it wasn't the input file, perhaps quarto changed the output name?
    # Check if the default output name exists without the PWD prefix first
    if [ -f "$HTML_FILE" ] && [[ "$EXTENSION" == "qmd" || "$EXTENSION" == "md" ]]; then
        HTML_FILE_PATH="${PWD}/${HTML_FILE}"
    else
      echo "Error: HTML file not found at $HTML_FILE_PATH"
      # Add a check for the original input if it was supposed to be HTML
      if [[ "$EXTENSION" == "html" ]] && [ ! -f "$INPUT_FILE" ]; then
          echo "Original HTML input file not found: $INPUT_FILE"
      fi
      exit 1
    fi
fi


echo "Converting '$HTML_FILE_PATH' to PDF..."
PDF_OUTPUT="${BASENAME}.pdf"

# Ensure Chrome path is correct for your system
# Using /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome as per original script
CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

"$CHROME_PATH" \
  --headless \
  --disable-gpu \
  --no-margins \
  --no-pdf-header-footer \
  --print-to-pdf="$PDF_OUTPUT" \
  "file://${HTML_FILE_PATH}" # Use the determined HTML file path

if [ $? -eq 0 ]; then
  echo "Done! Created $PDF_OUTPUT"
else
  echo "PDF conversion failed."
  exit 1
fi

