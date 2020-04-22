#!/usr/bin/env Rscript 

# extract predicted labels in standard format 

# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))
# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

option_list = list(
    make_option(
        c("-i", "--input-object"),
        action = "store",
        default = NA,
        type = 'character',
        help = "Path to the input CDS object in .rds format"
    ),

    make_option(
        c("-c", "--cell-id-field"),
        action = "store",
        default = NA,
        type = 'character',
        help = 'Column name of the cell id annotations. If not supplied, it is assumed
                that cell ids are represented by index'
    ),

    make_option(
        c("-p", "--predicted-cell-type-field"),
        action = "store",
        default = 'cluster_ext_type',
        type = 'character',
        help = 'Column name of the predicted cell type annotation'
    ), 

    make_option(
        c("-k", "--classifier"),
        action = 'store',
        default = NA,
        type = 'character',
        help = 'Path to the classifier object in .rds format (Optional; required to add dataset of origin to output table)'
    ),

    make_option(
        c("-o", "--output-file-path"),
        action = "store",
        default = NA,
        type = 'character',
        help = 'Path to the produced output file in .tsv format'
    )
)

opt = wsc_parse_args(option_list, mandatory = c('input_object',
                                                'predicted_cell_type_field',
                                                'output_file_path'))


suppressPackageStartupMessages(require(garnett))
cds = readRDS(opt$input_object)
cell_meta = pData(cds)

# can't use NAs in workflows? 
if(!is.na(opt$cell_id_field)){
    cell_id = cell_meta[, opt$cell_id_field]
} else{
    cat("no index column provided; use row names\n")
    cell_id = row.names(cell_meta)
}

predicted_label = as.character(cell_meta[, opt$predicted_cell_type_field])
output_table = data.frame(cbind(cell_id, predicted_label))
colnames(output_table) = c("cell_id", "predicted_label")


# add metadata if classifier is specified 
append = FALSE
if(!is.na(opt$classifier)){
    append = TRUE
    cl = readRDS(opt$classifier)
    dataset = attributes(cl)$dataset
    system(paste("echo '# tool garnett' >", opt$output_file_path))
    system(paste("echo '# dataset'", dataset, ">>", opt$output_file_path))
}

write.table(output_table, row.names = FALSE, file = opt$output_file_path, sep="\t", append=append)
