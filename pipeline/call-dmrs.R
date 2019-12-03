# ==============================================================================
# Environment
# ==============================================================================
suppressMessages(library("data.table"))
suppressMessages(library("bsseq"))
suppressMessages(library("dmrseq"))
suppressMessages(library("argparse"))

if (!interactive()) {
    PARSER <- argparse::ArgumentParser(
        description = "Perform DMR calculations using DMRSeq"
    )
    PARSER$add_argument(
        "cov",
        type = "character",
        help = "Bismark methylation extractor coverage output files",
        nargs="+"
    )
    PARSER$add_argument(
        "meta",
        type = "character",
        help = "Metadata TSV file"
    )
    PARSER$add_argument(
        "-o", "--output",
        type = "character",
        help = "Output TSV file path",
        default = "dmrs.tsv"
    )
    ARGS <- PARSER$parse_args()
}

# ==============================================================================
# Data
# ==============================================================================
cat("Reading data\n")
# read in sites
bismark_counts = read.bismark(files = ARGS$cov,
    rmZeroCov = TRUE,
    strandCollapse = FALSE,
    verbose = TRUE
)
# metadata for samples
meta = fread(
    ARGS$meta,
    sep = "\t",
    header = TRUE
)
pData(bs)$Condition = meta$Condition
pData(bs)$ID = meta$Sample
pData(bs)$SeqBatch = meta$SeqBatch

# sort before smoothing
bs = sort(bs)

# ==============================================================================
# Analysis
# ==============================================================================
# params = BatchJobsParam(4)
params = MulticoreParam(8)

# perform DMR calculations
cat("Finding DMRs\n")
regions = dmrseq(
    bs,
    cutoff = 0.05,
    # test for condition
    testCovariate = "Condition",
    # control for SeqBatch
    matchCovariate = "SeqBatch",
    BPPARAM = params
)

# convert to data table for saving as TSV
regions_dt = as.data.table(regions)

cat("Saving data\n")
# save data
fwrite(
    regions_dt,
    ARGS$output,
    sep = '\t',
    col.names = TRUE
)
