library(usethis)
library(devtools)

# Yr 1st package in a n hr
# https://www.pipinghotdata.com/posts/2020-10-25-your-first-r-package-in-1-hour/
# https://r-pkgs.org/whole-game.html
# https://gist.github.com/sinarueeger/4516b833f4c588a851b50ebcad6ff1d3

usethis::create_package("helpeRs")

#ignore this file

# 1.3.1 Edit the DESCRIPTION file

# 1.3.2 Create a LICENSE
usethis::use_mit_license(copyright_holder = "Denis O'Meally") # permissive sharing

# 1.3.3 Create a README

usethis::use_readme_rmd()

# Use Roxygen to generate documentation
usethis::use_roxygen_md()

# Create the documentation
devtools::document()

# Dependencies
usethis::use_pipe() #everyone needs pipes
# // needed <- renv::dependencies()[[2]]
# // lapply(needed, usethis::use_package(), simplify = TRUE)
usethis::use_package("magrittr")
usethis::use_package("DESeq2")
usethis::use_latest_dependencies()

# setup tests
usethis::use_testthat()
usethis::use_test("format_dt")

# ignore files for build
usethis::use_build_ignore("dev_history.R")

# Check the package is ready to be published
devtools::check()

# Git and Github
usethis::use_git()
usethis::use_github()
usethis::use_pkgdown_github_pages()
usethis::use_github_actions()
usethis::use_github_action("render-rmarkdown")  #render readme, and other Rmd files
usethis::use_github_action("pkgdown")



###############################################################################
###############################################################################

use_readme_rmd()
use_news_md()
use_vignette("helpeRs")
usethis::use_pkgdown()
pkgdown::build_site()

# building the package
devtools::check() # can take a long time
devtools::build()
devtools::install(paste0("../", pckg))


############################

pckg <- "helpeRs"
pckgdir <- "~/workspaces/helpeRs"
me <- "Denis O'Meally"

# run once at start of package
usethis::create_package(paste0(pckgdir, pckg))
usethis::use_mit_license(copyright_holder = me)
usethis::use_readme_rmd()
usethis::use_testthat()
usethis::use_roxygen_md()
usethis::use_pipe() # everyone needs pipes

# code for new functions
funcname <- "newfunction"
imports <- c("dplyr", "tidyr")
usethis::edit_file(paste0("R/", funcname, ".R"))
for (import in imports) usethis::use_package(import)

# testing a function
usethis::use_test(funcname)
devtools::test(filter = funcname)

# documentation
usethis::use_vignette("example")
usethis::use_pkgdown()
pkgdown::build_site()

# building the package
devtools::check() # can take a long time
devtools::build()
devtools::install(paste0("../", pckg))

# use these for specific tasks
# if check() or build_site() take too long
devtools::document() # updates from roxygen function documentation
devtools::test() # runs all your unit tests, or use filter
devtools::run_examples() # checks all your function examples work
pkgdown::build_home() # from README and DESCRIPTION
pkgdown::build_article() # from vignettes
pkgdown::build_reference() # from roxygen function documentation