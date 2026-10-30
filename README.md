Customize Obsidian from R
================

<!-- README.md is generated from README.Rmd. Please edit that file  -->

<p align="center">

<img src="images/R Programming.png" alt="R Programming" width="600">
</p>

take a look at my youtube playlist with R Tutorials:

------------------------------------------------------------------------

<https://www.youtube.com/playlist?list=PLRbCt61PaxX2d0_QXh6Qi6_jAQd66fmcI>

------------------------------------------------------------------------

# Summary of Obsidian R Utility Functions

This report provides an overview of the R script `ObsidianFunctions.R`,
which contains utility functions designed to automate common
maintenance, metadata management, and conversion tasks for an
**Obsidian** knowledge vault.

------------------------------------------------------------------------

## Overview of Functions

### 1. `GenerateSimpleObsidianIndex(path)`

- **Purpose:** Generates a Markdown index file listing internal
  wiki-links (`[[Note Name]]`) for all `.md` files in a target
  directory.
- **Key Steps:**
  - Scans the directory for files with the `.md` extension
    (non-recursive).
  - Formats each file name (without extension) as an Obsidian
    double-bracket link: `[[filename]]`.
  - Creates or overwrites an index file named `#<folder_name>.md` within
    the target folder.
  - Adds a timestamp header indicating when the index was generated.
  - Prints a summary message detailing the number of indexed files.

------------------------------------------------------------------------

### 2. `RemoveYAMLfrontmatter(path)`

- **Purpose:** Strips YAML frontmatter blocks (the metadata bounded by
  `---` lines at the start of a note) from all Markdown files in a
  directory.
- **Key Steps:**
  - Checks if a file begins with `---`.
  - Locates the matching closing delimiter `---`.
  - Deletes all lines within and including the delimiters, as well as
    leading blank lines.
  - Preserves UTF-8 encoding when writing back the cleaned content.
  - Skips files without YAML headers.

------------------------------------------------------------------------

### 3. `GenerateYAMLfrontmatter(path)`

- **Purpose:** Creates a customized YAML template file for a given
  folder using a master template.
- **Key Steps:**
  - Identifies the target directory name (`basename(path)`).
  - Reads a generic template located at `yaml/template.yaml`.
  - Replaces the placeholder variable `$folder_name` with the current
    folder’s name (commonly used for automatic tag assignment).
  - Saves the resulting configuration to `yaml/<folder_name>.yaml`.

------------------------------------------------------------------------

### 4. `InsertYAMLfrontmatter(path)`

- **Purpose:** Prepends folder-specific YAML frontmatter metadata to all
  Markdown files in a directory.
- **Key Steps:**
  - Reads the corresponding YAML file from `yaml/<folder_name>.yaml`.
  - Iterates through all `.md` files in the directory.
  - **Safety check:** Skips files that already begin with `---` to
    prevent duplicate frontmatter headers.
  - Prepends the YAML header and a blank separator line to each note.

------------------------------------------------------------------------

### 5. `ConvertHTMLtoMarkdown()`

- **Purpose:** Converts local HTML documents to GitHub-Flavored Markdown
  (`gfm`) using **Pandoc**.
- **Key Steps:**
  - Searches the local `./html` directory for files ending in `.html` or
    `.htm`.
  - Invokes the external CLI tool `pandoc` via `system2()`.
  - Converts content from HTML format to Markdown with line-wrapping
    disabled (`--wrap=none`).
  - Saves output `.md` files into the `./markdown` folder with matching
    base filenames.

------------------------------------------------------------------------
