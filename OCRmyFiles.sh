#!/bin/bash

# Bash script for adding a text layer to PDF files and converting images in PDFs (with OCR).
# Requirements:
# 	- OCRmyPDF: https://github.com/jbarlow83/OCRmyPDF
# 		Install instructions: https://ocrmypdf.readthedocs.io/en/latest/installation.html
#	- Tesseract: https://github.com/tesseract-ocr/
#		This is installed with OCRmyPDF automatically
#	- Tesseract language files
#		e.g. "apt-get install tesseract-ocr-deu" for German language
# Usage:
#	- OCRmyFiles.sh (no parameter): using default directories for input/output
#	- OCRmyFiles.sh <inputDir> <outputDir>: using specified directories for input/output
#
# Remarks:
# 	- After OCR, all files from the input directory are deleted. If you want to keep the input files, just comment out the call of the function 'cleanup_inputDir' at the end of the script.

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
imageConvertCmdArgs="-l deu+eng pdf"

countPDF=0
countImage=0
countCopy=0

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
# Locking
#
# The script should only run in one instance per input directory.
# So the lock directory is saved in the input directory, not under /var/lock
# Create a "lock" directory also in output directory to indicate that the script is currently running
lockdir="${inputDir}/ocrmyfiles.lock"
runningdir="${outputDir}/ocrmyfiles_running.lock"

if mkdir "$lockdir" 
then
     # Remove lockdir when the script finishes
     trap cleanup_locks 0
else
     errorecho "Script is currently running for input directory ${inputDir}, aborting..."
     exit 1
fi

# Create a "lock" directory in output directory to indicate that the script is currently running
runningdir="${outputDir}/ocrmyfiles_running.lock"
mkdir "$runningdir"

# Function to clean up locks
function cleanup_locks {
	rm -rf "$lockdir"
	rm -rf "$runningdir"
}

# Function to clean up the input directory
function cleanup_inputDir {
        rm -rf "${inputDir}"/*
}

#
# Function to read the input directory and OCR all contained PDFs resursively
#
ocr_recursive() {
    for i in "$1"/*;do
		tmp=$(echo "$i" | sed 's:^'"$inputDir"'::')

		# Skip lock directory
		if  [ "$i" = "$lockdir" ]; then
			continue
		fi

        if [ -d "$i" ]; then
			mkdir -p "${outputDir}${tmp}"
			ocr_recursive "$i"
        elif [ -f "$i" ]; then
			fileType="$(file -b "$i")"

			if [ -f "${outputDir}${tmp%.*}.pdf" ]; then
				# If the file already exist in the output directory, skip it.
				echo "File ${outputDir}${tmp%.*}.pdf already exists, skipping..."
				continue
			fi

			if [ "${fileType%%,*}" == "PDF document" ]; then
				# It's a PDF file -> OCR it
				echo "Processing (PDF) $i -> ${outputDir}${tmp}"
				ocrmypdf ${ocrmypdfCmdArgs} "${i}" "${outputDir}${tmp}"

				if [ ! $? -eq 0 ]; then
					# Error while processing PDF file, maybe it already contains a text layer -> simply copy to output directory
					cp "${i}" "${outputDir}${tmp}"
				fi

				echo "Done"
				echo
				countPDF=$((countPDF + 1))
			elif  [[ "${fileType}" = *"image data"* ]]; then
				# It's an image -> convert to PDF and OCR it
				echo "Processing (image) $i -> ${outputDir}${tmp%.*}.pdf"
				fullpath="${outputDir}${tmp}"				
				tesseract "${i}" "${fullpath%.*}" ${imageConvertCmdArgs}
				echo "Done"
				echo
				countImage=$((countImage + 1))
			else
				# Other file types -> just copy to output directory.
				echo "Copy $i -> ${outputDir}${tmp}"
				cp "${i}" "${outputDir}${tmp}"
				echo "Done"
				echo
				countCopy=$((countCopy + 1))
			fi
        fi
    done
}

shopt -s dotglob
ocr_recursive "${inputDir}"
cleanup_inputDir
shopt -u dotglob

echo
echo "Finished"
echo "PDF files processed: ${countPDF}"
echo "Image files processed: ${countImage}"
echo "Other files copied: ${countCopy}"
