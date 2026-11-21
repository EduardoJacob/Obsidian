

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


ExplainAndSaveNewNoteToObsidian = function(prompt,new_note) {
  # prompt = "Explain Zettelkasten Method"
  # new_note = "knowledge/zettelkasten.md"
  
  answer = aitools::gemini(prompt,model="3.5-flash-lite")
  answer = answer[1]
  
  # Create the folder if it doesn't exist
  # note_folder = dirname(new_note)
  # if (!dir.exists(note_folder)) dir.create(note_folder, recursive = TRUE)
  
  # Save the answer to the new note
  new_note = file.path(obsidian_folder,new_note)
  writeLines(answer,new_note,useBytes = TRUE)
  
  message("New note created: ", new_note)
}


GenerateObsidianIndex = function(folder,include_summarizations=FALSE) { 
  # folder = "C:/MEGA/Obsidian/python"
  files = GetObsidianNotes(folder)
  N = length(files)
  
  index_full_folder = GetObsidianIndex(folder)
  
  wikilinks = paste0("[[",tools::file_path_sans_ext(basename(files)),"]]")
 
  if (include_summarizations) {
    aux_wikilinks = vector()
    for ( i in 1:length(files) ) {
      summarization = GetSummarizationContent(files[i])
      aux_wikilinks = c(aux_wikilinks,wikilinks[i],summarization," ")
    }
    wikilinks = aux_wikilinks
  } 
  
  label = paste0("Index created by obsidian.R at ", Sys.time())
  wikilinks = c(label,wikilinks)  
  
  writeLines(wikilinks,index_full_folder)
  
  # cat(readLines(index_full_folder), sep = "\n")
  message("Obsidian index ",index_full_folder," created with ",N," entries")
}


GeneratePDF = function(folder) {
  # folder = "C:/MEGA/Obsidian/python"
  markdown = file.path("markdown",paste0(basename(folder),".md"))
  pdf = file.path("pdf",paste0(basename(folder),".pdf"))
  
  pandoc_available = rmarkdown::pandoc_available()
  if (!pandoc_available) {
    message("Pandoc is not available. Please install Pandoc to generate PDF.")
    return()
  }
  tinytext_available = tinytex::is_tinytex()
  if (!tinytext_available) {
    # install.packages("tinytex")
    # tinytex::install_tinytex()
    message("TinyTeX is not available. Please install TinyTeX to generate PDF.")
    return()
  }
  # xelatex_available = tinytex::tlmgr_search("xelatex")
  
  message("Generating PDF: ", pdf) 
  
  files = list.files(folder,pattern = "\\.md$",full.names = TRUE)
  
  content = unlist(lapply(files, function(f) {
    c(
      "\\newpage",
      readLines(f, warn = FALSE)
    )
  }))
  
  writeLines(content,markdown)
  
  # Inject YAML Header for PDF output
  yaml = c(
    "---",
    "title: Generated from RStudio",
    "output:",
    "  pdf_document:",
    "    latex_engine: xelatex",
    "header-includes:",
    "  - \\usepackage{graphicx}",
    "  - \\graphicspath{{C:/MEGA/Obsidian/_attachments/}}",
    "---",
    ""
  )
  
  markdown_content = readLines(markdown, warn = FALSE)
  
  writeLines(c(yaml, markdown_content),markdown)
  
  rmarkdown::render(
    markdown,
    output_format = rmarkdown::pdf_document(
      latex_engine = "xelatex",
      extra_dependencies = NULL
    ),
    output_dir = "pdf",
    quiet = TRUE,
    envir = new.env()
  )
  
  
}


