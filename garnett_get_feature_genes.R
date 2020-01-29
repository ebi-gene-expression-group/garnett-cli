#!/usr/bin/env Rscript

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
    stop((paste('File', opt$classifier_object, 'does not exist')))
}

# if input is OK, load main packages
suppressPackageStartupMessages(require(opt$database,  character.only = TRUE))
# convert string into variable 
opt$database = get(opt$database)
suppressPackageStartupMessages(require(garnett))

# read the classifier object 
classifier = readRDS(opt$classifier_object)
feature_genes = get_feature_genes(classifier, node = opt$node,
                                  db = opt$database,
                                  convert_ids = opt$convert_ids)
head(feature_genes)

write.table(feature_genes, opt$output_path, sep = "\t") 
print(paste("Output file is written to", opt$output_path))
