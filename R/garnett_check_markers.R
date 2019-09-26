#!/usr/bin/env Rscript


# package management
suppressPackageStartupMessages(require(pacman))
# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))
# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))


# Using information from CDS object, determine which markers are suitable 
# for identification of cell type. See Garnett publication for more details.
# 
# inputs:
#	- CDS object (either obtained initially or generated via parse_expr_data.R script)
#	- marker file 
#	- db: argument for Bioconductor AnnotationDb-class package used for converting gene IDs.
#	- cds_gene_id_type: the format of the gene IDs in your CDS object
#	- marker_file_gene_id_type: the format of the gene IDs in your marker file
#	- path to marker output file
#	- (optional) path to plot output file


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
		c("-m", "--marker-file"),
		action = "store",
		default = NA,
    	type = 'character',
    	help = "File with marker genes specifying cell types. See https://cole-trapnell-lab.github.io/garnett/docs/#constructing-a-marker-file
    			for specification of the file format."
	),
	make_option(
		c("-d", "--database"),
		action = "store",
		default = NA,
    	type = 'character',
    	help = "argument for Bioconductor AnnotationDb-class package used for converting gene IDs
    			For example, use org.Hs.eg.db for Homo Sapiens genes."
	),
	make_option(
		c("--cds-gene-type"),
		action = "store",
		default = "ENSEMBL",
    	type = 'character',
    	help = "Format of the gene IDs in your CDS object. The default is \"ENSEMBL\"."
	),
	make_option(
		c("--marker-gene-type"),
		action = "store",
		default = "ENSEMBL",
    	type = 'character',
    	help = "Format of the gene IDs in your marker file. The default is \"ENSEMBL\"."
	),
	make_option(
		c("-o", "--marker-output-file"),
		action = "store",
		default = NA,
    	type = 'character',
    	help = "Path to the output file with marker scores"
	),
	make_option(
		c("--plot-output-file"),
		action = "store",
		default = NA,
		type = 'character',
		help = "Optional. If you would like to make a marker plot, provide a name (path) for it."
	)
)

opt = wsc_parse_args(option_list, mandatory = c('cds_object', 'marker_file', 'database', 'marker_output_file'))
#TODO:remove print statements 
print(opt$database)
print(opt$cds_object)
print(opt$plot_output_file)

# check parameters are correctly defined 
if(! file.exists(opt$cds_object)){
	stop((paste('File ', opt$cds_object, 'does not exist')))
}

if(! file.exists(opt$marker_file)){
	stop((paste('File ', opt$marker_file, 'does not exist')))
}

# load the database. pacman downloads the package if it's not installed 
tryCatch({
	p_load(opt$database, character.only = TRUE)},
	warning = function(w){
	stop((paste('Database', opt$database, 'was not found on Bioconductor')))}
)

# convert string into variable 
opt$database = get(opt$database)

# if input is OK, load the package
suppressPackageStartupMessages(require(garnett))

# read the CDS object
pbmc_cds = readRDS(opt$cds_object)
print(pbmc_cds)

# run the core function 
print("start the function")

marker_check = check_markers(pbmc_cds, opt$marker_file,
							 db = opt$database, cds_gene_id_type = opt$cds_gene_type,
							 marker_file_gene_id_type = opt$marker_gene_type)


if(! is.na(opt$plot_output_file)){
	print(paste("plotting path", opt$plot_output_file))
	png(filename = opt$plot_output_file)
	# check if dev is working correct 
	dev.list()
	print(plot_markers(marker_check))
	dev.off()
}

print("test how device works outside the if-block:")
png()
dev.list()
dev.off()

print(marker_check)
write.table(marker_check, file = opt$marker_output_file, sep = "\t")

















