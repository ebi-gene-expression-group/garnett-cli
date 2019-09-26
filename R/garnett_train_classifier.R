#!/usr/bin/env Rscript


# package management
suppressPackageStartupMessages(require(pacman))
# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))
# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))


# Train the classification model using the updated marker file and CDS object
# Inputs:
#	- CDS object (either obtained initially or generated via parse_expr_data.R script)
#	- marker file
#	- db: argument for Bioconductor AnnotationDb-class package used for converting gene IDs.
#	- cds_gene_id_type: the format of the gene IDs in your CDS object
#	- marker_file_gene_id_type: the format of the gene IDs in your marker file. 
#	- num unknown: how many outgroups to compare against (required in case of cluster-extended option). Default = 500

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
		c("-n", "--num-unknown"),
		action = "store",
		default = 500,
    	type = "integer",
    	help = "Number of outgroups to compare against. Default %default."
	),
	make_option(
		c("-o", "--output-path"),
		action = "store",
		default = NA,
    	type = 'character',
    	help = "Path to the output file"
	)
)

opt = wsc_parse_args(option_list, mandatory=c("cds_object", "marker_file", "database", "output_path"))

# check parameters are correctly defined 
if(! file.exists(opt$cds_object)){
	stop((paste('File ', opt$cds_object, 'does not exist')))
}

if(! file.exists(opt$marker_file)){
	stop((paste('File ', opt$marker_file, 'does not exist')))
}

# load the database. pacman downloads the package if it hasn't been downloaded before 
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

#load(opt$cds_object) #debug line, remove

# run the main function 
set.seed(123)
pbmc_classifier <- train_cell_classifier(cds = pbmc_cds,
                                         marker_file = opt$marker_file,
                                         db=opt$database,
                                         cds_gene_id_type = opt$cds_gene_type,
                                         num_unknown = opt$num_unknown,
                                         marker_file_gene_id_type = opt$marker_gene_type)

saveRDS(pbmc_classifier, file = opt$output_path)




















