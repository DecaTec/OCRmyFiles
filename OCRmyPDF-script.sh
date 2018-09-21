#!/bin/bash

# Script for OCR of all PDFs and images from an input directory to an output directory.
# Requirements:
# 	- OCRmyPDF: https://github.com/jbarlow83/OCRmyPDF
# 		Install instructions: https://ocrmypdf.readthedocs.io/en/latest/installation.html
#	- Tesseract language files
#		e.g. "apt-get install tesseract-ocr-deu" for German language
# Usage:
#	- OCRmyPDF-script.sh (no parameter): using default directories for input/output
#	- OCRmyPDF-script.sh <inputDir> <outputDir>: using specified directories for input/output

# Default input/output directories
inputDirDefault="/mnt/LinuxShare/OCR/Input"
outputDirDefault="/mnt/LinuxShare/OCR/Output"

# General command line arguments for OCRmyPDF.
# Modify these to fit your needs.
# More information about command line arguments for OCRmyPDF: https://ocrmypdf.readthedocs.io/en/latest/cookbook.html
# -l deu+eng: Gives a hint for OCRmyPDF which languages are contained in the PDF (requires the corresponding tesseract language files to be installed)
# --output-type pdf: Creates a standard PDF as output (OCRmyPDF creates PDF/A documents by default)
ocrmypdfCmdArgs="-l deu+eng --output-type pdf"

# General command line arguments for tesseract calls (ONLY when converting image files to PDF).
# Modify these to fit yout needs.
# -l deu+eng: Gives a hint for tesseract which languages are contained in the image (requires the corresponding tesseract language files to be installed)
# pdf: Ouput should be PDF
# quiet: Supress tesseract output
imageConvertCmdArgs="-l deu+eng pdf quiet"

# Function for error messages
errorecho() { cat <<< "$@" 1>&2; }

inputDir=$1
outputDir=$2

#
# Check for parameters
#
if [ $# != "0" ] && [ $# != "2" ]
then
    errorecho "ERROR: Wrong number of parameters!"
	errorecho "Usage: OCRmyPDF-script.sh (no parameter): using default directories for input/output"
	errorecho "Usage: OCRmyPDF-script.sh <inputDir> <outputDir>: using specified directories for input/output"
    exit 1
fi

#
# Use default directories if none were specified
#
if [ -z ${inputDir} ]
then
	inputDir=${inputDirDefault}
	echo "No input directory given, using the default input directory ${inputDir}"
	echo
fi

if [ -z ${outputDir} ]
then
	outputDir=${outputDirDefault}
	echo "No output directory given, using the default output directory ${outputDir}"
	echo
fi

#
# Check if directories already exist
#
if [ ! -d "${inputDir}" ]
then
	errorecho "ERROR: The input directory ${inputDir} does not exist!"
	exit 1
fi

if [ ! -d "${outputDir}" ]
then
	echo "The output directory does not exist -> creating ${outputDir}"
	mkdir -p "${outputDir}"
	echo
fi

#
# Check if output directory is empty
#
if [ "$(ls -A "${outputDir}")" ]
then
    errorecho "ERROR: The output directory ${outputDir} is not empty!"
	exit 1
fi

#
# Function to read the input directory and OCR all contained PDFs resursively
#
ocr_recursive() {
    for i in "$1"/*;do
	tmp=$(echo "$i" | sed 's:^'$inputDir'::')

        if [ -d "$i" ]; then
			mkdir -p "${outputDir}${tmp}"
			ocr_recursive "$i"
        elif [ -f "$i" ]; then
			fileType="$(file -b "$i")"

			if [ "${fileType%%,*}" == "PDF document" ]; then
				# It's a PDF file -> OCR it
				echo "Processing (PDF) $i -> ${outputDir}${tmp}"
				ocrmypdf ${ocrmypdfCmdArgs} "${i}" "${outputDir}${tmp}"
				echo "Done"
				echo
			elif  [[ "${fileType}" = *"image data"* ]]; then
				# It's an image -> convert to PDF and OCR it
				echo "Processing (image) $i -> ${outputDir}${tmp%.*}.pdf"
				fullpath="${outputDir}${tmp}"				
				tesseract "${i}" "${fullpath%.*}" ${imageConvertCmdArgs}
				echo "Done"
				echo
			fi
        fi
    done
}

ocr_recursive "${inputDir}"
