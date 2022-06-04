#' Mixed pairwise association
#'
#' Calculate a pairwise association between all variables in a data-frame.
#' In particular nominal vs nominal with Chi-square, numeric vs numeric
#' with Pearson correlation, and nominal vs numeric with ANOVA.
#' Adapted from <https://stackoverflow.com/a/52557631/590437>
#' @export
#' @name mixed_assoc
#' @param df a data.frame
#' @param cor_method the method to use, one of `c("pearson", "kendall", "spearman")`; (Default: `spearman`)
#' @param adjust_cramersv_bias Use bias corrected Cramer's V as described in [rcompanion::cramerV()]; (Default: `TRUE`)
#' @return a list with two elements:
#' - `associations` a data.frame  with the pairwise association between each variable
#' - `assoc_matrix` a square matrix of association scores between each variable, with dimensions
#' equal to the number of variables.
mixed_assoc <- function(df, cor_method = "spearman", adjust_cramersv_bias = TRUE) {
    df_comb <- expand.grid(names(df), names(df), stringsAsFactors = F) |> purrr::set_names("X1", "X2")

    is_nominal <- function(x) class(x) %in% c("factor", "character")
    # https://community.rstudio.com/t/why-is-purrr-is-numeric-deprecated/3559
    # https://github.com/r-lib/rlang/issues/781
    is_numeric <- function(x) {
        is.integer(x) || purrr::is_double(x)
    }

    f <- function(xName, yName) {
        x <- dplyr::pull(df, xName)
        y <- dplyr::pull(df, yName)

        result <- if (is_nominal(x) && is_nominal(y)) {
            # use bias corrected cramersV as described in https://rdrr.io/cran/rcompanion/man/cramerV.html
            cv <- rcompanion::cramerV(as.character(x), as.character(y), bias.correct = adjust_cramersv_bias)
            data.frame(xName, yName, assoc = cv, type = "cramersV")
        } else if (is_numeric(x) && is_numeric(y)) {
            correlation <- cor(x, y, method = cor_method, use = "complete.obs")
            data.frame(xName, yName, assoc = correlation, type = "correlation")
        } else if (is_numeric(x) && is_nominal(y)) {
            # from https://stats.stackexchange.com/questions/119835/correlation-between-a-nominal-iv-and-a-continuous-dv-variable/124618#124618
            r_squared <- summary(lm(x ~ y))$r.squared
            data.frame(xName, yName, assoc = sqrt(r_squared), type = "anova")
        } else if (is_nominal(x) && is_numeric(y)) {
            r_squared <- summary(lm(y ~ x))$r.squared
            data.frame(xName, yName, assoc = sqrt(r_squared), type = "anova")
        } else {
            warning(paste("unmatched column type combination: ", class(x), class(y)))
        }

        # finally add complete obs number and ratio to table
        result %>%
            dplyr::mutate(complete_obs_pairs = sum(!is.na(x) & !is.na(y)), complete_obs_ratio = complete_obs_pairs / length(x)) %>%
            dplyr::rename(x = xName, y = yName)
    }

    # apply function to each variable combination
    associations <- purrr::map2_df(df_comb$X1, df_comb$X2, f)

    assoc_matrix <- associations |>
        dplyr::select(x, y, assoc) |>
        tidyr::pivot_wider(names_from = y, values_from = assoc) |>
        tibble::column_to_rownames("x") |>
        as.matrix()

    return(list(assoc_matrix = assoc_matrix, associations = associations))
}