#' @description
#' Turns a data frame or matrix into a DT formatted table
#' with export buttons for copy, csv or excel.
#'
#' @title format_dt
#' @param x a data object (either a `matrix` or a `data.frame`)
#' @return a data table decorated with export buttons
#' @author Denis O'Meally
#' @export
#' @importFrom DT datatable
#' @examples
#' x = matrix(rnorm(9), nrow = 3)
#' format_dt(x)

format_dt <- function(x) {
    DT::datatable(x,
        extensions = "Buttons",
        options = list(
            dom = "Blfrtip",
            buttons = c("copy", "csv", "excel"),
            lengthMenu = list(
                c(10, 25, 50, -1),
                c(10, 25, 50, "All")
            )
        )
    )
}
