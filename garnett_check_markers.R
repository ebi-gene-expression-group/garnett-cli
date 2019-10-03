#!/usr/bin/env Rscript

# package management
#suppressPackageStartupMessages(require(pacman))
# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))
# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

# Using information from CDS object, determine which markers are suitable 
# for identification of cell type. See Garnett publication for more details.

# parse options 
option_list = list(
    make_option(
        c("-c", "--cds-object"),
        action = "store",
        default = NA,
        type = 'character',
        help = "CDS object with expression data"
    ),
    make_option(
        c("-m", "--marker-file-path"),
        action = "store",
        default = NA,
        type = 'character',
        help = "File with marker genes specifying cell types. See 
        https://cole-trapnell-lab.github.io/garnett/docs/#constructing-a-marker-file
        for specification of the file format."
    ),
    make_option(
        c("-d", "--database"),
        action = "store",
        default = NA,
        type = 'character',
        help = "argument for Bioconductor AnnotationDb-class package
                used for converting gene IDs.
                For example, use org.Hs.eg.db for Homo Sapiens genes."
    ),
    make_option(
        c("--cds-gene-id-type"),
        action = "store",
        default = "ENSEMBL",
        type = 'character',
        help = "Format of the gene IDs in your CDS object.
                The default is \"ENSEMBL\"."
    ),
    make_option(
        c("--marker-file-gene-id-type"),
        action = "store",
        default = "SYMBOL",
        type = 'character',
        help = "Format of the gene IDs in your marker file.
                The default is \"ENSEMBL\"."
    ),
    make_option(
        c("-o", "--marker-output-path"),
        action = "store",
        default = NA,
        type = 'character',
        help = "Path to the output file with marker scores"
    ),
    make_option(
        c("--plot-output-path"),
        action = "store",
        default = NA,
        type = 'character',
        help = "Optional. If you would like to make a marker plot,
                provide a name (path) for it."
    ),
    make_option(
        c("--propogate-markers"),
        action = "store_true",
        default = TRUE,
        type = 'logical',
        help = "Optional. Should markers from child nodes of a cell type be used
                in finding representatives of the parent type?
                Default: TRUE."
    ),
    make_option(
        c("--use-tf-idf"),
        action = "store_true",
        default = TRUE,
        type = 'logical',
        help = "Optional. Should TF-IDF matrix be calculated during estimation?
                If TRUE, estimates will be more accurate, but calculation is slower
                with very large datasets.
                Default: TRUE."
    ),
    make_option(
        c("--classifier-gene-id-type"),
        action = "store",
        default = "ENSEMBL",
        type = 'character',
        help = "Optional. The type of gene ID that will be used in the
                classifier. If possible for your organism, this should be 'ENSEMBL',
                which is the default. Ignored if db = 'none'."
    ),
    make_option(
        c("--amb-marker-cutoff"),
        action = "store",
        default = 0.5,
        type = 'double',
        help = "(Plotting option). Numeric; Cutoff at which to label ambiguous markers.
                Default 0.5."
    ),
    make_option(
        c("--label-size"),
        action = "store",
        default = 2,
        type = 'double',
        help = "(Plotting option). Numeric, size of the text labels for ambiguous
                markers and unplotted markers."
    )
)

opt = wsc_parse_args(option_list, mandatory = c('cds_object', 'marker_file_path',
                                                'database', 'marker_output_path'))

# check parameters are correctly defined 
if(! file.exists(opt$cds_object)){
    stop((paste('File ', opt$cds_object, 'does not exist')))
}

if(! file.exists(opt$marker_file_path)){
    stop((paste('File ', opt$marker_file_path, 'does not exist')))
}

# load the database. pacman downloads the package if it's not installed 
# tryCatch({
#     p_load(opt$database, character.only = TRUE)},
#     warning = function(w){
#     stop((paste('Database', opt$database, 'was not found on Bioconductor')))}
# )

suppressPackageStartupMessages(require(opt$database, character.only = TRUE))
# convert string into variable 
opt$database = get(opt$database)

# if input is OK, load the package
suppressPackageStartupMessages(require(garnett))

# read the CDS object
pbmc_cds = readRDS(opt$cds_object)

# run the core function 
marker_check = check_markers(pbmc_cds, opt$marker_file_path,
                             db = opt$database, 
                             cds_gene_id_type = opt$cds_gene_id_type,
                             marker_file_gene_id_type = opt$marker_file_gene_id_type, 
                             propogate_markers = opt$propogate_markers,
                             use_tf_idf = opt$use_tf_idf,
                             classifier_gene_id_type = opt$classifier_gene_id_type)

if(! is.na(opt$plot_output_path)){
    print(paste("plotting path", opt$plot_output_path))
    png(filename = opt$plot_output_path)
    print(plot_markers(marker_check, amb_marker_cutoff = opt$amb_marker_cutoff,
                       label_size = opt$label_size))
    dev.off()
}

print(marker_check)
write.table(marker_check, file = opt$marker_output_path, sep = "\t")