
 
# Generate an index of all files in the specified path for Obsidian
GenerateSimpleObsidianIndex = function(path) {
  # path = "C:/MEGA/Obsidian/python"
  files = paste0("[[",
    tools::file_path_sans_ext(
      list.files(path, pattern = "\\.md$", recursive = FALSE, full.names = FALSE,ignore.case=T)
      ),
    "]]"
  )
  N = length(files)
  
  index = paste0("#",basename(path), ".md")
  index_full_path = file.path(path,index)
  
  label = paste0("Index created by obsidian.R at ", Sys.time())
  files = c(label,files)
  writeLines(files,index_full_path)
  
  cat(readLines(index_full_path), sep = "\n")
  message("Obsidian index ", file.path(path,index)," created with ",N," entries")
}
 

# Remove YAML frontmatter
RemoveYAMLfrontmatter = function(path) {
  # path = "C:/MEGA/Obsidian/python"
  
  # Get Markdown files
  files = list.files(
    path = path,
    pattern = "\\.md$",
    recursive = FALSE,
    full.names = TRUE,
    ignore.case = TRUE
  )
  
  for (file in files) {
    
    # Read the note
    lines = readLines(file, warn = FALSE, encoding = "UTF-8")
    
    # Check whether the note starts with YAML frontmatter
    if (length(lines) >= 2 && identical(trimws(lines[1]), "---")) {
      
      # Find the closing delimiter
      closing = which(
        trimws(lines[-1]) == "---"
      ) + 1L
      
      if (length(closing) > 0) {
        
        # Remove the YAML block, including delimiters
        lines = lines[-seq_len(closing[1])]
        
        # Remove blank lines at the beginning
        while (length(lines) > 0 && trimws(lines[1]) == "") {
          lines = lines[-1]
        }
        
        # Write the modified note
        writeLines(
          lines,
          file,
          useBytes = TRUE
        )
        
        message("YAML frontmatter removed from: ", file)
      } 
    } else {
      message("No YAML frontmatter found in: ", file)
    }
  }
  
}


# Generate a YAML frontmatter template for the specified path
GenerateYAMLfrontmatter = function(path) {
  # path = "C:/MEGA/Obsidian/python"
  tagname = basename(path)
  yaml_template = file.path("yaml","template.yaml")
  yaml_file = paste0(tagname,".yaml")
  yaml_file = file.path("yaml",yaml_file)
  
  # Read template
  yaml = readLines(yaml_template, warn = FALSE)
  
  # Replace placeholder
  yaml = gsub("\\$folder_name",tagname, yaml, fixed = FALSE)
  
  # Save YAML file
  output_file = file.path("yaml",paste0(tagname,".yaml"))
  writeLines(yaml, output_file)
  message("YAML frontmatter template created: ", output_file) 
}


# Insert YAML frontmatter into all Markdown files in the specified path
InsertYAMLfrontmatter = function(path) {
  yaml_file = paste0(basename(path),".yaml")
  yaml_file = file.path("yaml",yaml_file)
  
  # Read YAML template
  yaml = readLines(
    yaml_file,
    warn = FALSE,
    encoding = "UTF-8"
  )
  
  # Get Markdown files
  files = list.files(
    path = path,
    pattern = "\\.md$",
    recursive = FALSE,
    full.names = TRUE,
    ignore.case = TRUE
  )
  
  for (file in files) {
    
    # Read note
    lines = readLines(
      file,
      warn = FALSE,
      encoding = "UTF-8"
    )
    
    # Skip notes that already have YAML frontmatter
    if (length(lines) > 0 && trimws(lines[1]) == "---") {
      message(file," already has YAML frontmatter. Skipping.")
      next
    }
    
    # Insert YAML at the beginning
    output = c(yaml, "", lines)
    
    # Write modified note
    writeLines(output,file,useBytes = TRUE
    )
    
    message("YAML frontmatter inserted in: ", file)
  }
  
}


# Convert all HTML files in the source directory to Markdown and copy them to the vault directory
# If needed use windows 11 power rename to all html files prior to call this function
ConvertHTMLtoMarkdown = function() {
 
  # Find HTML files
  html_files = list.files(
    "./html",
    pattern = "\\.html?$",
    full.names = TRUE,
    recursive = FALSE,
    ignore.case = TRUE
  )
  
  # Convert HTML files to Markdown
  for (html_file in html_files) {
    
    md_file = file.path(
      "./markdown",
      paste0(
        tools::file_path_sans_ext(basename(html_file)),
        ".md"
      )
    )
    
    system2(
      "pandoc",
      args = c(
        "-f", "html",
        "-t", "gfm",
        "--wrap=none",
        "-o", shQuote(md_file),
        shQuote(html_file)
      )
    )
    
    cat("Converted:", basename(html_file), "\n")
  }
  
  cat("\nConversion completed!\n")
}


