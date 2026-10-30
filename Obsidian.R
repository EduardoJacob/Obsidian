

# Load Functions ----
source("ObsidianFunctions.R")

# Select Obsidian Path and Folders ----
obsidian_path = "C:/MEGA/Obsidian"
obsidian_folders = list.dirs(obsidian_path, recursive = FALSE, full.names = TRUE)
obsidian_folders = obsidian_folders[!grepl("^\\.", basename(obsidian_folders))]
obsidian_folders = obsidian_folders[!basename(obsidian_folders) %in% c("Attachments", "images")]

# Generate Indexes for Each Folder ----
for (folder in obsidian_folders) GenerateSimpleObsidianIndex(folder)

# Remove YAML Frontmatter ----
for (folder in obsidian_folders) RemoveYAMLfrontmatter(folder)

# Generate YAML Frontmatter templates ----
for (folder in obsidian_folders) GenerateYAMLfrontmatter(folder)

# Insert YAML Frontmatter ----  
for (folder in obsidian_folders) InsertYAMLfrontmatter(folder)

# ConvertHTMLtoMarkdown() - Use Importer Plugin in Obsidian instead





