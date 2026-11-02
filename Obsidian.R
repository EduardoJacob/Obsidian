

# Load Functions ----
source("ObsidianFunctions.R")

# Select Obsidian Path and Folders ----
obsidian_path = "C:/MEGA/Obsidian"
obsidian_folders = list.dirs(obsidian_path, recursive = FALSE, full.names = TRUE)
obsidian_folders = obsidian_folders[!grepl("^\\.", basename(obsidian_folders))]
obsidian_folders = obsidian_folders[!grepl("^\\_", basename(obsidian_folders))]
#obsidian_folders = obsidian_folders[!basename(obsidian_folders) %in% c("Attachments")]

# Rare operations ----

# Remove YAML Frontmatter ----
# ( Optional: Only use if you want to remove existing YAML frontmatter from notes before inserting new frontmatter )
for (folder in obsidian_folders) RemoveYAMLfrontmatter(folder)
# Generate default YAML Frontmatter templates ----
# ( or generate them manually in the yaml folder)
for (folder in obsidian_folders) GenerateYAMLfrontmatter(folder)








# Generate AI summarizations for all notes in Obsidian folder ----
# Uses free Gemini model, but needs API key set in environment variable "GEMINI_API_KEY"
for (folder in obsidian_folders) GenerateSummarizations(folder)

# Generate Indexes for Each Folder ----
for (folder in obsidian_folders) GenerateObsidianIndex(folder,include_summarizations = T)

# Insert YAML Frontmatter ---- 
# Only inserts frontmatter if it doesn't already exist in the note
for (folder in obsidian_folders) InsertYAMLfrontmatter(folder)

# Converts all HTML files in html folder to markdown files
# Needs PANDOC installed in your system
# Better use Importer Plugin in Obsidian instead
# ConvertHTMLtoMarkdown() 

for (folder in obsidian_folders) RecomendNewTopics(folder,num_topics = 4)

# ExplainAndSaveNewNoteToObsidian("Explain Zettelkasten Method","knowledge/zettelkasten.md")
# ExplainAndSaveNewNoteToObsidian("Explain Latent Space in the context of Ai","ai/latent_space.md")
ExplainAndSaveNewNoteToObsidian("Explain Vector Databases in the context of Ai","ai/vector_databases.md")



























