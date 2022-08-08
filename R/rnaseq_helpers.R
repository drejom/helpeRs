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
#' m <- -log2(replicate(10, rgamma(3e4, 0.1))) %>%
#'     magrittr::set_colnames(letters[1:10])
#' sample_sheet <- data.frame(
#'     sample_id = letters[1:10],
#'     group = c(rep("A", 4), rep("B", 6))
#' )
#'
#' RLEplot_mod(
#'     m,
#'     sample_sheet,
#'     col_by = "group",
#'     title = "Relative log expression",
#'     caption = "Simulated data set of 10 samples in 5 groups drawn from 30000 genes"
#' )
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
#' @description calculate TPMs from a matrix of genes (rows) by samples
#' (columns) and a vector of feature lengths.
#' @param counts raw counts, as a data.frame or matrix
#' @param len a vector of feature lengths, in Kbp
#' @source https://support.bioconductor.org/p/91218/
#' @return Returns a matrix of TPMs, genes in rows, samples in columns
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

#' @title Write an expression matrix to file
#' @name write_tpm_matrix
#' @description Write an TPM expression matrix to a CSV file in `extdata`
#' @param summarised_experiment a `SummarisedExperiment` object
#' @param path the existing folder to write to, Default is `inst/extdata/`
#' @param drop samples (columns) to remove
#' @param tpm minimum TPM for a gene to be kept, Default: 1
#' @param samples minimum number of samples a gene must be present in to be kept, Default: 5
#' @return path to the CSV file
#' @details This function writes an expression matrix to a CSV file in `extdata`,
#' filtering out genes with fewer than `tpm` reads in at least `samples` samples.
#' @examples
#' \dontrun{
#' if (interactive()) {
#'     write_tpm_matrix(cml_mrna_GRCm38_HLT, c("F545.7", "X490.17"), tpm = 1, samples = 5)
#' }
#' }
#' @seealso
#'  \code{\link[SummarizedExperiment]{SummarizedExperiment-class}}
#'  \code{\link[utils]{write.table}}
#' @rdname write_tpm_matrix
#' @export
write_tpm_matrix <- function(summarised_experiment, path = "inst/extdata/", drop = NULL, tpm = 1, samples = 5) {
    object_name <- summarised_experiment@metadata$object_name
    # Subset to samples to drop
    summarised_experiment <- summarised_experiment[, !(colnames(summarised_experiment) %in% drop)]
    # Make a CSV of TPMs, keeping genes with > 1 TPM in 5 samples, and transgenes
    mat <- SummarizedExperiment::assay(summarised_experiment, "abundance")
    filter <- rowSums(mat >= tpm) >= samples
    filter[grep("^HSA_", rownames(summarised_experiment))] <- TRUE
    filtered <- summarised_experiment[filter, ]
    tpm_matrix <- SummarizedExperiment::assay(filtered, "abundance")
    file_name <- paste0(path, object_name, "_", tpm, "tpm_in_", samples, "samples.csv")
    utils::write.csv(tpm_matrix, file_name)
    return(file_name)
}
