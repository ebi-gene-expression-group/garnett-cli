#!/usr/bin/env Rscript

# parse and transform marker file from SCXA's format into that accepted by Garnett
# Marker gene files from SCXA come in tabular format. They are filtered according to p-value 
# and then transformed into format as shown here: https://cole-trapnell-lab.github.io/garnett/docs/#constructing-a-marker-file


# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))
# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

# parse options 
option_list = list(
    make_option(
        c("-i", "--input-marker-file"),
        action = "store",
        default = NA,
        type = 'character',
        help = "Path to the SCXA-style marker gene file in .txt format"
    ),
    make_option(
        c("-l", "--marker-list"),
        action = "store",
        default = "marker_list.rds",
        type = 'character',
        help = "Path to a serialised object containing marker genes"
    ),
    make_option(
        c("-p", "--pval-col"),
        action = "store",
        default = "pvals_adj",
        type = 'character',
        help = "Column name of marker p-values"
    ),
    make_option(
        c("-t", "--pval-threshold"),
        action = "store",
        default = 0.05,
        type = 'numeric',
        help = "Cut-off p-value for marker genes"
    ),
    make_option(
        c("-g", "--groups-col"),
        action = "store",
        default = "groups",
        type = 'character',
        help = "Column name of cell groups (i.e. cluster IDs or cell types) in marker file"
    ),
    make_option(
        c("-n", "--gene-names"),
        action = "store",
        default = "names",
        type = 'character',
        help = "Column containing gene names in marker file"
    ),
    make_option(
        c("-o", "--garnett-marker-file"),
        action = "store",
        default = NA,
        type = 'character',
        help = "Path to the garnett format marker gene file in .txt format"
    )
)


opt = wsc_parse_args(option_list, mandatory = c("input_marker_file",
                                                "garnett_marker_file"))

if(!file.exists(opt$input_marker_file)) stop(paste("File does not exist:", opt$input_marker_file))

pval_col = opt$pval_col
pval_cutoff = opt$pval_threshold
groups_col = opt$groups_col
names = opt$gene_names

# df with SCXA markers
markers_tbl = read.delim(opt$input_marker_file, stringsAsFactors = FALSE)
# filter siginficant genes
markers_tbl = markers_tbl[markers_tbl[, pval_col] <= pval_cutoff, , drop = FALSE]
# extract distinct cell types/clusters 
groups = unique(markers_tbl[, groups_col])
markers_per_group = list()

for(idx in 1:length(groups)){
    group = groups[idx]
    # subset df by group and extract corresponding genes 
    tmp = markers_tbl[markers_tbl[, groups_col] == group, ]
    genes = tmp[, names]
    markers_per_group[[idx]] = genes
}
names(markers_per_group) = groups
# save the list as RDS object as it will be re-used in marker filtering step
saveRDS(markers_per_group, file = opt$marker_list)

# write markers to garnett-formatted text file (see https://cole-trapnell-lab.github.io/garnett/docs/#constructing-a-marker-file)
out_file = opt$garnett_marker_file
if(file.exists(out_file)) file.remove(out_file)
for(idx in 1:length(markers_per_group)){
    write(paste(">", names(markers_per_group)[idx], sep=""), file=out_file, append = TRUE)
    write(paste("expressed:", paste0(markers_per_group[[idx]], collapse=", ")), file=out_file, append = TRUE)
    write("\n", file = out_file, append = TRUE)
}
