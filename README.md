# OCRmyFiles

Bash script for adding a text layer to PDF files and converting images in PDFs (with OCR).

Adds an OCR text layer to all __PDF files__ in the given input directory and saves the new PDF files to the output directory.

When the input directory also contains __image files__ (e.g. jpg, png), these are converted to (OCR'ed) PDFs.

All __other file types__ are just copied from the input directory to the output directory.

## Requirements

- [OCRmyPDF](https://github.com/jbarlow83/OCRmyPDF)\
  For Debian 9/Ubuntu 16.10: `apt-get install ocrmypdf`\
  For other distros: https://ocrmypdf.readthedocs.io/en/latest/installation.html
- [Tesseract](https://github.com/tesseract-ocr/)\
  This is installed with OCRmyPDF automatically
- Tesseract language files\
  e.g. `apt-get install tesseract-ocr-deu` for German language

## Usage
- Download script or clone repository
- Make script executable `sudo chmod +x OCRmyFiles.sh`
- Modify the script to fit your needs:
  - Set default input/output directories
  - Modify the OCRmyPDF command line arguments (you can find an overview of available command line arguments [here](https://ocrmypdf.readthedocs.io/en/latest/cookbook.html))
  - Modify the Tesseract command line arguments (you can find an overview of available command line arguments [here](https://github.com/tesseract-ocr/tesseract/wiki/Command-Line-Usage))
- Call the script:
  - `OCRmyFiles.sh` (no parameter): using default directories for input/output (as defined in the script itself)
  - `OCRmyFiles.sh <inputDir> <outputDir>`: using specified directories for input/output
- The script might print some warnings/errors from Tesseract. These can be ignored in most cases as the OCR text layer will be created anyway
