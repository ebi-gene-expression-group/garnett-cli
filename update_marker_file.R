#!/usr/bin/env Rscript 

# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))
# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

# parse options 
option_list = list(
    make_option(
        c("-i", "--marker-list-obj"),
        action = "store",
        default = NA,
        type = 'character',
        help = "Path to the original marker gene list serialised object"
    ),
    make_option(
        c("-f", "--marker-check-file"),
        action = "store",
        default = NA,
        type = 'character',
        help = "Path to the file with marker gene assessment done by garnett"
    ),
    make_option(
        c("-s", "--summary-col"),
        action = "store",
        default = 'summary',
        type = 'character',
        help = "Marker gene assessment column name"
    ),
    make_option(
        c("-c", "--cell-type-col"),
        action = "store",
        default = 'cell_type',
        type = 'character',
        help = "Marker gene assessment column name"
    ),
    make_option(
        c("-g", "--gene-id-col"),
        action = "store",
        default = 'gene_id',
        type = 'character',
        help = "Gene id column name in marker assessment file"
    ),
    make_option(
        c("-o", "--updated-marker-file"),
        action = "store",
        default = NA,
        type = 'character',
        help = "Path to the updated marker file"
    )
)

opt = wsc_parse_args(option_list, mandatory = c("marker_list_obj", "marker_check_file", "updated_marker_file"))
marker_list = readRDS(opt$marker_list_obj)
marker_check_tbl = read.table(opt$marker_check_file, sep=" ")
summary_col = opt$summary_col
cell_type_col = opt$cell_type_col
gene_id = opt$gene_id_col

# filter out 'bad' markers 
marker_check_tbl = marker_check_tbl[marker_check_tbl[, summary_col] != "Ok", ]
cell_types = as.character(unique(marker_check_tbl[, cell_type_col]))
for(idx in 1:length(cell_types)){
    cell_type = cell_types[idx]
    tmp = marker_check_tbl[marker_check_tbl[, cell_type_col] == cell_type, ]
    genes_to_remove = as.character(tmp[, gene_id])
    print(typeof(genes_to_remove))
    print(cell_type)
    print(marker_list[[cell_type]])
    l = marker_list[[cell_type]]
    l = l[which(!l %in% genes_to_remove)]
    marker_list[[cell_type]] = l
}

# re-write updated markers to a new file
out_file = opt$updated_marker_file
if(file.exists(out_file)) file.remove(out_file)
for(idx in 1:length(marker_list)){
    write(paste(">", names(marker_list)[idx], ":", sep=""), file=out_file, append = TRUE)
    write(paste("expressed:", paste0(marker_list[[idx]], collapse=", ")), file=out_file, append = TRUE)
    write("\n", file = out_file, append = TRUE)
}
