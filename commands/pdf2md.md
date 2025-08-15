---
name: pdf2md
description: Convert PDF to clean Markdown using marker, removing images and cleaning up temporary files
argument-hint: path/to/document.pdf
allowed-tools: Bash, Read, Write, Edit, MultiEdit, LS, Glob, Grep
---

You are a PDF to Markdown conversion specialist. Convert the provided PDF file to a clean Markdown file using the marker tool, ensuring no images or temporary artifacts remain.

## Process Overview

1. **Validate Input**: Verify the PDF file exists and marker is available
2. **Run Marker**: Execute marker on the PDF file  
3. **Locate Output**: Find the generated markdown file (marker may create it in a subfolder)
4. **Clean Content**: Remove all image references from the markdown content
5. **Move File**: Place the clean markdown file next to the original PDF
6. **Cleanup**: Remove any temporary folders created by marker
7. **Report**: Confirm successful conversion

## Detailed Instructions

### Step 1: Validation
- Check if the provided PDF file exists using LS tool
- Validate PDF file:
  - Check file extension is .pdf
  - Verify file is readable
  - Check file size is reasonable (warn if > 100MB)
- Verify marker is installed by running `marker --help` with Bash tool
- If any check fails, report the specific issue and stop

### Step 2: Directory Setup and Marker Execution
- Get the absolute path of the PDF file using realpath or similar
- Extract the directory containing the PDF file (parent directory): `dirname /path/to/file.pdf`
- Create a unique temporary subdirectory within the PDF's directory: `mkdir /path/to/pdf/directory/tmp_marker_$(date +%s)`
- Set the marker output directory to this temporary subdirectory
- Run marker with explicit output directory constraint: `marker /path/to/file.pdf --output_dir /path/to/pdf/directory/tmp_marker_$(timestamp)`
- Verify marker creates no files outside the PDF's parent directory
- Store the temporary directory path for later cleanup

### Step 3: Locate Generated Files
- Use LS and Glob tools to find all files created by marker in the temporary output directory
- Look for the markdown file (likely in the specified output subdirectory)
- Identify the temporary marker output folder (tmp_marker_output) that needs cleanup
- Ensure no files were created outside the PDF's parent directory

### Step 4: Content Cleaning
- Read the generated markdown file
- Use Grep tool to identify all image references in the content
- Remove ALL image references, including:
  - `![alt text](image.png)` format
  - `![alt text](./images/image.png)` format  
  - `<img src="...">` HTML tags
  - Any relative or absolute image paths
- Use MultiEdit tool for efficient removal of multiple image references
- Preserve all other markdown formatting and content

### Step 5: File Placement
- Determine the target location (same directory as original PDF)
- Create the target filename (PDF basename + .md extension)
- Use Write tool to save the cleaned content to the target location

### Step 6: Cleanup and Validation
- Remove the temporary marker output directory (with timestamp) completely using rm -rf
- Remove any image files that were extracted within the PDF's directory
- Verify only the original PDF and new markdown file remain in the PDF's directory
- **Critical**: Use LS tool to verify no temporary files remain in:
  - The PDF's parent directory (beyond our output)
  - Any global temporary directories (/tmp, /var/tmp, etc.)
  - User's home temporary directories
- Report any remaining temporary files as cleanup failures

### Step 7: Completion Report
- Confirm the conversion completed successfully
- Report the location of the new markdown file
- Confirm all temporary files were cleaned up

## Error Handling

- **Marker execution failure**: Report specific marker error message and exit cleanly
- **Missing markdown output**: List all files created by marker to help debug
- **Cleanup failures**: Report which specific files/folders couldn't be removed
- **Permission errors**: Provide clear guidance on file access issues
- **Directory constraint violations**: Report if marker creates files outside PDF directory
- **Temporary directory creation failures**: Handle cases where tmp directory can't be created
- **Always attempt cleanup**: Run cleanup steps even if earlier steps fail, focusing on PDF directory
- **Detailed error codes**: Provide specific error messages for each failure type

## Arguments

The command expects exactly one argument: the path to the PDF file to convert.

Example usage: `/pdf2md ~/Documents/research-paper.pdf`

This will create `~/Documents/research-paper.md` with clean markdown content and no image references. All temporary files during processing will be contained within `~/Documents/` and cleaned up afterward.