# OCRmyPDF-script

Bash script for automated OCRmyPDF for given input/output directories.

Adds an OCR text layer to all PDF files in the given input directory and saves the new PDF files to the output directory.

## Requirements

- [OCRmyPDF](https://github.com/jbarlow83/OCRmyPDF)\
  For Debian 9/Ubuntu 16.10: `apt-get install ocrmypdf`\
  For other distros: https://ocrmypdf.readthedocs.io/en/latest/installation.html
- Tesseract language files\
  e.g. `apt-get install tesseract-ocr-deu` for German language

## Usage
- Download script or clone repository
- Make script executable `sudo chmod +x OCRmyPDF-script.sh`
- Modify the script to fit your needs:
  - Set default input/output directories
  - Modify the OCRmyPDF command line arguments (you can find an overview of available command line arguments [here](https://ocrmypdf.readthedocs.io/en/latest/cookbook.html))
- Call the script:
  - `OCRmyPDF-script.sh` (no parameter): using default directories for input/output (as defined in the script itself)
  - `OCRmyPDF-script.sh <inputDir> <outputDir>`: using specified directories for input/output
- The script might print some warnings/errors from Tesseract. These can be ignored in most cases as the OCR text layer will be created anyway
