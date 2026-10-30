
# Install packages
# pak::pak("eduardojacob/rstudiotools")
# pak::pak("eduardojacob/aitools")
# pak::pak("eduardojacob/xfunctions")
# pak::pak("eduardojacob/minifunctions")

# devtools::install_github("eduardojacob/rstudiotools", build_vignettes = TRUE, dependencies = TRUE)
# devtools::install_github("eduardojacob/aitools", build_vignettes = TRUE, dependencies = TRUE)
# devtools::install_github("eduardojacob/xfunctions", build_vignettes = TRUE, dependencies = TRUE)
# devtools::install_github("eduardojacob/minifunctions", build_vignettes = TRUE, dependencies = TRUE)

usethis::use_git()
#usethis::use_git_remote("origin", url = NULL, overwrite = TRUE)

usethis::use_github()

usethis::use_readme_rmd()

usethis::browse_github()

# usethis::use_git_ignore("voices")
# usethis::use_git_ignore("transcriptions")

# Start LM Studio if needed (if terminal already in use, close terminal panel and run again)
terminal_id = rstudiotools::terminal("./powershell/LMstudioStart.ps1",caption="Claude")
# Start Claude Code if needed ( Claude Code is failing with my qwen model )
# terminal_id = rstudiotools::terminal("claude --model qwen/qwen3.5-9b",terminal_id = terminal_id)

# prompt = "Review the project and update claude.md to reflect the current architecture and recent changes."
# terminal_id = rstudiotools::terminal(prompt, terminal_id = terminal_id)
# terminal_id = rstudiotools::terminal("qual a capital de El Salvador ?", terminal_id = terminal_id)




minifunctions::imagegrid("P:/DISKD/Youtube R Programming/AppLogos")
 
rstudiotools::displaymedia("./screenshots")
 





