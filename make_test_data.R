#!/usr/bin/env Rscript 

suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(workflowscriptscommon))
suppressPackageStartupMessages(require(garnett))

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
        default = 'matrix.mtx',
        type = 'character',
        help = 'Output path for expression matrix' 
    ),
    make_option(
        c("-p", "--pheno-data"),
        action = 'store',
        default = 'barcodes.tsv',
        type = 'character',
        help = 'Output path for phenotype data' 
    ),
    make_option(
        c("-f", "--feature-data"),
        action = 'store',
        default = 'genes.tsv',
        type = 'character',
        help = 'Output path for feature data' 
    ),
    make_option(
        c("-o", "--output-dir"),
        action = 'store',
        default = 'test_10x_dir',
        type = 'character',
        help = 'Output path for feature data' 
    )
)

opt = wsc_parse_args(option_list, mandatory=c("marker_file"))
# obtain marker file and write it to specified location  
path = paste(find.package("garnett"), "/extdata/pbmc_test.txt", sep='')
if(file.exists(path)){
  invisible(file.copy(path, opt$marker_file))  
} else{
    stop("Warning: cannot extract test data: marker file does not exist.")
}

# extract test data from garnett package  
matrix = Matrix::readMM(system.file("extdata", "exprs_sparse.mtx", package = "garnett"))
fData = read.table(system.file("extdata", "fdata.txt", package = "garnett"))
pData = read.table(system.file("extdata", "pdata.txt", package = "garnett"), sep="\t")

dir = opt$output_dir
if(!endsWith(dir, "/")) dir = paste(dir, "/", sep="")
dir.create(dir)

# write files into 10x directory 
Matrix::writeMM(matrix, file = paste0(dir, opt$expr_matrix, sep=""))
write.table(pData, file = paste0(dir, opt$pheno_data, sep=""), row.names = TRUE, sep="\t")
write.table(fData, file = paste0(dir, opt$feature_data, sep=""), row.names = TRUE,  sep="\t")
