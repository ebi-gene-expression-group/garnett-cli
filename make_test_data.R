#!/usr/bin/env Rscript 

# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))
# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))

# create input to check the parse_expr_data.R script works correctly 
# input:
#	- cds object: object to decompose into parts

option_list = list(
	make_option(
		c("-i", "--input-file"), 
		action = 'store',
		default = NA,
		type = 'character',
		help = 'Path to CDS object' 
	),
	make_option(
		c("-e", "--expr-matrix"),
		action = 'store',
		default = NA,
		type = 'character',
		help = 'Output path for expression matrix' 
	),
	make_option(
		c("-p", "--pheno-data"),
		action = 'store',
		default = NA,
		type = 'character',
		help = 'Output path for phenotype data' 
	),
	make_option(
		c("-f", "--feature-data"),
		action = 'store',
		default = NA,
		type = 'character',
		help = 'Output path for feature data' 
	)
)
opt = wsc_parse_args(option_list, mandatory=c("input_file", "expr_matrix",
                                              "pheno_data", "feature_data"))

suppressPackageStartupMessages(library(garnett))

cds = readRDS(opt$input_file)
matrix = exprs(cds)
writeMM(matrix, file = opt$expr_matrix)

pData = data.frame(cds@phenoData@data)
write.table(pData, file = opt$pheno_data, sep="\t", row.names = TRUE,
            col.names = TRUE)

fData = data.frame(cds@featureData@data)
write.table(fData, file = opt$feature_data, sep="\t", row.names = TRUE,
            col.names = TRUE)





