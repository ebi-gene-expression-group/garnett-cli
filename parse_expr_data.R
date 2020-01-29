#!/usr/bin/env Rscript

# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))
# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

# create a CDS object from raw expression matrix. 
# The CDS will then be used as input in further steps of the workflow

# parse options 
option_list = list(
    make_option(
        c("-i", "--input-10x-dir"),
        action = "store",
        default = "reference_10x_dir",
        type = 'character',
        help = "10X-type directory with reference expression data"
    ),
    make_option(
        c("-o", "--output-cds"),
        action = "store",
        default = "query_cds.rds",
        type = 'character',
        help = "output file path for query CDS object in .rds format"
    )
)

opt = wsc_parse_args(option_list, mandatory = c("input_10x_dir", "output_cds"))

# process input directory
input_dir = opt$input_10x_dir 
if(! file.exists(input_dir)) stop(paste('File', input_dir, 'does not exist'))
# standard 10X-type directory is expected to contain matrix.mtx, genes.tsv and barcodes.tsv files
if(!all(c("matrix.mtx", "barcodes.tsv", "genes.tsv") %in% list.files(input_dir))){
    stop(paste("Incorrect 10X directory file names:", input_dir, "Directory must contain files 'matrix.mtx', 'barcodes.tsv' and 'genes.tsv'"))
}
# remove trailing slashes 
input_dir = sub("/$", "", input_dir)

# if input is OK, load main packages
suppressPackageStartupMessages(require(garnett))
 
# parse individual files into CDS object 
expr_matrix = Matrix::readMM(paste(input_dir, "/matrix.mtx", sep=""))
genes = read.table(paste(input_dir, "/genes.tsv", sep=""), sep="\t", stringsAsFactors=FALSE)
row.names(genes) = genes[,1] 
barcodes = read.table(paste(input_dir, "/barcodes.tsv", sep=""), sep="\t", stringsAsFactors=FALSE)
row.names(barcodes) = barcodes[, 1]

# matrix entries need to be named
row.names(expr_matrix) = row.names(genes)
colnames(expr_matrix) = row.names(barcodes)

cds = new_cell_data_set(as(expr_matrix, "dgCMatrix"), cell_metadata = barcodes, gene_metadata = genes)
saveRDS(cds, file = opt$output_cds)

