


#' Write rda file to `data/`
#'
#' This function writes an `rda` file in `data`
#' and names it `schemeName`. Makes saving objects easier
#' from within a function. Inspired by [this](https://stackoverflow.com/questions/56293910/create-r-data-with-a-dynamic-variable-name-from-function-for-package)
#' StackOverflow post. Uses 'xz' to compress the file.
#'
#' @param schemeName the name of the rda file, without the `.rda` extension
#' @param data the object to save
#' @examples
#' \dontrun{
#' if(interactive()){
#'  write_rda("an_rda_file_named_that", an_object_named_this)
#'  }
#' }
#' @return the path to the rda file
#' @export
#' @rdname write_data
write_data <- function(schemeName, data) {
    rdaFile <- paste0(schemeName, ".rda")
    fileLocation <- file.path(".", "data", rdaFile)
    varName <- paste0(schemeName)

    assign(varName, data)
    eval(parse(text = sprintf("save(%s, file = '%s', compress = 'xz')", varName, fileLocation)))
    return(paste0("data/", rdaFile))
}
