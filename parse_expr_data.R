#!/usr/bin/env Rscript

suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(workflowscriptscommon))
suppressPackageStartupMessages(require(garnett))
suppressPackageStartupMessages(require(monocle3))

# create a CDS object from raw expression matrix. 
# The CDS will then be used as input in further steps of the workflow

# parse options 
option_list = list(
    make_option(
        c("-r", "--ref-10x-dir"),
        action = "store",
        default = "reference_10X_dir",
        type = 'character',
        help = "10X-type directory with reference expression data"
    ),
    make_option(
        c("-q", "--query-10x-dir"),
        action = "store",
        default = "query_10X_dir",
        type = 'character',
        help = "10X-type directory with query expression data"
    ),
    make_option(
        c("-c", "--ref-output-cds"),
        action = "store",
        default = "ref_cds.rds",
        type = 'character',
        help = "output file path for reference CDS object in .rds format"
    ),
    make_option(
        c("-d", "--query-output-cds"),
        action = "store",
        default = "query_cds.rds",
        type = 'character',
        help = "output file path for query CDS object in .rds format"
    )
)

opt = wsc_parse_args(option_list)
input_dirs = c(opt$ref_10x_dir, opt$query_10x_dir)
cds_names = c(opt$ref_output_cds, opt$query_output_cds)
# process input directories
for(idx in 1:length(input_dirs)){
    input_dir = input_dirs[idx] 
    if(! file.exists(input_dir)) stop((paste('File ', input_dir, 'does not exist')))
    
    # standard 10X-type directory is expected to contain matrix.mtx, genes.tsv and barcodes.tsv files
    if(!all(c("matrix.mtx", "barcodes.tsv", "genes.tsv") %in% list.files(input_dir))){
        stop(paste("Incorrect 10X directory file names: ", input_dir, sep="")
    }
    # remove trailing slashes 
    input_dir = sub("/$", "", input_dir)

    # parse individual files into CDS object 
    expr_matrix = Matrix::readMM(paste(input_dir, "/matrix.mtx"))
    genes = read.table(paste(input_dir, "/genes.tsv"), sep="\t")
    barcodes = read.table(paste(input_dir, "/barcodes.tsv"), sep="\t")
    # matrix entries need to be named 
    row.names(expr_matrix) = genes[, 1]
    colnames(expr_matrix) = barcodes[, 1]
    cds = new_cell_data_set(as(expr_matrix, "dgCMatrix"), cell_metadata = barcodes, gene_metadata = genes)
    saveRDS(cds, file = cds_names[idx])
}
