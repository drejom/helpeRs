#' @title RLEplot_mod
#' @description plot the relative log expresion for each sample. This plot is 
#' useful for comparing normalization procedures between groups.
#' @param data_matrix log2 transformed counts, as a `data.frame` or `matrix`
#' @param sample_sheet a sample_sheet object that describes the sample metadata
#' @param col_by a column name from `sample_sheet` to colour the plot by
#' @param title a title for the plot. Leave blank for none, or a character string
#' @param caption caption for the plot. Leave blank for none, or a character string
#' @return a ggplot object
#' @author Denis O'Meally
#' @export
#' @import ggplot2
#' @importFrom matrixStats rowMedians
#' @examples
#'
#' m <- -log2(replicate(10,rgamma(3e4, 0.1)))
#' colnames(m) <- letters[1:10]
#' sample_sheet <- data.frame(sample_id = letters[1:10], group = c(rep("A",4),rep("B",6)))
#'
#' RLEplot_mod(m, sample_sheet, col_by = "group", title = "Relative log expression",
#' caption = "Simulated data set of 10 samples in 5 groups drawn from 30000 genes")

RLEplot_mod <- function(data_matrix, sample_sheet, col_by = group, title = NULL, caption = NULL) {

    # check that the sample_sheet has the same length as the data_matrix
    if (nrow(sample_sheet) != ncol(data_matrix)) {
        stop("sample_sheet must have the same number rows as the data_matrix does columns")
    }

    data_matrix <- as.matrix(data_matrix)
    data_matrix <- data_matrix - matrixStats::rowMedians(data_matrix)
    data_matrix %>%
        as.data.frame() %>%
        tibble::rownames_to_column("Name") %>%
        tidyr::pivot_longer(-Name, values_to = "Count", names_to = "sample_id") %>%
        dplyr::left_join(sample_sheet, copy = TRUE) %>%
        ggplot(aes(x = sample_id, y = Count, fill = !!rlang::sym(col_by))) +
        geom_hline(yintercept = 0, color = "black") +
        geom_boxplot(outlier.size = 0.8, outlier.alpha = 0.5) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        ylab("Relative expression") +
        xlab("Sample") +
        labs(title = title, caption = caption)
}

#' @title matrix2tpm
#' @description calculate TPMs from a matrix and a vector of feature lengths
#' @param counts raw counts, as a data.frame or matrix
#' @param len a vector of feature lengths, in Kbp
#' @return a matrix of TPMs
#' @author Mike Love
#' @export

# make a matrix of TPM from raw counts --------------------------------------------------
# https://support.bioconductor.org/p/91218/
matrix2tpm <- function(counts, len) {
    if (grep("gene_symbol", colnames(counts))) {
        counts <- counts[, -c("gene_symbol")]
    }
    x <- counts / len
    return(t(t(x) * 1e6 / colSums(x)))
}
