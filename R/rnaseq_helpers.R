#' @title RLEplot_mod
#' @description plot the RLEs for each sample
#' @param data_matrix log2 transformed counts, as a data.frame or matrix
#' @param sample_sheet a sample_sheet of class data.frame, with a column named batch
#' @return a ggplot object
#' @author Denis O'Meally
#' @export

RLEplot_mod <- function(data_matrix, sample_sheet, title = NULL, caption = NULL) {
    requireNamespace(matrixStats)
    requireNamespace(tidyr)
    requireNamespace(ggplot2)
    requireNamespace(tibble)

    data_matrix <- as.matrix(data_matrix)
    data_matrix <- data_matrix - rowMedians(data_matrix)
    data_matrix %>%
        as.data.frame() %>%
        tibble::rownames_to_column("Name") %>%
        tidyr::pivot_longer(-Name, values_to = "Count", names_to = "sample_id") %>%
        dplyr::left_join(sample_sheet, copy = TRUE) %>%
        ggplot(aes(x = sample_id, y = Count, fill = condition)) +
        geom_hline(yintercept = 0, color = "black") +
        geom_boxplot(outlier.size = 0.8, outlier.alpha = 0.5) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        ylab("Relative expression") +
        xlab("Sample") +
        labs(title = title, caption = caption)
}

#' @title matrix2tpm
#' @description calculate TPMs from a matrix and a vector of feature lengths
#' @param data_matrix raw counts, as a data.frame or matrix
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
