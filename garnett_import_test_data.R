#!/usr/bin/env Rscript

# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))
# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

# need to import CDS object and marker file
option_list = list(
    make_option(
        c("-c", "--cds-object"),
        action = 'store',
        default = NA,
        type = 'character',
        help = 'Output path for CDS object'
    ), 
    make_option(
        c("-m", "--marker-file"),
        action = 'store',
        default = NA,
        type = 'character',
        help = 'Output path for marker file'
    )
)
opt = wsc_parse_args(option_list, mandatory=c("cds_object", "marker_file"))
suppressPackageStartupMessages(library(garnett))
path = paste(find.package("garnett"), "/extdata/pbmc_test.txt", sep='')
if(file.exists(path)){
  invisible(file.copy(path, opt$marker_file))  
} else{
    stop("Warning: cannot extract test data: marker file does not exist.")
}
saveRDS(test_cds, file = opt$cds_object)