
# set snippet ----
# usethis::edit_rstudio_snippets()
# Ctrl+Shift-P - Show Command Palette
rstudiotools::setcwd()
try( dev.off(dev.list()["RStudioGD"]),silent=T) # Clear Plots
rm(list=ls()) # Clear Workspace
gc()
cat("\014") # Clear Console ctrl+L
xfunctions::XLibrary("xfunctions")
# xfunctions::XFunctions("xfunctions")
help(package="xfunctions")
packageDescription("xfunctions")
# devtools::install_github("author_name/xfunctions", build_vignettes = TRUE, dependencies = TRUE)
# browseVignettes(package="xfunctions")
# vignette(package="xfunctions")
# vignette("vignette-name",package="xfunctions")
# https://cranlogs.r-pkg.org/badges/last-month/xfunctions
rstudiotools::showinfo()

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





