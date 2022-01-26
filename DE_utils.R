#' @title RUV_total
#' @param raw raw counts, with housekeeping, positive and negative control genes of class data.frame
#' @param pData a sample_sheet of class data.frame
#' @param fData a dataframe with gene symbols for rownames, and a "codeClass" column indicating endogenous/housekeeping/positive/negative of class data.frame
#' @param k number of hidden factors to remove, integer
#' @param hkgenes a chr vector of housekeeping gene symbols to override the Nanostring list
#' @param exclude a chr vector of NanoString housekeeping gene symbols to exclude from RUVg. Remove genes if they are affected by the experiemnt.
#'
#' @return a list with an ExpressionSet and a DESeqDataSet, with adjusted values in the assay slot.
#' @author Denis O'Meally
#' @export


RUV_total <- function(raw, pData, fData, k, hkgenes = NULL, exclude = NULL) {
    require(RUVSeq)
    require(DESeq2)
    require(limma)
    require(matrixStats)

    rownames(pData) <- pData$sample_id

    fData <- fData[rownames(raw), , drop = FALSE]
    int <- intersect(rownames(raw), rownames(fData))
    fData <- fData[int, , drop = FALSE]
    raw <- raw[int, ]

    ## USE DESEQ2 FORMULATION TO INTEGRATE RAW EXPRESSION
    ## PDATA AND FDATA
    set <- newSeqExpressionSet(as.matrix(round(raw)),
        phenoData = pData,
        featureData = fData
    )

    cIdx <- rownames(set)[fData(set)$CodeClass == "Housekeeping"]
    cIdx <- cIdx[!(cIdx %in% exclude)]

    if (!is.null(hkgenes)) {
        fData(set)$CodeClass[rownames(set) %in% hkgenes] <- "Housekeeping"
    }

    ## UPPER QUANTILE NORMALIZATION (BULLARD 2010)
    set <- betweenLaneNormalization(set, which = "upper")
    ## RUVg USING HOUSKEEPING GENES
    set <- RUVg(set, cIdx, k = k)
    dds <- DESeqDataSetFromMatrix(counts(set), colData = pData(set), design = ~1)
    rowData(dds) <- fData

    ## SIZE FACTOR ESTIMATIONS
    dds <- estimateSizeFactors(dds)
    dds <- estimateDispersionsGeneEst(dds)
    cts <- counts(dds, normalized = TRUE)
    disp <- pmax((rowVars(cts) - rowMeans(cts)), 0) / rowMeans(cts)^2
    mcols(dds)$dispGeneEst <- disp
    dds <- estimateDispersionsFit(dds, fitType = "mean")

    ## TRANSFORMATION TO THE LOG SPACE WITH A VARIANCE STABILIZING TRANSFORMATION
    vsd <- varianceStabilizingTransformation(dds, blind = FALSE)
    mat <- assay(vsd)

    ## REMOVE THE UNWANTED VARIATION ESTIMATED BY RUVg
    covars <- as.matrix(colData(dds)[, grep("W", colnames(colData(dds))), drop = FALSE])
    mat <- removeBatchEffect(mat, covariates = covars)
    assay(vsd) <- mat
    return(list(set = set, vsd = vsd))
}

#' @title RLEplot_mod
#' @description plot the RLEs for each sample
#' @param data_matrix log2 transformed counts, as a data.frame or matrix
#' @param sample_sheet a sample_sheet of class data.frame, with a column named batch
#' @return a ggplot object
#' @author Denis O'Meally
#' @export

RLEplot_mod <- function(data_matrix, sample_sheet, title = NULL, caption = NULL) {
    require(matrixStats)
    require(tidyr)
    require(ggplot2)
    require(tibble)

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
