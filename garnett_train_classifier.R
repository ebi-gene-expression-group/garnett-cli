#!/usr/bin/env Rscript

# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))
# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

# Train the classification model using the updated marker file and CDS object

# get the number of cores for parallel execution 
suppressPackageStartupMessages(require(parallel))
n_cores = detectCores()

# parse options 
option_list = list(
    make_option(
        c("-c", "--cds-object"),
        action = "store",
        default = NA,
        type = 'character',
        help = "CDS object with expression data for training"
    ),
    make_option(
        c("-m", "--marker-file-path"),
        action = "store",
        default = NA,
        type = 'character',
        help = "File with marker genes specifying cell types. 
        See https://cole-trapnell-lab.github.io/garnett/docs/#constructing-a-marker-file
        for specification of the file format."
    ),
    make_option(
        c("-d", "--database"),
        action = "store",
        default = NA,
        type = 'character',
        help = "argument for Bioconductor AnnotationDb-class package used
                for converting gene IDs
                For example, use org.Hs.eg.db for Homo Sapiens genes."
    ),
    make_option(
        c("-f", "--train-idf"), 
        action = "store",
        default = NA,
        type = 'character',
        help = 'Path to the training data IDF file (optional)'
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
        The default is \"SYMBOL\"."
    ),
    make_option(
        c("-n", "--num-unknown"),
        action = "store",
        default = 500,
        type = "integer",
        help = "Number of outgroups to compare against. Default %default."
    ),
    make_option(
        c("--min-observations"),
        action = "store",
        default = 8,
        type = "integer",
        help = "An integer. The minimum number of representative cells per 
        cell type required to include the cell type in the predictive model.
        Default is 8."
    ),
    make_option(
        c("--max-training-samples"),
        action = "store",
        default = 500,
        type = "integer",
        help = "An integer. The maximum number of representative cells per cell
        type to be included in the model training. Decreasing this number 
        increases speed, but may hurt performance of the model. Default is 500."
    ),
    make_option(
        c("--propogate-markers"),
        action = "store_true",
        default = TRUE,
        help = "Optional. Should markers from child nodes of a cell type be used
        in finding representatives of the parent type?
        Default: TRUE."
    ),
    make_option(
        c("--cores"),
        action = "store",
        default = n_cores,
        type = 'integer',
        help = "Optional. The number of cores to use for computation. 
        Default: number returned by detectCores()."
    ),
    make_option(
        c("--lambdas"),
        action = "store",
        default = NULL,
        type = 'double',
        help = "Optional. Path to user-supplied lambda sequence
                (numeric vector in .rds format); default is NULL,
                and glmnet chooses its own sequence. "
    ),
    make_option(
        c("--classifier-gene-id-type"),
        action = "store",
        default = "ENSEMBL",
        type = 'character',
        help = "Optional. The type of gene ID that will be used in the classifier.
        If possible for your organism, this should be 'ENSEMBL', which is
        the default. Ignored if db = 'none'."
    ),
    make_option(
        c("-o", "--output-path"),
        action = "store",
        default = NA,
        type = 'character',
        help = "Path to the output file"
    )
)

opt = wsc_parse_args(option_list, mandatory=c("cds_object", "marker_file_path", 
                                              "database", "output_path"))

# check parameters are correctly defined 
if(! file.exists(opt$cds_object)){
    stop((paste('File', opt$cds_object, 'does not exist')))
}

if(! file.exists(opt$marker_file_path)){
    stop((paste('File', opt$marker_file_path, 'does not exist')))
}

# if input is OK, load main packages
suppressPackageStartupMessages(require(opt$database,  character.only = TRUE))
# convert string into variable 
opt$database = get(opt$database)
suppressPackageStartupMessages(require(garnett))

# read the CDS object
cds = readRDS(opt$cds_object)
set.seed(123)
if(! is.null(opt$lambdas)){
    lambdas = readRDS(opt$lambdas)
} else{
    lambdas = opt$lambdas
}

classifier = train_cell_classifier(cds = cds,
                                   marker_file = opt$marker_file_path,
                                   db=opt$database,
                                   cds_gene_id_type = opt$cds_gene_id_type,
                                   num_unknown = opt$num_unknown,
                                   marker_file_gene_id_type = opt$marker_file_gene_id_type,
                                   min_observations = opt$min_observations,
                                   max_training_samples = opt$max_training_samples,
                                   propogate_markers = opt$propogate_markers,
                                   cores = opt$cores, 
                                   lambdas = lambdas,
                                   classifier_gene_id_type = opt$classifier_gene_id_type)

# add dataset field to the object 
if(!is.na(opt$train_idf)){
    idf = readLines(opt$train_idf)
    L = idf[grep("ExpressionAtlasAccession", idf)]
    dataset = unlist(strsplit(L, "\\t"))[2]
    attributes(classifier)$dataset = dataset
    } else{
        attributes(classifier)$dataset = NA
    }

saveRDS(classifier, file = opt$output_path)