GenerateSummarizations = function(folder,overwrite=FALSE,max_words=40) {
  # folder = "C:/MEGA/Obsidian/python"
  files = GetObsidianNotes(folder)
  
  output_folder = file.path("summarizations",basename(folder))
  # Create the folder if it doesn't exist
  if (!dir.exists(output_folder)) dir.create(output_folder, recursive = F)
  
  for ( file in files) {
    markdown = readLines(file,warn = FALSE,encoding = "UTF-8")
    prompt_header = paste0("Summarize the following obsidian note. Return only one paragraph, no more then ",max_words," words:")
    prompt = c(prompt_header,markdown)
    prompt = paste(prompt, collapse = "\n")
    # print(prompt)
    output_summarization = GetSummarization(file)
    
    if (!file.exists(output_summarization) || overwrite) {
      # answer = aitools::lmstudio(prompt)
      answer = aitools::gemini(prompt,model="3.5-flash-lite")
      answer = answer[1]
      message("Summarization for ",output_summarization," created.")
      message(answer)
      writeLines(answer,output_summarization,useBytes = TRUE)
    } else {
      message("Summarization for ",output_summarization," already exists. Skipping.")
    }
    
  }
}


GenerateYAMLfrontmatter = function(folder) {
  # folder = "C:/MEGA/Obsidian/python"
  tagname = basename(folder)
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


GetObsidianIndex = function(folder) {
  # index = paste0("_",basename(folder),".md")
  index = paste0(basename(folder),".md")
  index = file.path(folder,index)
  return( index )
}


GetObsidianNotes = function(folder,include_index=FALSE) {
  # folder = "C:/MEGA/Obsidian/python"
  files = list.files(folder, pattern = "\\.md$", recursive = FALSE, full.names = T,ignore.case=T)
  if (include_index) return(files)
  
  # Remove the index file itself from the list of files
  index = GetObsidianIndex(folder)
  files = files[!grepl(index,files,fixed = TRUE)]
  
  return(files)
}


GetSummarization = function(file) {
  output_folder = paste0(basename(dirname(file)), "/", basename(file))
  summarization = file.path("summarizations",output_folder)
  return(summarization)
}


GetSummarizationContent = function(file) {
  summarization = GetSummarization(file)
  
  content = if (file.exists(summarization)) {
    paste(readLines(summarization, warn = FALSE), collapse = "\n")
  } else {
    ""
  }
  
  return(content)
}


InsertBlankLine = function(folder) {
  
  # Get Markdown files
  files = GetObsidianNotes(folder,include_index = TRUE)
  
  for (file in files) {
    # Appends a blank line
    cat("\n", file = file, append = TRUE)
    
    message("Blank Line inserted in: ", file)
  }
  
}


InsertYAMLfrontmatter = function(folder) {
  yaml_file = paste0(basename(folder),".yaml")
  yaml_file = file.path("yaml",yaml_file)
  
  # Read YAML template
  yaml = readLines(
    yaml_file,
    warn = FALSE,
    encoding = "UTF-8"
  )
  
  # Get Markdown files
  files = GetObsidianNotes(folder,include_index = TRUE)
  
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
    writeLines(output,file,useBytes = TRUE)
    
    message("YAML frontmatter inserted in: ", file)
  }
  
}


RecommendNewTopics = function(folder,num_topics=3) {
  # folder = "C:/MEGA/Obsidian/python"
  files = GetObsidianNotes(folder)
  # N = length(files)
  # if ( N == 0 ) {
  #   message(folder," does not contain markdown notes. Skipped")
  #   return()
  # }
  
  topic = basename(folder)
  wikilinks = paste0("[[",tools::file_path_sans_ext(basename(files)),"]]")
  
  prompt = c(
    "I have an Obsidian vault where i am studying",topic,
    ". my vault already contains the following notes:",wikilinks,
    ", please recommend",num_topics,"other topics related with",topic,"so I can progress in my study. Give me only the names of the topics")
  prompt = paste(prompt, collapse = " ")
  answer = aitools::gemini(prompt,model="3.5-flash-lite")
  answer = answer[1]
  cat("Recomendations about",topic,":\n",answer)
}


RemoveYAMLfrontmatter = function(folder) {
  # folder = "C:/MEGA/Obsidian/python"
  
  # Get Markdown files
  files = GetObsidianNotes(folder,include_index = TRUE)
  
  for (file in files) {
      
      lines = readLines(file, warn = FALSE)
      
      i = which(lines == "<!-- END -->")[1]
      
      if (!is.na(i)) {
        message("Removing YAML frontmatter from: ", file)
        lines = lines[(i + 1):length(lines)]
        writeLines(lines,file)
      } else {
        message("No YAML frontmatter found in: ", file)
      }
       
  }
  
}

