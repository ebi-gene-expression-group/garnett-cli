#!/usr/bin/env Rscript 

# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))
# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

# create input to check the parse_expr_data.R script works correctly 
option_list = list(
    make_option(
        c("-m", "--marker-file"),
        action = 'store',
        default = NA,
        type = 'character',
        help = 'Path for marker file' 
    ),
    make_option(
        c("-e", "--expr-matrix"),
        action = 'store',
        default = NA,
        type = 'character',
        help = 'Output path for expression matrix' 
    ),
    make_option(
        c("-p", "--pheno-data"),
        action = 'store',
        default = NA,
        type = 'character',
        help = 'Output path for phenotype data' 
    ),
    make_option(
        c("-f", "--feature-data"),
        action = 'store',
        default = NA,
        type = 'character',
        help = 'Output path for feature data' 
    )
)
opt = wsc_parse_args(option_list, mandatory=c("marker_file",
                                              "expr_matrix",
                                              "pheno_data",
                                              "feature_data"))

# load packages 
suppressPackageStartupMessages(require(monocle))
suppressPackageStartupMessages(require(garnett))

# obtain marker file and write it to specified location  
path = paste(find.package("garnett"), "/extdata/pbmc_test.txt", sep='')
if(file.exists(path)){
  invisible(file.copy(path, opt$marker_file))  
} else{
    stop("Warning: cannot extract test data: marker file does not exist.")
}

# extract test data from package  
matrix = Matrix::readMM(system.file("extdata", "exprs_sparse.mtx", package = "garnett"))
fData = read.table(system.file("extdata", "fdata.txt", package = "garnett"))
pData = read.table(system.file("extdata", "pdata.txt", package = "garnett"),
                   sep="\t")
#row.names(matrix) = row.names(fData)
#colnames(matrix) = row.names(pData)

# write data to check raw data parsing script 
writeMM(matrix, file = opt$expr_matrix)
write.table(pData, file = opt$pheno_data, row.names = TRUE, sep="\t")
write.table(fData, file = opt$feature_data, row.names = TRUE,  sep="\t")