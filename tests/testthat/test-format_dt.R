testthat::test_that("a datatables htmlwidget is returned", {

    y <- c("datatables", "htmlwidget")
    x <- class(format_dt(matrix(rnorm(9), nrow = 3)))

    testthat::expect_equal(y, x)
})
