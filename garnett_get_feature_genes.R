#!/usr/bin/env Rscript


# package management
suppressPackageStartupMessages(require(pacman))
# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))
# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))


# Obtain a list of genes used as features in classification model

# parse options 
option_list = list(
    make_option(
        c("-c", "--classifier-object"),
        action = "store",
        default = NA,
        type = 'character',
        help = "path to the object of class garnett_classifier, which is either
                trained via garnett_train_classifier.R or obtained previously"
    ),
    make_option(
        c("-n", "--node"),
        action = "store",
        default = "root",
        type = 'character',
        help = "In case a hierarchical marker tree was used to train the 
                classifier, specify which node features should be shown. Default
                is 'root'. For other nodes, use the corresponding parent cell
                type name"
    ),
    make_option(
        c("-d", "--database"),
        action = "store",
        default = NA,
        type = 'character',
        help = "argument for Bioconductor AnnotationDb-class package used for
                converting gene IDs. For example, use org.Hs.eg.db for
                Homo Sapiens genes."
    ),
    make_option(
        c("--convert-ids"),
        action = "store_true",
        default = FALSE,
        type = 'logical',
        help = "Boolean that indicates whether the gene IDs should be converted
                into SYMBOL notation. Default: FALSE"
    ),
    make_option(
        c("-o", "--output-path"),
        action = "store",
        default = NA,
        type = 'character',
        help = "Path to the output file"
    )

) 

opt = wsc_parse_args(option_list, mandatory=c("classifier_object", "database",
                                              "output_path"))

# check input parameters 
if(! file.exists(opt$classifier_object)){
    stop((paste('File ', opt$classifier_object, 'does not exist')))
}

# pacman downloads the package if it hasn't been downloaded before 
tryCatch({
    p_load(opt$database, character.only = TRUE)},
    warning = function(w){
        stop((paste('Database',
                     opt$database, 'was not found on Bioconductor')))}
)

# convert string into variable 
opt$database = get(opt$database)

# if input is OK, load the package
suppressPackageStartupMessages(require(garnett))

# read the classifier object 
pbmc_classifier = readRDS(opt$classifier_object)

# run the function 
print(opt$convert_ids)
feature_genes = get_feature_genes(pbmc_classifier, node = opt$node,
                                  db = opt$database,
                                  convert_ids = opt$convert_ids)

write.table(feature_genes, opt$output_path, sep = "\t") 
print(paste("Output file is written to ", opt$output_path))