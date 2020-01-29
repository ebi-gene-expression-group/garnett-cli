#!/usr/bin/env Rscript

# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))
# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

# Classify cells into cell types using a pre-trained classifier or one obtained
# via garnett_train_classifier.R 

# parse options 
option_list = list(
    make_option(
        c("-i", "--cds-object"),
        action = "store",
        default = NA,
        type = 'character',
        help = "Query CDS object holding expression data to be classified"
    ),
    make_option(
        c("-c", "--classifier-object"),
        action = "store",
        default = NA,
        type = 'character',
        help = "Path to the object of class garnett_classifier, which is either
                trained via garnett_train_classifier.R or obtained previously"
    ),
    make_option(
        c("-d", "--database"),
        action = "store",
        default = NA,
        type = 'character',
        help = "Argument for Bioconductor AnnotationDb-class package used for
                converting gene IDs. For example, use org.Hs.eg.db for
                Homo Sapiens genes."
    ),
    make_option(
        c("--cds-gene-id-type"),
        action = "store",
        default = "ENSEMBL",
        type = 'character',
        help = "Format of the gene IDs in your CDS object. The default
                is \"ENSEMBL\"."
    ),
    make_option(
        c("-e", "--cluster-extend"),
        action = "store_true",
        default = TRUE, 
        type = 'logical',
        help = "Boolean, tells Garnett whether to create a second set of
                assignments that expands classifications to cells in the same
                cluster. Default: TRUE"
    ),
    make_option(
        c("--rank-prob-ratio"),
        action = "store",
        default = 1.5,
        type = 'double',
        help = "Numeric value greater than 1. This is the minimum odds ratio
        between the probability of the most likely cell type to the second most
        likely cell type to allow assignment. Default is 1.5. 
        Higher values are more conservative."
    ),
    make_option(
        c("-v", "--verbose"),
        action = "store_true",
        default = FALSE,
        type = 'logical',
        help = "Logical. Should progress messages be printed. Default: FASLE."
    ),
    make_option(
        c("-p", "--plot-output-path"),
        action = "store",
        default = NA,
        type = 'character',
        help = "output path for the t-SNE plots. In case --cluster-extend
                tag is provided, two plots will be made. If no path is provided,
                plots will not be produced."
    ),
    make_option(
        c("-o", "--cds-output-obj"),
        action = "store",
        default = NA,
        type = 'character',
        help = "Output path for cds object holding predicted labels on query data"

    )
)

opt = wsc_parse_args(option_list, mandatory = c("cds_object",
                                                "classifier_object",
                                                "database", 
                                                "cds_output_obj"))

# check inputs are correct
inputs = c(opt$cds_object, opt$classifier_object)
for(obj in inputs){
    if(! file.exists(obj)) stop(paste("File", obj, "does not exist."))
}

# if input is OK, load main packages
suppressPackageStartupMessages(require(opt$database,  character.only = TRUE))
# convert string into variable 
opt$database = get(opt$database)
suppressPackageStartupMessages(require(garnett))

cds = readRDS(opt$cds_object)
classifier = readRDS(opt$classifier_object)

# run the function 
cds = classify_cells(cds, classifier,
                          db = opt$database, 
                          cluster_extend = opt$cluster_extend, 
                          cds_gene_id_type = opt$cds_gene_id_type)  

saveRDS(cds, file = opt$cds_output_obj)

# if plot output is provided, run plotting part 
if(! is.na(opt$plot_output_path)){
    suppressPackageStartupMessages(require(ggplot2))
    png(file = opt$plot_output_path)
    print(qplot(tsne_1, tsne_2, color = cell_type,
                data = as.data.frame(pData(cds))) + theme_bw())
    dev.off()
    if(opt$cluster_extend){
        path = paste(strsplit(opt$plot_output_path,
                              '.png')[[1]][1], "_ext.png", sep='')
        png(file = path)
        print(qplot(tsne_1, tsne_2, color = cluster_ext_type, 
                    data = as.data.frame(pData(cds))) + theme_bw())
        dev.off()
    }
}
