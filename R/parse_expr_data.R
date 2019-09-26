#!/usr/bin/env Rscript

# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))
# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))


# create a CDS object from raw expression matrix. The CDS will then be used as input in further steps of the workflow
# inputs: 
#	- exprs, a numeric matrix of expression values; rows: genes, columns: cells
#	- phenoData, an AnnotatedDataFrame object; rows: cells, columns: cell attributes
# 	  (such as cell type, culture condition, day captured, etc.) 
#	- featureData, an AnnotatedDataFrame object, rows:features (e.g. genes), columns: gene attributes 
#	  (such as biotype, gc content, etc.)


# parse options 
option_list = list(
	make_option(
		c("-e", "--expression-matrix"),
		action = "store",
    	default = NA,
    	type = 'character',
    	help = "Numeric matrix of expression values; rows: genes, columns: cells.
    			See http://cole-trapnell-lab.github.io/monocle-release/docs/#getting-started-with-monocle for explanation"
	), 
	make_option(
		c("-p", "--phenotype-data"),
		action = "store",
    	default = NA,
    	type = 'character',
    	help = "AnnotatedDataFrame object; rows: cells, columns: cell attributes 
    			(such as cell type, culture condition, day captured, etc.)"
    ),
	make_option(
		c("-f", "--feature-data"),
		action = "store",
    	default = NA,
    	type = 'character',
    	help = "AnnotatedDataFrame object, rows:features (e.g. genes), columns: gene attributes 
    			(such as biotype, gc content, etc.)"
	),
	make_option(
		c("-o", "--output-file"),
		action = "store",
    	default = NA,
    	type = 'character',
    	help = "output file for CDS object in .rds format"
	)
)

opt = wsc_parse_args(option_list, mandatory = c('expression_matrix', 'phenotype_data', 'feature_data', 'output_file'))

# check parameters are correctly defined 
if(! file.exists(opt$expression_matrix)){
	stop((paste('File ', opt$expression_matrix, 'does not exist')))
}

if(! file.exists(opt$phenotype_data)){
	stop((paste('File ', opt$phenotype_data, 'does not exist')))
}

if(! file.exists(opt$feature_data)){
	stop((paste('File ', opt$feature_data, 'does not exist')))
}


# if input is OK, load the package
suppressPackageStartupMessages(require(garnett))


# initialise the CDS object 
expr_matrix = readMM(opt$expression_matrix)
pd = new("AnnotatedDataFrame", data = read.table(opt$phenotype_data))
fd = new("AnnotatedDataFrame", data = read.table(opt$feature_data))
cds = newCellDataSet(as.matrix(expr_matrix), phenoData = pd, featureData = fd)
cds = estimateSizeFactors(cds)
saveRDS(cds, file = opt$output_file)







